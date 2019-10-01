install
text

url --url="http://server/centos/7/os/x86_64/"

eula --agreed
firstboot --disable

keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone Africa/Abidjan

auth --enableshadow --passalgo=sha512
rootpw --plaintext ***

ignoredisk --only-use=sda

zerombr
bootloader --location=mbr
clearpart --all --initlabel

part /boot/efi --fstype="efi" --size=100 --fsoptions="umask=0077,shortname=winnt"
part / --fstype="ext4" --size=1 --grow

network --bootproto=dhcp --hostname=localhost --onboot=on --activate

#reboot
poweroff

%packages --nocore --nobase --excludedocs
yum

%end

%addon com_redhat_kdump --disable

%end