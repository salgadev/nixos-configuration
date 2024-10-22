{ config, inputs, username, host, pkgs, ... }:

{
  imports = [ inputs.ags.homeManagerModules.default ];

  # config.allowUnfreePredicate = (_: true); 
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')        
    obs-studio # screen recording
    krusader # find duplicate files and more
    #betterbird # email
    joplin-desktop # notetaking gui      
    apostrophe # Markdown editor
    freeoffice
    rclone
    rclone-browser
    brave # private web browsing
    ungoogled-chromium # for compatibility
    zoom-us
    floorp 
    oculante
    imv
    mpv
    oterm
    alpaca
    # gpt4all    # broken as of Oct 2024
    slurp
    grim
  ];
  
  stylix = {
    enable = true;
    autoEnable = true;
    targets = {
      swaylock = {
        enable = true;
      };
    };
  };
  gtk = {
    enable = true;
    iconTheme = {            
      # this works starts
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;     
      # this works ends
      # name = "kora";
      # package = pkgs.kora-icon-theme;     
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  #qt = {
  #  enable = true;
  #  style.name = "adwaita-dark";
  #  # platformTheme.name = "gtk3";
  #};

  # This custom desktop entry doesn't seem to work
  #xdg.desktopEntries = {
  #  whatsappium = {
  #    name = "WhatsAppium";
  #    icon = "whatsapp";
  #    comment = "Launch WhatsApp Web in Chromium";    
  #    exec = "chromium --app=https://web.whatsapp.com/ --force-dark-mode --enable-features=WebUIDarkMode %U";
  #    terminal = false;
  #    categories = [ "Application" "Network" "WebBrowser" ];
  #  };
  #};  
  /*
  # this is already covered in configuration.nix
  xdg = {
    portal = {
      enable = true;      
      extraPortals = with pkgs; [         
        xdg-desktop-portal-wlr
        xdg-desktop-portal
      ];
    };
  };
  */
  services = {
    avizo = {
      enable = true;
      settings = {
        default = {
          time = 1.0;
          y-offset = 0.5;
          fade-in = 0.1;
          fade-out = 0.2;
          padding = 10;
        };        
      };

      };
    fnott = {
      enable = true;
      settings = {
        main = {          
          # output=<undefined>#          
          # max-width=0
          # max-height=0          
          anchor = "top-right";
          stacking-order = "top-down";
          min-width = 400;
          title-font = "Inter" + ":size=11";
          summary-font = "Inter" + ":size=10";
          # title-color=ffffffff
          # title-format=<i>%a%A</i>          
          body-font = "Inter" + ":size=10";
          border-size = 0;          
          # edge-margin-vertical=10
          # edge-margin-horizontal=10
          # notification-margin=10          
          icon-theme=config.gtk.iconTheme.name;
          # max-icon-size=32
          selection-helper="rofi";
          # selection-helper-uses-null-separator=no
          # play-sound=aplay ${filename}

          # Default values, may be overridden in 'urgency' specific sections
          # layer=top
          # background=3f5f3fff

          # border-color=909090ff
          # border-radius=0
          # border-size=1

          # padding-vertical=20
          # padding-horizontal=20

          # dpi-aware=no        

          # summary-font=sans serif
          # summary-color=ffffffff
          # summary-format=<b>%s</b>\n

          # body-font=sans serif
          # body-color=ffffffff
          # body-format=%b

          # progress-bar-height=20
          # progress-bar-color=ffffffff

          # sound-file=
          # icon=

          # Timeout values are in seconds. 0 to disable
          # max-timeout=0
          # default-timeout=0
          # idle-timeout=0

        };
        low = {
          background = config.lib.stylix.colors.base00 + "e6";
          title-color = config.lib.stylix.colors.base05 + "ff";
          summary-color = config.lib.stylix.colors.base05 + "ff";
          body-color = config.lib.stylix.colors.base05 + "ff";
          idle-timeout = 150;
          max-timeout = 30;
          default-timeout = 8;
        };
        normal = {
          background = config.lib.stylix.colors.base00 + "e6";
          title-color = config.lib.stylix.colors.base07 + "ff";
          summary-color = config.lib.stylix.colors.base07 + "ff";
          body-color = config.lib.stylix.colors.base07 + "ff";
          idle-timeout = 150;
          max-timeout = 30;
          default-timeout = 8;
        };
        critical = {
          background = config.lib.stylix.colors.base00 + "e6";
          title-color = config.lib.stylix.colors.base08 + "ff";
          summary-color = config.lib.stylix.colors.base08 + "ff";
          body-color = config.lib.stylix.colors.base08 + "ff";
          idle-timeout = 0;
          max-timeout = 0;
          default-timeout = 0;
        };    
      };
    };    
  };

  programs = {
    bash.enable = true;
    foot = {
      enable = true;
      server.enable = true;
    };
    kitty.enable = true;
    joplin-desktop.enable = true;

    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      # settings = {};
    };

    ags = {
      enable = true;
      # null or path, leave as null if you don't want hm to manage the config
      configDir = ../../ags;

      # additional packages to add to gjs's runtime
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    [screencast]
    output_name=DP-1
    max_fps=30
    chooser_cmd=slurp -f %o -or
    chooser_type=simple
  '';
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/salgadev/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
