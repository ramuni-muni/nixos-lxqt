# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in

{
  imports = [ 
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  # layouts
  nixpkgs.overlays = [
    (self: super: 
      {
        polybar = (super.polybar.override (prev: rec{
    		
        })).overrideAttrs (oldAttrs: rec{
          pname = "polybar";
          version = "3.7.0";
          src = super.fetchFromGitHub {
            owner = pname;
            repo = pname;
            rev = version;
            hash = "sha256-Z1rL9WvEZHr5M03s9KCJ6O6rNuaK7PpwUDaatYuCocI=";
            fetchSubmodules = true;
          };
        });   
        
      }
    ) 
  ];
  
  # powerManagement.cpuFreqGovernor = "performance"; 
  # Often used values: “ondemand”, “powersave”, “performance”

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-MidasForce_SSD_120GB_AA000000000000003126"; # change with your storage device id
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;
  boot.loader.grub.extraEntries = ''  
  menuentry "Nixos livecd" --class installer {
    set isofile="/nixos.iso"      
    loopback loop (hd0,2)$isofile 
    #configfile (loop)/EFI/grub/grub.cfg
    linux (loop)/boot/bzImage findiso=/$isofile init=/nix/store/0x1xgnlgs3p73khg3m45g1n7qmh46pmz-nixos-system-nixos-23.05.3759.261abe8a44a7/init root=LABEL=nixos-23.05-x86_64 boot.shell_on_fail nohibernate loglevel=4 
    initrd (loop)/boot/initrd
  }
  menuentry "Slax (Persistent changes)" {
    loopback loop (hd0,2)/slax.iso
    linux (loop)/slax/boot/vmlinuz vga=normal load_ramdisk=1 prompt_ramdisk=0 rw printk.time=0 consoleblank=0 slax.flags=perch,automount fromiso=/slax.iso
    initrd (loop)/slax/boot/initrfs.img
  }
  
  '';
  #boot.loader.grub.extraEntriesBeforeNixOS = true;
  #boot.loader.grub.timeoutStyle = "hidden";
  #boot.plymouth.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nvidia driver
  services.xserver.videoDrivers = [ "fbdev" ];
  #nixpkgs.config.nvidia.acceptLicense = true;   
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  #hardware.nvidia.modesetting.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # virtual camera
  # Make some extra kernel modules available to NixOS
  boot.extraModulePackages = with config.boot.kernelPackages;[ v4l2loopback.out ];  
  boot.kernelModules = [ "v4l2loopback" ];  
  boot.extraModprobeConfig = '' options v4l2loopback exclusive_caps=1 card_label="Virtual Camera" '';
  
  #zram
  zramSwap.enable = true;
  zramSwap.memoryPercent = 300;  
  
  #filesystem
  boot.supportedFilesystems = [
      "btrfs"
      "ntfs"
      "fat32"
      "exfat"
  ];  

  # waydroid
  #virtualisation = {
    #waydroid.enable = true;
    #lxd.enable = true;
    #lxc.enable = true;
  #};

  # lxc
  #virtualisation.lxc.defaultConfig = ''
    #lxc.net.0.type = veth
    #lxc.net.0.link = lxdbr0
    #lxc.net.0.flags = up
  #'';

   
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.hostName = "NixOS"; # Define your hostname.
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  # ENV
  environment.variables = {
    "WLR_NO_HARDWARE_CURSORS" = "1";
    "WLR_RENDERER" = "pixman";
    "WLR_RENDERER_ALLOW_SOFTWARE" = "1";
    "LIBGL_ALWAYS_SOFTWARE" = "1";
  };

  # Fonts  
  fonts.packages = with pkgs; [ nerdfonts ];

  # gvfs 
  services.gvfs.enable = true;

  # picom
  services.picom.enable = true;
  services.picom.fade = true;
  services.picom.shadow = false;
  services.picom.shadowExclude = [
    "window_type *= 'toolbar'"
    "window_type *= 'dock'"
    "window_type *= 'desktop'"
  ];
  #services.picom.fadeExclude = [ 
  #  "window_type *= 'menu'"
  #];
  #services.picom.fadeSteps = [
  #  0.04
  #  0.04
  #];  
  

  # Enable the X11 display server.
  services.xserver.enable = true;

  # Login Manager.
  services.xserver.displayManager.lightdm.enable = true;

  # window manager
  # swaywm
    #programs.sway.enable = true;  
    #programs.sway.extraPackages = with pkgs; [
    #  waybar rofi slurp grim wf-recorder
    #  fuzzel foot
    #];

  # hypr
  #services.xserver.windowManager.hypr.enable = true;

  # hyprland
  #programs.hyprland.enable = true;
  #programs.hyprland.enableNvidiaPatches = true;

  # openbox
  #services.xserver.windowManager.openbox.enable = true;

  # Desktop Environtmen
  services.xserver.desktopManager.lxqt.enable = true;
  #services.xserver.desktopManager.budgie.enable = true;
  #services.xserver.desktopManager.deepin.enable = true;
  #services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.desktopManager.pantheon.enable = true;
  #services.xserver.desktopManager.mate.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.desktopManager.enlightenment.enable = true;
  
  # plasma5 exclude
  environment.plasma5.excludePackages = with pkgs; [
    libsForQt5.elisa
    libsForQt5.gwenview
    libsForQt5.konsole
    libsForQt5.okular
    libsForQt5.spectacle    
    libsForQt5.ark
    orca
  ];

  # gnome exclude
  services.gnome.evolution-data-server.enable = pkgs.lib.mkForce false;
  services.gnome.gnome-online-accounts.enable = pkgs.lib.mkForce false;
  programs.gnome-terminal.enable = pkgs.lib.mkForce false;
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-terminal
    gnome.gnome-system-monitor
    gnome.gnome-screenshot
    gnome.gnome-music
    gnome.gnome-keyring
    gnome.file-roller
    gnome.eog
    gnome.yelp
    gnome.totem
    gnome.gedit
    gnome.geary
    gnome.cheese
    orca
    epiphany
    gnome-text-editor
    gnome.nautilus
    gnome.gnome-contacts
    gnome.gnome-weather
    gnome.simple-scan
    gnome-photos
    evince
    gnome.gnome-disk-utility    
    gnome-tour
  ];
  
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.  
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;    
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ramuni = {
    isNormalUser = true;
    description = "Ramuni muni";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];    
  };
  
  # editable nix store
  #boot.readOnlyNixStore = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [       
    gimp
    inkscape-with-extensions
    chromium 
    libreoffice-qt jre
    krdc
    krfb
    kget
    pdfarranger
    gparted    
    simplescreenrecorder
    vlc
    xorg.xhost pulseaudio wget onboard ffmpeg_5-full
    xfce.mousepad
    lxde.lxtask htop btop neofetch    
    p7zip       
  ] ++ (
    if (config.services.xserver.desktopManager.lxqt.enable == true)
    then with pkgs; [
      #libsForQt5.kwin
      #libsForQt5.systemsettings
      #libsForQt5.kglobalaccel
      #libsForQt5.qt5.qttools    
      networkmanagerapplet    
      feh   
    ] else with pkgs; [
      lxqt.screengrab
      lxqt.pavucontrol-qt
      lxqt.qterminal
      lxqt.pcmanfm-qt
      lxmenu-data
      menu-cache    
      lxqt.lximage-qt
      lxqt.lxqt-archiver
      lxqt.lxqt-sudo
      libsForQt5.breeze-icons
    ]
  ) ++ (
    if(config.services.xserver.desktopManager.plasma5.enable == true)
    then with pkgs;[
        libsForQt5.applet-window-buttons
    ] else with pkgs;[

    ]
  ) ++ (
    if(config.services.xserver.windowManager.hypr.enable == true)
    then with pkgs;[
      feh
      polybar
      rofi    
      networkmanagerapplet
      lxappearance
      apple-cursor
      udiskie
      lxqt.lxqt-policykit
      dunst
      libnotify
      volumeicon
      clipit
      gnome.zenity
      numlockx      
      xorg.setxkbmap
    ] else [

    ]
  );

  #virtualbox
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.guest.x11 = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
    
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
  
  # ftp
  #services.vsftpd.enable = false;
  #services.vsftpd.writeEnable =true;
  #services.vsftpd.localUsers = true;
  #services.vsftpd.anonymousUser = true;
  #services.vsftpd.anonymousUserHome = "/home/ftp/";
  #services.vsftpd.anonymousUserNoPassword = true;
  #services.vsftpd.anonymousUploadEnable = true;
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 5900 21 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # webserver
  #services.httpd.enable = true;
  #services.httpd.virtualHosts.localhost.documentRoot = "/home/ramuni/Public/";

  # my dot file  
  home-manager.users.ramuni = {    
    # hypr.conf
    home.file.".config/openbox/rc.xml".text = ''
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">

  <resistance>
    <strength>10</strength>
    <screen_edge_strength>20</screen_edge_strength>
  </resistance>

  <focus>
    <focusNew>yes</focusNew>    
    <followMouse>no</followMouse>
    <focusLast>yes</focusLast>
    <underMouse>no</underMouse>
    <focusDelay>200</focusDelay>
    <raiseOnFocus>no</raiseOnFocus>
  </focus>

  <placement>
    <policy>Smart</policy>
    <center>yes</center>
    <monitor>Primary</monitor>
    <primaryMonitor>1</primaryMonitor>
  </placement>

  <theme>
    <name>Bear2</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>no</animateIconify>
    <font place="ActiveWindow">
      <name>Sans Serif</name>
      <size>10</size>
      <weight>Normal</weight>
      <slant>Normal</slant>
    </font>
    <font place="InactiveWindow">
      <name>Sans Serif</name>
      <size>10</size>
      <weight>Normal</weight>
      <slant>Normal</slant>
    </font>
    <font place="MenuHeader">
      <name>sans</name>
      <size>9</size>
      <weight>normal</weight>
      <slant>normal</slant>
    </font>
    <font place="MenuItem">
      <name>sans</name>
      <size>9</size>
      <weight>normal</weight>
      <slant>normal</slant>
    </font>
    <font place="ActiveOnScreenDisplay">
      <name>sans</name>
      <size>9</size>
      <weight>bold</weight>
      <slant>normal</slant>
    </font>
    <font place="InactiveOnScreenDisplay">
      <name>sans</name>
      <size>9</size>
      <weight>bold</weight>
      <slant>normal</slant>
    </font>
  </theme>

  <desktops>
    <number>4</number>
    <firstdesk>1</firstdesk>
    <names>
    </names>
    <popupTime>2</popupTime>
  </desktops>

  <resize>
    <drawContents>yes</drawContents>
    <popupShow>Nonpixel</popupShow>
    <popupPosition>Center</popupPosition>
    <popupFixedPosition>
      <x>10</x>
      <y>10</y>
    </popupFixedPosition>
  </resize>

  <margins>
    <top>0</top>
    <bottom>0</bottom>
    <left>0</left>
    <right>0</right>
  </margins>

  <dock>
    <position>TopRight</position>
    <floatingX>0</floatingX>
    <floatingY>0</floatingY>
    <noStrut>no</noStrut>
    <stacking>Above</stacking>
    <direction>Vertical</direction>
    <autoHide>no</autoHide>
    <hideDelay>300</hideDelay>
    <showDelay>300</showDelay>
    <moveButton>Middle</moveButton>
  </dock>

  <keyboard>
    <chainQuitKey>C-g</chainQuitKey>

    <!-- maximize and restore -->    
    <keybind key="W-Prior">
      <action name="Maximize"/>
      <action name="Undecorate"/>
    </keybind>
    <keybind key="W-Next">
      <action name="Unmaximize"/>
      <action name="Decorate"/>
    </keybind>

    <!-- change desktop -->
    <keybind key="W-1">
      <action name="GoToDesktop">
        <to>1</to>
      </action>
    </keybind>
    <keybind key="W-C-Left">
      <action name="GoToDesktop">
        <to>left</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-C-Right">
      <action name="GoToDesktop">
        <to>right</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-C-Up">
      <action name="GoToDesktop">
        <to>up</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-C-Down">
      <action name="GoToDesktop">
        <to>down</to>
        <wrap>no</wrap>
      </action>
    </keybind>

    <!-- move app to desktop -->
    <keybind key="W-A-Left">
      <action name="SendToDesktop">
        <to>left</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-A-Right">
      <action name="SendToDesktop">
        <to>right</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-A-Up">
      <action name="SendToDesktop">
        <to>up</to>
        <wrap>no</wrap>
      </action>
    </keybind>
    <keybind key="W-A-Down">
      <action name="SendToDesktop">
        <to>down</to>
        <wrap>no</wrap>
      </action>
    </keybind>

    <!-- show desktop -->    
    <keybind key="W-d">
      <action name="ToggleShowDesktop"/>
    </keybind>

    <!-- Keybindings for windows -->
    <keybind key="W-c">
      <action name="Close"/>
    </keybind>
    <keybind key="W-End">
      <action name="Close"/>
    </keybind>
    <keybind key="A-Escape">
      <action name="Lower"/>
      <action name="FocusToBottom"/>
      <action name="Unfocus"/>
    </keybind>

    <!-- show client menu -->
    <keybind key="A-Space">
      <action name="ShowMenu">
        <menu>client-menu</menu>
      </action>
    </keybind>

    <!-- change window -->
    <keybind key="W-Tab">
      <action name="NextWindow">
        <finalactions>
          <action name="Focus"/>
          <action name="Raise"/>
          <action name="Unshade"/>
        </finalactions>
      </action>
    </keybind>
    <keybind key="A-Tab">
      <action name="PreviousWindow">
        <finalactions>
          <action name="Focus"/>
          <action name="Raise"/>
          <action name="Unshade"/>
        </finalactions>
      </action>
    </keybind>
        
    <!-- pseudo tiles -->
    <keybind key="W-Left">
      <action name="Unmaximize"/>
      <action name="Undecorate"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>0</y>
        <width>50%</width>
        <height>100%</height>
      </action>
    </keybind>
    <keybind key="W-Right">
      <action name="Unmaximize"/>
      <action name="Undecorate"/>
      <action name="MoveResizeTo">
        <x>-0</x>
        <y>0</y>
        <width>50%</width>
        <height>100%</height>
      </action>
    </keybind>
    <keybind key="W-Up">
      <action name="Unmaximize"/>
      <action name="Undecorate"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>0</y>
        <width>100%</width>
        <height>50%</height>
      </action>
    </keybind>
    <keybind key="W-Down">
      <action name="Unmaximize"/>
      <action name="Undecorate"/>
      <action name="MoveResizeTo">
        <x>0</x>
        <y>-0</y>
        <width>100%</width>
        <height>50%</height>
      </action>
    </keybind>

    <!-- running applications -->
    <keybind key="W-t">
      <action name="Execute">
        <command>qterminal</command>
      </action>
    </keybind>
    <keybind key="W-p">
      <action name="Execute">        
        <command>pcmanfm-qt</command>
      </action>
    </keybind>
    <keybind key="W-g">
      <action name="Execute">
        <command>google-chrome-stable</command>
      </action>
    </keybind>
  </keyboard>

  <mouse>
    <dragThreshold>1</dragThreshold>    
    <doubleClickTime>500</doubleClickTime>
    <screenEdgeWarpTime>400</screenEdgeWarpTime>
    <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
    <context name="Frame">
      <mousebind button="W-Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="W-Left" action="Click">
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="W-Left" action="Drag">
        <action name="Move"/>
      </mousebind>
      <mousebind button="W-Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="W-Right" action="Drag">
        <action name="Resize"/>
      </mousebind>
      <mousebind button="W-Middle" action="Press">
        <action name="Lower"/>
        <action name="FocusToBottom"/>
        <action name="Unfocus"/>
      </mousebind>
      <mousebind button="W-Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="W-Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="W-A-Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="W-A-Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="A-W-Up" action="Click">
        <action name="SendToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="A-W-Down" action="Click">
        <action name="SendToDesktop">
          <to>next</to>
        </action>
      </mousebind>
    </context>
    <context name="Titlebar">
      <mousebind button="Left" action="Drag">
        <action name="Move"/>
      </mousebind>
      <mousebind button="Left" action="DoubleClick">
        <action name="ToggleMaximize"/>
      </mousebind>
      <mousebind button="Up" action="Click">
        <action name="if">
          <shaded>no</shaded>
          <then>
            <action name="Shade"/>
            <action name="FocusToBottom"/>
            <action name="Unfocus"/>
            <action name="Lower"/>
          </then>
        </action>
      </mousebind>
      <mousebind button="Down" action="Click">
        <action name="if">
          <shaded>yes</shaded>
          <then>
            <action name="Unshade"/>
            <action name="Raise"/>
          </then>
        </action>
      </mousebind>
    </context>
    <context name="Titlebar Top Right Bottom Left TLCorner TRCorner BRCorner BLCorner">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Middle" action="Press">
        <action name="Lower"/>
        <action name="FocusToBottom"/>
        <action name="Unfocus"/>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="ShowMenu">
          <menu>client-menu</menu>
        </action>
      </mousebind>
    </context>
    <context name="Top">
      <mousebind button="Left" action="Drag">
        <action name="Resize">
          <edge>top</edge>
        </action>
      </mousebind>
    </context>
    <context name="Left">
      <mousebind button="Left" action="Drag">
        <action name="Resize">
          <edge>left</edge>
        </action>
      </mousebind>
    </context>
    <context name="Right">
      <mousebind button="Left" action="Drag">
        <action name="Resize">
          <edge>right</edge>
        </action>
      </mousebind>
    </context>
    <context name="Bottom">
      <mousebind button="Left" action="Drag">
        <action name="Resize">
          <edge>bottom</edge>
        </action>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="ShowMenu">
          <menu>client-menu</menu>
        </action>
      </mousebind>
    </context>
    <context name="TRCorner BRCorner TLCorner BLCorner">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Left" action="Drag">
        <action name="Resize"/>
      </mousebind>
    </context>
    <context name="Client">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="Middle" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
    </context>
    <context name="Icon">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
        <action name="ShowMenu">
          <menu>client-menu</menu>
        </action>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="ShowMenu">
          <menu>client-menu</menu>
        </action>
      </mousebind>
    </context>
    <context name="AllDesktops">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Left" action="Click">
        <action name="ToggleOmnipresent"/>
      </mousebind>
    </context>
    <context name="Shade">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="Left" action="Click">
        <action name="ToggleShade"/>
      </mousebind>
    </context>
    <context name="Iconify">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="Left" action="Click">
        <action name="Iconify"/>
      </mousebind>
    </context>
    <context name="Maximize">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Middle" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Left" action="Click">
        <action name="ToggleMaximize"/>
      </mousebind>
      <mousebind button="Middle" action="Click">
        <action name="ToggleMaximize">
          <direction>vertical</direction>
        </action>
      </mousebind>
      <mousebind button="Right" action="Click">
        <action name="ToggleMaximize">
          <direction>horizontal</direction>
        </action>
      </mousebind>
    </context>
    <context name="Close">
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="Left" action="Click">
        <action name="Close"/>
      </mousebind>
    </context>
    <context name="Desktop">
      <mousebind button="Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="A-Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="A-Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="C-A-Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="C-A-Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
    </context>
    <context name="Root">
      <!-- Menus -->
      <mousebind button="Middle" action="Press">
        <action name="ShowMenu">
          <menu>client-list-combined-menu</menu>
        </action>
      </mousebind>
      <!-- <mousebind button="Right" action="Press">
        <action name="ShowMenu">
          <menu>root-menu</menu>
        </action>
      </mousebind> -->
    </context>
    <context name="MoveResize">
      <mousebind button="Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
      <mousebind button="A-Up" action="Click">
        <action name="GoToDesktop">
          <to>previous</to>
        </action>
      </mousebind>
      <mousebind button="A-Down" action="Click">
        <action name="GoToDesktop">
          <to>next</to>
        </action>
      </mousebind>
    </context>
  </mouse>

  <menu>
  </menu>

  <applications>
    <application type="normal">
      <maximized>true</maximized>
      <decor>no</decor>
    </application>
  </applications>
  
</openbox_config>

    '';    
    home.stateVersion = "23.05";    
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  
}
