## Raspberry Pi 4

[Install](https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4#installation)

    touch boot/ssh # Enable & start sshd.
    wpa_passphrase ng > boot/wpa_supplicant.conf
    # Enter password and press Enter.
    # Edit out everything except "country=.." and the "ng" section.

### Arm64/aarch64

[This post](https://archlinuxarm.org/forum/viewtopic.php?t=13948) immediately
[refers to](https://archlinuxarm.org/forum/viewtopic.php?f=8&t=13734&start=50)
[rootfs](https://olegtown.pw/Public/ArchLinuxArm/RPi4/rootfs/).

Use the standard install instructions above,
but replace the rootfs with the latest one from these posts.

After installation, install the kernel, headers, and firmware. e.g.,

    wget -c https://olegtown.pw/Public/ArchLinuxArm/RPi4/kernel/linux-raspberrypi4-4.19.114-1-aarch64.pkg.tar.xz
    sudo pacman -U ./linux-raspberrypi4-*
    wget -c https://olegtown.pw/Public/ArchLinuxArm/RPi4/kernel/linux-raspberrypi4-headers-4.19.114-1-aarch64.pkg.tar.xz
    sudo pacman -U ./linux-raspberrypi4-headers-*
    wget -c https://olegtown.pw/Public/ArchLinuxArm/RPi4/firmware/raspberrypi-firmware-20200411-1-aarch64.pkg.tar.xz
    sudo pacman -U ./raspberrypi-firmware-*

### Setup

    passwd # Password is "alarm" -- change based on hostname?
    su # Password is "root".
    passwd # Change for root.
    hostnamectl set-hostname $name
    nano /etc/locale.gen # Uncomment "en_US.UTF-8 UTF-8".
    locale-gen
    localectl # Should look good.
    timedatectl set-ntp true
    timedatectl set-timezone America/Chicago # list-timezones
    nano /etc/sysctl.d/02-ipv6-disable.conf # ipv6.disable=1
    nano /etc/nsswitch.conf # Put "mdns_minimal [NOTFOUND=return]" before "resolve".
    nano /etc/systemd/resolved.conf # Set DNS=1.1.1.1#1dot1dot1dot1.cloudflare-dns.com, DNSOverTLS=opportunistic, MulticastDNS=yes, etc.
    systemctl enable --now systemd-resolved # Do NOT use avahi-daemon.
    nano /etc/systemd/networkd.conf # [Network] LinkLocalAddressing=ipv4 IPv6AcceptRA=false, [DHCP] UseDNS=false [IPv6AcceptRA] UseDNS=false
    nano /etc/systemd/network/eth*.network /etc/systemd/network/wlan0.network # See *.network below.
    mv /boot/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
    chmod 0400 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
    rm /etc/wpa_supplicant/wpa_supplicant.conf

#### /etc/systemd/network/\*.network

    [Match]
    Name=eth* or wlan0 or en* or whatever
    
    [Network]
    DHCP=ipv4
    IPv6AcceptRA=false
    
    [DHCP]
    UseDNS=false
    
    [IPv6AcceptRA]
    UseDNS=false

### pacman

    pacman-key --init
    pacman-key --populate archlinuxarm
    pacman -Syu
    pacman -S nss-mdns
    pacman -S vi tmux nvim git mosh zsh zsh-doc man sudo wget cmake make rsync
    pacman -S binutils fakeroot patch which # For AUR builds with makepkg.
    su -c 'visudo' # Uncomment the %wheel line to run all commands.
    git clone https://github.com/gavinbeatty/gavinbeatty.git
    cd gavinbeatty && ./install.sh # But edit ~/.tmux.conf back down to ~nothing.
    configure-git.sh -v # But edit ~/.gitconfig to remove all user & mail settings.
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    cd ~/.oh-my-zsh/custom/themes && git clone https://github.com/romkatv/powerlevel10k

### mirage

First time:

    sudo pacman -S opam m4 gcc pkgconf
    opam init
    eval $(opam env)
    opam update
    opam switch install 4.10.0 # Or something.
    opam install mirage
    git clone https://github.com/mirage/mirage-skeleton.git

Subsequently:

    eval $(opam env)
    cd mirage-skeleton/tutorial/hello && mirage configure -t hvt && make depend && make
    solo5-hvt ./hello.hvt

