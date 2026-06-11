# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on

{
  config,
  lib,
  pkgs,
  niri,
  ...
}:

let
  sddm-astronaut-theme = pkgs.stdenv.mkDerivation {
    name = "sddm-astronaut-theme";
    src = pkgs.fetchFromGitHub {
      owner = "keyitdev";
      repo = "sddm-astronaut-theme";
      rev = "master";
      hash = "sha256-+Z1igZ4BxRqXr/lxfHEr3I4n/sX8+AIwUr6JFO9yoWs=";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
      cp -r . $out/share/sddm/themes/sddm-astronaut-theme
      mkdir -p $out/share/fonts/truetype/pixelon
      cp Fonts/pixelon.regular.ttf $out/share/fonts/truetype/pixelon/
      cp Fonts/pixelon.regular.ttf $out/share/sddm/themes/sddm-astronaut-theme/
      sed -i 's|ConfigFile=Themes/astronaut.conf|ConfigFile=Themes/hyprland_kath.conf|' \
        $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    '';
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine = {
    enable = true;
    resolution = "1920x1080x32";
    style = {
      wallpapers = [
        ./assets/limine-wallpaper.jpg
      ];
    };
    extraEntries = ''
      /Windows
          protocol: efi_chainload
          image_path: guid(e1a19b50-ee28-4d77-8fe7-c3e64397c415):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "video=1920x1080" ];

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # services.keyd = {
  #   enable = true;
  # keyboards.default = {
  #   ids = [ "*" ]; # 後でここは設定するHHKBのみにしたい
  #   settings = {
  #     main = {
  #       rightmeta = "F13";
  #       rightshift = "F14";
  #     };
  #   };
  # };
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.pulseaudio.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk -c /etc/weston.ini";
    };
    theme = "sddm-astronaut-theme";
    extraPackages = [
      sddm-astronaut-theme
      pkgs.qt6.qtsvg
      pkgs.qt6.qtmultimedia
    ];
  };
  fonts.packages = [
    (pkgs.runCommand "pixelon-font" { } ''
      mkdir -p $out/share/fonts/truetype
      cp ${sddm-astronaut-theme}/share/sddm/themes/sddm-astronaut-theme/Fonts/pixelon.regular.ttf \
        $out/share/fonts/truetype/
    '')
    pkgs.source-han-sans
  ];

  environment.etc."weston.ini".text = ''
    [keyboard]
    keymap_layout=us
    keymap_model=pc104
    keymap_options=terminate:ctrl_alt_bksp
    keymap_variant=

    [libinput]
    enable-tap=true
    left-handed=false

    [output]
    name=Virtual-1
    mode=1920x1080
  '';
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/boson/.config/sops/age/keys.txt";
    secrets.github_ssh_key = {
      path = "/home/boson/.ssh/id_ed25519";
      owner = "boson";
      mode = "0600";
    };
    secrets.boson_password = {
      neededForUsers = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.boson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.sops.secrets.boson_password.path;
    shell = pkgs.fish;
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    foot
    keyd
    sddm-astronaut-theme
    qt6.qtsvg
    qt6.qtmultimedia
    brightnessctl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.niri = {
    enable = true;
    package = niri.packages.x86_64-linux.niri-unstable;
  };

  programs.fish.enable = true;

  services.fprintd.enable = true;

  security.pam.services = {
    sudo.fprintAuth = true;
    sddm.fprintAuth = false;
    login.fprintAuth = false;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  nixpkgs.config.allowUnfree = true;
}
