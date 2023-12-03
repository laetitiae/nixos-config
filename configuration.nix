# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;

#  boot.loader.grub.extraEntries =  ''
#        menuentry "Windows" {
#          insmod part_gpt
#          insmod fat
#         insmod search_fs_uuid
#          insmod chain
#          search --fs-uuid --set=root $FS_UUID
#          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
#        }
#      '';

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "es";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.enableAllFirmware = true;

  virtualisation.docker = {
    enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lae = {
    isNormalUser = true;
    description = "Leticia";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    packages = with pkgs; [
      firefox
      google-chrome
      kate
      nix-index
      terminator
      tdesktop
      comma
      gopass
      syncthing
      spotify
      vscode
      ark
      zsh
      obsidian
    ];
  };

  home-manager.users.lae = { pkgs, ... }: {
    home.packages = with pkgs; [ 
      zsh
      yubico-piv-tool
      yubikey-manager
      yubioath-flutter
      yubikey-manager-qt 
      gopass-jsonapi
      xclip
      vlc
    ];

    # git configuration
    programs.git = {
      enable = true;
      userEmail = "leti.garcia.martin@gmail.com";
      userName = "Leticia García Martín";
      signing = {
        key = "C9E9 42A4 747F F51C 68D1  8FBA F2B7 FBE1 2A33 E3D0";
        signByDefault = true;
      };
    };

    # zsh configuration
    programs.zsh.enable = true;
    programs.zsh.oh-my-zsh = {
      enable = true;
      plugins = [ "git" "python" "man" "colorize" "kubectl" "systemadmin" ];
      theme = "robbyrussell"; #agnoster
    };
    programs.zsh.history = {
      size = 100000;
      path = "/home/lae/.zsh_history";
      save = 100000;
      share = true;
      expireDuplicatesFirst = true;
    };
    
    programs.bat.enable = true;
    
    # terminator configuration
    programs.terminator.enable = true;
    programs.terminator.config =  {
      global_config.borderless = false;
      global.config.title_transmit_bg_color = "#c64600";
      profiles.default = {
        background_color = "#333333";
        cursor_color = "#aaaaaa";
        font = "Liberation Mono 15";
        foreground_color = "#9a9996";
        use_system_font = false;
        copy_on_selection = true;
      };    
    };

    # gpg configuration
    programs.gpg = {
      scdaemonSettings = {
        disable-ccid = true;  # Play nice with yubikey https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
        reader-port = "Yubico YubiKey OTP+FIDO+CCID 00 00";  # Get this value with pcsc_scan
      };
      enable = true;
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        { source = ./keys/robertomartinezp_at_gmail.com.asc; trust = 4; }
        { source = ./keys/leti.garcia.martin_at_gmail.com; trust = 5; }
      ];
    };
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableScDaemon = true;
      grabKeyboardAndMouse = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      sshKeys = [
        "DB91D67C1268E1AB575A5B02C58615A76F92CE39"
      ];
    };

    home.stateVersion = "22.11";
  };

  # gpg needed
  services.pcscd.enable = true;
  
  # syncthing configuration
  services.syncthing = let
      rbpstor02-id = "ECT74R2-FDJKLU2-QZQRBAV-OZJFL5V-DVYLT3C-QLRUWCG-CBQ3SJK-WSTQAQB";
      folder-books-id = "htqor-lmajr";
      folder-notebooks-id = "yrz5j-y8qlk";
    in {
      enable = true;
      user = "lae";
      group = "users";
      configDir = "/home/lae/syncthing/.config";
      openDefaultPorts = true;
      overrideFolders = true;
      overrideDevices = true;
      devices = {
        rbpstor02 = {
          id = rbpstor02-id;
          addresses = [
            "tcp://10.4.1.206:22000"
          ];
        };
      };
      folders = {
        Books = {
          path = "/home/lae/Books";
          id = folder-books-id;
          devices = [ "rbpstor02" ];
        };
        Notebooks = {
          path = "/home/lae/Documents/Notebooks";
          id = folder-notebooks-id;
          devices = [ "rbpstor02" ];
        };
      };
      extraOptions = {
        gui = {
          theme = "black";
          insecureAdminAccess = false;
        };
      };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   python3
   pipenv
   pdftk
   ffmpeg
   wget
   ((vim_configurable.override {  }).customize{
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        " your custom vimrc
        set nocompatible
        set mouse=
        set backspace=indent,eol,start
        " Turn on syntax highlighting by default
        syntax on
        " ...
      '';
    })
   jetbrains.idea-community
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
