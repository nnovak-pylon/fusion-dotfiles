{ config, pkgs, ... }:

{
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.neovim
    # pkgs.jdk8
    pkgs.jdk17
    pkgs.prismlauncher
    pkgs.kitty
    # pkgs.bash
    # pkgs.bashInteractive
    pkgs.nodePackages.tailwindcss
    pkgs.texlive.combined.scheme-full
    pkgs.python311Packages.pynvim
    pkgs.zathura
    # pkgs.gcc
    pkgs.graphviz
    pkgs.unrar
    pkgs.obsidian
    # pkgs.xournal
    pkgs.kalker
    pkgs.ghc
    pkgs.tree-sitter
    pkgs.clang-tools
    pkgs.wezterm
    pkgs.speedtest-cli
    pkgs.google-java-format
    pkgs.go
    pkgs.nodePackages.npm
    pkgs.haskellPackages.haskell-language-server
    pkgs.haskellPackages.implicit-hie
    pkgs.sshfs
    pkgs.macfuse-stubs
    pkgs.yt-dlp
  ];

  environment = {
    variables = {
      EDITOR = "vim";
    };
  };

  # environment.etc."java".source = "${pkgs.jdk8}/zulu-8.jdk/Contents/Home/bin/java";

  environment.pathsToLink = [ "/share/bash-completion" ];

  imports = [
    <home-manager/nix-darwin>
  ];

  users.users.nicholas = {
    name = "nicholas";
    home = "/Users/nicholas";
    # shell = pkgs.bashInteractive;
  };

  home-manager.users.nicholas = { pkgs, ... }: {
    home.stateVersion = "24.05";
    home.packages = [ pkgs.neovim pkgs.zathura pkgs.jdk17 ];
    # programs.bash.enable = true;
    # programs.bash.enableCompletion = true;
  };

  home-manager.useUserPackages = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "ffmpeg"
      "htop"
      "xdotool"
      {
        name = "dbus";
        start_service = true;
        restart_service = true;
      }
      {
        name = "girara";
        args = ["--HEAD"];
      }
      {
        name = "zathura";
        args = ["HEAD" "with-synctex"];
      }
      "zathura-pdf-poppler"
      "jupyterlab"
      "black"
      "bpytop"
      "typst"
    ];
    casks = [ "spotify" "wacom-tablet" "inkscape" "xournal-plus-plus" "mactex-no-gui" "mullvadvpn" "slack" "ollama" "skim" "linearmouse"];
    taps = [ "zegervdv/zathura" ];
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.bash.enable = true;
  # programs.bash.enableCompletion = true;
  # programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
