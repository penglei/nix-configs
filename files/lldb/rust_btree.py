"""LLDB formatters for Rust's BTreeMap and BTreeSet.

rustc's lldb_lookup.py has none, so the generic struct summary walks the raw
nodes, spare MaybeUninit slots included: stale heap words are read as
String/Vec lengths and LLDB allocates them (GBs to TBs). These formatters
visit only initialized slots and check every node against the B-tree
invariants before trusting it, so an uninitialized map shows no entries
instead of being followed.

They go into the default category, which takes precedence over the "Rust"
one, so the load order does not matter:

    command script import $HOME/.config/lldb/rust_btree.py
"""

import lldb

MAP_RE = r"^alloc::collections::btree::map::BTreeMap<.+>$"
SET_RE = r"^alloc::collections::btree::set::BTreeSet<.+>$"
NODE_REF = "alloc::collections::btree::node::NodeRef<"
NON_NULL = "core::ptr::non_null::NonNull<"
UNINIT_RE = r"^core::mem::maybe_uninit::MaybeUninit<.+>$"

# std's node::B: a node holds at most 2*B-1 keys and 2*B edges.
CAPACITY = 11
# A height beyond this cannot be a real tree: guards garbage roots.
MAX_HEIGHT = 48
# Entries collected at most; the rest are left out, not walked.
MAX_ENTRIES = 100_000
# Longest key summary used as a child name.
MAX_NAME = 120

WRAPPERS = (
    "core::mem::maybe_uninit::MaybeUninit<",
    "core::mem::manually_drop::ManuallyDrop<",
    "core::mem::maybe_dangling::MaybeDangling<",
)


def field(ty, name):
    """`ty`'s field `name` as (offset, type), or None."""
    for i in range(ty.GetNumberOfFields()):
        f = ty.GetFieldAtIndex(i)
        if f.GetName() == name:
            return f.GetOffsetInBytes(), f.GetType()
    return None


def unwrap(ty):
    """The `T` of MaybeUninit<T> through its ManuallyDrop/MaybeDangling layers.

    MaybeUninit is a union of `uninit: ()` and `value`; the others hold their
    `T` as their only field (`value` or `__0`). Each layer starts at offset 0.
    """
    while (ty.GetName() or "").startswith(WRAPPERS):
        inner = field(ty, "value") or field(ty, "__0")
        if inner is None:
            break
        ty = inner[1]
    return ty


class Tree:
    """A BTreeMap's entries as (key address, value address), in order.

    `error` is set instead when the map does not hold together.
    """

    def __init__(self, map_value):
        self.entries = []
        self.error = None
        self.length = 0
        try:
            self._walk(map_value.GetNonSyntheticValue())
        except Exception as e:  # a formatter must never take the debugger down
            self._corrupt("map: %s" % e)

    def _walk(self, m):
        length = m.GetChildMemberWithName("length").GetValueAsUnsigned()
        self.length = length
        if length == 0:
            return
        root = m.GetChildMemberWithName("root")
        process = m.GetProcess()
        target = m.GetTarget()

        # Option<NodeRef>: `node` is a NonNull, so the Some payload is the
        # NodeRef itself at offset 0 (niche); find NodeRef's type from Some.
        node_ref_ty = find(root.GetType(), "__0", NODE_REF)
        if node_ref_ty is None or node_ref_ty.GetByteSize() != root.GetType().GetByteSize():
            return self._corrupt("root layout")
        h_off, _ = field(node_ref_ty, "height")
        n_off, n_ty = field(node_ref_ty, "node")
        leaf_ty = field(n_ty, "pointer")[1].GetPointeeType()

        root_addr = root.GetLoadAddress()
        err = lldb.SBError()
        height = process.ReadUnsignedFromMemory(root_addr + h_off, 8, err)
        node = process.ReadPointerFromMemory(root_addr + n_off, err)
        if err.Fail() or height > MAX_HEIGHT or node == 0:
            return self._corrupt("root")

        len_off, len_ty = field(leaf_ty, "len")
        keys_off, keys_ty = field(leaf_ty, "keys")
        vals_off, vals_ty = field(leaf_ty, "vals")
        self.key_ty = unwrap(keys_ty.GetArrayElementType())
        self.val_ty = unwrap(vals_ty.GetArrayElementType())
        self.keys_off, self.vals_off = keys_off, vals_off
        self.key_size = keys_ty.GetArrayElementType().GetByteSize()
        # Zero for BTreeSet's SetValZST: a set's entries have no value.
        self.val_size = vals_ty.GetArrayElementType().GetByteSize()

        edges_off = None
        if height > 0:
            # Looking InternalNode up by name fails (LLDB renames `i32` to
            # `int` and so on); a leaf's `parent` points to one, though.
            parent = find(field(leaf_ty, "parent")[1], "__0", NON_NULL)
            internal = field(parent, "pointer")[1].GetPointeeType() if parent else None
            e = field(internal, "edges") if internal else None
            if e is None:
                return self._corrupt("tree: no InternalNode type")
            edges_off = e[0]
        ptr = process.GetAddressByteSize()

        # In-order walk with an explicit stack of (node, height, i, is_root).
        # An internal node at slot i first emits key i-1 (i > 0), then
        # descends edge i (i <= len): edge 0, key 0, edge 1, ..., edge len.
        stack = [(node, height, 0, True)]
        while stack:
            node, h, i, is_root = stack.pop()
            n = process.ReadUnsignedFromMemory(node + len_off, len_ty.GetByteSize(), err)
            # Only the root may be empty (a map emptied by removals keeps it).
            if err.Fail() or n > CAPACITY or (n == 0 and not is_root):
                return self._corrupt("node at 0x%x" % node)
            if h == 0:
                for k in range(n):
                    self._add(node, k)
            else:
                if 0 < i <= n:
                    self._add(node, i - 1)
                if i <= n:
                    child = process.ReadPointerFromMemory(node + edges_off + i * ptr, err)
                    if err.Fail() or child == 0:
                        return self._corrupt("edge at 0x%x" % node)
                    stack.append((node, h, i + 1, is_root))
                    stack.append((child, h - 1, 0, False))
            # Bounds the walk even when garbage edges form a cycle.
            if len(self.entries) > length:
                return self._corrupt("more entries than length %d" % length)
            if len(self.entries) >= MAX_ENTRIES:
                return
        if len(self.entries) != length:
            self._corrupt("walked %d entries, length says %d" % (len(self.entries), length))

    def _corrupt(self, what):
        self.entries, self.error = [], "corrupt " + what

    def _add(self, node, k):
        key = node + self.keys_off + k * self.key_size
        val = node + self.vals_off + k * self.val_size if self.val_size else None
        self.entries.append((key, val))


