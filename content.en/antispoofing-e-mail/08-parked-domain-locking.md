---
title: "Parked Domain Locking - 8/9"
description: "DNS configuration to lock down a domain that does not send email: SPF -all, DMARC reject, DKIM with an empty key, and Null MX (RFC 7505)."
weight: 8
---

A domain that sends no email at all must still configure SPF, DKIM and DMARC in order to declare: "This domain never sends email. If you receive one, discard it immediately." This is essential to protect against spoofing: attackers could use "dormant" domains or variations of your domain (typosquatting) to send phishing, since no one is watching them.

Here is the DNS configuration to apply:

| Type | Host / Name | Value | Role |
| --- | --- | --- | --- |
| TXT | @   | v=spf1 -all | SPF  <br>(Declares that no one is authorized to send email on behalf of the domain) |
| TXT | \_dmarc | v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; | DMARC (Asks the recipient to reject any email that claims to come from the domain) |
| TXT | \*.\_domainkey | v=DKIM1; p= | DKIM (Invalidates all keys) |
| MX  | @   | . (Priority 0) | MX (this domain does not receive email [RFC 7505](https://www.rfc-editor.org/rfc/rfc7505) (Null MX)) |
