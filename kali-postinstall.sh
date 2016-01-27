#!/bin/bash
#-Metadata-----------------------------------------------------------------
# Filename: kali-postinstall.sh
# Date: 2016-01-26
#-Notes--------------------------------------------------------------------
# Run curl -L https://tinyurl.com/teammember8 | bash
#
# These are the things I do after install Kali 2016.1 on a new VM/System. 
#
# Run this as root after an install of Kali 2016.
# 
# This is provided as-is and is not meant for others. However, you might 
# find some of this stuff useful. Got some of these ideas from g0tm1lk,
# see his script at:
#
# https://github.com/g0tmi1k/os-scripts/blob/master/kali.sh
#
# Shamelessly stolen from @CTFKris
#

HASHES="8b8f834b9b100b5a6750c9444684acc6bf199e58b707a4a0ea4dc77198439456  ambiance-colors_15.10.1~wily~NoobsLab.com_all.deb\n"
HASHES+="4f114fd822a15b8b548cdbd67d73e16bc1a2601dfc42a8c54487247adf1bd1ba  humanity-icon-theme_0.6.10_all.deb\n"
HASHES+="3a6d205e68dc621d421ec6a0ac60d2d1520b0ef8997136f97de4fb6828f21370  ubuntu-mono_14.04+15.10.20151001-0ubuntu1_all.deb"

# Path to download packages, XPI's etc to
SCRIPTDLPATH="scriptdls/"

# Kali mirror you prefer, Australians can use AARNet
KALIMIRROR="mirror\.aarnet\.edu\.au\/pub\/kali"

# We do VM detection later, default case it false, set manually to true if the 
# detection fails for you
VM=false

# Check we're root
if [ $EUID -ne 0 ]
then
	echo "[-] This script must be run as root." 
	exit 1
fi

echo "[*] Improving Kali 2016.1"

dmidecode | grep -ic virtual && VM=true

echo -e "[+] Setting preferred Kali mirror - $KALIMIRROR ..."
sed -i "s/http\.kali\.org/$KALIMIRROR/" /etc/apt/sources.list
echo "[+] Updating repos from new mirror..."
apt-get -qq update

if [ $VM == true ]
then
	echo "[+] Installing open-vm-tools..."
	apt-get -y -qq install open-vm-tools-desktop fuse 
else
	echo "[*] Virtual machine NOT detected, skipping vmtools installation..."
fi
echo "[+] Installing mate desktop and setting it to default Xsession..."
apt-get -y -qq install mate-core mate-desktop-environment-extra mate-desktop-environment-extras 
echo mate-session > ~/.xsession

echo "[+] Downloading Ambiance themes..."
mkdir scriptdls 2>/dev/null
wget -q -P "$SCRIPTDLPATH" http://ftp.iinet.net.au/pub/ubuntu/pool/main/u/ubuntu-themes/ubuntu-mono_14.04+15.10.20151001-0ubuntu1_all.deb
wget -q -P "$SCRIPTDLPATH" http://ftp.iinet.net.au/pub/ubuntu/pool/main/h/humanity-icon-theme/humanity-icon-theme_0.6.10_all.deb
wget -q -P "$SCRIPTDLPATH" https://launchpad.net/~ravefinity-project/+archive/ubuntu/ppa/+files/ambiance-colors_15.10.1~wily~NoobsLab.com_all.deb

cd "$SCRIPTDLPATH" || exit #in case cd fails.
echo "[+] Verifying Hashes..."
echo -e "$HASHES" > hashes.txt
if [ "$(shasum -a 256 -c hashes.txt)" ]
then
	echo "[+] Hashes verified!"
else
	echo "[-] Hashes did NOT match, quitting installation..."
	exit
fi

echo "[+] Installing themes and fonts..."
dpkg -i "humanity-icon-theme_0.6.10_all.deb"
dpkg -i "ubuntu-mono_14.04+15.10.20151001-0ubuntu1_all.deb"
dpkg -i "ambiance-colors_15.10.1~wily~NoobsLab.com_all.deb"
cd "$OLDPWD" || exit #in case cd fails.

echo "[+] Downloading firefox extensions..."
wget -q -P "$SCRIPTDLPATH" https://addons.mozilla.org/firefox/downloads/latest/310783/addon-310783-latest.xpi
wget -q -P "$SCRIPTDLPATH" https://addons.mozilla.org/firefox/downloads/latest/3899/addon-3899-latest.xpi
wget -q -P "$SCRIPTDLPATH" https://addons.mozilla.org/firefox/downloads/latest/92079/addon-92079-latest.xpi
wget -q -P "$SCRIPTDLPATH" https://addons.mozilla.org/firefox/downloads/latest/472577/addon-472577-latest.xpi
wget -q -P "$SCRIPTDLPATH" https://addons.mozilla.org/firefox/downloads/latest/51740/platform:5/addon-51740-latest.xpi

echo "[+] Downloading wallpaper to ~/Pictures/kalibg.png"
wget -q -O ~/Pictures/kalibg.png http://img11.deviantart.net/1cda/i/2015/294/f/b/kali_2_0__not_official__wallpaper_by_xxdigipxx-d9dw004.png

echo "[+] Installing more packages..."
apt-get -y -qq install gimp squashfs-tools pngcheck exiftool mongodb-clients xchat sshpass

echo "[+] Installing pwntools..."
pip install pwntools

echo "[+] Installing PEDA..."
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

echo "[+] Updating Metasploit..."
msfupdate

echo "[+] Installing pentest.rb into Metasploit plugins..."
mkdir ~/.msf5/
mkdir ~/.msf5/plugins
wget -q -O ~/.msf5/plugins/pentest.rb https://raw.githubusercontent.com/darkoperator/Metasploit-Plugins/master/pentest.rb

echo "[+] Updating wpscan..."
wpscan --update

echo "[+] Updating mate settings..."
# Terminal 
gsettings set org.mate.terminal.profile:/org/mate/terminal/profiles/default/ scrollback-unlimited true	# unlimited terminal scrollback
gsettings set org.mate.terminal.keybindings help 'disabled' # hate hitting help accidently, noone cares

# Disable screensavers!
gsettings set org.mate.screensaver idle-activation-enabled false	# disable screensave
gsettings set org.mate.power-manager sleep-display-ac 0				# disable screen sleeping when plugged in

# Wallpaper settings
gsettings set org.mate.background picture-options 'centered'		# set wallpaper options
gsettings set org.mate.background picture-filename '/root/Pictures/kalibg.png'
gsettings set org.mate.background color-shading-type 'solid'
gsettings set org.mate.background primary-color '#23231f1f2020'

# Theme and fonts
gsettings set org.mate.interface gtk-theme 'Ambiance-Orange'
gsettings set org.mate.interface icon-theme 'ubuntu-mono-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Ambiance-Orange'
gsettings set org.mate.Marco.general theme 'Ambiance-Orange'
gsettings set org.mate.font-rendering antialiasing 'rgba'
gsettings set org.mate.font-rendering hinting 'slight'

echo "[+] Upgrading packages..."
APT_LISTCHANGES_FRONTEND=none apt-get -o Dpkg::Options::="--force-confnew" -y -qq upgrade

echo "[+] Installing firefox extensions, go through the tabs and accept the installs..."
cd "$SCRIPTDLPATH" || exit #in case cd fails.
firefox -- *.xpi
rm -fr -- "$SCRIPTDLPATH"
echo "[*] You need to reboot for the vmtools to take effect."
