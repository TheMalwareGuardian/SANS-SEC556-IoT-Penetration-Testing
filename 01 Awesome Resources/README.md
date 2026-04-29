# ***🏴‍☠️ SEC556 IoT Penetration Testing Awesome Resources***



<p align="center">
	<img src="../Images/Logos/SEC556_Resources.png">
</p>



<p align="center">
	Curated resources to support the SEC556 IoT Penetration Testing course. This section includes videos, blogs, tools, firmware references, and real-world research to help you understand, replicate, and go beyond the labs.
</p>



---
---
---


## Table of Contents

<ul>
	<li><a href="#section1">Section 1 - Introduction to IoT Network Traffic and Web Services</a></li>
<details>
	<summary>📂</summary>
	<ul>
		<li><a href="#section1_topics">Topics</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section1_topic_courseintro">         Course introduction</a></li>
			<li><a href="#section1_topic_iota">                Course methodology for testing IoT</a></li>
			<li><a href="#section1_topic_tooling">             Tooling for IoT Attack Methodology</a></li>
			<li><a href="#section1_topic_networkrecon">        Network discovery and recon</a></li>
			<li><a href="#section1_topic_activediscovery">     Active network discovery</a></li>
			<li><a href="#section1_topic_networkexploitation"> Network exploitation for IoT</a></li>
			<li><a href="#section1_topic_webservices">         Web services in IoT</a></li>
			<li><a href="#section1_topic_webapirecon">         Web and API recon and discovery</a></li>
			<li><a href="#section1_topic_webtools">            Tools for web services</a></li>
			<li><a href="#section1_topic_webattacks">          Web service attack types and exploitation</a></li>
		</ul>
</details>
		<li><a href="#section1_labs">Labs</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section1-lab1-1">   Lab 1.1 - Wireshark filters and PCAP inspection</a></li>
			<li><a href="#section1-lab1-2">   Lab 1.2 - Nmap scan of an IoT device and exploitation with Metasploit</a></li>
			<li><a href="#section1-lab1-3-1"> Lab 1.3 Part 1 - Burp Suite interception on IoT web portal for exposed secrets</a></li>
			<li><a href="#section1-lab1-3-2"> Lab 1.3 Part 2 - Using Postman to send password data to an IoT API</a></li>
			<li><a href="#section1-lab1-4-1"> Lab 1.4 Part 1 - Exploiting an IoT portal for consumer-grade devices</a></li>
			<li><a href="#section1-lab1-4-2"> Lab 1.4 Part 2 - Injecting commands into vulnerable IoT web services</a></li>
		</ul>
</details>
	</ul>
</details>
	<li><a href="#section2">Section 2 - Exploiting IoT Hardware Interfaces and Analyzing Firmware</a></li>
<details>
	<summary>📂</summary>
	<ul>
		<li><a href="#section2_topics">Topics</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section2_topic_background"> Background and importance of IoT hardware</a></li>
			<li><a href="#section2_topic_opening">    Opening the device</a></li>
			<li><a href="#section2_topic_components"> Examining and identifying components</a></li>
			<li><a href="#section2_topic_ports">      Discovering and identifying ports</a></li>
			<li><a href="#section2_topic_soldering">  A soldering primer</a></li>
			<li><a href="#section2_topic_interfaces"> Sniffing, interaction, and exploitation of hardware ports: Serial, SPI, JTAG</a></li>
			<li><a href="#section2_topic_recovery">   Recovering firmware</a></li>
			<li><a href="#section2_topic_analysis">   Firmware analysis</a></li>
			<li><a href="#section2_topic_pillaging">  Pillaging the firmware</a></li>
		</ul>
