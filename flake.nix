{
  description = "my flake from first principles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations."inspiron7506" = nixpkgs.lib.nixosSystem {

      modules = [
        ./hosts/inspiron7506
      ];
    };
  };
}
