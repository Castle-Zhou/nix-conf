# niri 桌面环境的用户配置部署
# 配置文件本体在 ../config/ 下（来自 fedora/arch 的 dot-config，已适配台式机）
# waybar style.css / dunst dunstrc / fuzzel fuzzel.ini / alacritty 颜色
# 均由 home/catppuccin.nix 的 flavor 生成：换主题只改那一行。

{ config, pkgs, lib, username, ... }:

let
  palette = import ./catppuccin.nix;
  p = palette.palettes.${palette.flavor};

  # #rrggbb -> rgba(r, g, b, alpha)，用于半透明底色（GTK CSS 不支持 8 位 hex）
  hexToRgba = hex: alpha: let
    hexDigit = c: {
      "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5;
      "6" = 6; "7" = 7; "8" = 8; "9" = 9;
      "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    }.${c};
    toDec = s: builtins.foldl' (acc: c: acc * 16 + hexDigit c) 0 (lib.stringToCharacters s);
  in "rgba(${toString (toDec (builtins.substring 1 2 hex))}, ${toString (toDec (builtins.substring 3 2 hex))}, ${toString (toDec (builtins.substring 5 2 hex))}, ${alpha})";

  # #rrggbb -> rrggbb（fuzzel 用 8 位 hex，无 #）
  hexNoHash = hex: lib.replaceStrings [ "#" ] [ "" ] hex;
  hex8 = hex: alpha: hexNoHash hex + alpha;

  # ---------- waybar style.css（模板） ----------
  waybarStyle = ''
    * {
      min-height: 0;
      min-width: 0;
      font-family: "Maple Mono NF CN";
      font-size: 15px;
      font-weight: 600;
    }

    window#waybar {
      /* 整体半透明底色（flavor 的 base @ 40%），模块再叠 surface0 色块 */
      background-color: ${hexToRgba p.base "0.4"};
      color: ${p.text};
    }

    /* 模块色块（surface0 底色 + hover 提亮） */
    #clock, #custom-logo, #custom-power, #custom-bandwidth,
    #cpu, #custom-gpu, #memory, #temperature,
    #pulseaudio, #tray, #mpd {
      padding: 0.3rem 0.6rem;
      margin: 0.35rem 0.2rem;
      border-radius: 8px;
      background-color: ${p.surface0};
      transition: background-color 0.2s ease;
    }
    #clock:hover, #custom-logo:hover, #custom-power:hover, #custom-bandwidth:hover,
    #cpu:hover, #custom-gpu:hover, #memory:hover, #temperature:hover,
    #pulseaudio:hover, #tray:hover, #mpd:hover {
      background-color: ${p.surface1};
    }

    /* 各模块 accent 色（沿用语义：cpu teal / gpu sky / 内存 mauve / 温度 red …） */
    #cpu { color: ${p.teal}; }
    #custom-gpu { color: ${p.sky}; }
    #memory { color: ${p.mauve}; }
    #temperature { color: ${p.red}; }
    #clock { color: ${p.blue}; font-size: 17px; font-weight: 700; }
    #pulseaudio { color: ${p.lavender}; }
    #pulseaudio.muted { color: ${p.overlay0}; }
    #custom-bandwidth { color: ${p.peach}; }
    #custom-logo { color: ${p.blue}; }
    #custom-power { color: ${p.red}; }
    #mpd.playing { color: ${p.green}; }
    #mpd.paused { color: ${p.overlay1}; }

    tooltip {
      background-color: ${p.crust};
      border: 2px solid ${p.mauve};
      border-radius: 8px;
      color: ${p.text};
    }
    tooltip label {
      color: ${p.text};
    }
  '';

  # ---------- dunst dunstrc（模板：占位符换色板色） ----------
  dunstConf = lib.replaceStrings
    [ "@bg@" "@fg@" "@frame@" "@frame-critical@" "@username@" ]
    [ p.base p.text p.blue p.peach username ]
    (builtins.readFile ../config/dunst/dunstrc.template);

  # ---------- fuzzel fuzzel.ini（模板：占位符换色板 8 位 hex） ----------
  fuzzelConf = lib.replaceStrings
    [ "@background@" "@text@" "@prompt@" "@overlay1@" "@red@" "@selection@" ]
    [ (hex8 p.base "dd") (hex8 p.text "ff") (hex8 p.subtext1 "ff")
      (hex8 p.overlay1 "ff") (hex8 p.red "ff") (hex8 p.surface2 "ff") ]
    (builtins.readFile ../config/fuzzel/fuzzel.ini.template);

  # ---------- btop（模板：color_theme 跟随 flavor；activation 同步为可写副本） ----------
  btopConfFile = pkgs.writeText "btop.conf" (lib.replaceStrings
    [ "@theme@" ]
    [ "catppuccin_${palette.flavor}" ]
    (builtins.readFile ../config/btop/btop.conf.template));

  # ---------- swaylock（模板） ----------
  swaylockConf = lib.replaceStrings
    [ "@base@" "@yellow@" "@teal@" "@red@" "@blue@" "@green@" "@text@" ]
    [ p.base p.yellow p.teal p.red p.blue p.green p.text ]
    (builtins.readFile ../config/swaylock/config.template);

  # ---------- niri config.kdl（模板：focus-ring/border/overview 颜色跟随 flavor） ----------
  # 占位符统一替换表：主题色 + 机器相关路径（@home@ / @username@）
  niriPlaceholders = [ "@focus-active@" "@focus-inactive@" "@border-active@" "@border-inactive@" "@border-urgent@" "@overview-bg@" "@home@" "@username@" ];
  niriValues = [ p.green p.surface1 p.green p.surface1 p.yellow p.surface0 config.home.homeDirectory username ];
  replaceNiri = text: lib.replaceStrings niriPlaceholders niriValues text;

  niriConf = replaceNiri (builtins.readFile ../config/niri/config.kdl.template);

  # ---------- 机器 niri patch（~/slot/niri.kdl，机器本地，不存在则跳过） ----------
  # 与主配置共用同一套占位符（主题色/@home@/@username@ 都会替换）；
  # 通过 niri 的 include 机制合并（后写覆盖前写、binds 冲突键覆盖、output 追加），
  # 详见 README「个性化机制」。
  slotNiriPatch = "${config.home.homeDirectory}/slot/niri.kdl";
  hasNiriPatch = builtins.pathExists slotNiriPatch;
  niriMachineConf = lib.optionalString hasNiriPatch (replaceNiri (builtins.readFile slotNiriPatch));

  # ---------- 壁纸：~/slot/wallpaper.jpg 存在则用机器壁纸（激活时复制），否则仓库默认 ----------
  slotWallpaper = "${config.home.homeDirectory}/slot/wallpaper.jpg";
  hasSlotWallpaper = builtins.pathExists slotWallpaper;

  # ---------- alacritty（颜色整体由 flavor 生成，不再 import 风味文件） ----------
  alacrittyToml = ''
    [general]
    # 颜色由 home/catppuccin.nix 的 flavor 生成，无需 import 风味文件

    [window]
    dimensions = { columns = 135, lines = 30 }
    padding = { x = 4, y = 2 }
    dynamic_padding = true

    [font]
    normal = { family = "Maple Mono NF CN"}
    bold = { family = "Maple Mono NF CN", style = "Bold" }
    italic = { family = "Maple Mono NF CN", style = "Italic" }
    size = 14.0

    [cursor]
    style = { shape = "Block", blinking = "On" }

    [terminal]
    osc52 = "CopyPaste"

    [env]
    TERM = "xterm-256color"

    [colors.primary]
    background = "${p.base}"
    foreground = "${p.text}"
    dim_foreground = "${p.overlay1}"
    bright_foreground = "${p.text}"

    [colors.cursor]
    text = "${p.base}"
    cursor = "${p.rosewater}"

    [colors.vi_mode_cursor]
    text = "${p.base}"
    cursor = "${p.lavender}"

    [colors.search.matches]
    foreground = "${p.base}"
    background = "${p.subtext0}"

    [colors.search.focused_match]
    foreground = "${p.base}"
    background = "${p.green}"

    [colors.footer_bar]
    foreground = "${p.base}"
    background = "${p.subtext0}"

    [colors.hints.start]
    foreground = "${p.base}"
    background = "${p.yellow}"

    [colors.hints.end]
    foreground = "${p.base}"
    background = "${p.subtext0}"

    [colors.selection]
    text = "${p.base}"
    background = "${p.rosewater}"

    [colors.normal]
    black = "${p.surface1}"
    red = "${p.red}"
    green = "${p.green}"
    yellow = "${p.yellow}"
    blue = "${p.blue}"
    magenta = "${p.pink}"
    cyan = "${p.teal}"
    white = "${p.subtext1}"

    [colors.bright]
    black = "${p.surface2}"
    red = "${p.red}"
    green = "${p.green}"
    yellow = "${p.yellow}"
    blue = "${p.blue}"
    magenta = "${p.pink}"
    cyan = "${p.teal}"
    white = "${p.subtext0}"

    [[colors.indexed_colors]]
    index = 16
    color = "${p.peach}"

    [[colors.indexed_colors]]
    index = 17
    color = "${p.rosewater}"
  '';
