{
	description = "Boson's NixOS";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		niri.url = "github:sodiboo/niri-flake";
		niri.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
        rust-overlay.url = "github:oxalica/rust-overlay";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

	};

	outputs = { self, nixpkgs, niri, home-manager, rust-overlay, ... }: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
              { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }
			  ./configuration.nix
			  ./hardware-configuration.nix
			  niri.nixosModules.niri
			  home-manager.nixosModules.home-manager {
			 	home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.boson = import ./home.nix;
			  } 
            ];
		};
	};
}
