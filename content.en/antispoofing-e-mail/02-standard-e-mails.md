---
title: "Standard email addresses - 2/9"
description: "Configuring the standard email addresses (postmaster, abuse, hostmaster...) required by the RFCs to ensure the interoperability and security of your domain."
weight: 2
---

{{< toc >}}

The anti-spoofing protocols we will cover in the following articles are the walls of your fortress, and the standard email addresses are the guard posts. If you build the walls (SPF/DKIM) but there is no one in the guard posts (postmaster/abuse) to hear the alarms, your security will eventually be bypassed or degraded without your knowing it. Let's start by configuring the standard email addresses.

Creating certain mailboxes is a technical requirement defined by the Internet standards (**RFCs**). These addresses, known as **"Role-Based Email Addresses"**, ensure interoperability and security.

## 💡 In short, for a typical domain (email and website)
Create the following aliases (redirected to your administration address) in order to be compliant:
- `abuse@`
- `admin@`
- `administrator@`
- `hostmaster@`
- `postmaster@`
- `root@`
- `security@`
- `webmaster@`

These addresses make it possible to set up feedback loops (FBL, Feedback Loop).

**⚠️ A point of attention regarding redirections:**
The final destination address should ideally be hosted on the same domain. If you redirect these aliases to an external mailbox (e.g. Gmail), the **SPF** mechanism will often fail (because [SPF does not survive redirection](/en/antispoofing-e-mail/04-spf-sender-policy-framework/#spf-does-not-survive-email-forwarding)). In that case, only **DKIM** will be able to prove the authenticity of the forwarded email.

## Detailed explanation

### 1. The Essentials (Technical Requirement)

These addresses are critical. If they do not exist, you risk being blocked by other servers or missing security alerts.

#### **`abuse@`**
* **Function:** Receiving complaints (spam, phishing). Used by ISPs and blacklists to report a problem originating from your domain.
* **Reference:**
    * **[RFC 2142](https://www.ietf.org/rfc/rfc2142.txt) (Section 4):** Defines `abuse` as the standard for abusive behavior.

#### **`postmaster@`**
* **Function:** Receiving delivery errors and technical requests between administrators.
* **Reference:**
    * **[RFC 5321](https://www.ietf.org/rfc/rfc5321.txt) (Section 4.5.1):** "Any SMTP system [...] MUST support the reserved mailbox 'postmaster'."
    * **[RFC 5321](https://www.ietf.org/rfc/rfc822.txt):** Historical standard.

---

### 2. Service Standards ([RFC 2142](https://www.ietf.org/rfc/rfc2142.txt))

[RFC 2142](https://www.ietf.org/rfc/rfc2142.txt) standardizes the contacts so that you do not have to guess the address of the person responsible for a service.

| Address | Service | Function / Rationale ([RFC 2142](https://www.ietf.org/rfc/rfc2142.txt)) |
| :--- | :--- | :--- |
| **`webmaster@`** | HTTP | For issues related to the website (broken links, errors). |
| **`hostmaster@`** | DNS | For issues related to the DNS zones and the domain. |
| **`security@`** | Security | Reporting vulnerabilities (*Responsible Disclosure*, [RFC 9116](https://www.ietf.org/rfc/rfc9116.txt)). |
| **`noc@`** | Network | Infrastructure and connectivity (*Network Operations Center*). Mainly concerns ISPs and network operators. |

---

### 3. SSL/TLS Validation (Certificates)

Legacy Certificate Authorities (CAs) such as *DigiCert*, *Sectigo*, *GlobalSign*, *GeoTrust* or *ZeroSSL* use these aliases for email-based validation (known as "Email-based DCV" — Domain Control Validation) of SSL/TLS certificates. The certificate authority sends an email containing a validation code to one of the 5 standard addresses or to the address listed in WHOIS (although WHOIS is often masked by the GDPR today).

* `admin@`
* `administrator@`
* `hostmaster@`
* `postmaster@`
* `webmaster@`

> **Note:** Modern certificate authorities (e.g. Let's Encrypt) rely on the [ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) protocol (validation via an HTTP file or a DNS entry) and therefore no longer use these mailboxes.

Now that your domain has the required mailboxes to receive alerts, we will check whether the technical infrastructure (your server and its IP) is correctly declared. This is the FCrDNS step.