in
{
  home.packages = with pkgs; [
    alacritty
    bibata-cursors        # niri 配置里指定的光标主题
  ];

  xdg.configFile = {
    # 主配置 + 机器 patch 的 include（slot 存在时才追加；niri ≥ 26.04 支持 ~ 展开）
    "niri/config.kdl".text = niriConf + lib.optionalString hasNiriPatch "\ninclude \"~/.config/niri/niri-machine.kdl\"\n";
    "niri/niri-machine.kdl" = lib.mkIf hasNiriPatch { text = niriMachineConf; };
    "niri/scripts".source = ../config/niri/scripts;
    "waybar/config.jsonc".source = ../config/waybar/config.jsonc;
    "waybar/scripts".source = ../config/waybar/scripts;
    "waybar/style.css".text = waybarStyle;
    "dunst/dunstrc".text = dunstConf;                     # 模板生成，跟随 flavor
    "fuzzel/fuzzel.ini".text = fuzzelConf;                # 模板生成，跟随 flavor
    "fuzzel/scripts".source = ../config/fuzzel/scripts;
    "alacritty/alacritty.toml".text = alacrittyToml;      # 模板生成，跟随 flavor
    "swaylock/config".text = swaylockConf;               # 模板生成，跟随 flavor
    "Thunar".source = ../config/Thunar;
    "nvim".source = ../config/nvim;

    # 只部署配置文件，运行时数据（database/state/log）由 mpd 自己生成
    "mpd/mpd.conf".source = ../config/mpd/mpd.conf;
    "copyq/copyq.conf".source = ../config/copyq/copyq.conf;
  };

  # btop 配置部署为可写副本（不是只读符号链接）：
  # btop 界面里改设置能直接写回；rebuild 时模板重新同步一次（用户自加的主题保留，
  # 因为 themes rsync 不带 --delete）。想持久化改动就改仓库的 btop.conf.template。
  home.activation.btop = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/btop/themes"
    run ${pkgs.rsync}/bin/rsync -rl --chmod=u+rwX \
      "${btopConfFile}" "$HOME/.config/btop/btop.conf"
    run ${pkgs.rsync}/bin/rsync -rl --chmod=u+rwX \
      "${../config/btop/themes}/" "$HOME/.config/btop/themes/"
  '';

  # polkit 认证代理的稳定路径（niri config.kdl 里 spawn-at-startup 引用）
  home.file.".local/bin/polkit-agent".source =
    "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";

  # 壁纸（niri config.kdl 里 swaybg 引用）：默认用仓库壁纸；
  # 机器壁纸放 ~/slot/wallpaper.jpg，存在时激活阶段复制覆盖（见下方 activation）
  home.file."Pictures/Wallpapers/wallpaper.jpg" = lib.mkIf (!hasSlotWallpaper) {
    source = ../wallpaper.jpg;
  };

  # 常用目录
  home.activation.createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Music" \
      "$HOME/.local/share/mpd/playlists" \
      "$HOME/Pictures/Screenshots" \
      "$HOME/Pictures/Wallpapers" \
      "$HOME/bin" "$HOME/.local/bin"
  '';

  # 机器壁纸（slot 存在时复制为可写文件，替代默认壁纸的只读符号链接）
  home.activation.wallpaper = lib.mkIf hasSlotWallpaper (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Pictures/Wallpapers"
    run cp "${slotWallpaper}" "$HOME/Pictures/Wallpapers/wallpaper.jpg"
  '');
}
