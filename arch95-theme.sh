#!/bin/bash

# Проверка на root
if [ "$(id -u)" -ne 0 ]; then
  echo "Этот скрипт должен быть запущен с правами root" >&2
  exit 1
fi

echo "=== Установка GNOME с GDM и темы Windows 95 ==="

## 1. Обновление системы
pacman -Syu --noconfirm

## 2. Установка GNOME и GDM
echo "Установка GNOME и GDM..."
pacman -S --noconfirm gnome gnome-extra gdm

## 3. Установка зависимостей для тем
echo "Установка зависимостей для тем..."
pacman -S --noconfirm git wget unzip gnome-shell-extensions gtk-engine-murrine gtk-engines

## 4. Установка темы Windows 95
echo "Установка темы Windows 95..."
temp_dir=$(mktemp -d)
cd "$temp_dir"

# Скачивание темы с GNOME-Look (замените URL на актуальный)
wget https://www.gnome-look.org/p/1184663/loadFiles -O win95-theme.zip
unzip win95-theme.zip

# Определение имени темы (может потребоваться корректировка)
theme_name=$(find . -maxdepth 1 -type d -name "Windows-95*" | head -n 1)

if [ -z "$theme_name" ]; then
  echo "Не удалось определить имя темы в архиве"
  exit 1
fi

# Установка темы
mkdir -p /usr/share/themes
mv "$theme_name" /usr/share/themes/Windows95

## 5. Установка иконок Windows 95
echo "Установка иконок Windows 95..."
git clone https://github.com/B00merang-Artwork/Windows-95-Icons.git
mv Windows-95-Icons /usr/share/icons/Windows95

## 6. Установка шрифтов
echo "Установка шрифтов Windows..."
pacman -S --noconfirm ttf-ms-fonts
fc-cache -fv

## 7. Настройка GDM
echo "Настройка GDM..."
cat > /etc/gdm/custom.conf <<EOF
[daemon]
WaylandEnable=false
DefaultSession=gnome-xorg.desktop

[security]

[xdmcp]

[chooser]

[debug]
EOF

## 8. Настройка GNOME для использования темы
echo "Настройка GNOME для использования темы..."

# Создаем скрипт для настройки темы после первого входа
cat > /usr/local/bin/setup-win95-theme.sh <<'EOF'
#!/bin/bash

# Установка темы
gsettings set org.gnome.desktop.interface gtk-theme "Windows95"
gsettings set org.gnome.desktop.wm.preferences theme "Windows95"
gsettings set org.gnome.shell.extensions.user-theme name "Windows95"
gsettings set org.gnome.desktop.interface icon-theme "Windows95"
gsettings set org.gnome.desktop.interface font-name "MS Sans Serif 10"
gsettings set org.gnome.desktop.interface monospace-font-name "Courier New 10"

# Установка фонового изображения
wget https://i.imgur.com/JVASdCc.jpg -O /usr/share/backgrounds/win95.jpg
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/win95.jpg"
gsettings set org.gnome.desktop.background picture-options "scaled"

# Включение необходимых расширений
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
EOF

chmod +x /usr/local/bin/setup-win95-theme.sh

# Добавляем автозапуск для настройки темы
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/setup-win95-theme.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Windows 95 Theme Setup
Exec=/usr/local/bin/setup-win95-theme.sh
OnlyShowIn=GNOME;
X-GNOME-Autostart-Phase=Initialization
EOF

## 9. Включение GDM
echo "Включение GDM..."
systemctl enable gdm

## 10. Установка дополнительных компонентов
echo "Установка дополнительных компонентов..."
pacman -S --noconfirm gnome-tweaks chrome-gnome-shell

echo "=== Установка завершена ==="
echo "Система будет использовать:"
echo "- GDM как дисплей менеджер"
echo "- GNOME как окружение рабочего стола"
echo "- Windows 95 тему"
echo ""
echo "После перезагрузки войдите в систему и тема будет автоматически применена."
echo "Для ручной настройки используйте приложение 'Tweaks' (gnome-tweaks)."
echo ""
echo "Перезагрузите систему командой: reboot"
