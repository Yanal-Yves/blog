---
title: "Really erasing a USB stick: why deleting and formatting are not enough"
description: "Securely erasing a USB stick under Linux: why deletion, formatting and shred fail on flash memory, how to overwrite the device with dd, and how to verify the result with cmp."
draft: false
---

{{< toc >}}

You copied sensitive files onto a USB stick, you deleted them, and you vaguely know that "deleting doesn't really erase". That's correct — but the actual reason is more interesting than the usual explanation, and most reflexes inherited from hard drives are **counter-productive** on flash memory.

This article explains what really happens inside a USB stick, why running `shred` on a file is useless, how to proceed correctly, how to **verify** the result, and above all where the guarantee stops.

> ⚠️ **Warning**: the commands in this article destroy a device's entire contents, without confirmation. A naming mistake (`sda` instead of `sdb`) can overwrite a system disk. Identify your stick with certainty before running anything — the method is detailed in [Identifying your USB stick and writing an ISO to it under Linux]({{< relref "/gnu-linux/ecrire-iso-usb-dd" >}}).

---

## 1. What "deleting" and "formatting" actually do

Deleting a file does not touch its contents. The filesystem removes the directory entry and marks the blocks as reusable; the bytes stay where they are until something overwrites them. That's the well-known mechanism, and it's what makes recovery tools work.

What is less well known: **formatting doesn't erase anything either.** If you responded to an incident by rebuilding the partition table and the filesystem, for example:

```bash
sudo sgdisk --zap-all /dev/sdX
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MYSTICK /dev/sdX1
```

… you only wrote a few megabytes of metadata at the start of the device. The tens of gigabytes of previous content are intact. A file carving tool such as PhotoRec, `foremost` or `scalpel` ignores the filesystem entirely: it sweeps the raw device looking for file-header signatures (JPEG, PDF, ZIP…) and rebuilds whatever it finds. A quick format doesn't hinder it at all.

In other words: after a format, your sensitive data is still there, and recoverable with free software.

---

## 2. Why a USB stick is not a hard drive

This is where the differences that change the method begin.

### You cannot overwrite in place

NAND memory has a physical constraint: a programmed cell must be **erased** before it can be rewritten, and erasure only works at the granularity of a whole **block** — typically 512 KiB to several megabytes. Writing, on the other hand, happens by **page**, of 4 to 16 KiB. Modifying 4 KiB "in place" would therefore require erasing the few megabytes surrounding them.

### The translation layer hides everything

The controller works around this constraint with the **FTL** (Flash Translation Layer), a mapping table between the logical addresses the system sees (the LBAs) and the actual physical pages. When you write to logical address X:

1. the controller writes the new version into a **blank** page, taken from a pool of pre-erased blocks;
2. it updates its table so that X now points to this new page;
3. it marks the old page **"invalid"** — and stops there. **It is not erased.**

The previous content therefore remains physically present in the silicon, in a page no longer referenced by any logical address. These invalid pages are only reclaimed later, by the controller's garbage collector, when the pool of free blocks runs low.

Two additional mechanisms come into play, and they matter for what follows:

- **Wear leveling** spreads writes so as not to always wear the same cells. The controller therefore preferentially picks blocks with low erase counts.
- **Over-provisioning**: the chip contains more NAND than the advertised capacity. A 64 GB stick exposes 61,530,439,680 bytes, i.e. 57.3 GiB, while the raw chip is most likely 64 GiB. So roughly 10 % of physical blocks — on the order of 6 GiB — are mapped by the FTL to **no** logical address at all.

Keep that last point in mind: there is memory inside your stick that you cannot address.

---

## 3. Why erasing file by file does not work

The natural reflex is to use `shred` on the files concerned:

```bash
shred -u sensitive-file.pdf   # ineffective on flash memory
```

On a hard drive this works: the rewrite happens at the same physical location. On a USB stick, `shred` writes to the same **logical addresses**, but the controller redirects each write to **different** physical pages. The old version of the file stays intact in the invalidated pages. You have consumed write cycles without erasing anything.

