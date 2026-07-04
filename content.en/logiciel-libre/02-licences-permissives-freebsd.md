---
title: "The flip side of permissive licences — FreeBSD, and freedom for whom?"
description: "Permissive licences (BSD, MIT, Apache) through FreeBSD and its use by Netflix, Sony (PlayStation) and Apple: how giants build proprietary products on a free base, and what they give back (or not) to the community."
weight: 2
---

{{< toc >}}

In the [founding article of this series](../01-quand-le-logiciel-privateur-nous-abandonne/), I recounted how proprietary software ends up abandoning its users. The answer I champion is free software. But "free" is not a single block: there are two great families of licences, with opposing philosophies.

- **Permissive** licences (BSD, MIT, Apache…): do whatever you want with the code, including closing it up inside a proprietary product.
- **Copyleft** licences: require that any redistributed version stay free. The best known is the [GPL](https://www.gnu.org/licenses/gpl-3.0.html), but it is not the only one: the [LGPL](https://www.gnu.org/licenses/lgpl-3.0.html), the [AGPL](https://www.gnu.org/licenses/agpl-3.0.html) and the [MPL](https://www.mozilla.org/en-US/MPL/2.0/) apply the same idea to varying degrees.

This article explores the **first** family — permissive licences — through the most spectacular case there is: [FreeBSD](https://www.freebsd.org/), the operating system you probably use every day without knowing it. The second, copyleft, is the subject of [a dedicated article](../03-licences-copyleft/).

## What is a permissive licence?

A permissive licence — the main ones are **BSD** (2- or 3-clause), **MIT** and **Apache 2.0** — rests on a simple idea: to give whoever receives the code an **almost total freedom**. In concrete terms, three rights:

- the right to **modify** the code;
- the right to **redistribute** it;
- the right to **close** it — that is, to turn it into a proprietary product, a black box, without publishing your modifications.

In exchange, a single genuine constraint: **keep the original copyright and licence notice**. That's all. (Apache 2.0 adds a patent-grant clause and a `NOTICE` file; BSD-3 forbids using the authors' names to endorse a derived product — but the spirit remains the same.)

Here lies the whole difference with **copyleft** (the GPL being its best-known example), which we will look at in detail in a forthcoming article: a copyleft licence requires that any redistributed version stay free, source code included. A permissive licence does not require this. **It therefore explicitly allows taking free software and turning it into proprietary software.** Remember this sentence: the whole article follows from it.

## FreeBSD, a complete operating system, free… and permissive

To see what this looks like in practice, a good example is **FreeBSD**. And the first thing to understand is that **it is not a "distribution" like Ubuntu or Fedora**.

GNU/Linux is a kernel (Linux) assembled with a host of software from separate projects (the GNU userland, etc.), brought together by a distributor. FreeBSD, by contrast, develops the **kernel AND the userland** (the system's core tools) **together, in a single source tree**. The result is a **complete, coherent and unified** operating system, designed as one whole.

This coherence earned it a reputation for **extreme stability**, particularly on two fronts: a **TCP/IP network stack** reckoned among the best in the industry, and native integration of the **ZFS** file system. That is exactly what makes it a favourite choice for **infrastructure** — where you have to handle enormous loads for years without flinching. And this is where permissive licences come into play.

## How the giants exploit FreeBSD

### Netflix: the invisible infrastructure

When you watch a Netflix video, it probably does not come from a distant data centre, but from an **Open Connect Appliance** (OCA) installed directly at your internet provider's (Free, Orange, etc.). And these boxes run **FreeBSD**.

The scale is considerable: Netflix has spent **more than a billion dollars** developing and deploying **more than 8,000** of these appliances, installed by more than **1,000 internet providers** — which allowed the latter to **save 1.25 billion dollars** (as of the end of 2021) by avoiding routing all that video traffic over their links. On the performance side, Netflix engineers presented at [EuroBSDCon](https://www.eurobsdcon.org/) 2022 a single server capable of serving **nearly 800 Gb/s** of encrypted video.

Netflix illustrates the **permissive model in practice**: building one of the largest proprietary services in the world on a free base, giving back only what it is in its interest to give back. And that is exactly what Netflix does: it **gives back its kernel modifications** to FreeBSD, and runs its servers on **FreeBSD-CURRENT** (the development branch) — not out of generosity, but out of **well-understood self-interest**: keeping a private fork that diverges from upstream is expensive in "technical debt." It does, on the other hand, keep its **application layer** closed — the Open Connect software itself: streaming server, caching and content-placement algorithms.

But let us be honest, because the point matters for what follows: **a copyleft licence (GPL) would change almost nothing here.** First, because that closed layer runs in **user space**: even on a copyleft kernel like Linux, an application that merely calls the kernel is not a "derived work" and can stay proprietary (which is why so much closed software runs on Linux). Second, because copyleft is triggered only by the **distribution** of the software: yet the boxes remain Netflix's property, operated in-house — and its modified kernel is in any case **already public**, by choice. For **infrastructure operated in-house**, the choice of licence therefore carries little weight. Where it becomes decisive is when the software is **delivered into the hands of the end user** — exactly what the next two cases show.

> Sources: [Open Connect (Wikipedia)](https://en.wikipedia.org/wiki/Open_Connect) (FreeBSD system; over $1bn for 8,000+ OCAs; $1.25bn saved for ISPs as of end 2021) · [Netflix serves nearly 800 Gb/s on FreeBSD (EuroBSDCon 2022)](https://papers.freebsd.org/2022/eurobsdcon/gallatin-the_other_freebsd_optimizations-netflix/) · upstreaming strategy to reduce technical debt: [Netflix case study (FreeBSD Foundation)](https://freebsdfoundation.org/netflix-case-study/), ["Netflix and FreeBSD," J. Looney, FOSDEM 2019](https://papers.freebsd.org/2019/fosdem/looney-netflix_and_freebsd/) · on copyleft, user space and distribution: [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html)

### Sony PlayStation: the locked fortress

The genealogy of Sony's consoles is a BSD story. The **PS3** already relied on an internal system (CellOS) **forked from both FreeBSD and NetBSD**. The **PS4** switched entirely to a system named **Orbis OS**, a fork of **FreeBSD 9.0**. The **PS5**, for its part, runs an internal system named **ProsperoOS**, based on **FreeBSD 11**.

A small point of honesty, because it matters: for the PS5, **Sony communicates nothing**. The name "ProsperoOS" and the version "FreeBSD 11" are **deduced by security researchers** who repair and study the console (reverse engineering), not officially confirmed. I flag this all the more readily because one often reads that the PS5 supposedly runs "Orbis OS 2.0" — that is a confusion: *Orbis* is the PS4's code name, *Prospero* the PS5's.

Why FreeBSD for a console? For two reasons that go together: an **industrial-grade, robust x86 OS**, and a **licence that allows everything to be locked down**. Sony closes the essentials — graphics drivers co-developed with AMD, the security hypervisor, the user interface — and designs the machine to run only **signed code**, in order to block piracy. Logically, the company gives very little back upstream: the hardware is too specific, and secrecy is part of the security.

> Sources — **PS3**: [PlayStation 3 system software (Wikipedia)](https://en.wikipedia.org/wiki/PlayStation_3_system_software) ("a fork of both FreeBSD and NetBSD") · **PS4**: [PlayStation 4 system software (Wikipedia)](https://en.wikipedia.org/wiki/PlayStation_4_system_software), ["PlayStation 4 runs modified FreeBSD 9.0: Orbis OS" (OSNews)](https://www.osnews.com/story/27145/playstation-4-runs-modified-freebsd-90-orbis-os/) · **PS5**: [PS5 Kernel — FreeBSD 11.0 / `__FreeBSD_version 1100122` (PS5 Developer wiki, reverse engineering)](https://www.psdevwiki.com/ps5/Kernel)

### Apple: the technological Frankenstein

The deepest case is Apple's, and it goes back a long way. In 1985, Steve Jobs left Apple and founded NeXT, whose **NeXTSTEP** system (1989) married a **Mach** kernel with a **4.3BSD** Unix subsystem. When Apple bought NeXT in 1996, it was **NeXTSTEP that became the foundation** of Mac OS X — and therefore, today, of macOS, iOS, watchOS and tvOS.

At the heart of these systems: the **XNU** kernel, called "hybrid." It combines the **Mach** microkernel, a **BSD layer** (derived from 4.3BSD, then enriched with 4.4BSD and **FreeBSD** code: networking, POSIX compatibility, file system) and **IOKit** for drivers. A concrete and amusing consequence: when you type `ls` or `cp` in a Mac's Terminal, you use the **BSD** versions of those commands, not the GNU versions Linux users know.

But Apple above all illustrates another facet of licences. Be careful not to overstate it: Apple **long shipped software under GPLv2** (the GCC compiler, the bash shell…). What it **methodically** refuses is **GPLv3** (published in 2007). Three examples, all at the precise moment the software moved from GPLv2 to GPLv3:

- **The compiler.** Apple long used **GCC**, then froze it at version **4.2.1** — the last one released under GPLv2 — before funding and adopting **Clang/LLVM**, under a permissive licence. On a Mac, typing `gcc` actually launches Clang.
- **The shell.** Apple likewise kept **bash 3.2** (the last version under GPLv2) for years, refusing the later versions that had moved to GPLv3, then made **zsh the default shell** starting with macOS **Catalina (2019)**.
- **Windows file sharing.** When the **Samba** project moved to GPLv3, Apple simply **removed it from macOS** (Lion, 2011) to replace it with its own implementation of the SMB protocol.

And yet — this is where it gets delicious — when Apple **publishes** its own code, it does not choose a permissive licence. The free core of macOS, **Darwin**, is released under the **Apple Public Source License (APSL)**: a licence the FSF recognises as free, but which is **copyleft** and **incompatible with the GPL** — the FSF even compares it to the **AGPL** for a clause requiring you to publish your modifications as soon as you deploy the software externally. In other words, Apple **flees copyleft for the code it consumes**, but **attaches one to the code it distributes**. Proof, if any were needed, that the choice of a licence is not a matter of principle, but of **interest** — depending on whether you are the one taking or the one giving.

Why this constancy in avoiding GPLv3? Because it contains clauses Apple does not want to accept — in particular its obligations on patents and its "anti-tivoization" clause, which [a dedicated article in this series](../04-torvalds-gplv3/) returns to.

> Sources: [Apple's Open Source Roots: The BSD Heritage Behind macOS and iOS (FreeBSD Foundation)](https://freebsdfoundation.org/news-and-events/latest-news/apples-open-source-roots-the-bsd-heritage-behind-macos-and-ios/) · [Darwin (operating system) (Wikipedia)](https://en.wikipedia.org/wiki/Darwin_(operating_system)) · bash → zsh and the GPLv3 reason: ["Why does macOS Catalina use Zsh instead of Bash? Licensing" (The Next Web)](https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing), [zsh, default shell (Apple docs)](https://support.apple.com/en-us/102360) · Samba removed because of GPLv3: [OSNews](https://www.osnews.com/story/24572/apple-ditches-samba-in-favour-of-homegrown-replacement/), [Engadget](https://www.engadget.com/2011-03-24-apple-to-drop-samba-networking-tools-from-lion.html) · APSL: [Apple Public Source License (Wikipedia)](https://en.wikipedia.org/wiki/Apple_Public_Source_License), [FSF classification (GNU licence list)](https://www.gnu.org/licenses/license-list.html#apsl2)

## The nuance: what the giants really give back

The picture would be dishonest if it were purely for the prosecution. Even when the end user is locked in, **the free ecosystem draws real benefits** from the presence of these giants. Three facts, verified:

- **Funding.** Netflix is a **regular financial supporter of the FreeBSD Foundation** (donations and hardware for developers). *(For Apple and Sony, on the other hand, I found no documented direct funding of the FreeBSD Foundation; their major contribution comes from elsewhere — see below.)*
- **LLVM/Clang, the most precious counter-gift.** By refusing GPLv3 for its tools, Apple propelled a brand-new modern compiler: **LLVM/Clang**, today under the **Apache 2.0 licence (with LLVM exceptions)** — originally under a permissive BSD-style licence (NCSA). Apple hired its creator Chris Lattner as early as **2005**; and **Sony is among Clang's contributors**. Yet this compiler now benefits **the whole industry**, including Linux and FreeBSD. A tool born of a refusal of the GPL has become a commons.
- **The shared building blocks.** **WebKit**, Apple's rendering engine, is itself a fork of **KHTML** (the engine of the free KDE project, under LGPL) — and it redefined the modern web (Chrome itself descends from it). **Bonjour/mDNSResponder**, Apple's network service discovery, was published under **Apache 2.0**.

In other words: permissive licences create a circulation, imperfect but real, between the giants and the communities. It would be a caricature to see nothing in it but plunder.

> Sources: [FreeBSD Foundation — Record Growth and Partner Investments (2024)](https://www.globenewswire.com/news-release/2024/05/28/2889125/0/en/FreeBSD-Foundation-Marks-Record-Growth-and-Partner-Investments.html) · [LLVM (Wikipedia)](https://en.wikipedia.org/wiki/LLVM) · [Clang (Wikipedia)](https://en.wikipedia.org/wiki/Clang) · [WebKit (Wikipedia)](https://en.wikipedia.org/wiki/WebKit) · [Bonjour (Wikipedia)](https://en.wikipedia.org/wiki/Bonjour_(software))

## And copyleft?

Permissive licences, as we have seen, let the giants build proprietary products on a free base — while giving back to it, out of self-interest, precious counter-gifts. This is consistent with the philosophy of **open source**: making the best possible software, the most widely reused. The other great family of free licences — **copyleft** (GPL, LGPL, AGPL) — pursues a very different goal: **preventing freedom from being taken back from the user**. This will be the subject of [a forthcoming article in this series](../03-licences-copyleft/), which will start from a case that has become emblematic, **tivoization**, and lead to a conclusion common to both our families of licences.

## Sources and references

- Free and permissive licences — [Definition of free software (GNU)](https://www.gnu.org/philosophy/free-sw.en.html) · [Comparison of open-source licences (OSI)](https://opensource.org/licenses) · [GNU GPL FAQ — copyleft, user space, distribution](https://www.gnu.org/licenses/gpl-faq.html)
- FreeBSD, a complete system, and ZFS — [Apple's Open Source Roots (FreeBSD Foundation)](https://freebsdfoundation.org/news-and-events/latest-news/apples-open-source-roots-the-bsd-heritage-behind-macos-and-ios/)
- Netflix / Open Connect — [Open Connect (Wikipedia)](https://en.wikipedia.org/wiki/Open_Connect) · [Netflix at ~800 Gb/s on FreeBSD (EuroBSDCon 2022)](https://papers.freebsd.org/2022/eurobsdcon/gallatin-the_other_freebsd_optimizations-netflix/) · [Netflix case study (FreeBSD Foundation)](https://freebsdfoundation.org/netflix-case-study/) · ["Netflix and FreeBSD" (FOSDEM 2019)](https://papers.freebsd.org/2019/fosdem/looney-netflix_and_freebsd/)
- Sony PlayStation — **PS3**: [PlayStation 3 system software (Wikipedia)](https://en.wikipedia.org/wiki/PlayStation_3_system_software) · **PS4**: [PS4 system software (Wikipedia)](https://en.wikipedia.org/wiki/PlayStation_4_system_software), [Orbis OS / FreeBSD 9 (OSNews)](https://www.osnews.com/story/27145/playstation-4-runs-modified-freebsd-90-orbis-os/) · **PS5**: [PS5 Kernel (PS5 Developer wiki)](https://www.psdevwiki.com/ps5/Kernel)
- Apple, XNU and the BSD heritage — [Darwin (Wikipedia)](https://en.wikipedia.org/wiki/Darwin_(operating_system)) · [bash → zsh under Catalina, the GPLv3 reason (The Next Web)](https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing) · [zsh, default shell (Apple docs)](https://support.apple.com/en-us/102360)
- Counter-gifts (LLVM, WebKit, Bonjour, funding) — [LLVM (Wikipedia)](https://en.wikipedia.org/wiki/LLVM) · [Clang (Wikipedia)](https://en.wikipedia.org/wiki/Clang) · [Chris Lattner (Wikipedia)](https://en.wikipedia.org/wiki/Chris_Lattner) · [WebKit (Wikipedia)](https://en.wikipedia.org/wiki/WebKit) · [Bonjour (Wikipedia)](https://en.wikipedia.org/wiki/Bonjour_(software)) · [FreeBSD Foundation, 2024 partners](https://www.globenewswire.com/news-release/2024/05/28/2889125/0/en/FreeBSD-Foundation-Marks-Record-Growth-and-Partner-Investments.html)