</details>
		<li><a href="#section2_labs">Labs</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section2-lab2-1">Lab 2.1 - Obtaining and analyzing Specification Sheets</a></li>
			<li><a href="#section2-lab2-2">Lab 2.2 - Sniffing serial and SPI</a></li>
			<li><a href="#section2-lab2-3">Lab 2.3 - Recovering firmware from PCAP</a></li>
			<li><a href="#section2-lab2-4">Lab 2.4 - Recovering filesystems with binwalk</a></li>
			<li><a href="#section2-lab2-5">Lab 2.5 - Pillaging the filesystem</a></li>
		</ul>
</details>
	</ul>
</details>
	<li><a href="#section3">Section 3 - Exploiting Wireless IoT: WiFi, BLE, Zigbee, LoRA, and SDR</a></li>
<details>
	<summary>📂</summary>
	<ul>
		<li><a href="#section3_topics">Topics</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section3_topic_wifi">   WiFi security assessment</a></li>
			<li><a href="#section3_topic_ble">    Bluetooth Low Energy vulnerabilities</a></li>
			<li><a href="#section3_topic_zigbee"> Zigbee protocol analysis</a></li>
			<li><a href="#section3_topic_lora">   LoRA communication techniques</a></li>
			<li><a href="#section3_topic_sdr">    Software-Defined Radio exploration</a></li>
		</ul>
</details>
		<li><a href="#section3_labs">Labs</a></li>
<details>
	<summary>📂</summary>
		<ul>
			<li><a href="#section3-lab3-1">WiFi network cracking</a></li>
			<li><a href="#section3-lab3-2">Bluetooth Low Energy interaction</a></li>
			<li><a href="#section3-lab3-3">Zigbee traffic analysis</a></li>
			<li><a href="#section3-lab3-4">Wireless replay attacks</a></li>
		</ul>
</details>
	</ul>
</details>
</ul>



---
---
---



<div id='section1'/>

## ***🛰️ Section 1 - Introduction to IoT Network Traffic and Web Services***

<div id='section1_topics'/>

### ***Topics***

<div id='section1_topic_courseintro'/>

#### Course introduction

