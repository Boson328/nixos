{ config, pkgs, ... }:
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

        function fish_greeting
            set seed (random 1 101)
            set greet "Hello, World!"
            
            if test $seed -lt 10
                set greet "Hello, World!"
            else if test $seed -lt 20
                set greet "Good Luck!"
            else if test $seed -lt 30
                set greet "May the Force!"
            else if test $seed -lt 40
                set greet "Stay Hungry, Stay Foolish!"
            else if test $seed -lt 50
                set greet "Awesome Fish!"
            else if test $seed -lt 60
                set greet "Deja vu!"
            else if test $seed -lt 70
                set greet "Never dig down!"
            else if test $seed -lt 80
                set greet "Omnipotent!"
            else if test $seed -lt 90
                set greet "Just Do It!!!!"
            else if test $seed -lt 100
                set greet "Alice In the Freezer."
            else
                set greet "Super Lucky Day!?"

            end

            figlet $greet
        end
    '';
    shellAliases = {
      ll = "ls -la";
      n = "nvim";
    };
  };

  xdg.configFile."niri".source = ./niri;

  xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    owner = "boson328";
    repo = "nvimconfig";
    rev = "fa9b5bc5fb735000759ad602c523971f8a6fca79";
    hash = "sha256-l9Qu4yMQt07Vkh6sEJCmPeI0H2ebzp8Alk8WipXgbwo=";
  };

  xdg.configFile."ghostty".source = ./ghostty;

  home.packages = with pkgs; [
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

    # NeoVim関連
    tree-sitter
    nil # Nix LSP
    nixfmt-rfc-style # Formatter

    # デフォルトで入れときたいやつ
    gcc
    gnumake
    ripgrep
    fd
    wl-clipboard

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

    # フォントたち
    nerd-fonts.jetbrains-mono

  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
  };

  fonts.fontconfig.enable = true;
}
