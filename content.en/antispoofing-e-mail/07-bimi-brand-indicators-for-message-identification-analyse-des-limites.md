---
title: "BIMI and an analysis of its limits - 7/9"
description: "A technical analysis of the BIMI protocol (Brand Indicators for Message Identification): certified logo display, VMC certificate, and the security limits over IMAP."
weight: 7
---

{{< toc >}}

In the email security ecosystem, **BIMI (Brand Indicators for Message Identification)** is often presented as the logical next step after achieving DMARC compliance. The goal is to allow a certified logo to be displayed in email clients in order to reinforce visual trust.

However, an in-depth technical analysis reveals that this protocol is more complex than it appears. Unlike SPF or DKIM, which are purely declarative, BIMI generally relies on a trusted third party through a digital certificate called a VMC (Verified Mark Certificate). While this mechanism works in integrated environments (such as the Google or Yahoo webmails), it runs into major structural obstacles as soon as it is confronted with the open, standardized architecture of email.

Here is an analysis of the three main obstacles that make adopting BIMI complex, or even risky, for the open Internet.

## The security risk: the vulnerability of the decoupled architecture
The main technical obstacle to a widespread implementation of BIMI lies in the separation of roles between the server and the client.

In the BIMI specification, the burden of verification falls on the MTA (Mail Transfer Agent — the receiving server). It is the MTA that must validate the VMC certificate, check DMARC alignment and, if successful, add or regenerate specific headers (e.g. `BIMI-Location` or `Authentication-Results`) to tell the client that the logo can be displayed.

**The problem of transmitting trust via IMAP:** This architecture assumes an unbroken chain of trust. Yet, for universal email clients (MUAs) such as **Thunderbird** or **Outlook** (in IMAP mode), this chain is broken. The IMAP protocol, in its current standardization, does not allow the client to know with certainty who wrote the BIMI header:
1. Is it the server (MTA) that legitimately validated the message and inserted the header?
2. Or is it a malicious sender who injected a fake BIMI-Location header before sending?

Without a strict extension of the IMAP protocol that would allow the server to sign its authentication results or to guarantee to the client that it has "cleaned" the incoming headers, the mail client is unable to distinguish a genuine logo from a sophisticated phishing attempt.

It is for this precise technical reason that the developers of **Mozilla Thunderbird** [refuse to implement BIMI as it stands](https://bugzilla.mozilla.org/show_bug.cgi?id=1670078), considering it insecure for an open architecture. For its part, **Microsoft** has worked around the problem for Outlook by ignoring BIMI in favor of a centralized proprietary solution, not trusting the headers that transit through the mail.

For this to be secure, the specification requires the MTA to **strip** all incoming BIMI headers before performing its own checks and adding its own header.

### Detailed scenario
1. **The role of the server (MTA) in the BIMI specification:** In the BIMI specification, it is the receiving server that does the heavy lifting. It must:
1.1 Check DMARC.
1.2 Retrieve the VMC certificate (Verified Mark Certificate).
1.3 Validate the certification chain of the logo.
1.4 Once all this is validated, it adds a specific header to the email (e.g. `Authentication-Results` or `BIMI-Location`) to tell the client: "It's OK, I've checked, you can display this logo."
2. **The attack scenario:** Imagine an attacker sends you a phishing email claiming to come from your bank.
  2.1 **The attack:** The attacker manually injects the following header into their fraudulent email before sending it: `Authentication-Results: bimi=pass; header.d=mabanque.com;`
  2.2 **The intermediate server (non-BIMI):** Your email arrives on a conventional mail server (e.g. an old corporate Postfix server, or an ISP that has not yet implemented BIMI).
    - This server does not know about BIMI.
	- It may check SPF/DKIM, but it **ignores** the forged BIMI header.
	- Above all, **it does not remove it**, because it does not know that this header is sensitive. It passes the mail along as-is to Thunderbird.
  2.3 **Receiving in Thunderbird:** Thunderbird fetches the mail over IMAP. It sees the header `Authentication-Results: bimi=pass`.
3. **The dilemma for Thunderbird (and for all universal MUAs)**
Thunderbird connects to any IMAP server in the world. When it sees this "bimi=pass" header, it has two possibilities:
  3.1 **Possibility A:** The server is BIMI-compatible. It received the mail, removed the fake headers, performed the verification, and applied this seal of trust. **(Legitimate)**
  3.2 **Possibility B:** The server is "dumb" (non-BIMI). It simply let through the header forged by the attacker. **(Phishing)**
   **Thunderbird has no technical means of knowing whether it is in situation A or B.**
   There is (currently) no standardized IMAP command (e.g. `CAPABILITY BIMI`) that would allow the server to tell Thunderbird: "Hey, I handle BIMI, you can trust my headers, I have cleaned out the fake ones."
4. **Why don't Gmail or Yahoo have this problem?** The Gmail app on Android or the Yahoo Mail web interface know full well that they are talking to Google's or Yahoo's servers. The Gmail interface code "knows" that the Gmail server cleans the headers. The trust is implicit because the client and the server belong to the same entity. Thunderbird, as a universal client, cannot grant this blind trust to every IMAP server on the planet.

If Thunderbird implemented BIMI today based simply on the presence of the headers, an attacker could display the official logo of "PayPal" or "Crédit Agricole" on a phishing email simply by adding a line of text to the mail's header, as long as your mail server does not actively filter these tags.

For Thunderbird to be able to implement it safely, one of the following would be required:
1. That Thunderbird itself perform the entire BIMI validation (which is heavy: retrieving VMC certificates, crypto validation, etc., on the client side).
2. That an extension to the IMAP protocol be created to certify that the upstream server is "BIMI-Aware".

### An economic barrier to entry (VMC)
Unlike the fundamental email protocols (SMTP, SPF, DKIM, DMARC), which are based on technical competence and freely available to anyone who owns a domain name, BIMI introduces a financial barrier through the **VMC (Verified Mark Certificate)**.

To comply with the specification (as required by Google or Apple), the domain must acquire a certificate from a third-party certificate authority. This cost, in the region of **€1,200 to €1,500 per year**, is admittedly affordable for a small business, a mid-sized company or a large enterprise treating it as a marketing expense.

However, this business model de facto excludes a significant share of Internet players:
- **Micro and very small businesses**, for whom this cost is prohibitive.
- The **nonprofit and voluntary sector** (apart from large NGOs).
- **Individuals**, independent developers and free-software communities.

By tying visual security to the ability to pay and to owning a registered trademark, BIMI moves away from the philosophy of net neutrality, where a sender's technical legitimacy (proven by DMARC) should be enough, regardless of its financial power.

## Conclusion
BIMI raises an interesting question about the evolution of Internet standards. While the intent to provide visual validation is commendable, its current implementation poses a security problem for universal mail clients and introduces economic discrimination.

For now, the most robust technical recommendation remains the strict application of open standards: **SPF, DKIM and DMARC (`p=reject` or `p=quarantine` on 100% of mail)**. These protocols guarantee the security and deliverability of the message for everyone, without depending on a paid certification chain or a proprietary client-server architecture.
