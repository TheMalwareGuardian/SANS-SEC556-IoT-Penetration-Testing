# ***🧪 Day 1***

## ***📡 Introduction to IoT Network Traffic and Web Services***

To get into the right mindset before tackling the official Day 1 labs, approach this exercise as if you were performing a real IoT security assessment.

---

### ***🧠 Scenario***

You are an IoT penetration tester assigned to assess a target environment.

However, your access is limited:
- You have no credentials.
- You have no direct access to devices.
- You have no internal documentation.

You are simply placed somewhere within the network, knowing that IoT devices are actively communicating nearby.

---

### ***🌐 Initial Position***

From this position, you decide to perform a network-based attack to intercept communications.

You place yourself in a position where devices believe you are part of the network infrastructure, effectively acting as an intermediary, allowing you to capture their traffic.

As a result, you obtain a PCAP containing communications from multiple IoT devices.

---

### ***🔍 What You Have***

Within this traffic, there may already be sensitive information:
- Credentials
- Encryption keys
- API interactions

These could be used by devices to authenticate, encrypt data, and communicate with backend services.

---

### ***🎯 Objective***

Your goal is not to "solve" a challenge, but to think through the scenario:

> You have a packet capture. Now what?

---

### ***🧩 Things to Consider***

- Identify the protocols in use.
- Extract credentials or sensitive data.
- Reuse any discovered credentials in other contexts.
- Understand how devices interact with external services.

For example:
- A device may connect to an HTTP service or a messaging protocol.
- Credentials might be reused across different endpoints.
- APIs may be exposed and interactable.

---

### ***⚡ From Observation to Interaction***

Once you identify how devices communicate:

- What services are exposed?
- What kind of requests are being made?
- Can those requests be replicated or modified?
- What happens if you abuse those API interactions?

Think in terms of moving from passive observation -> active interaction.

---

### ***🛠️ Tools You Can Use***

- Wireshark
- Burp Suite
- tcpdump / tshark

You don't need to build your own lab. You can use publicly available PCAP datasets, including IoT-related traffic.

---

### ***📂 Public PCAP Sources***

To carry out this exercise in practice, you can use publicly available PCAP datasets instead of building your own lab. Some recommended sources include:

- [IoT-23 Dataset](https://www.stratosphereips.org/datasets-iot23)
- [Malware Traffic Analysis](https://www.malware-traffic-analysis.net)
- [Netresec PCAP Collection](https://www.netresec.com/?page=PcapFiles)
- [Wireshark Sample Captures](https://wiki.wireshark.org/samplecaptures)

---

### ***🧠 Key Idea***

The important part is not the dataset, it's the way you approach it.

If you go through this exercise properly, even at a conceptual level, you will already have a strong foundation for the Day 1 labs.
