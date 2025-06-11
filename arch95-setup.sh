#!/bin/bash

# Winux98 Arch Linux Installer
# Requires: sudo, internet connection

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please run this script as a normal user, not as root."
    exit 1
fi

# Check for sudo access
if ! sudo -v; then
    echo "You need sudo privileges to run this script."
    exit 1
fi

# Update system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install required dependencies
echo "Installing dependencies..."
sudo pacman -S --noconfirm --needed curl wget gnome-shell gtk3 gnome-control-center gnome-tweaks \
    gnome-backgrounds xdg-user-dirs gtk-engine-murrine gnome-themes-extra

# Download and install Windows 98 theme
echo "Downloading Windows 98 theme..."
mkdir -p ~/.themes
curl -L "https://ocs-dl.fra1.cdn.digitaloceanspaces.com/data/files/1500769295/Windows95.tar.gz?response-content-disposition=attachment%3B%2520Windows95.tar.gz" -o /tmp/Windows95.tar.gz
tar -xzf /tmp/Windows95.tar.gz -C ~/.themes/
mv ~/.themes/Windows95 ~/.themes/Windows98

# Create GTK 3 config
echo "Configuring GTK 3..."
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini <<EOL
[Settings]
gtk-theme-name=Windows98
gtk-icon-theme-name=Windows98
gtk-font-name="MS Sans Serif 10"
gtk-cursor-theme-name=Windows98
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOL

# Set GNOME Shell theme (will need to be manually enabled in gnome-tweaks)
echo "Configuring GNOME Shell..."
gsettings set org.gnome.desktop.interface gtk-theme 'Windows98'
gsettings set org.gnome.desktop.interface icon-theme 'Windows98'
gsettings set org.gnome.desktop.interface cursor-theme 'Windows98'
gsettings set org.gnome.desktop.interface font-name 'MS Sans Serif 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font false
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'MS Sans Serif Bold 10'

# Install additional applications
echo "Installing applications..."
sudo pacman -S --noconfirm --needed firefox chromium telegram-desktop ares steam snapd vlc p7zip winrar

# Install AUR helper (yay) and AUR packages
echo "Installing AUR helper and packages..."
sudo pacman -S --noconfirm --needed base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd ~

# Install AUR packages
yay -S --noconfirm ayugram sonic-robo-blast-2

# Enable snapd
echo "Enabling snapd..."
sudo systemctl enable --now snapd.socket

# Install Snap Store
echo "Installing Snap Store..."
sudo snap install snap-store

# Set Windows 98 wallpaper
echo "Setting up Windows 98 wallpaper..."
mkdir -p ~/Pictures/Wallpapers
curl -L "https://i.imgur.com/3m2tYrJ.jpg" -o ~/Pictures/Wallpapers/windows98.jpg
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/windows98.jpg"

# Final instructions
echo ""
echo "Winux98 installation complete!"
echo "To complete the setup:"
echo "1. Open 'GNOME Tweaks' and select 'Windows98' as your Shell theme"
echo "2. Log out and log back in to see all changes"
echo "3. Enjoy your Windows 98 experience on Arch Linux!"
echo ""
echo "Installed applications:"
echo "- Firefox, Chromium, Telegram, Ayugram"
echo "- Steam, Snap Store (with snapd)"
echo "- Ares v144, Sonic Robo Blast 2"
echo "- VLC, 7z, WinRAR"
