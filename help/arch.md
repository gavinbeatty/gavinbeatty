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

    sudo pacman -U https://olegtown.pw/Public/ArchLinuxArm/RPi4/kernel/linux-raspberrypi4-5.4.41-1-aarch64.pkg.tar.xz \
                   https://olegtown.pw/Public/ArchLinuxArm/RPi4/kernel/linux-raspberrypi4-headers-5.4.41-1-aarch64.pkg.tar.xz \
                   https://olegtown.pw/Public/ArchLinuxArm/RPi4/firmware/raspberrypi-firmware-20200809-1-aarch64.pkg.tar.xz

If there are errors regarding missing signatures, change `RemoveFileSigLevel = Optional` in `/etc/pacman.conf`.

### Setup

    passwd # Password is "alarm" -- change based on hostname?
    su # Password is "root".
    passwd # Change for root.
    hostnamectl set-hostname $name
    nano /etc/locale.gen # Uncomment "en_US.UTF-8 UTF-8".
    locale-gen
    localectl # Should look good.
    nano /etc/systemd/journald.conf # Set Storage=volatile, if /var/log/journal is an SD card.
    systemctl force-reload systemd-journald
    timedatectl set-ntp true
    timedatectl set-timezone America/Chicago # list-timezones
    nano /etc/sysctl.d/02-ipv6-disable.conf # ipv6.disable=1
    # Make sure system clock is synchronized if DNSSEC=true (i.e., if it's mandatory).
    nano /etc/systemd/resolved.conf # Set DNS=1.1.1.1#1dot1dot1dot1.cloudflare-dns.com, DNSSEC=allow-downgrade, DNSOverTLS=opportunistic, MulticastDNS=true, etc.
    systemctl enable --now systemd-resolved # Do NOT use avahi-daemon.
    nano /etc/nsswitch.conf # hosts: files mymachines resolve [!UNAVAIL=return] myhostname dns
    nano /etc/systemd/networkd.conf # [Network] LinkLocalAddressing=ipv4 IPv6AcceptRA=false, [DHCP] UseDNS=false [IPv6AcceptRA] UseDNS=false
    nano /etc/systemd/network/eth*.network /etc/systemd/network/wlan*.network # See *.network below.
    mv /boot/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
    chmod 0400 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
    rm /etc/wpa_supplicant/wpa_supplicant.conf

#### /etc/systemd/network/\*.network

    [Match]
    Name=eth* or wlan* or en* or whatever
    
    [Network]
    DHCP=ipv4
    IPv6AcceptRA=false
    MulticastDNS=true
    
    [DHCP]
    UseDNS=false
    
    [IPv6AcceptRA]
    UseDNS=false

#### Multicast DNS

As mentioned in [systemd-resolved#mDNS](https://wiki.archlinux.org/index.php/Systemd-resolved#mDNS),

    mDNS will only be activated for the connection if both the systemd-resolved's global setting (MulticastDNS= in resolved.conf(5))
    and the network manager's per-connection setting is enabled. By default systemd-resolved enables mDNS responder,
    but both systemd-networkd and NetworkManager[2] do not enable it for connections:

Meaning `MulticastDNS=true` is required in both `/etc/systemd/resolved.conf` *and*
the relevant `/etc/systemd/network/*.network` files.

### pacman

    pacman-key --init
    pacman-key --populate archlinuxarm
    pacman -Syu
    pacman -S nss-mdns
    pacman -S vi tmux nvim git mosh zsh zsh-doc man sudo wget cmake make rsync
    pacman -S binutils fakeroot patch which autoconf automake # For AUR builds with makepkg.
    visudo # Uncomment the %wheel line to run all commands.
    exit # Back to alarm user
    git clone https://github.com/gavinbeatty/gavinbeatty.git
    cd gavinbeatty && ./install.sh # But edit ~/.tmux.conf back down to ~nothing.
    configure-git.sh -v # But edit ~/.gitconfig to remove all user & mail settings.
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    cd ~/.oh-my-zsh/custom/themes && git clone https://github.com/romkatv/powerlevel10k

### makepkg

    sudo nano /etc/makepkg.conf
      CFLAGS="-march=armv8-a+crc+simd ..." # Raspbery Pi 4, 32-bit only
      CFLAGS="-march=armv8.1-a+crc+simd ..." # Raspbery Pi 4, 64-bit only
      MAKEFLAGS="-j3"
      BUILDDIR=/tmp/makepkg
      COMPRESSXZ=(... --threads=0)
      COMPRESSZST=(... --threads=0)
      PKGEXT='.pkg.tar.zst'

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

