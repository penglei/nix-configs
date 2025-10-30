{ pkgs, config, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "penglei";
        email = "lambit@qq.com";
      };
      alias = {
        # Prettier `git log` https://git-scm.com/docs/pretty-formats
        lg = "log --color --pretty=format:'%Cred%h%Creset %G? -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        # `git checkout` with fuzzy matching
        co = "!git for-each-ref --format='%(refname:short)' refs/heads | ${pkgs.fzf}/bin/fzf -0 | xargs git checkout";
        # `git restore --staged` with fuzzy matching
        rs = "!git diff --name-only --cached | ${pkgs.fzf}/bin/fzf -0 --multi | xargs git restore --staged";
        # Fetch a branch from a remote and rebase it on the current branch
        frb = "!git fetch $1 && git rebase $1/$2 && :";

        new = "checkout -b";
        rb = "rebase --interactive";
        last = "show HEAD";
        cim = "commit --amend";
        cimn = "commit --amend --no-edit";
        st = "status";
        br = "branch";
        ci = "commit";
        df = "diff";
        ps = "push";
        fp = "push --force";
        track = "checkout --track";
        cliff = "!${pkgs.git-cliff}/bin/git-cliff";
        whois = ''
          !sh -c 'git log -i -1 --pretty="format:%an <%ae>
          " --author="$1"' -'';
        whatis = "show -s --pretty='tformat:%h (%s, %ad)' --date=short";

        dlog = "-c diff.external=difft log --ext-diff";
        dshow = "-c diff.external=difft show --ext-diff";
        ddiff = "-c diff.external=difft diff";
        dd = "-c diff.external=difft diff";
      };

      extraConfig = {
        pager.branch = false;
        pull.rebase = true;
        init.defaultBranch = "main";
        push.default = "current";
        merge.conflictstyle = "zdiff3";
        diff.colorMoved = "default";
        core = {
          hooksPath = "${config.xdg.configHome}/git/hooks";
          quotepath = false;
        };
      };
    };
    signing = {
      signByDefault = false;
      #key = null; # Let the gpg agent handle it
      key = (import ../config.nix).gpg.sign_key + "!";
    };

    ignores = [
      "go.work"
      "go.work.sum"
      ".envrc"
      ".direnv"
      ".DS_Store"
      # system SWAP, TMP and BACKUP files
      "*~"
      "*.swp"
      ".*.*.swp"
      "*.bak"
      "*.log"
      # c/c++ object
      "*.o"
      "*.so"
      "*.so.[0-9]*"
      "*.a"
      # latex
      "*.aux"
      "*.bbl"
      "*.bcf"
      "*.blg"
      "*.nav"
      "*.out"
      "*.run.xml"
      "*.snm"
      "*.toc"
      "*.vrb"
      #lua
      ".luarc.json"
    ];

  };

  # Prettier pager for git, adds syntax highlighting and line numbers
  # see: https://github.com/dandavison/delta
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      conflictstyle = "diff3";
      side-by-side = true;
    };
  };

  home.shellAliases = {
    ga = "git add";
    gaa = "git add --all";
    gapa = "git add --patch";
    gau = "git add --update";
    gav = "git add --verbose";

    gb = "git branch";
    gbl = "git blame -b -w";
    gbr = "git branch --remote";
    gbs = "git bisect";
    gbsb = "git bisect bad";
    gbsg = "git bisect good";
    gbsr = "git bisect reset";
    gbss = "git bisect start";

    gc = "git commit -v";
    "gc!" = "git commit -v --amend";
    "gcn!" = "git commit -v --no-edit --amend";
    gca = "git commit -v -a";
    "gca!" = "git commit -v -a --amend";

    gcb = "git checkout -b";
    gco = "git checkout";

    gd = "git diff";
    gdca = "git diff --cached";
    gdcw = "git diff --cached --word-diff";

    gl = "git pull";
    gp = "git push";
    gpu = "git push upstream";
    gst = "git status";

    #simple commit ammend
    gaucim = "gau;git commit --amend --no-edit";
  };

}