This is not a theoretical assumption. The reference study on the subject — [Wei, Grupp, Spada and Swanson, *Reliably Erasing Data From Flash-Based Solid State Drives*, USENIX FAST '11](https://www.usenix.org/conference/fast11/reliably-erasing-data-flash-based-solid-state-drives) (UC San Diego) — measured exactly this. The researchers built a hardware rig able to read raw NAND **bypassing the FTL**, and therefore to see what actually remains in the chips.

They tested thirteen single-file erasure protocols, including several government standards. Result: **none succeeded**. On SSDs, between 4 % and 75 % of the files' contents survived. On USB drives, between 0.57 % and 84.9 %. A few values from the "USB drive" column alone:

| Method applied to a file | Data remaining (USB drive) |
|---|---|
| Filesystem delete | 99.4 % |
| Gutmann (35 passes) | 71.7 % |
| Gutmann "Lite" | 84.9 % |
| US Air Force 5020 | 0.0 – 63.5 % |
| British HMG IS5 (Enhanced) | 0.0 – 34.7 % |

The most telling figure is Gutmann's: **35 rewrite passes over a file leave 71.7 % of its contents on the stick.** Considerable effort, almost no result.

> **Practical conclusion**: selectively erasing a single file is beyond the reach of any software tool on flash memory. The only approach that works is overwriting the **entire device**.

---

## 4. What your stick cannot do

Before overwriting, two commonly recommended shortcuts need to be ruled out. On a USB stick they are generally unavailable — and it's better to verify than to assume.

### TRIM / discard

The TRIM command tells the controller that a range of addresses is no longer in use, which triggers physical erasure. Check for support:

```bash
lsblk -D /dev/sdX
```

```
NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
sdX           0        0B       0B         0
```

`DISC-GRAN` and `DISC-MAX` at `0B` mean: **not supported**. `blkdiscard` and `fstrim` will fail. This is the normal case, because the USB Mass Storage bridge does not pass through the SCSI protocol's UNMAP commands. That was the cleanest shortcut; it's ruled out.

### ATA secure erase

`hdparm --security-erase` addresses the ATA layer. A native USB stick has none: it presents itself as SCSI over USB. There is literally nothing to send the command to. (This differs from an SSD in a USB-SATA enclosure, where the bridge sometimes translates ATA commands.)

### And when these commands do exist, they lie

This is the second striking finding of the FAST '11 study. Of twelve drives collected, eight claimed to support the ATA SECURITY command set. Of the seven that could be verified, **only four executed `ERASE UNIT` correctly**. The most worrying case, quoted by the authors:

> *Drive B's behavior is the most disturbing: it reported that sanitization was successful, but all the data remained intact. In fact, the filesystem was still mountable.*

A drive reporting "sanitization successful" while the filesystem is still mountable. The general lesson holds well beyond flash: **an erasure command whose result you don't verify is worthless.**

> **A note on degaussing**: irrelevant here. The authors subjected flash chips to a rotating 14,000 gauss field plus an 8,000 gauss perpendicular alternating field, using a device evaluated for the NSA. Verdict: *"In all cases, the data remained intact."* Flash storage is not magnetic.

---

## 5. Overwriting the entire device

This is the method that works. The principle: by writing across **the whole** address range, you force the controller to consume its entire pool of free blocks, which obliges the garbage collector to erase invalid blocks to replenish it.

### Identify and unmount

Identify the stick unambiguously, then unmount its partitions — you unmount the **partition**, not the disk:

```bash
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
sudo umount /dev/sdX1
```

Check that the `MOUNTPOINTS` column is indeed empty before continuing.

### The two passes

Replace `sdX` with the real name of **your** stick, and note that you write to the **whole disk** (`sdX`), not to a partition (`sdX1`):

```bash
# Pass 1 — random data across the whole capacity
sudo dd if=/dev/urandom of=/dev/sdX bs=4M status=progress conv=fsync

# Pass 2 — zeros across the whole capacity
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress conv=fsync
```

| Option | Role |
|--------|------|
| `if=/dev/urandom` | Source of random data. See below why random rather than zeros. |
| `of=/dev/sdX` | The **whole disk**. Writing to `sdX1` would leave the boot sector and all space outside the partition intact. |
| `bs=4M` | 4 MB blocks. Without this option, `dd` works in 512-byte blocks — far slower. 4 MB also falls within the order of magnitude of the NAND erase block, which avoids partial block writes. |
| `status=progress` | Shows progress and actual throughput. |
| `conv=fsync` | Forces the data to actually reach the stick before returning. Without it, `dd` can finish while megabytes are still in the kernel cache. |

Expect **20 to 30 minutes per pass** for a 64 GB stick: these devices often sustain 30 to 60 MB/s, the "USB 3.2 Gen 1" label describing the bus rather than the NAND. `status=progress` will show you the real throughput within seconds.

### Why random data on the first pass

Because some controllers compress or deduplicate data on the fly. A pass of zeros may then be recorded as a mere "this range is all zeros" annotation in the metadata, **without consuming physical blocks**. No pressure on the free pool, no reclamation triggered, and your old data intact.

Random data is incompressible: the controller is forced to perform real writes. Pass 1 is what produces the useful effect; pass 2 in zeros mainly serves to make the result **verifiable**.

### Why two passes, and not thirty-five

The multi-pass argument comes from hard drives: the historical standards (DoD 5220.22-M, Gutmann's 35 passes) targeted **magnetic remanence**, the idea that residual magnetisation at track edges would betray the previous bit. This has never been demonstrated at modern densities, and NIST 800-88 has considered a single pass sufficient on magnetic disks since 2006.

**On NAND, that argument does not even exist**: a cell is either erased or programmed, there is no analogue echo of the previous charge level. Multi-pass on flash has an entirely different justification — covering the **pool of physical blocks**, not defeating physics.

The point of the second pass is therefore specific. At the end of pass 1, the blocks that escaped reclamation still have a low erase count: if the controller performs *static* wear leveling, they become the priority candidates for the next pass. Pass 2 therefore has a good chance of reaching them.

A good chance only — section 8 explains why you should not promise more than that.

---

## 6. Verifying the erasure

Do not trust `dd`'s final message. Verify.

The trick is to compare the stick against an infinite stream of zeros:

```bash
sudo cmp /dev/zero /dev/sdX
```

`cmp` compares two files **byte by byte** and reports the first difference — unlike `diff`, which thinks in lines of text. `/dev/zero` produces null bytes forever; `/dev/sdX` has an end. Two outcomes are therefore possible.

**If everything is zero**, `cmp` exhausts the stick before the stream and reports the end of the shorter one:

```
cmp: EOF on /dev/sdX after byte 61530439680
```

This is the expected result, and it verifies two things at once: every byte was null, **and** that number matches the device size exactly — so `dd` did reach the last sector.

**If a non-zero byte remains**, `cmp` stops and gives its position:

```
/dev/zero /dev/sdX differ: byte 500001, line 1
```

### The exit-status trap

`cmp` returns **1 in both cases**. It only returns 0 if the files are identical *including in length* — and `/dev/zero` is infinite, so the lengths always differ. Consequently:

```bash
sudo cmp /dev/zero /dev/sdX && echo "OK"   # will NEVER print "OK"
```

Trust only the message. For a scriptable test:

```bash
sudo cmp /dev/zero /dev/sdX 2>&1 | grep -q 'EOF on /dev/sdX' \
  && echo "ERASURE OK" || echo "RESIDUE DETECTED"
```

### Locating residue

The `-l` option lists **all** non-zero bytes instead of just the first:

```bash
sudo cmp -l /dev/zero /dev/sdX | head -20
```

The format is `position  octal_value_file1  octal_value_file2`. Note that `cmp` counts bytes **from 1**, not from 0:

```
actual offset = reported_position - 1
sector        = (reported_position - 1) / 512
```

The diagnosis depends on the location: a difference right at the end suggests a final partial write; a difference in the middle of the useful area means `dd` was interrupted — run it again.

A complementary check, which does not replace `cmp` but catches other cases:

```bash
sudo strings -n 8 /dev/sdX | head
```

This command must return nothing. Expect 8 to 15 minutes for `cmp`: it reads the whole device, but reading is faster than writing. Both operations are strictly read-only, and therefore safe.

---

## 7. Rebuilding a usable stick

After erasure, the stick has neither a partition table nor a filesystem. For everyday use, exFAT is the best choice: readable under Linux, Windows and macOS, and without FAT32's 4 GB per-file limit.

```bash
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MYSTICK /dev/sdX1
```

> **Note**: if your stick only exposed a 32 GiB partition on a 64 GB capacity, that was not a hardware fault. Windows' built-in formatting tool refuses to create a FAT32 partition beyond 32 GiB; many sticks leave the factory that way. The command above reclaims the full space.

---

## 8. What this method does not guarantee

This is the most important section, and the one most tutorials leave out.

### What you do get

Pass 1 destroys **everything reachable through the device's normal interface**. That is a strong guarantee, and `cmp` proves it to you. No recovery software can read whatever may remain, for a structural reason: the FTL no longer maps any logical address to those blocks. There is no address to ask the stick for. This holds for `dd`, for PhotoRec, for TestDisk and for any commercial forensic tool.

For the realistic threat — someone finds or acquires your stick — the problem is solved.

### What you do not

Blocks taken out of circulation stay beyond the reach of rewriting: blocks the controller flagged as defective, and the over-provisioning area. They are only readable by chip-off — desoldering the chips and reading the raw NAND with specialised equipment.

And above all, **there is no formula** giving the residue after N passes. I would be tempted to write that if pass 1 leaves a fraction *f* of blocks unreclaimed, pass 2 brings the residue down to *f²*. That would be wrong: this calculation assumes that block selection in pass 2 is independent of which blocks survived pass 1. It is not independent, and in both directions:

- with **static** wear leveling, the controller *preferentially* targets lightly worn blocks, hence the survivors: coverage is **better** than that calculation suggests;
- with only **dynamic** wear leveling — common on cheap stick controllers — unmapped blocks are **never** touched. Repeating the pass sweeps the same physical set, and the residue stays identical indefinitely. The gain is then **nil**.

The firmware that decides is proprietary, undocumented, and varies between production revisions of one and the same commercial part number.

### What measurement shows

Table 2 of the FAST '11 study gives the number of passes needed to actually erase eight non-encrypting drives:

| Drive | Passes needed |
|---|---|
| B | 1 |
| C, D, F, J, K, L | 2 |
| **A** | **more than 20** |

The authors note:

> *In most cases, overwriting the entire disk twice was sufficient to sanitize the disk, regardless of the previous state of the drive. There were three exceptions: about 1% (1 GB) of the data remained on Drive A after twenty passes.*

**One gigabyte still present after twenty full passes.** The distribution is therefore not a smooth decay: either two passes suffice, or the device resists twenty. Hence the authors' verdict:

> *Overall, the results for overwriting are poor: while overwriting appears to be effective in some cases across a wide range of drives, it is clearly not universally reliable.*

Two honest caveats about these figures: this table covers **SATA SSDs**, not USB sticks (the study only tests USB drives on single-file erasure), and it dates from **2011**, on SLC and MLC. Transposing to a current TLC stick is a reasonable extrapolation, not a deduction.

### What to take away

The second pass is a **sound empirical practice**, not a quantifiable guarantee. It costs twenty minutes and a negligible fraction of the stick's lifespan (see the appendix), so do it. But don't promise a percentage, and above all: it only reduces the chip-off attack surface, since the rest was already unreachable by software.

If your threat model includes a laboratory able to desolder chips, neither the third pass nor the thirty-fifth will change Drive A's case. The only answers are encryption from the outset, or **physical destruction** of the chips — not just of the plastic casing. A new stick costs less than the risk.

Finally, think about copies elsewhere: the files passed through your machine. Check the trash, `~/.local/share/recently-used.xbel`, the thumbnails in `~/.cache/thumbnails/`, and your backups.

---

## 9. The real solution: encrypt from the outset

This is the structural fix, and it is also the recommendation of the study's authors. If the stick is encrypted from the very first byte, "erasing" amounts to destroying the encryption key: an instantaneous operation, independent of the FTL's behaviour, since what remains in the NAND is unusable ciphertext.

**Linux-only use** — LUKS, with `cryptsetup`:

```bash
sudo cryptsetup luksFormat /dev/sdX1
sudo cryptsetup open /dev/sdX1 mystick
sudo mkfs.exfat -n MYSTICK /dev/mapper/mystick
sudo cryptsetup close mystick
```

Desktop environments (GNOME, KDE) will then prompt for the passphrase automatically when the stick is plugged in.

**Cross-platform use** — VeraCrypt, as a file container or a full volume, with traveler disk mode to use it without installing anything on the host machine.

In both cases the rule is the same: encrypt **before** putting anything sensitive on it. Encrypting after the fact leaves the old data in the clear inside the invalidated blocks.

---

## 10. Appendix: measuring the physical geometry

Since the erase block size governs the controller's behaviour, can it be known? From the host, **no**. The FTL exists precisely to hide the physical geometry.

```bash
for f in logical_block_size physical_block_size optimal_io_size \
         discard_granularity rotational; do
  printf "%-22s = %s\n" "$f" "$(cat /sys/block/sdX/queue/$f)"
done
```

Typical output on a USB stick:

```
logical_block_size     = 512
physical_block_size    = 512
optimal_io_size        = 0
discard_granularity    = 0
rotational             = 1
```

`physical_block_size = 512` has **nothing to do** with the NAND erase block: it is the block size the USB bridge declares over SCSI, a pure convention. And `rotational = 1` is telling — the kernel believes it is talking to a spinning disk. The host knows nothing.

What does work is inference by timing: [flashbench](https://github.com/bradfa/flashbench), written by Arnd Bergmann for Linaro's flash memory survey. The tool performs short reads on either side of alignment boundaries of increasing size and measures the latencies; a step change reveals an erase block boundary. The context is explained in [this LWN article](https://lwn.net/Articles/428584/).

```bash
flashbench -a /dev/sdX     # -a mode: read-only, safe
```

> ⚠️ The `-a` mode is non-destructive, but other `flashbench` modes (`--open-au` in particular) **write** to the device.

One last conceptual trap: even by reading the chip's part number off the silicon, the block size on its datasheet is not the garbage collector's erase granularity. Controllers erase by **superblocks**, grouping several blocks spread across multiple planes and multiple dies in order to parallelise. The real unit is an undocumented multiple.

Usual orders of magnitude, to be taken as such:

| Unit | Typical value |
|---|---|
| Page (write unit) | 4 to 16 KiB |
| Block (erase unit) | 512 KiB to 8 MiB |
| Effective superblock | often 4 to 24 MiB on 3D TLC |

---

## 11. Appendix: what it costs the stick

You often read that passes should be limited so as not to wear out the memory. Let's check.

Manufacturers of consumer USB sticks do not publish endurance in P/E cycles — their datasheets state a warranty period. So we have to reason by cell type, with ranges drawn from industry literature:

| Type | Bits/cell | Typical P/E cycles |
|---|---|---|
| SLC | 1 | 50,000 – 100,000 |
| MLC | 2 | 3,000 – 10,000 |
| **TLC** | **3** | **1,000 – 3,000** |
| QLC | 4 | 100 – 1,000 |

A current 64 GB stick is TLC, often with second-tier NAND: dies that fail SSD-grade binning are redirected to sticks and memory cards. Several sources put the flash in these products at around 700 cycles. Assume an order of magnitude of 500 to 1,500 cycles, bearing in mind that this is an estimate and not a specification.

Two full passes consume roughly **2 P/E cycles**: on a fully sequential write, write amplification is close to 1, so there is no hidden multiplier.

| Endurance budget | Cost of 2 passes | Cost of 35 passes |
|---|---|---|
| 700 cycles (pessimistic) | 0.29 % | 5.0 % |
| 3,000 cycles (optimistic) | 0.07 % | 1.2 % |

**Wear is therefore not an argument.** Even the full Gutmann protocol consumes only a few percent of the lifespan. The real argument against multi-pass is not that it damages the stick, it's that it **does not work** — Drive A resists twenty passes — and that it costs twenty minutes per pass.

---

## Cheat sheet (summary)

```bash
# 1. Identify the stick and check for absence of TRIM
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINTS
lsblk -D /dev/sdX

# 2. Unmount every partition
sudo umount /dev/sdX1

# 3. Pass 1: random data across the whole disk (~20-30 min)
sudo dd if=/dev/urandom of=/dev/sdX bs=4M status=progress conv=fsync

# 4. Pass 2: zeros, to make the result verifiable (~20-30 min)
sudo dd if=/dev/zero of=/dev/sdX bs=4M status=progress conv=fsync

# 5. Verify — expected: "EOF on /dev/sdX after byte <exact size>"
#    (the exit status is 1 even on success: trust the message)
sudo cmp /dev/zero /dev/sdX
sudo strings -n 8 /dev/sdX | head     # must return nothing

# 6. Rebuild a usable stick
sudo parted -s /dev/sdX mklabel msdos mkpart primary 1MiB 100%
sudo mkfs.exfat -n MYSTICK /dev/sdX1
```

And for your next stick: encrypt it before copying anything sensitive onto it. That is the only method whose guarantee does not depend on proprietary firmware.

---

## Sources

- [Michael Wei, Laura M. Grupp, Frederick E. Spada, Steven Swanson, *Reliably Erasing Data From Flash-Based Solid State Drives*, USENIX FAST '11](https://www.usenix.org/conference/fast11/reliably-erasing-data-flash-based-solid-state-drives) — the reference study, reading raw NAND while bypassing the FTL
- [flashbench](https://github.com/bradfa/flashbench) — inferring physical geometry by timing
- [Optimizing Linux with cheap flash drives](https://lwn.net/Articles/428584/) — LWN.net, background on flashbench and flash memory geometry
- [Solid state drive (SSD) forensics](https://forensics.wiki/solid_state_drive_(ssd)_forensics/) — forensics.wiki
- [Understanding NAND endurance](https://www.simms.co.uk/tech-talk/understanding-nand-endurance/) — SIMMS
