---
title: "Identifying your USB stick and writing an ISO to it under Linux"
description: "A practical guide to safely identifying a USB stick's device under Linux (lsblk, journalctl) and writing an installation ISO to it with dd."
draft: false
---

{{< toc >}}

A guide for Linux (tested on TuxedoOS, valid on any recent distribution). The procedure works for any installation ISO: Debian, Ubuntu, Fedora, Proxmox VE, Arch, etc.

> ⚠️ **Warning**: `dd` writes without asking for confirmation and destroys everything on the target device. A naming mistake (`sda` instead of `sdb`) can overwrite a system disk. Check **twice** before running it.

---

## 1. Identify the USB stick's device

### Main method: `lsblk`

Plug in the stick, then run:

```bash
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
```

Spot the line matching your stick using three clues:

- **`TRAN`** shows `usb` → it's a USB device (the internal disk shows `nvme` or `sata`).
- **`SIZE`** matches the stick's advertised capacity (a 64 GB stick shows up around 57–58 GB).
- **`MODEL`** often shows the manufacturer's name (e.g. `USB DISK 3.0`).

Example output:

```
NAME          SIZE TYPE TRAN   MODEL                   MOUNTPOINTS
sda          57,8G disk usb    USB DISK 3.0
└─sda1       57,8G part                                /media/user/DATA
nvme0n1     953,9G disk nvme   SKHynix_HFS001TEM9X169N
├─nvme0n1p1   200M part nvme                           /boot/efi
└─nvme0n1p5 476,8G part nvme                           /
```

Here the stick is **`/dev/sda`** (57.8 GB, `usb`, `USB DISK 3.0`). The `nvme0n1` system disk must not be touched under any circumstances.

> **Note**: built-in multi-card readers sometimes show several devices at `0B` (`sdb`, `sdc`…). These are empty slots — ignore them.

### Foolproof method: watch the name appear live

If any doubt remains, let the kernel tell you which name it assigns at the exact moment you plug the stick in.

With the stick **unplugged**, run:

```bash
journalctl -kf
```

Then **plug in** the stick. The lines scroll live and you will see the assigned device appear, for example:

```
juil. 20 04:57:43 tuxedo-os kernel: sd 1:0:0:0: [sda] Attached SCSI removable disk
```

The name in brackets (`[sda]`) is the one to use. `Ctrl+C` to quit.

**What does `journalctl -kf` do?** `journalctl` reads the **systemd journal**, the centralized logging system of modern distributions (including TuxedoOS and Fedora). Where we historically had scattered text files in `/var/log/`, systemd collects everything into an indexed binary journal that you query with this command. The two options:

- **`-k`** (`--dmesg`) filters to show only **kernel** messages, like the `dmesg` command. It's the kernel that detects USB hardware and assigns the device name (`sda`, `sdb`…), so it's exactly what we want to observe.
- **`-f`** (`--follow`) switches to **real-time follow** mode: the command stays open and prints each new line as it arrives, like `tail -f`. That's what lets you see the line appear at the precise moment you plug in.

> Depending on the configuration, reading the kernel journal may require privileges. If the output is empty or truncated, prefix it with `sudo`: `sudo journalctl -kf`.

Equivalent variant, right after plugging in:

```bash
sudo dmesg | tail -20
```

---

## 2. Unmount the stick (without unplugging it)

If a partition of the stick is mounted (the `MOUNTPOINTS` column is not empty), unmount it. You unmount the **partition** (`sda1`), not the whole disk:

```bash
sudo umount /dev/sda1
```

Repeat for each mounted partition (`sda2`, etc.) as needed.

---

## 3. Check the ISO's path

Confirm the file exists before starting the write:

```bash
ls -lh ~/Downloads/my-image.iso
```

Adapt the path and name to your file.

---

## 4. Write the ISO with `dd`

Replace `sda` with the real name of **your** stick (identified in step 1) and the filename with your ISO:

```bash
sudo dd if=~/Downloads/my-image.iso of=/dev/sda bs=4M status=progress oflag=direct conv=fsync
```

### What the options mean

| Option | Role |
|--------|------|
| `if=` | *input file* — the source ISO. |
| `of=/dev/sda` | *output file* — the **whole disk**, not a partition (`sda`, not `sda1`). Most modern installation ISOs are hybrid images ("isohybrid") that contain their own partition table: they are therefore written to the whole disk. |
| `bs=4M` | Block size of 4 MB. Without it, `dd` copies in 512-byte blocks — slower. |
| `status=progress` | Shows a progress bar and the throughput. |
| `oflag=direct` | Writes directly to the stick, bypassing the kernel cache (page cache). The progress bar then reflects the real write to the device, not merely RAM being filled — this avoids believing the write is finished while the kernel is still writing. |
| `conv=fsync` | Forces the real write to the stick before returning. This is the true safeguard against unplugging too early. |

> If `dd` returns an `Invalid argument` error (rare, on some sticks or USB controllers that handle direct I/O poorly), remove `oflag=direct`: `conv=fsync` plus the final `sync` (step 5) are then enough.

> The progress bar may race ahead and then **pause at the end**: that's `conv=fsync` flushing the cache to the stick. This is normal — be patient.

> **Write to `sdX` or to `sdX1`?** By default, you write to the **whole disk** (`sdX`), which works for all hybrid images — that's the case for the vast majority of current installation ISOs (Debian, Ubuntu, Fedora, Proxmox VE, Arch…). The rare non-hybrid images are the exception; when in doubt, `sdX` remains the right reflex.

---

## 5. Sync before unplugging

As a precaution, force one last cache flush before removing the stick:

```bash
sync
```

Once `sync` has finished, you can safely unplug the stick. It's ready to boot.

---

## Cheat sheet (summary)

```bash
# 1. Identify
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS

# 2. Unmount the mounted partition
sudo umount /dev/sdX1

# 3. Check the ISO
ls -lh ~/Downloads/my-image.iso

# 4. Write (replace sdX with the right device!)
sudo dd if=~/Downloads/my-image.iso of=/dev/sdX bs=4M status=progress oflag=direct conv=fsync

# 5. Sync
sync
```
