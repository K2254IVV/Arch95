#!/bin/bash

# Проверка на root
if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root" >&2
  exit 1
fi

echo "=== Установка Arch95 - Windows 95-подобного интерфейса для Arch Linux ==="

# Обновление системы
pacman -Syu --noconfirm

# Установка необходимых пакетов
echo "Установка необходимых пакетов..."
pacman -S --noconfirm xorg xorg-xinit lightdm lightdm-gtk-greeter \
    openbox tint2 pcmanfm lxappearance wget curl feh rofi \
    xfce4-terminal gnome-icon-theme gtk-engine-murrine \
    gtk-engines gtk2-perl ttf-ms-fonts wine winetricks

# Установка тем и иконок Windows 95
echo "Установка тем Windows 95..."
mkdir -p /tmp/arch95
cd /tmp/arch95

wget https://github.com/B00merang-Project/Windows-95/archive/master.zip -O win95-theme.zip
unzip win95-theme.zip
mv Windows-95-master /usr/share/themes/Windows95

wget https://github.com/B00merang-Artwork/Windows-95/archive/master.zip -O win95-icons.zip
unzip win95-icons.zip
mv Windows-95-master /usr/share/icons/Windows95

# Установка шрифтов
echo "Установка шрифтов Windows 95..."
wget https://www.freedesktop.org/software/fontconfig/webfonts/webfonts.tar.gz
tar -xzf webfonts.tar.gz
mv msfonts /usr/share/fonts/truetype/
fc-cache -fv

# Настройка LightDM
echo "Настройка LightDM..."
cat > /etc/lightdm/lightdm-gtk-greeter.conf <<EOF
[greeter]
background = /usr/share/backgrounds/arch95.jpg
theme-name = Windows95
icon-theme-name = Windows95
font-name = "MS Sans Serif 10"
xft-antialias = true
xft-dpi = 96
xft-hintstyle = hintslight
xft-rgba = rgb
indicators = ~host;~spacer;~clock;~spacer;~language;~session;~a11y;~power
EOF

# Загрузка обоев Windows 95
wget https://i.imgur.com/JVASdCc.jpg -O /usr/share/backgrounds/arch95.jpg

# Настройка Openbox (Windows 95-like)
echo "Настройка Openbox..."
mkdir -p /etc/skel/.config/openbox
cat > /etc/skel/.config/openbox/autostart <<EOF
# Windows 95-like autostart
tint2 &
pcmanfm --desktop &
feh --bg-scale /usr/share/backgrounds/arch95.jpg &
EOF

cat > /etc/skel/.config/openbox/menu.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
<menu id="root-menu" label="Menu">
  <item label="Terminal">
    <action name="Execute">
      <command>xfce4-terminal</command>
    </action>
  </item>
  <item label="File Manager">
    <action name="Execute">
      <command>pcmanfm</command>
    </action>
  </item>
  <item label="Web Browser">
    <action name="Execute">
      <command>firefox</command>
    </action>
  </item>
  <separator />
  <menu id="system-menu" label="System">
    <item label="Appearance">
      <action name="Execute">
        <command>lxappearance</command>
      </action>
    </item>
    <item label="Exit">
      <action name="Execute">
        <command>oblogout</command>
      </action>
    </item>
  </menu>
</menu>
</openbox_menu>
EOF

# Настройка tint2 (панель задач)
mkdir -p /etc/skel/.config/tint2
cat > /etc/skel/.config/tint2/tint2rc <<EOF
#---------------------------------------------
# TINT2 CONFIG FILE (Windows 95 style)
#---------------------------------------------
# Panel
panel_monitor = all
panel_position = bottom center horizontal
panel_items = TSC
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 2 0 2
panel_dock = 0
wm_menu = 1
panel_layer = bottom
panel_background_id = 1
panel_ontop = 0

# Panel Background
rounded = 0
border_width = 1
border_sides = TBLR
background_color = #c0c0c0 100
border_color = #000000 100
background_color_hover = #c0c0c0 100
border_color_hover = #000000 100
background_color_pressed = #c0c0c0 100
border_color_pressed = #000000 100

# Taskbar
taskbar_mode = single_desktop
taskbar_padding = 2 2 2
taskbar_background_id = 0
taskbar_active_background_id = 0
taskbar_name = 1
taskbar_name_background_id = 0
taskbar_name_active_background_id = 0
taskbar_name_font = MS Sans Serif 8
taskbar_name_font_color = #000000 100
taskbar_name_active_font_color = #000000 100

# Tasks
urgent_nb_of_blink = 20
task_icon = 1
task_text = 0
task_centered = 1
task_maximum_size = 150 30
task_padding = 2 2
task_background_id = 2
task_active_background_id = 3
task_urgent_background_id = 4
task_iconified_background_id = 2

# Task Background
rounded = 2
border_width = 1
border_sides = TBLR
background_color = #c0c0c0 100
border_color = #000000 100
background_color_hover = #c0c0c0 100
border_color_hover = #000000 100
background_color_pressed = #000080 100
border_color_pressed = #000000 100

# Active Task Background
rounded = 2
border_width = 1
border_sides = TBLR
background_color = #000080 100
border_color = #000000 100
background_color_hover = #000080 100
border_color_hover = #000000 100
background_color_pressed = #000080 100
border_color_pressed = #000000 100

# System Tray
systray = 1
systray_padding = 2 0 2
systray_sort = ascending
systray_background_id = 0
systray_icon_size = 24
systray_icon_asb = 100 0 0

# Clock
time1_format = %H:%M
time2_format = %d.%m.%Y
time1_font = MS Sans Serif 8
time2_font = MS Sans Serif 8
clock_font_color = #000000 100
clock_padding = 2 0
clock_background_id = 0
clock_rclick_command = orage
clock_tooltip = 
EOF

# Настройка PCManFM (рабочий стол)
mkdir -p /etc/skel/.config/pcmanfm/default
cat > /etc/skel/.config/pcmanfm/default/desktop-items-0.conf <<EOF
[*]
wallpaper_mode=stretch
wallpaper_common=1
wallpaper=/usr/share/backgrounds/arch95.jpg
desktop_bg=#0078d7
desktop_fg=#ffffff
desktop_shadow=#000000
desktop_font=MS Sans Serif 10
show_wm_menu=0
sort=mtime;ascending;
show_documents=1
show_trash=1
show_mounts=1
EOF

# Создание пользователя (если нужно)
read -p "Создать нового пользователя? [y/N]: " create_user
if [[ "$create_user" =~ [yY] ]]; then
    read -p "Введите имя пользователя: " username
    useradd -m -G wheel -s /bin/bash "$username"
    passwd "$username"
    echo "Пользователь $username создан."
fi

# Включение LightDM
systemctl enable lightdm

echo "=== Установка завершена ==="
echo "Перезагрузите систему для применения изменений."
echo "После входа в систему вы увидите интерфейс, стилизованный под Windows 95."
