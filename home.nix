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
	};

    xdg.configFile."niri".source = ./niri;
    
	xdg.configFile."nvim".source = pkgs.fetchFromGitHub {
    		owner = "boson328";
    		repo = "nvimconfig";
    		rev = "406a543a583a95ba13c0457ae13847aced01b5a2";
    		hash = "sha256-1B6iRk+B9w+rpSOpdE+D1EdvKlN3+s+NGDSm8+poV7k=";
	};

	home.packages = with pkgs; [
         lazygit

         gcc
         gnumake
         tree-sitter
         nodejs
         ripgrep
         fd

         firefox

         nerd-fonts.jetbrains-mono

         (rust-bin.stable."1.87.0".default.override { 
             extensions = ["rust-src" "rust-analyzer"];
         })
	];

    i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = [pkgs.fcitx5-mozc];
    };

    fonts.fontconfig.enable = true;
}