* [SANS Course: SEC556 - IoT Penetration Testing](https://www.sans.org/cyber-security-courses/iot-penetration-testing) -> EC556 is an IoT hacking course that facilitates examining the entire IoT ecosystem, helping you build the vital skills needed to identify, assess, and exploit basic and complex security mechanisms in IoT devices. This course gives you tools, hands-on techniques, and a strategic framework for comprehensively evaluating IoT device security, exploring vulnerabilities across network layers, firmware, hardware, and application interfaces.
* [Resources: TheMalwareGuardian - SANS Course SEC-556 IoT Penetration Testing](https://github.com/TheMalwareGuardian/SANS-SEC556-IoT-Penetration-Testing)
* [Resources: TheMalwareGuardian - SANS Core NetWars Tournament & Skills Quest by NetWars](https://github.com/TheMalwareGuardian/SANS-Core-NetWars-and-Skills-Quest)

---

<div id='section1_topic_iota'/>

#### Course methodology for testing IoT

* [Methodology: OWASP Internet of Things Project](https://wiki.owasp.org/index.php/OWASP_Internet_of_Things_Project) -> The OWASP Internet of Things Project is designed to help manufacturers, developers, and consumers better understand the security issues associated with the Internet of Things, and to enable users in any context to make better security decisions when building, deploying, or assessing IoT technologies.
* [Methodology: OWASP IoT Security Testing Guide](https://github.com/OWASP/owasp-istg) -> The OWASP IoT Security Testing Guide provides a comprehensive methodology for penetration tests in the IoT field offering flexibility to adapt innovations and developments on the IoT market while still ensuring comparability of test results. The guide provides an understanding of communication between manufacturers and operators of IoT devices as well as penetration testing teams that's facilitated by establishing a common terminology.
* [Methodology: Internet of Things Attack (IoTA) Methodology](https://github.com/haxorthematrix/IoTA) -> This document describes the Internet of Things Assessment (IoTA) Red Team approach to security testing of different IoT devices and architectures. The definition of IoT varies depending on the organization providing the definition. This document will proceed on the basis of the definitions in NIST Special Publication SP800-183. That document is written around the concept of NoTs (Networks of Things) and treats IoTs as "an instantiation of a NoT, more specifically, IoT has its 'things' tethered to the Internet." A NoT is usually composed of five primitives or building blocks, and may have one or more of each primitive.
* [Video: SANS Webcast, I Don't Give One IoTA - Introducing the IoT Attack Methodology](https://www.youtube.com/watch?v=7vFJQlodx3M) -> Attacking and assessing IoT can easily miss the forest for the trees. However we need to be comprehensive in our methodology and not end up down a rabbit hole; we need to know how the wind affects each tree, but also the forest as a whole. We even need to make sure we consider the trailer park adjacent to the forest, which may not be quite as resilient to a tornado. We're here to pass along a methodology for testing all of the components of any end-to end IoT solution; from end user hardware, proprietary and standards-based RF (Zigbee, Zwave, BLE/Bluetooth and all sorts of modulation), Wi-Fi, network protocols, mobile device applications (Android and iOS), internet-connected servers, web applications and databases. Come learn how to build a testing lab, investigate some testing tools, and how to apply to a real world test.

---

<div id='section1_topic_tooling'/>

#### Tooling for IoT Attack Methodology

* [Hardware: HackRF One](https://greatscottgadgets.com/hackrf/) -> SDR tool widely used for RF analysis across multiple IoT protocols (Zigbee, BLE, LoRa, etc.).
* [Hardware: Bus Pirate](https://buspirate.com/) -> Multi-protocol hardware tool for interacting with embedded systems (SPI, I2C, UART, JTAG).
* [Hardware: Panda USB Adapter](https://www.pandawireless.com/) -> USB Wi-Fi adapter (802.11ac and below) commonly used in IoT assessments.
* [Hardware: TP-Link UB400 Bluetooth Adapter](https://www.tp-link.com/) -> Low-cost Bluetooth adapter for BLE testing and interaction.
* [Hardware: CC2531 USB Dongle](https://www.ti.com/product/CC2531) -> Zigbee sniffer widely used for traffic capture and protocol analysis.
* [Hardware: Raspberry Pi](https://www.raspberrypi.org/) -> Flexible platform for building IoT labs, rogue devices, and testing environments.
* [Virtual Machine: SANS Slingshot VM (Community Edition & C2 Matrix)](https://www.sans.org/tools/slingshot) -> IoT-focused reconnaissance and testing platform used during SEC556.

---

<div id='section1_topic_networkrecon'/>

#### Network discovery and recon

* [Tool: Wireshark](https://www.wireshark.org/) -> Network protocol analyzer for packet inspection and traffic analysis.
* [Tool: TShark](https://www.wireshark.org/docs/man-pages/tshark.html) -> Command-line version of Wireshark for automated packet capture and analysis.
* [Tool: tcpdump](https://www.tcpdump.org/) -> Lightweight packet capture tool for network traffic analysis.
* [Tool: Mosquitto](https://mosquitto.org/) -> MQTT broker used to simulate and interact with IoT messaging protocols.
* [Tool: dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) -> Lightweight DNS/DHCP server useful for local network simulation and IoT lab environments.
* [Tool: Shodan](https://www.shodan.io/) -> Search engine for exposed IoT devices and services.
* [Tool: Censys](https://search.censys.io/) -> Internet-wide scanning and asset discovery platform.

---

<div id='section1_topic_activediscovery'/>

#### Active network discovery

* [Tool: Nmap](https://nmap.org/) -> Network discovery and security auditing.
* [Tool: Masscan](https://github.com/robertdavidgraham/masscan) -> High-speed port scanner.
* [Tool: RustScan](https://github.com/bee-san/RustScan) -> Fast scanning wrapper.
* [Tool: arp-scan](https://github.com/royhills/arp-scan) -> Local network scanning.

---

<div id='section1_topic_networkexploitation'/>

#### Network exploitation for IoT

* [Exploitation Framework: Metasploit Framework](https://github.com/rapid7/metasploit-framework) -> Exploitation framework with modules covering IoT devices, embedded systems, and network services.
* [Exploitation Framework: Expliot Framework](https://expliot.io/open-source-framework/) -> Open-source IoT exploitation framework focused on device interaction, protocol abuse, and real-world attack scenarios.
* [Exploitation Framework: RouterSploit](https://github.com/threat9/routersploit) -> Exploitation framework focused on routers and embedded devices.
* [Exploit Database: Exploit-DB](https://www.exploit-db.com/) -> Public exploit database for known vulnerabilities and PoCs.
* [Tool: pymodbus](https://github.com/riptideio/pymodbus) -> Python library for interacting with Modbus devices (useful for testing and exploitation).
* [Tool: ICS-Security-Tools](https://github.com/ITI/ICS-Security-Tools) -> Collection of tools for attacking and testing industrial and IoT protocols.
* [Tool: Yet Another BACnet Explorer](https://sourceforge.net/projects/yetanotherbacnetexplorer/) -> Tool for discovering, browsing, and interacting with BACnet devices in building automation and IoT/OT environments.

---

<div id='section1_topic_webservices'/>

#### Web services in IoT

* [Methodology: OWASP API Security Project](https://owasp.org/www-project-api-security/) -> A foundational element of innovation in today's app-driven world is the API. From banks, retail and transportation to IoT, autonomous vehicles and smart cities, APIs are a critical part of modern mobile, SaaS and web applications and can be found in customer-facing, partner-facing and internal applications. By nature, APIs expose application logic and sensitive data such as Personally Identifiable Information (PII) and because of this have increasingly become a target for attackers.

---

<div id='section1_topic_webapirecon'/>

#### Web and API recon and discovery

* [Tool: ffuf](https://github.com/ffuf/ffuf) -> Fast web fuzzing.
* [Tool: dirsearch](https://github.com/maurosoria/dirsearch) -> Directory brute forcing.
* [Tool: gobuster](https://github.com/OJ/gobuster) -> Tool for brute-forcing URIs, DNS, and virtual hosts.
* [Tool: Swagger UI](https://swagger.io/tools/swagger-ui/) -> API documentation interface.

---

<div id='section1_topic_webtools'/>

#### Tools for web services

* [Tool: Burp Suite](https://portswigger.net/burp) -> Web security testing platform for intercepting, modifying, and analyzing HTTP/S traffic.
* [Tool: Caido](https://caido.io/) -> Modern web security testing platform focused on performance and usability.
* [Tool: OWASP ZAP](https://www.zaproxy.org/) -> Open-source web application security scanner and proxy.
* [Tool: mitmproxy](https://mitmproxy.org/) -> Interactive interception proxy for inspecting and modifying network traffic.
* [Tool: Postman](https://www.postman.com/) -> API development and testing tool for sending, modifying, and automating HTTP requests.
* [Tool: Bruno](https://www.usebruno.com/) -> Lightweight and local-first API client for testing and interacting with web services.

---

<div id='section1_topic_webattacks'/>

#### Web service attack types and exploitation

* [Tool: sqlmap](https://github.com/sqlmapproject/sqlmap) -> Automated SQL injection detection and exploitation tool.
* [Tool: Commix](https://github.com/commixproject/commix) -> Automated command injection exploitation tool.
* [Tool: XSStrike](https://github.com/s0md3v/XSStrike) -> Advanced XSS detection and exploitation tool.

---

<div id='section1_labs'/>

### ***Labs***

<div id='section1-lab1-1'/>

#### Lab 1.1 - Wireshark filters and PCAP inspection

* [Video: Top 10 Wireshark Filters](https://www.youtube.com/watch?v=68t07-KOH9Y) -> In this video, we cover the top 10 Wireshark display filters in analyzing network and application problems. Find the packets that matter!
* [Video: Hands-On Traffic Analysis with Wireshark](https://www.youtube.com/watch?v=5PKAa6TI82U) -> TryHackme Room, Wireshark Traffic Analysis.
* [Video: Top 10 Real World Wireshark Filters you need to know](https://www.youtube.com/watch?v=26MAaX2ldnI) -> Chris Greer shares his top 10 Real World Wireshark filters. Learn how to use Wireshark from one of the best in the industry!

---

<div id='section1-lab1-2'/>

#### Lab 1.2 - Nmap scan of an IoT device and exploitation with Metasploit

* [Video: Nmap Tutorial to find Network Vulnerabilities](https://www.youtube.com/watch?v=4t4kBkMsDbQ) -> Learn Nmap to find Network Vulnerabilities.
* [Video: Ethical Hacking Deep Dive, Metasploit, Nmap, and Advanced Techniques](https://www.youtube.com/watch?v=Ft6tLATCIVQ) -> This video is a comprehensive tutorial on leveraging Metasploit in Ethical Hacking. It kicks off with a concise explanation of Metasploit's modules, laying the groundwork for a better understanding of how Metasploit operates. The tutorial seamlessly transitions to the terminal, guiding you through various Nmap scanning techniques-from network reconnaissance to port and service enumeration on selected targets.
* [Video: NMAP Full Guide (You will never ask about NMAP again)](https://www.youtube.com/watch?v=JHAMj2vN2oU) -> NMAP Full Guide.

---

<div id='section1-lab1-3-1'/>

#### Lab 1.3 Part 1 - Burp Suite interception

* [Video: Master Burp Suite Like A Pro In Just 1 Hour](https://www.youtube.com/watch?v=QiNLNDSLuJY) -> One of the most common problems with modern tutorials for tools is that they tend to sound a lot like man-pages or documentation. For instance, they'll tell you all about the little command flags, all the little buttons you can click on; but something that they seem to miss out on is "WHY you would use each of these options?".
* [Video: Burpsuite Basics (FREE Community Edition)](https://www.youtube.com/watch?v=QiNLNDSLuJY) -> Burp Suite Community Edition is a free, essential web application security testing toolkit, featuring a manual HTTP/S proxy, Repeater, Decoder, and Comparer tools. It enables users to intercept and modify traffic, making it ideal for learning, manual penetration testing, and bug bounty hunting.

---

<div id='section1-lab1-3-2'/>

#### Lab 1.3 Part 2 - Postman API interaction

* [Video: Postman Beginner's Course, API Testing](https://www.youtube.com/watch?v=VywxIQ2ZXw4) -> Postman has over 10 million users worldwide. This course will introduce you to Postman and is suited for beginners. You will learn how to build API requests with Postman, how to inspect responses and create workflows.

---

<div id='section1-lab1-4-1'/>

#### Lab 1.4 Part 1 - IoT portal exploitation

* [Video: DEF CON 33 - How a vuln in dealer software could've unlocked your car, E Zveare, R Piyush](https://www.youtube.com/watch?v=U1VKazuvGrc) -> Dealers are a vital part of the automotive industry – intentionally separate entities from the manufacturers, but highly interconnected. Most dealers use platforms built by the manufacturers that can be used to order cars, view/store customer information, and manage their day-to-day operations. Earlier this year, new vulnerabilities were discovered in a top automaker's dealer platform that enabled the creation of a national admin account. This level of access, a privilege reserved for a select few corporate users, opened the door to a wide range of fun exploits.
* [Video: DEF CON 32 - Anyone can hack IoT- Beginner's Guide to Hacking Your First IoT Device, Andrew Bellini](https://www.youtube.com/watch?v=YPcOwKtRuDQ) -> Yes, anyone can hack IoT devices and I'll show you how! It doesn't matter if you're an experienced pen tester in other fields, completely new to cybersecurity or just IoT curious, by the end of this talk you'll have the knowledge to hack your first device. You might be thinking - but I thought IoT was complicated, required knowledge of hardware, and expensive tools. In this talk, I'm here to dispel those myths by directly showing you the methodology, tools and tactics you can use to go and hack an IoT device today (or maybe when you get home). I'll cover what IoT devices are best for beginners, what tools you need (and don't need), how to build a small toolkit for less than $100, common tactics to get a foothold into IoT devices and how to find your first vulnerability or bug.

---

<div id='section1-lab1-4-2'/>

#### Lab 1.4 Part 2 - Command injection

* [Blog: Mirai Botnet exploits CVE-2025-29635 to target legacy D-Link routers](https://securityaffairs.com/191135/malware/mirai-botnet-exploits-cve-2025-29635-to-target-legacy-d-link-routers.html) -> Mirai botnet is targeting old D-Link routers using CVE-2025-29635, a command injection flaw exploitable via crafted POST requests after public PoC disclosure.
* [Blog: Tracking RondoDox, Malware Exploiting Many IoT Vulnerabilities](https://www.f5.com/labs/articles/tracking-rondodox-malware-exploiting-many-iot-vulnerabilities) -> Over a dozen exploits were used to target IoT devices.



---
---
---



<div id='section2'/>

## ***🔧 Section 2 - Exploiting IoT Hardware Interfaces and Analyzing Firmware***

<div id='section2_topics'/>

### ***Topics***

<div id='section2_topic_background'/>

#### Background and importance of IoT hardware

* [Blog: Dark Reading IoT](https://www.darkreading.com/ics-ot-security/iot) -> Industry insights and vulnerabilities affecting IoT ecosystems.
* [Video: IoT & Hardware Hacking for Beginners](https://www.youtube.com/watch?v=j8SqZLr64NA) -> Learn Fundamentals IoT & Hardware Hacking in 9+ Hours.

---

<div id='section2_topic_opening'/>

#### Opening the device

* [Blog: Hardware Hacking Basics](https://www.rtl-sdr.com/) -> Intro to hardware analysis.
* [Blog: Teardown.com](https://www.ifixit.com/Teardown) -> Real-world device teardowns and component analysis.

---

<div id='section2_topic_components'/>

#### Examining and identifying components

* [Tool: Chip Datasheets](https://www.alldatasheet.com/) -> Component lookup.

---

<div id='section2_topic_ports'/>

#### Discovering and identifying ports

* [Playlist: Hardware Hacking Tutorials](https://www.youtube.com/watch?v=LSQf3iuluYo&list=PLoFdAHrZtKkhcd9k8ZcR4th8Q8PNOx7iU) -> Hardware Hacking Tutorial series.
* [Video: Finding UART and Getting a Root Shell on a Linux Router](https://www.youtube.com/watch?v=HWJddAd2T5Q) -> In this video, we will discuss how to find UART debug interfaces on an embedded linux device. We will then leverage UART to get a root shell on the device.

---

<div id='section2_topic_soldering'/>

#### A soldering primer

* [Video: Soldering Tutorial for Beginners](https://www.youtube.com/watch?v=Qps9woUGkvI) -> If you've ever wondered how to solder electronic components, you've come to the right place! This video breaks down soldering technique into five steps. I'll show you how to solder through-hole components as well as how to solder wire.
* [Playlist: Soldering Tutorials](https://www.youtube.com/watch?v=J5Sb21qbpEQ&list=PL2862BF3631A5C1AA) -> Dave takes you through everything you need to know to do good quality soldering.

---

<div id='section2_topic_interfaces'/>

#### Serial, SPI, JTAG

* [Video: Every Hardware Protocol Explained in 6 Minutes](https://www.youtube.com/watch?v=0rlpwVNyBO8) -> Ever wondered how chips and devices actually talk to each other? In this video I break down 6 of the most important hardware communication protocols UART, SPI, I2C, CAN, RS232, and 1-Wire so you can finally understand what's happening inside every circuit board.

---

<div id='section2_topic_recovery'/>

#### Recovering firmware

* [Tool: binwalk](https://github.com/ReFirmLabs/binwalk) -> Firmware Analysis Tool.
* [Tool: ChipWhisperer](https://github.com/newaetech/chipwhisperer) -> The complete open-source toolchain for side-channel power analysis and glitching attacks.

---

<div id='section2_topic_analysis'/>

#### Firmware analysis

* [Tool: FACT](https://github.com/fkie-cad/FACT_core) -> Advanced framework for automated firmware extraction, analysis, and comparison.
* [Tool: EMBA](https://github.com/e-m-b-a/emba) -> The security analyzer for firmware of embedded devices.
* [Tool: Attify Firmware Analysis Toolkit](https://github.com/attify/firmware-analysis-toolkit)

---

<div id='section2_topic_pillaging'/>

#### Pillaging the firmware

* [Tool: Firmware Mod Kit](https://code.google.com/archive/p/firmware-mod-kit/) -> Extract, modify and rebuild embedded Linux firmware images.

---

<div id='section2_labs'/>

### ***Labs***

<div id='section2-lab2-1'/>

#### Lab 2.1 - Specification Sheets

* [Video: How To Reverse Engineer A PCB To Make A Schematic](https://www.youtube.com/watch?v=ch1gqZkMb60) -> So you have a PCB and no Schematic - here one method you can use to reverse engineer a PCB layout.

---

<div id='section2-lab2-2'/>

#### Lab 2.2 - Serial and SPI sniffing

* [Video: Sniffing SPI Flash Signals on a GPS Tracker](https://www.youtube.com/watch?v=aAhT0h8Sujo) -> Digital Signal Analysis for Hardware Hackers.

---

<div id='section2-lab2-3'/>

#### Lab 2.3 - Firmware recovery

* [Video: Chinese IP Camera Firmware Extraction](https://www.youtube.com/watch?v=Su4MTlgDfzI) -> IoT Pentesting Basics.

---

<div id='section2-lab2-4'/>

#### Lab 2.4 - Filesystem extraction

* [Blog: Reverse engineering my router's firmware with binwalk](https://sergioprado.blog/reverse-engineering-router-firmware-with-binwalk/) -> IoT Pentesting Basics.
* [Video: Mastering UART Communication, Gaining Access & Extracting Firmware on Unknown Boards](https://www.youtube.com/watch?v=s8s3gvZPc0c) -> Welcome to our comprehensive guide on UART (Universal Asynchronous Receiver-Transmitter) communication, where we delve into the intriguing world of hardware hacking and reverse engineering. In this tutorial, we embark on a journey to uncover the secrets of unknown boards, focusing on identifying and tapping into UART ports to gain unparalleled access to device functionalities.

---

<div id='section2-lab2-5'/>

#### Lab 2.5 - Filesystem pillaging

* [Video: Persistent Root Shell via IoT Firmware Modification](https://www.youtube.com/watch?v=m3iXNUa-OA8) -> Rooting a TP-Link Security Camera.

---
---
---



<div id='section3'/>

## ***📡 Section 3 - Exploiting Wireless IoT: WiFi, BLE, Zigbee, LoRA, and SDR***

<div id='section3_topics'/>

### ***Topics***

<div id='section3_topic_wifi'/>

#### WiFi security assessment

* [Tool: Aircrack-ng](https://www.aircrack-ng.org/) -> Suite for WiFi auditing and password cracking.
* [Tool: Kismet](https://www.kismetwireless.net/) -> Wireless network detector, sniffer, and intrusion detection system.

---

<div id='section3_topic_ble'/>

#### Bluetooth Low Energy vulnerabilities

* [Tool: Bettercap](https://github.com/bettercap/bettercap) -> BLE scanning, spoofing and MITM.
* [Tool: Ubertooth](https://github.com/greatscottgadgets/ubertooth) -> Bluetooth sniffing platform.

---

<div id='section3_topic_zigbee'/>

#### Zigbee protocol analysis

* [Tool: KillerBee](https://github.com/riverloopsec/killerbee) -> Zigbee sniffing and attack framework.
* [Tool: ApiMotev4](https://github.com/riverloopsec/apimote) -> The ApiMote v4beta version is beta hardware intended for researchers, students, utility companies, etc. to use for learning about and evaluating the security of IEEE 802.15.4/ZigBee systems as authorized.
* [Tool: Zigbee2MQTT](https://www.zigbee2mqtt.io/) -> Interact with Zigbee devices via MQTT (great for lab environments).

---

<div id='section3_topic_lora'/>

#### LoRA communication techniques

* [Tool: ChirpStack](https://github.com/chirpstack/chirpstack) -> Open-source LoRaWAN network server.

---

<div id='section3_topic_sdr'/>

#### Software-Defined Radio exploration

* [Tool: GNU Radio](https://www.gnuradio.org/) -> SDR signal processing toolkit.
* [Tool: SDR# (SDRSharp)](https://airspy.com/download/) -> SDR receiver software.

---

<div id='section3_labs'/>

### ***Labs***

<div id='section3-lab3-1'/>

#### WiFi network cracking

* [Video: Cracking WiFi WPA2 Handshake](https://www.youtube.com/watch?v=WfYxrLaqlN8) -> Full process using Kali Linux to crack WiFi passwords. I discuss network adapters, airmon-ng, airodump-ng, aircrack-ng and more in this video.

---

<div id='section3-lab3-2'/>

#### Bluetooth Low Energy interaction

* [Video: Bluetooth Hacking Is Easier Than You Thin](https://www.youtube.com/watch?v=yQaq40rfIBg) -> Bluetooth hacking is real - and way easier than you think. In this video, Yaniv teams up with OTW, wireless hacking expert, to demonstrate how hackers can exploit Bluetooth signals to target your devices: headphones, watches, speakers, even cars.
* [Video: Hardwear.io USA 2019 - Bluetooth Hacking, Tools And Techniques, Mike Ryan](https://www.youtube.com/watch?v=8kXbu2Htteg) -> This talk by Mike Ryan described how to reverse engineer Bluetooth data on a variety of devices including a heart monitor, a padlock, a music listening device, a Bluetooth credit card, and a Bluetooth-controlled skateboard. Although the techniques depended on physical access to the device (attacks that did not have this access would require a protocol sniffer), it was an exciting demonstration of how to extract Bluetooth data from the device before it goes out to the air. And that said, the threat model for some Bluetooth devices (such as that credit card) should assume that someone will be handling those devices out of your sight.

---

<div id='section3-lab3-3'/>

#### Zigbee traffic analysis

* [Video: BlackHat USA 2015 - ZigBee Exploited The Good, The Bad, And The Ugly](https://www.youtube.com/watch?v=9xzXp-zPkjU) -> ZigBee is one of the most widespread communication standards used in the Internet of Things and especially in the area of smart homes. If you have, for example, a smart light bulb at home, the chance is very high that you are actually using ZigBee. Popular lighting applications, such as Philips Hue or Osram Lightify are based on this standard. Usually, IoT devices have very limited processing and energy resources, and therefore not capable of implementing well-known communication standards, such as Wifi. ZigBee is, however, an open, publicly available alternative that enables wireless communication for such devices

---

<div id='section3-lab3-4'/>

#### Wireless replay attacks

* [Playlist: Software Defined Radio with HackRF by Michael Ossmann](https://www.youtube.com/watch?v=BeeSN14JUYU&list=PLu0BPYzTjiHru1KmPThmbY-8rRm3EWvUQ) -> HackRF training series by Michael Ossmann of Great Scott Gadgets.
