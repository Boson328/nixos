{
  config,
  pkgs,
  ...
}:
{
  home.username = "boson";
  home.homeDirectory = "/home/boson";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;
    withNodeJs = true;
  };

  #------------ コンフィグ ---------------
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      zoxide init fish --cmd cd | source
      starship init fish | source
      source ~/.config/fish/greeting.fish
      export HF_TOKEN=$(cat /run/secrets/hf_token)
      export DOTNET_ROOT=$(dirname (readlink -f (which dotnet)))
    '';
    shellAliases = {
      ll = "ls -la";
      n = "nvim";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      nvim-fetch = "nix-prefetch-git https://github.com/boson328/nvimconfig --rev refs/heads/nixos";
    };
  };

  home.file.".config/fish/greeting.fish".source = ./greeting.fish;

  xdg.configFile."niri".source = ./niri;

  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "boson328";
    repo = "nvimconfig";
    rev = "6c8c096056bdfe318360f18a173ff9240431ead1";
    hash = "sha256-h5dDWn1gVTdQ5CTCaurBQ+FWqChuIgAUL1MDomK5ikE=";
  };

  xdg.configFile."ghostty".source = ./ghostty;

  home.file.".config/starship.toml".source = ./starship.toml;
  home.file.".config/wallpaper/wallpaper.gif".source = ./assets/niri-wallpaper.gif;

  home.file.".config/fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;

  xdg.configFile."waybar".source = ./waybar;
  home.file.".local/bin/niri-workspaces" = {
    source = ./niri-workspaces.sh;
    executable = true;
  };

  home.pointerCursor = {
    package = pkgs.xcursor-pro;
    name = "XCursor-Pro-Dark";
    size = 24;
    gtk.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  home.packages = with pkgs; [
    # 壁紙
    awww

    #  上のバー
    waybar

    # アプリケーションランチャー
    fuzzel

    # ターミナル
    ghostty

    # シェル
    fish # シェル本体
    starship # シェルの装飾
    zoxide # cdを便利に

    # ちょっとしたコマンド追加
    figlet # でかい文字表示できるやつ

    # TUIツールたち
    lazygit
    yazi
    (btop.override { cudaSupport = true; })

    # NeoVim関連
    tree-sitter
    nil # Nix LSP
    nixfmt-rfc-style # Formatter
    pyright
    stylua
    lua-language-server
    ruff

    # デフォルトで入れときたいやつ
    gcc
    gnumake
    ripgrep
    fd
    wl-clipboard # クリップボード
    jq # json
    ffmpeg
    xdg-desktop-portal-gtk

    # 偶に使うcli
    github-cli
    sops
    nix-prefetch-scripts

    # 開発用
    nodejs
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })
    uv

    # ブラウザ
    firefox

    # Discord
    vesktop

    # Figma
    figma-linux

    # office代替
    libreoffice

    # フォントたち
    nerd-fonts.jetbrains-mono
    source-han-sans
    jetbrains-mono
    ipafont
    ipaexfont

    # unity
    unityhub
    sqlite
    omnisharp-roslyn

    swaylock
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-skk
      pkgs.fcitx5-tokyonight
    ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Source Han Sans JP" ];
    };
  };
}
