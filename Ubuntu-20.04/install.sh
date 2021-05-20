#!/bin/bash

# Update/upgrade the currently installed packages
sudo apt update
sudo apt upgrade -y

if [ -e /usr/local/sbin/unminimize ]
then
	sudo /usr/local/sbin/unminimize
fi

# Install the required packages and desktop environment
sudo apt install -y systemd
sudo apt install -y tasksel flatpak
sudo apt install -y build-essential git-lfs vim dos2unix libboost-all-dev texinfo texi2html libxml2-dev subversion bison flex zlib1g-dev m4
sudo apt install -y ubuntu-mate-desktop
sudo apt install -y tigervnc-standalone-server autocutsel
sudo apt install -y imagemagick

# Install Google Chrome
rm -f google-chrome-stable_current_amd64.deb
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# Install the GIMP
sudo flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

#Install required perl modules for z88dk
sudo cpan install App::Prove Modern::Perl Capture::Tiny Capture::Tiny::Extended Path::Tiny File::Path Template Template::Plugin::YAML Test::Differences CPU::Z80::Assembler Test::HexDifferences Data::HexDump Object::Tiny::RW Regexp::Common List::Uniq Text::Table

# Configure xstartup for vncserver
mkdir -p ~/.vnc
echo "#!/bin/bash" > ~/.vnc/xstartup
echo "autocutsel -fork" >> ~/.vnc/xstartup
echo "dbus-launch --exit-with-session mate-session" >> ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

# If not already done, setup the environment file for z88dk
if [ ! -e ~/.z88dkrc ]
then
	# Setup env for z88dk in .bashrc
	echo "export Z88DK=\${HOME}/z88dk" > ~/.z88dkrc
	echo "export ZCCCFG=\${Z88DK}/lib/config" >> ~/.z88dkrc
	echo "export PATH=\${Z88DK}/bin:\$PATH" >> ~/.z88dkrc
	echo "export BUILD_SDCC=1" >> ~/.z88dkrc
	echo "export PATH=\${HOME}/Tiled:\${PATH}" >> ~/.z88dkrc
	echo "export PATH=/mnt/c/Program\ Files\ \(x86\)/Fuse:\${PATH}" >> ~/.z88dkrc
	
	echo ". ~/.z88dkrc" >> ~/.bashrc
fi

# Install and build z88dk from source
if [ ! -e ~/z88dk ]
then
	cd ~
	git clone --depth 1 --recursive https://github.com/z88dk/z88dk.git
	cd z88dk
	./build.sh
	ln -s ~/z88dk/src/z80asm/asmstyle.pl ~/z88dk/bin
	cd ~
fi

