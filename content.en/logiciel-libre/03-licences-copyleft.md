---
title: "Copyleft licences: the freedom that can't be taken back"
description: "Copyleft licences (GPL, LGPL, AGPL) compared with permissive ones: how copyleft seeks to make the user's freedom inalienable, what tivoization is, and why it gave rise to GPLv3."
weight: 3
---

{{< toc >}}

The [first instalment of this series](../02-licences-permissives-freebsd/) explored **permissive** licences (BSD, MIT, Apache) through FreeBSD: they leave everyone free to do what they like with the code, **including closing it back up**. Here is their counterpart: **copyleft** licences.

The difference comes down to a single idea. Where permissive licences allow closing the code, **copyleft requires that any redistributed version stay free**, source code included. The best known is the [GPL](https://www.gnu.org/licenses/gpl-3.0.html), with its [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html) and [AGPL](https://www.gnu.org/licenses/agpl-3.0.html) variants. Its purpose is not merely to share code: it is to ensure that freedom **cannot be taken back** from the user downstream.

## What is copyleft?

Copyleft is a **reversal of copyright**. Rather than giving up their rights (as with a dedication to the public domain) or using them to forbid (as with proprietary software), the author uses them to **guarantee** one thing: any redistributed version — including a modified one — must remain under the **same free conditions**, source code included. Freedom thus becomes **transitive**, forced to "trickle down" to the last link in the chain; no one can close it up downstream. This is the exact opposite of permissive licences, which specifically allow closing the code.

The **word** itself is a pun, older than the GPL: it appears as early as **1976** in the distribution notice of Li-Chen Wang's *Palo Alto Tiny BASIC* — "**@COPYLEFT — ALL WRONGS RESERVED**," a nod to copyright's "*All rights reserved*." But at the time it was only a joke, with no legal mechanism. It was **Richard Stallman** who turned it into a genuine licensing strategy — he recounts adopting the term after receiving an envelope bearing the note "*Copyleft — all rights reversed*."

> Sources: ["What is copyleft?" (GNU)](https://www.gnu.org/licenses/copyleft.en.html) · ["All rights reversed" and the origin of the term (Wikipedia)](https://en.wikipedia.org/wiki/All_rights_reversed).

## How the GPL came to be

The copyleft mechanism did not appear all at once. Its first incarnation is the **GNU Emacs General Public License**, around **1985** — born in part from a mishap: code that Stallman had used (the Gosling Emacs editor) was bought up and then closed by a third-party vendor, and he wanted to prevent that from happening again. Analogous licences followed for the **GCC** compiler and the **GDB** debugger. The problem: each was **specific to its program** (you had to copy the text and name the software concerned), so they were mutually **incompatible**.

Hence the decisive step: in **1989** (the name "GNU General Public License" appears as early as **June 1988**), the **GPL version 1** **generalised** this text. That is the whole meaning of **"general"** here: **a single licence text, independent of any program, applicable as-is to any software** — instead of a licence to be copied and adapted for each project. The GPL therefore did not *invent* copyleft (both the term and the mechanism predated it), but it was the **first reusable licence** to use it — and that is what drove its massive adoption.

The rest comes down to two dates. **GPLv2 (1991)** adds the so-called "Liberty or Death" clause (in essence: if an external constraint — a patent, for example — prevents you from distributing while respecting the freedoms, you may not distribute at all); it is the one that became the reference licence — **the Linux kernel is under GPLv2**. **GPLv3 (2007)** finally modernises the text against more recent threats (patents, tivoization), detailed further down.

> Sources: [History of the GNU GPL (free-soft.org)](https://www.free-soft.org/gpl_history/) · [GNU General Public License (Wikipedia)](https://en.wikipedia.org/wiki/GNU_GPL) · [Sam Williams, *Free as in Freedom*, ch. 9 (O'Reilly)](https://www.oreilly.com/openbook/freedom/ch09.html).

## Two axes to keep from getting lost

The names — GPL, LGPL, AGPL, and their "v2"/"v3" — mix **two independent dimensions**. Keeping them distinct avoids a great deal of confusion:

- **The *strength* of the copyleft** — how far the obligation to stay free extends: **LGPL** (weak) → **GPL** (standard) → **AGPL** (network, the most far-reaching).
- **The *version* over time** — **v1 (1989)** → **v2 (1991)** → **v3 (2007)**: above all a legal modernisation.

A name like "AGPLv3" is thus merely a point on each of these two axes. The next two sections take them one at a time.

## The GPL family: LGPL, GPL, AGPL (the "strength" axis)

- **GPL** — the **standard** copyleft. If you distribute a program that includes GPL code, **the whole thing** must be published under the GPL, sources included.
- **LGPL** — a **weak** copyleft, designed for **libraries**. Proprietary software can **link** to an LGPL library without itself having to become free; only modifications **to the library** stay copyleft. Born in 1991 under the name *Library* GPL, it was **renamed *Lesser* GPL (v2.1) in 1999** — a name change that reflects the FSF's intent: not to make it the default choice.
- **AGPL** — a **"network"** copyleft, the most far-reaching. It closes the "SaaS loophole": with the GPL, running a modified program as an **online service** (without distributing the binary) **does not trigger** the obligation to share the sources. The AGPL extends it to users who interact with the program **over a network** (its "Remote Network Interaction" clause). It descends from the **Affero GPL** (2002); the **GNU AGPLv3** dates from **November 2007**.

> Sources: [GNU LGPL (gnu.org)](https://www.gnu.org/licenses/lgpl-3.0.html) · [History of the LGPL (FOSSA)](https://fossa.com/blog/open-source-software-licenses-101-lgpl-license/) · [GNU Affero GPL (Wikipedia)](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License).

That leaves the other axis: the **evolution of the versions**. This is where GPLv3 comes in, whose most emblematic case — the one through which the subject is most often (mis)understood — is tivoization.

## Tivoization and the asymmetry of power

Let us pause on a key concept, because it is often poorly explained: **tivoization**.

The term comes from the **TiVo** box, a video recorder that used… **Linux**, under the GPLv2 licence. In keeping with the GPL, TiVo did publish the source code. But the device was designed to **run only binaries signed** by the manufacturer: the user could read the code, modify it, recompile it… **without ever being able to run their modified version on their own box**. Freedom on paper, the lock in the hardware. Richard Stallman coined the word to name this workaround, and the **FSF explicitly banned it in GPLv3** (2007) through a so-called "anti-tivoization" clause.

A clarification is needed here, because the shortcut is tempting: **you might think tivoization has to do with permissive licences — it's the opposite.** **Tivoization is a copyleft problem.** If TiVo had to play tricks with the hardware, it is precisely because GPLv2 **required it to hand over the source code**: unable to hide the sources, it locked the hardware to prevent modifications anyway. **With a permissive licence, that detour is pointless**: the manufacturer has no need to lock anything, since it can simply **never publish the code** at all. Permissive is even more radical — it makes the lock *legally free of charge* — but that has nothing to do with tivoization.

A revealing detail: the **Linux kernel stayed on GPLv2** and never moved to GPLv3. Linus Torvalds explicitly rejected the anti-tivoization clause, which he considers outside the scope of a software licence. So the topic divides opinion right to the heart of the free-software world — so much so that I devote [a separate article](../04-torvalds-gplv3/) to it.

What remains is the essential point: the **asymmetry of power**. Whether through tivoization (locked copyleft) or through outright closing (permissive), the result for the user is the same. The model benefits **mega-corporations** enormously — total freedom to innovate on a free base, **massively reduced R&D costs** (decades of OS development inherited without having to build it), industrial secrets perfectly protected. But for **users, SMEs and individuals**, it is the exact opposite: impossible to repair, obsolescence engineered by a mere software update, total dependence on the manufacturer. The console you paid for is one you do not **control**.

> Sources: [Tivoization (Wikipedia)](https://en.wikipedia.org/wiki/Tivoization) · [Richard Stallman, "Why Upgrade to GPLv3" (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · ["Tivoization & Your Right to Install" (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)

## Beyond tivoization: the other contributions of GPLv3

Tivoization is the best-known addition in v3, but not the only one. The others are aimed above all at **plugging legal loopholes** that had appeared since 1991:

- **Patents** — v3 includes an **explicit patent grant**: whoever distributes GPLv3 code grants recipients a licence to their own patents covering that code, which protects them from a later attack.
- **Compatibility with Apache 2.0** — a direct consequence: Apache 2.0's patent clause was an "additional restriction" **incompatible with GPLv2**; **GPLv3 makes it compatible**, which finally allows the two code bases to be combined.
- **Anti-DRM** — v3 specifies that GPL software cannot serve as an "anti-circumvention" lock enforceable against the user.
- **Internationalised wording** — legal vocabulary less centred on US law, so as to hold up better outside the United States.

> Sources: ["A Quick Guide to GPLv3" (GNU)](https://www.gnu.org/licenses/quick-guide-gplv3.en.html) · [Stallman, "Why Upgrade to GPLv3" (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · [Apache Software Foundation, "Apache License v2.0 and GPL Compatibility"](https://www.apache.org/licenses/GPL-compatibility.html).

## Two philosophies, one wish

At bottom, permissive and copyleft do not oppose each other on the technical level: they carry **two philosophies**. **Permissive** licences are in the spirit of **open source** — making the best possible software, the most widely reused, while leaving everyone free to do what they like with it, **including closing it up**. **Copyleft** is in the spirit of **free software** in the FSF's sense — ensuring that the user's freedom cannot be taken away from them along the way: there it is **transitive**, forced to "trickle down" to the last link. The first approach is primarily **pragmatic**; the second, primarily **ethical**.

> Source: Richard Stallman, ["Why Open Source Misses the Point of Free Software"](https://www.gnu.org/philosophy/open-source-misses-the-point.en.html).

I draw no lesson to hand out. As I recount in the [founding article](../01-quand-le-logiciel-privateur-nous-abandonne/), I myself earn my living on proprietary software — which is to say I would be poorly placed to tell others what they ought to do. My preference goes to the philosophy that places the user's freedom at the centre; but it is a **preference**, not a verdict.

So I will not end with a judgement, but with a **wish**: for a computing world that is more **free**, where everyone can understand, repair and extend the tools their life depends on. Permissive and copyleft both contribute to it, each in its own way — and FreeBSD, whose code runs part of the world's infrastructure, is fully a part of it.

## Sources and references

- Copyleft and free software — [Definition of free software (GNU)](https://www.gnu.org/philosophy/free-sw.en.html) · ["What is copyleft?" (GNU)](https://www.gnu.org/licenses/copyleft.en.html) · [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html) · texts: [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html), [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), [AGPL](https://www.gnu.org/licenses/agpl-3.0.html)
- Origin of the term "copyleft" — ["All rights reversed" (Wikipedia)](https://en.wikipedia.org/wiki/All_rights_reversed) · [Li-Chen Wang (Wikipedia)](https://en.wikipedia.org/wiki/Li-Chen_Wang)
- Birth and versions of the GPL — [History of the GNU GPL (free-soft.org)](https://www.free-soft.org/gpl_history/) · [GNU GPL (Wikipedia)](https://en.wikipedia.org/wiki/GNU_GPL) · [Sam Williams, *Free as in Freedom*, ch. 9 (O'Reilly)](https://www.oreilly.com/openbook/freedom/ch09.html)
- The LGPL / GPL / AGPL family — [GNU LGPL](https://www.gnu.org/licenses/lgpl-3.0.html) · [History of the LGPL (FOSSA)](https://fossa.com/blog/open-source-software-licenses-101-lgpl-license/) · [GNU Affero GPL (Wikipedia)](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License)
- Contributions of GPLv3 — ["A Quick Guide to GPLv3" (GNU)](https://www.gnu.org/licenses/quick-guide-gplv3.en.html) · [Apache, "Apache License v2.0 and GPL Compatibility"](https://www.apache.org/licenses/GPL-compatibility.html)
- Tivoization and GPLv3 — [Tivoization (Wikipedia)](https://en.wikipedia.org/wiki/Tivoization) · ["Why Upgrade to GPLv3" (Stallman, GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html) · ["Tivoization & Your Right to Install" (Software Freedom Conservancy)](https://sfconservancy.org/blog/2021/jul/23/tivoization-and-the-gpl-right-to-install/)
- Open source vs free software — [Stallman, "Why Open Source Misses the Point"](https://www.gnu.org/philosophy/open-source-misses-the-point.en.html)
