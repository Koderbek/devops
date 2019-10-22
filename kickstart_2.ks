text
install
cdrom
lang en_US.UTF-8
keyboard uk
timezone --utc Europe/London
rootpw  --iscrypted $$nndedddewfooofcerd3r434
selinux --disabled
# Custom user added
user --name=kevinmitnick --groups=users --password=HackThePlanet
authconfig --enableshadow --passalgo=sha512 --enablefingerprint
firewall --service=ssh
# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
clearpart --all --drives=sda
ignoredisk --only-use=sda
part /boot --fstype=ext2 --asprimary --size=500
part /OtherOS --fstype=ext4 --asprimary --size=10240
part swap --asprimary --size=2048
part pv.fedora1000 --grow --asprimary --size=500
volgroup fedora --pesize=32768 pv.fedora1000
logvol /centosVM --fstype=ext4 --name=centosVM --vgname=fedora --size=30720
logvol /home --fstype=ext4 --name=home --vgname=fedora --size=81920
logvol / --fstype=ext4 --name=root --vgname=fedora --size=25600
logvol /windowsVM --fstype=ext4 --name=windowsVM --vgname=fedora --size=40960
bootloader --location=mbr --driveorder=sda --append="nomodeset rhgb quiet"
# setup the network with DHCP
network --device=eth0 --bootproto=dhcp
# packages that will be installed, anything starting with an @ sign is a yum package group.
%packages
@admin-tools
@authoring-and-publishing
@base
@core
@development-libs
@development-tools
@dial-up
@editors
@education
@electronic-lab
@engineering-and-scientific
@eclipse
@fedora-packager
@fonts
@gnome-desktop
@gnome-software-development
@graphical-internet
@graphics
@hardware-support
@input-methods
@java
@java-development
@kde-desktop
@kde-software-development
@legacy-fonts
@office
@online-docs
@printing
@sound-and-video
@system-tools
@text-internet
@x-software-development
@base-x
kpackagekit
system-config-network
scribus
xfsprogs
mtools
gpgme
gpm
rpmdevtools
koji
mercurial
lua
pylint
rpmlint
plague-client
cmake
mock
bzr
pptp
kdeedu-marble
minicom
opencv
yum-priorities
plotutils
openoffice.org-opensymbol-fonts
qtcurve-gtk2
gvfs-obexftp
glibmm24-devel
gnome-vfs2-devel
libsigc++20-devel
libart_lgpl-devel
kdepim
konversation
ImageMagick
digikam
kipi-plugins
kdegraphics
gypsy
gpsd
hdparm
m17n-db-tamil
m17n-db-gujarati
m17n-db-kannada
m17n-db-hindi
gok
m17n-db-oriya
m17n-db-bengali
m17n-contrib-sinhala
m17n-db-assamese
m17n-db-punjabi
iok
m17n-db-telugu
m17n-db-malayalam
xorg-x11-fonts-ISO8859-1-100dpi
urw-fonts
ghostscript-fonts
kdepim
vorbis-tools
amarok
jack-audio-connection-kit
kaffeine
kdemultimedia
vbetool
gssdp
geoclue
createrepo
radeontool
PackageKit-command-not-found
obexftp
enca
festival
ntpdate
xsel
gupnp
rdesktop
fuse
ncftp
mesa-libGLU-devel
xorg-x11-apps
xscreensaver-gl-extras
gdm
xscreensaver-extras
xscreensaver-base
xterm
xorg-x11-resutils
gitk
git-gui
dia
tftp
python-crypto
boost-devel
valgrind
subversion
cvs
thunderbird-lightning
python-sqlite2
asciidoc
glibc-static
tcllib
python-psycopg*
ssh*
perl-ExtUtils-MakeMaker
perl-Net-Telnet
perl-HTML-FromText
libICE.so.6
libSM.so.6
libXmu.so.6
libXp.so.6
libXpm.so.4
libXt.so.6
help2man
cscope
ctags
git
kernel-devel
tftp-server
texlive-latex
texi2html
cmake
transfig
alsa-lib
libXScrnSaver
qt
qt-x11
libasound.so.2

libXss.so.1
libQtDBus.so.4
libQtGui.so.4
pulseaudio
alsa-plugins-pulseaudio
pulseaudio-esound-compat
pulseaudio-libs
pulseaudio-libs-glib2
pulseaudio-module-zeroconf
pulseaudio-libs-zeroconf
xmms-pulse
pulseaudio-module-gconf
wine-pulseaudio
xine-lib-pulseaudio
pulseaudio-utils
pulseaudio-module-bluetooth
padevchooser
paman
paprefs
pavucontrol
pavumeter
ncurses-devel.i686
%end
%post --log=/root/my-post-log
exec < /dev/tty3 > /dev/tty3
chvt 3
echo
echo "################################"
echo "# Running Post Configuration   #"
echo "################################"
# prevent future yum updates pulling down & install new kernels (and breaking VMware & video drivers).
echo "exclude=kernel*" >> /etc/yum.conf
# update the system
yum update -y 
# install rpm fusion repo
rpm -Uvh \
http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm \
http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm
# disable rpmfusion repo, to prevent a yum update contaminating the system with rpmfusion rpms.
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rpmfusion-*
# install video drivers - enabling rpmfusion repos on the command line.
yum -y --enablerepo=rpmfusion-nonfree --enablerepo=rpmfusion-free  --enablerepo=rpmfusion-free-updates --enablerepo=rpmfusion-nonfree-updates install kmod-nvidia xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-libs.x86_64 akmod-nvidia
# start akmods on boot
chkconfig akmods on
# add pcadmin to sudoers
echo "kevinmitnick ALL=(ALL)       ALL" >> /etc/sudoers
# set perms on vmware partitions so users in the users group can create vm's
chown :users /windowsVM && chmod 775 /windowsVM
chown :users /centosVM && chmod 775 /centosVM
# Make sure the system boots X by setting the system to run level 5
sed -i 's/id:3:initdefault:/id:5:initdefault:/g' /etc/inittab
# install openvpn & configure
wget ftp://$host/pub/VPN/OpenVPN/Linux/openvpnclient-custom-settings-1.6-3.i386.rpm
rpm -ivh openvpnclient-custom-settings-1.6-3.i386.rpm
cd /etc/openvpn/
rm client.conf-*
wget ftp://$host/pub/VPN/OpenVPN/Linux/64bit/client.conf-1
mv client.conf-1 client.conf-0
rm -f /openvpnclient-custom-settings-1.6-3.i386.rpm
# add Kevin Mitnick to group users
usermod -a -G users kevinmitnick
# pull down vmware images
cd /windowsVM/
wget --user=magicinstaller --password=hacktheplanet ftp://magicinstaller:fubar@ftp.$host.com/images/windowsVM.tar.gz
tar -xvzf windowsVM.tar.gz
cd /centosVM/
wget --user=magicinstaller --password=hacktheplanet ftp://magicinstaller:fubar@ftp.$host.com/images/centosVM.tar.gz
tar -xvzf centosVM.tar.gz
# create symlink as instructed
cd /usr/lib; ln -s libtinfo.so libtermcap.so.2
# confirm perms are set correctly
chown -R :users /windowsVM && chmod -R 775 /windowsVM
chown -R :users /centosVM && chmod -R 775 /centosVM
# swap to console 1
chvt 1