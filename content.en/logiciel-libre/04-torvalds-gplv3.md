---
title: "Why the Linux kernel stayed on GPLv2: Torvalds versus GPLv3"
description: "Linus Torvalds's position on GPLv3 and the anti-tivoization clause: why the Linux kernel stayed on GPLv2, what he actually rejected, and the underlying divide between the FSF's ethics and the pragmatism of open source."
weight: 4
---

{{< toc >}}

In the [previous article on copyleft licences](../03-licences-copyleft/), one detail was worth pausing on properly: **GPLv3** (2007) added an **anti-tivoization** clause, and the **Linux kernel** never moved to GPLv3. The most visible opponent of that version: **Linus Torvalds**, the creator of Linux.

You might assume he favours DRM, or that he neglects user freedom. Neither is true: his position is **coherent** and rests on a precise idea — *a software licence should govern software, not hardware*. Unpacking it is worthwhile, because it reveals a **real fault line** within the free-software world itself.

## A preliminary point: "GPLv2 only," not "v2 or later"

Many projects release under "**GPLv2 or later**": such wording lets anyone move the code to a more recent version of the licence. The Linux kernel, however, is under **GPLv2 *only*** — its `COPYING` file states that it is governed "*under the terms of the GNU General Public License version 2 only*," without the "or later" option.

Practical consequence: even if everyone wanted it, **moving the kernel to GPLv3 would require the agreement of all the rights holders** — thousands of contributors accumulated over decades. In practice, that is **impossible**. So "v2 only" is both a **practical lock** and a **deliberate choice**: before any debate of opinion even begins, the switch was out of reach.

> Sources: [Linux kernel, `COPYING` file](https://github.com/torvalds/linux/blob/master/COPYING) · [Kernel documentation, "License rules"](https://www.kernel.org/doc/html/latest/process/license-rules.html).

## The core objection: the licence covers the software, not the hardware

The heart of the disagreement is the **anti-tivoization** clause. The principle Torvalds defends, in his own words (January 2006):

> "I believe that a software license should cover the software it licenses."

For him, whether a device accepts only signed firmware is a matter of **hardware design** — a manufacturer's decision, not the business of the software licence. He says so bluntly (February 2006):

> "I literally feel that we do not — as software developers — have the moral right to enforce our rules on hardware manufacturers. […] I do software, and I license software."

Yet GPLv3 requires, for this kind of device, that the manufacturer provide the means to install and run a modified version (the "*installation information*," meaning in practice the signing keys). That is exactly the point Torvalds rejects:

> "I think it's insane to require people to make their private signing keys available, for example. I wouldn't do it."

He even went so far as to call the **term "tivoization" itself** misplaced, arguing that TiVo **complied with GPLv2** (the company did publish the source code) and had therefore, in his view, done nothing illegitimate.

> Sources: messages from Linus Torvalds (January–February 2006) — [themed "GPL" archive on yarchive.net](https://yarchive.net/comp/linux/gpl.html) (verbatim copies with dates and Message-IDs) · [Computerworld, "Torvalds says no to GPLv3"](https://www.computerworld.com/article/1577303/torvalds-says-no-to-gplv3.html) · LKML thread ["GPL V3 and Linux"](https://lkml.iu.edu/hypermail/linux/kernel/0601.3/1495.html).

## "Pro-DRM": what he actually said

The label is not invented: Torvalds wrote plainly, in April 2003, "*I want to make it clear that DRM is perfectly ok with Linux!*", and he opposed using the GPL to **forbid** DRM. But "DRM is allowed" does not mean "DRM is good": it is exactly the same rule as for hardware — a licence says what you must **share** (the source code), not what you are allowed to **do** with the software. Refusing to let it ban a use is not praising that use.

What he rejected in GPLv3 is therefore not "less DRM," but the **hardware-related obligation** (handing over the signing keys). And in the face of locks, his bet is not coercion through the licence but **competition**: he reckoned that hardware which restricts its users would eventually lose **on its own**, hostility to the user not being a good business model.

In other words, where the FSF wants to **forbid** the lock through the licence, Torvalds prefers to **let the market** punish it. You may find that bet naive or realistic — that is another debate — but allowing DRM (refusing to ban it through the licence) is not the same as promoting it.

> Sources: [LWN.net, "Linus on digital rights management" (April 2003 — "DRM is perfectly ok with Linux!")](https://lwn.net/Articles/30048/) · [Linux.com, "Stallman, Torvalds, Moglen share views on DRM and GPLv3"](https://www.linux.com/news/stallman-torvalds-moglen-share-views-drm-and-gplv3/).

## The real divide: FSF ethics versus open-source pragmatism

At bottom, this is not a technical quarrel but a disagreement over **values** — the same one that separates "free software" from "open source":

- For **Richard Stallman and the FSF**, the user's freedom must be protected **all the way onto their machine**: if you can read and modify the code but not run your modified version on your own device, the freedom is only apparent. The anti-tivoization clause **fills** that gap.
- For **Torvalds**, GPLv2 is a balanced exchange — *"you get the code, you give back your changes to the code"* — and the licence has no business reaching **beyond the code** itself.

Two **coherent** value systems, not one camp being right against the other. The result, however, is concrete: the most important GPL project in the world, **the Linux kernel**, stayed on GPLv2 — and it is far from an isolated case. Four years after the release of v3, roughly **42% of catalogued free-software projects were still on GPLv2, versus ~6% on GPLv3** (Black Duck, 2011); adoption of v3 remained **partial**, for reasons specific to each project rather than out of allegiance to Torvalds. The debate was never settled; above all, it shows that "free software" is **not monolithic**.

> Source: [GNU General Public License — GPLv2 / GPLv3 adoption (Wikipedia, based on Black Duck 2011 data)](https://en.wikipedia.org/wiki/GNU_General_Public_License).

## In short

Torvalds's rejection of GPLv3 is neither a whim nor a betrayal of freedom: it is a **different conception of the scope of a licence**. Stallman wants the licence to protect the user even into the hardware; Torvalds wants it to stop at the software. Understanding this point is understanding why two people equally committed to free software could, in perfectly good faith, choose opposite sides — and why your phone or your console, for their part, often stay locked no matter what.

## Sources and references

- Linux kernel licence (GPLv2 *only*) — [`COPYING` file](https://github.com/torvalds/linux/blob/master/COPYING) · [Documentation, "License rules"](https://www.kernel.org/doc/html/latest/process/license-rules.html)
- Torvalds's statements (January–February 2006) — [themed "GPL" archive on yarchive.net](https://yarchive.net/comp/linux/gpl.html) (verbatim copies, dated, with traceable Message-IDs) · [Computerworld, "Torvalds says no to GPLv3"](https://www.computerworld.com/article/1577303/torvalds-says-no-to-gplv3.html) · LKML thread ["GPL V3 and Linux"](https://lkml.iu.edu/hypermail/linux/kernel/0601.3/1495.html)
- DRM, Torvalds's position — [LWN.net, "Linus on digital rights management" (April 2003)](https://lwn.net/Articles/30048/) · [Linux.com, "Stallman, Torvalds, Moglen share views on DRM and GPLv3"](https://www.linux.com/news/stallman-torvalds-moglen-share-views-drm-and-gplv3/)
- Tivoization and GPLv3 — [Tivoization (Wikipedia)](https://en.wikipedia.org/wiki/Tivoization) · [Stallman, "Why Upgrade to GPLv3" (GNU)](https://www.gnu.org/licenses/rms-why-gplv3.html)
