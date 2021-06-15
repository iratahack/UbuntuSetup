#!/bin/bash

function install_desktop() {
	# Install desktop environment
	sudo apt install -y ubuntu-mate-desktop^
	sudo apt install -y tigervnc-standalone-server autocutsel
	sudo apt install -y imagemagick

	# Install Google Chrome
	rm -f google-chrome-stable_current_amd64.deb
	wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install -y ./google-chrome-stable_current_amd64.deb
	rm -f google-chrome-stable_current_amd64.deb

	# Install the GIMP
	sudo apt install -y tasksel flatpak
	sudo flatpak install -y https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref

	# Configure xstartup for vncserver
	mkdir -p ~/.vnc
	echo "#!/bin/bash" > ~/.vnc/xstartup
	echo "autocutsel -fork" >> ~/.vnc/xstartup
	echo "dbus-launch --exit-with-session mate-session" >> ~/.vnc/xstartup
	chmod +x ~/.vnc/xstartup
}

function display_help() {
	echo "Usage: $0 [OPTIONS]"
	echo
	echo "OPTIONS"
	echo "  --help|-h           Display this information"
	echo "  --no-desktop|-nd    Do not install the desktop environment"
	echo "  --no-build|-nb      Checkout but do not build z88dk"
	echo
}

NO_DESKTOP=0
NO_BUILD=0

while [ "$1" ]
do
	case $1 in
		--help|-h)
			display_help
			exit 0
			;;
		--no-desktop|-nd)
			NO_DESKTOP=1
			;;
		--no-build|-nb)
			NO_BUILD=1
			;;
		*)
			echo "$1: unknown parameter"
			exit 1
			;;
	esac
	shift	
done

# Cleanup the PATH by removing all paths beginning with /mnt/c
export PATH=`echo $PATH | sed "s/\(^\|:\)\/mnt\/c[^:]*//g" | sed "s/^://g"`
echo "PATH = $PATH"

# Update/upgrade the currently installed packages
sudo apt update && sudo apt upgrade -y

if [ -e /usr/local/sbin/unminimize ]
then
	sudo /usr/local/sbin/unminimize
fi

sudo apt install -y standard^

sudo apt install -y daemonize dbus-user-session fontconfig

# Install the required packages
sudo apt install -y build-essential cpanminus ccache git git-lfs vim dos2unix libboost-all-dev texinfo texi2html libxml2-dev subversion bison flex zlib1g-dev m4

#Install required perl modules for z88dk
sudo cpanm -n App::Prove Modern::Perl Capture::Tiny Capture::Tiny::Extended Path::Tiny File::Path Template Template::Plugin::YAML Test::Differences CPU::Z80::Assembler Test::HexDifferences Data::HexDump Object::Tiny::RW Regexp::Common List::Uniq Text::Table Iterator::Simple Iterator::Simple::Lookahead

if [ $NO_DESKTOP = 0 ]
then
	install_desktop
fi

# If not already done, setup the environment file for z88dk
if [ ! -e ~/.z88dkrc ]
then
	echo "echo \$PATH | grep z88dk > /dev/null" > ~/.z88dkrc
	echo "if [ \$? != 0 ]" >> ~/.z88dkrc
	echo "then" >> ~/.z88dkrc

	# Setup env for z88dk in .bashrc
	echo "    export Z88DK=\${HOME}/z88dk" >> ~/.z88dkrc
	echo "    export ZCCCFG=\${Z88DK}/lib/config" >> ~/.z88dkrc
	echo "    export PATH=\${Z88DK}/bin:\$PATH" >> ~/.z88dkrc
	echo "    export PATH=\${HOME}/Tiled:\${PATH}" >> ~/.z88dkrc
	echo "    export PATH=/mnt/c/Program\ Files\ \(x86\)/Fuse:\${PATH}" >> ~/.z88dkrc
	echo "fi" >> ~/.z88dkrc
	
	echo ". ~/.z88dkrc" >> ~/.bashrc
fi

# Install and build z88dk from source
if [ ! -e ~/z88dk ]
then
	cd ~
	. .z88dkrc
	git clone --depth 1 --recursive https://github.com/iratahack/z88dk.git
	if [ $NO_BUILD = 0 ]
	then
		cd z88dk
		./build.sh -p zx
		cd ~
	else
		echo "Skipping z88dk build"
	fi
else
	echo "$HOME/z88dk already exists"
fi

