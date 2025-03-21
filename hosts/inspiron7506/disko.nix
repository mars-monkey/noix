# UEFI only GPT
let
  host = "inspiron7506";
  diskid = "nvme-LITEON_CL1-8D512_002007100VEX";
in {
  disko.devices.disk = {
    "liteon-nvme" = {
      device = "/dev/disk/by-id/${diskid}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          "${host}-zroot" = {
            label = "${host}-zroot";
            end = "-512M"; # Negative end means "Leave this much empty space at the end of the device"
            content = {
              type = "zfs";
              pool = "${host}-zroot";
            };
          };

          "${host}-zboot" = {
            label = "${host}-zboot";
            size = "100%";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
        };
      };
    };

    zpool."${host}-zroot" = {
      type = "zpool";
      options.ashift = "12";

      rootFsOptions = {
        # These are inherited to all child datasets as the default value
        canmount = "off"; # ...Except for `canmount`
        mountpoint = "none"; # Don't mount the main pool anywhere
        atime = "off"; # atime generally sucks, only enable it when needed
        compression = "zstd"; # Slightly more CPU heavy, but better compressratio
        xattr = "sa"; # Store extra attributes with metadata, good for performance
        acltype = "posix"; # Allows extra attributes i.e. SELinux
        dnodesize = "auto"; # Requires a feature (ZFS 0.8.4+), but sizes metadata nodes more efficiently
        normalization = "formD"; # Validate and normalize file names, good for SMB
      };

      datasets = {
        "built" = {
          type = "zfs_fs";
          options = {
            canmount = "off";
            mountpoint = "none";
          };
        };

        "built/nix" = {
          type = "zfs_fs";
          # fstab, not zfsprop
          mountpoint = "/nix";
          options = {
            mountpoint = "legacy";
          };
        };

        "safe" = {
          type = "zfs_fs";
          options = {
            canmount = "off";
            mountpoint = "none";
          };
        };

        "safe/home" = {
          type = "zfs_fs";
          # fstab, not zfsprop
          mountpoint = "/home";
          options = {
            mountpoint = "legacy";
          };
        };

        "state" = {
          type = "zfs_fs";
          # fstab, not zfsprop
          options = {
            canmount = "off";
            mountpoint = "none";
          };
        };

        "state/root" = {
          type = "zfs_fs";
          # fstab, not zfsprop
          mountpoint = "/";
          options = {
            mountpoint = "legacy";
          };
        };
      };

      postCreateHook = "zfs snapshot -r ${host}-zroot@blank";
    };
  };
}
