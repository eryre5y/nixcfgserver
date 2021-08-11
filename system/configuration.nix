{ config, pkgs, lib, unstable, home, nur, inputs, nixpkgs, overlays, ... }:

let

myneovim = pkgs.neovim.override {
configure =
{
customRC =
''
let g:lightline = {
\ 'colorscheme': 'jellybeans',
\ }
syntax on
set number
set mouse=a
nnoremap <C-n> :NERDTree<CR>
autocmd BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "normal! g`\"" |
\ endif
'';
plug.plugins = with pkgs.vimPlugins;
[
vim-nix
vim-closetag
lightline-vim
coc-nvim
];
};
};

stable = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz) { config = config.nixpkgs.config; };

in

{
  imports = [
     ./hardware-configuration.nix
#     ./home.nix
  ];
#  home-manager = { users.reimu = (import ./home.nix {inherit config pkgs lib unstable;}); };
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    autoOptimiseStore = true;
    extraOptions = ''
      experimental-features = nix-command flakes
      '';
  };
  programs = {
    dconf.enable = true;
    bash = {
      shellAliases = {
        l = "ls -alh";
        ll = "ls -l";
        nrsu = "sudo nixos-rebuild switch --upgrade";
        nrs = "sudo nixos-rebuild switch";
        hms = "home-manager switch";
        hmsu = "home-manager switch --upgrade";
        tb = "nc termbin.com 9999";
        editcfg = "sudo nvim /etc/nixos/configuration.nix";
        edithome = "nvim ~/.config/nixpkgs/home.nix";
        o = "nvidia-offload";
        ncfg = "sudo cp -r /etc/nixos/* ~/nixcfgserver/system && sudo cp -r ~/.config/nixpkgs/* ~/nixcfgserver/home-manager";
      };
    };
  };
  time.timeZone = "Europe/Moscow";
  sound.enable = true;
  system.stateVersion = "20.03";

  networking = {
    hostName = "nixos";
    firewall.enable = false;
    dhcpcd.wait = "background";
    interfaces.enp1s0.useDHCP = true;
  };

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ intel-media-driver vaapiVdpau libvdpau-va-gl ];
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  boot = {
    supportedFilesystems = [ "xfs" "ntfs" "f2fs" ];
    loader = {
      grub.device = "/dev/sdb";
    };
  };

  environment.systemPackages = with pkgs; [ 
    # test
    polybar
    feh
    rofi
    maim
    bpytop
    brightnessctl
    xclip
    jdk
    gparted
    pywal
    qbittorrent
    pavucontrol
    pulseaudio
    playerctl
    sakura

    emacs
    tdesktop
    git
    nodejs
    myneovim
    vim
    hello
    latte-dock
    htop
    google-chrome
    discord
    stable.steam
    firefox
    spotify
    pulseeffects-legacy
    atom
    minecraft
    remmina
    lutris
    libsForQt5.qtstyleplugin-kvantum
    etcher
    vlc
    kate
    ark
    filelight
    exodus
    adoptopenjdk-jre-openj9-bin-8
    leafpad
    neofetch
    glxinfo
    # scripts
];

  services = {
    printing.enable = true;
    openssh.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "us,ru";
      dpi = 96;
      displayManager = {
#        sddm.enable = true;
        defaultSession = "plasma5";
        lightdm.greeters.mini = {
          enable = true;
          user = "reimu";
          extraConfig = ''
            [greeter]
            show-password-label = false
            [greeter-theme]
            background-image = ""
            '';
          };
        };
      desktopManager = {
        plasma5.enable = true;
      };
      libinput.enable = true;
#      desktopManager.xterm.enable = false;
#      displayManager.defaultSession = "none+i3";
#      windowManager.i3 = {
#        package = pkgs.i3-gaps;
#        enable = true;
#        extraPackages = with pkgs; [
#          dmenu #application launcher most people use
#          i3status # gives you the default i3 status bar
#          i3lock #default i3 screen locker
#          i3blocks #if you are planning on using i3blocks over i3status
#       ];
#      };
    };
  };

  users = {
    mutableUsers = false;
    users.reimu = {
      isNormalUser = true;
      hashedPassword = "$5$W7lyoN9pWq2/BH9F$jXaIpFZy3L9NgqrZhK382rre.ljdmLlHzvKvVQ1s3VA";
      extraGroups = [ "wheel" "audio" "video" ];
    };
  };
}
