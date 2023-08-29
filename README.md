FreeBSD Container VM tools for Podman
=====================================

This repository contains (early, very work-in-progress) scripts to build a VM image that can be used with `podman machine` to manage FreeBSD VMs (initially on macOS, hopefully elsewhere eventually) to run FreeBSD containers on other operating systems.

Current status
--------------

The VM image can be loaded by `podman machine init`:

 - [X] User accounts from the Ignition file provided by the host over the qemufwcfg interface are created.
 - [X] SSH keys are provisioned.
 - [X] The network is set up, podman is able to ssh into the guest.
 - [X] Host filesystems are mounted.
 - [ ] Host filesystems are mounted in the right place.
       Podman expects to ssh into the vm and run Linux-specific commands to mount filesystems.
       We currently mount them in a location identified by the mount tag, unfortunately Podman does not set the mount tag to anything sensible.
       The simplest fix is probably to make the ssh bit optional, put the mount path in the mount tag, and then the existing code will just work.
 - [X] Podman service runs in the guest.
 - [X] Podman can connect to the service in the guest.
       This is currently done using a hack to symlink the socket to where Podman expects it.
       Eventually, podman should be taught to look in the right place.
 - [X] `podman container` and `podman image` commands work.
 - [ ] Accessing host filesystems from the container works.
       This is currently blocked on not mounting these where Podman expects them to be.
 - [ ] Test on x86-64.
       Currently tested only on AArch64 ('Apple silicon').

A lot of the base system is unnecessary for the VM image (most kernel drivers, the toolchain, and so on) and a future version should install a smaller base.
This does not prevent containers from including a full FreeBSD base system image.

Using
-----

The `build-container-vm.sh` expects to run as root and should be run on -CURRENT.
You can download VM images for -CURRENT from the FreeBSD project, they work well with UTM.
It will uses `poudrierer` to build the image.
Poudriere works much better on ZFS, so using one of these as the base is a good idea.

The script runs the following steps:

1. Clones the FreeBSD sources and applies the patch for 9p-over-virtio support.
2. Uses Poudriere to build a jail containing the downloaded sources.
3. Uses Poudriere to build the necessary packages (podman, qemufwcfg)
4. Uses Poudriere again to build an image containing the base

This will generate the VM image in `/usr/local/poudriere/data/images/podmanvm.img`.
You can copy this to a macOS system and then run:

```sh
$ podman machine init --cpus $(sysctl -n hw.ncpu) --image-path podmanvm.img --rootful freebsd
$ podman machine start freebsd
$ podman system connection default freebsd-root
```

You can now run `podman` commands and they will automatically invoke the podman service in the VM.

If you want to debug the VM edit `.config/containers/podman/machine/qemu/freebsd.json` *before* running the `podman machine start` command and add the following two lines in the `CmdLine` section:

```
  "-serial",
  "tcp::4444,server",
```

Note that some qemu command-line options are split over multiple arguments.
Inserting this before the `-fw_cfg` line is safe.
This will allow you to connect to the console of the VM with `nc localhost 4444`.

Future plans
------------

Many of the bits here need to be upstreamed to FreeBSD (ports or the base system).
Eventually, most of this repository should go away, but I want to get it to the state where it's actually usable first.

Most of the next steps will require changes to Podman, to decouple the how-to-create-a-VM abstractions from the how-to-configure-a-Linux-VM bits.
These will probably also be useful for managing Windows VMs with Podman, if someone ever wants to do that.

On other hosts, Podman uses different virtualization mechanisms.
The QEMU guest support should be sufficient on Linux, but on Windows it would be good to have Hyper-V support at some point.

The VM creation process should be automated and run from CI.
Cirrus has x86-64 and AArch64 VM instances that should be fast enough to do this quickly.

For some reason, using `qemu-img` to convert the raw disk image to QCoW2 results in something that doesn't boot.
It's probably a good idea to figure out why and fix it.

Notes
-----

This currently uses a patched version of ocijail to build with CMake because Bazel depends on OpenJDK, which does not appear to work on FreeBSD/AArch64.
Hopefully that can be fixed at some point, or the CMake build can be upstreamed.
This version also builds its dependencies from ports, so should work with `pkg audit` if there are vulnerabilities in the JSON parser.

We currently provide an entire `sshd_config` to permit root login.
This would be better to do this modification later or we risk failing to pick up changes to the defaults.
Root login via ssh is safe here because the Podman does not expose the SSH login port except to the owner of the VM.

It's weird having an `rc.conf` for a single thing when everything else is in `rc.conf.d` but I can't work out how to do the `ifconfig` bits with `rc.conf.d`.

The VM is built from -CURRENT at the moment so that containers for -CURRENT and any -RELEASE should work.
At some point, it's probably a good idea to default to building from 14.0 since most users probably don't want to run -CURRENT containers and there's less chance of breakage.
