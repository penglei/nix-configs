import json
import os
import subprocess
import tempfile
import traceback
from pathlib import Path
from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import add_timer
from kitty.window import Window


def _ensure_path() -> None:
    """kitty 作为 GUI app 启动时 PATH 不含 nix-profile / ~/.local/bin，
    导致 subprocess 找不到 sketchybar 等 nix 管理的二进制。
    在此补上，与 launch_agent_common (hm-modules/darwin/launchd.nix) 保持一致。
    """
    prepend = [
        os.path.expanduser("~/.nix-profile/bin"),
        os.path.expanduser("~/.local/bin"),
    ]
    parts = [p for p in os.environ.get("PATH", "").split(os.pathsep) if p]
    for d in reversed(prepend):
        if d and os.path.isdir(d) and d not in parts:
            parts.insert(0, d)
    os.environ["PATH"] = os.pathsep.join(parts)


_ensure_path()


def ensure_state_filepath():
    file_path = Path(os.path.expanduser("~/.local/state/kitty/data.json"))
    if not file_path.exists():
        file_path.parent.mkdir(parents=True, exist_ok=True)
    return file_path


def on_load(boss, data):
    ensure_state_filepath()


def on_cmd_startstop(boss, window, data):
    # 后台窗口的命令启停不应影响状态栏（状态栏只反映聚焦窗口）
    active = boss.active_window
    if active is None or window.id != active.id:
        return
    output_tabs(boss, window, data)


def on_title_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    # 后台窗口（如跑 AI agent 的 tab）高频改 title，忽略以免状态栏闪烁
    active = boss.active_window
    if active is None or window.id != active.id:
        return
    output_tabs(boss, window, data)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    output_tabs(boss, window, data)


def on_close(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    # 关闭窗口/标签页时刷新状态栏。
    # on_close 在 window.destroy() 期间触发，此刻该 window 所属 tab 尚未从
    # boss.all_tabs 移除（remove_window 在 destroy 之后调用），直接读取会得到
    # 陈旧的 tab 数量。延迟到事件循环下一轮再读，确保 tab 结构已更新。
    # 也覆盖了"关闭非聚焦 tab"——此时不会触发 on_focus_change，只能靠这里刷新。
    def _refresh(timer_id=None):
        try:
            output_tabs(boss, window, data)
        except Exception:
            traceback.print_exc()

    add_timer(_refresh, 0, False)


def output_tabs(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    file_path = ensure_state_filepath()

    # 始终以"当前聚焦窗口"为准，避免后台窗口事件写入错误的 tab 编号
    active_window = boss.active_window
    if active_window is None:
        return

    new_data: dict[str, Any] = {}

    os_win_tab_counter = {}
    window_tab_infos = []
    curr_os_window_id = -1
    curr_tab_detail = {}
    curr_tab_index = 0
    for tab in boss.all_tabs:
        count = os_win_tab_counter.get(tab.os_window_id) or 0
        count += 1
        os_win_tab_counter[tab.os_window_id] = count

        if active_window.tab_id == tab.id:
            curr_tab_index = count
            curr_os_window_id = tab.os_window_id

            if tab.active_window != None:
                tabwin = tab.active_window.as_dict()
                foreground_processes = tabwin["foreground_processes"]
                if len(foreground_processes) > 0:
                    curr_tab_detail["process"] = foreground_processes[0]
                curr_tab_detail["env"] = {
                    "HOME": (tabwin.get("env") or {}).get("HOME") or ""
                }

        tab_info = {
            "id": tab.id,
            "name": tab.name,
            "os_window_id": tab.os_window_id,
        }
        if tab.active_window != None:
            tab_info["win"] = tab.active_window.as_dict()
        window_tab_infos.append(tab_info)

    # data["window_tab_infos"] = window_tab_infos

    new_data["tab_id"] = active_window.tab_id
    new_data["curr_num_tabs"] = os_win_tab_counter.get(curr_os_window_id) or 0  # tabs个数
    new_data["curr_tab_index"] = curr_tab_index
    cwd = (curr_tab_detail.get("process") or {}).get("cwd") or ""
    home_dir = (curr_tab_detail.get("env") or {}).get("HOME") or ""
    if home_dir != "":
        if cwd.startswith(home_dir):
            cwd = "~" + cwd[len(home_dir) :]
    new_data["curr_tab_cwd"] = cwd
    new_data["curr_tab_detail"] = curr_tab_detail

    # 读取旧数据用于对比
    old_data = None
    try:
        if file_path.exists():
            with open(file_path, "r", encoding="utf-8") as f:
                old_data = json.load(f)
    except (OSError, ValueError):
        old_data = None

    # 数据完全未变则无需写文件
    if old_data == new_data:
        return

    # sketchybar 的 kitty_tabs 只消费 curr_num_tabs / curr_tab_index；
    # 仅这两个字段变化时才触发 title_change，避免 AI agent 高频改 title 时状态栏闪烁
    display_changed = (
        old_data is None
        or old_data.get("curr_num_tabs") != new_data["curr_num_tabs"]
        or old_data.get("curr_tab_index") != new_data["curr_tab_index"]
    )

    # 原子写：临时文件 + rename，防止 sketchybar 读到写一半的 JSON
    tmp_fd, tmp_path = tempfile.mkstemp(
        dir=str(file_path.parent), prefix=".data_", suffix=".tmp"
    )
    try:
        with os.fdopen(tmp_fd, "w", encoding="utf-8") as f:
            json.dump(new_data, f, ensure_ascii=False, indent=2)
        os.replace(tmp_path, file_path)
    except Exception:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise

    if display_changed:
        subprocess.run(["sketchybar", "--trigger", "title_change"])
