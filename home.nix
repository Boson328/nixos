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
    '';
    shellAliases = {
      ll = "ls -la";
      n = "nvim";
      rebuild = "sudo nixos-rebuild switch";
    };
  };

  home.file.".config/fish/greeting.fish".source = ./greeting.fish;

  xdg.configFile."niri".source = ./niri;

  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "boson328";
    repo = "nvimconfig";
    rev = "fa9b5bc5fb735000759ad602c523971f8a6fca79";
    hash = "sha256-l9Qu4yMQt07Vkh6sEJCmPeI0H2ebzp8Alk8WipXgbwo=";
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

    # NeoVim関連
    tree-sitter
    nil # Nix LSP
    nixfmt-rfc-style # Formatter

    # デフォルトで入れときたいやつ
    gcc
    gnumake
    ripgrep
    fd
    wl-clipboard # クリップボード
    jq # json

    # 開発用
    nodejs
    (rust-bin.stable."1.87.0".default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })

    # ブラウザ
    firefox

    # Discord
    vesktop

    # Figma
    figma-linux

    # フォントたち
    nerd-fonts.jetbrains-mono
    source-han-sans
    jetbrains-mono
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