def find(ty, name, prefix):
    """The type of a field `name` of a type named `prefix...`, at any depth.

    Without a Rust plugin LLDB sees an Option as nested Clang structs
    ($variants$ / Some$Variant / value / __0): this digs out its payload.
    """
    todo = [ty]
    while todo:
        ty = todo.pop()
        for i in range(ty.GetNumberOfFields()):
            f = ty.GetFieldAtIndex(i)
            fty = f.GetType()
            if f.GetName() == name and (fty.GetName() or "").startswith(prefix):
                return fty
            todo.append(fty)
    return None


def child_name(value, i):
    s = value.GetSummary() or value.GetValue()
    if not s or len(s) > MAX_NAME:
        return "[%d]" % i
    return s


class BTreeMapSynth:
    """Children: each value, named by its key's summary."""

    def __init__(self, valobj, _dict):
        self.valobj = valobj
        self.tree = None

    def tree_of(self):
        return self.valobj

    def update(self):
        self.tree = Tree(self.tree_of())
        return False

    def num_children(self):
        return len(self.tree.entries)

    def get_child_index(self, name):
        for i in range(self.num_children()):
            if self.get_child_at_index(i).GetName() == name:
                return i
        return -1

    def get_child_at_index(self, i):
        if not 0 <= i < len(self.tree.entries):
            return None
        k_addr, v_addr = self.tree.entries[i]
        key = self.valobj.CreateValueFromAddress("[%d]" % i, k_addr, self.tree.key_ty)
        if v_addr is None:
            return key
        return self.valobj.CreateValueFromAddress(child_name(key, i), v_addr, self.tree.val_ty)

    def has_children(self):
        return True


class BTreeSetSynth(BTreeMapSynth):
    """Children: each element, as `[i]`."""

    def tree_of(self):
        return self.valobj.GetNonSyntheticValue().GetChildMemberWithName("map")

    def get_child_at_index(self, i):
        if not 0 <= i < len(self.tree.entries):
            return None
        return self.valobj.CreateValueFromAddress("[%d]" % i, self.tree.entries[i][0], self.tree.key_ty)


def map_summary(valobj, _dict):
    return size_summary(valobj.GetNonSyntheticValue())


def set_summary(valobj, _dict):
    return size_summary(valobj.GetNonSyntheticValue().GetChildMemberWithName("map"))


def size_summary(m):
    # Read off the map itself, not the children, so that a summary never
    # walks the tree (the parent's struct summary asks for it eagerly).
    return "size=%d" % m.GetChildMemberWithName("length").GetValueAsUnsigned()


def __lldb_init_module(debugger, _dict):
    for cmd in (
        'type synthetic add -l rust_btree.BTreeMapSynth -x "%s"' % MAP_RE,
        'type summary add -e -F rust_btree.map_summary -x "%s"' % MAP_RE,
        'type synthetic add -l rust_btree.BTreeSetSynth -x "%s"' % SET_RE,
        'type summary add -e -F rust_btree.set_summary -x "%s"' % SET_RE,
        # Elsewhere (tokio's slots, Vec spare capacity seen raw) a MaybeUninit
        # may hold garbage too: never descend into one.
        'type summary add -s "<maybe uninit>" -x "%s"' % UNINIT_RE,
    ):
        debugger.HandleCommand(cmd)
