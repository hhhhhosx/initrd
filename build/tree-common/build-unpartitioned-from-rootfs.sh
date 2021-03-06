einfo "Building from rootfs"

rootfs=/tmp/rootfs.tar
volume=$(get_any volume "/dev/vda")
rootfs_url=$(get_any rootfs_url)
[ -z "$rootfs_url" ] && die "No url to get the rootfs from provided"

pre_build() {
    einfo "Retrieving rootfs"
    run --abort wget -O $rootfs $rootfs_url
}

build() {
    einfo "Creating filesystem"

    mkfs.ext4 -L root $volume

    einfo "Mounting partitions"

    root_mountpoint=$(mktemp -d)
    mount $volume $root_mountpoint

    einfo "Installing rootfs"
    /bin/tar -C $root_mountpoint -xf $rootfs
    echo """ Generated by Scaleway's build system
UUID=$(blkid -o export $volume | grep UUID | cut -d'=' -f2) / ext4 rw,relatime 0 1
""" > $root_mountpoint/etc/fstab
    sync
}

post_build() {
    einfo "Filesystem initialized:"
    file -s $volume
}
