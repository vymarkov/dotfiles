{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    aerospace.url = "github:vymarkov/aerospace-flake/2112f2efd9410ed4fee834af12736a91cb61c9d8";
    aerospace.inputs.nixpkgs.follows = "nixpkgs";

    nvim.url = "github:vymarkov/nvim/develop";
    nvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, aerospace, nvim, ... }:
  let
    username = "batman";
    userhome = "/Users/${username}";

    configuration = { pkgs, config, ... }: {
      system.primaryUser = username;

      nixpkgs.overlays = [
        aerospace.overlays.default or (final: prev: {})
        nvim.overlays.default or (final: prev: {})
      ];

      power.sleep.allowSleepByPowerButton = true;

      nix.enable = false;

      nixpkgs.config.allowUnfree = true;

      users.users.${username} = {
        name = username;
        home = userhome;
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          nvim.packages.${pkgs.system}.default
          aerospace.packages.${pkgs.system}.default
          # not available for apple silicon chips
          # pkgs.virtualbox

          # cli apps
          pkgs.zellij
          pkgs.httpie
          pkgs.bat
          pkgs.git-open
          pkgs.mas
          pkgs.awscli2
          pkgs.gh
          pkgs.direnv
          pkgs.xcodes
          pkgs.zulu23
          pkgs.mkalias
          pkgs.devbox
          # Node.js, pnpm, yarn, etc
          pkgs.yarn
          pkgs.pnpm

          # gui apps
          pkgs.insomnia
          pkgs.jetbrains.datagrip
          pkgs.jetbrains.idea-community
          pkgs.brave
          pkgs.lens
          pkgs.vscode
          pkgs.postman
          pkgs.wezterm
          # pkgs._1password-gui  # Does not work as of September 2025, using Mac App Store version instead

          #
          pkgs.ngrok
          pkgs.atuin
          # devops
          # pkgs.vagrant
        ];

      homebrew = {
        enable = true;
        # onActivation.cleanup = "uninstall";

        taps = [];
        brews = [
          "cowsay"
          "leapp-cli"
        ];

        # You must be signed into your Apple ID account to install the apps below
        # masApps = {
        #   "1Password 7" = 1333542190;  # Using Mac App Store version since pkgs._1password-gui doesn't work
        # };

        casks = [
          "sdm"
          "leapp"
          "docker"
        ];
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';


      # programs.zsh.enable = true;

      programs.direnv.enable = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      # uncomment this line if your mac on Intel chip
      # nixpkgs.hostPlatform = "x86_64-darwin";
    };
  in
  {
    # sudo darwin-rebuild switch --flake ~/.config/nix-darwin/.#system
    darwinConfigurations.system = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit username;
            };
            users.${username} = import ../home-manager/home.nix;
          };
        }
      ];
    };
  };
}
