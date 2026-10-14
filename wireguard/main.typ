#import "@preview/diatypst:0.9.3": *

#set text(font: "Iosevka")

#show: slides.with(
  title: "The WireGuard Protocol",
  subtitle: [how a DS securely communicate? \ 
    #text(size: 10pt)[Distributed Systems and Computing - _Mid Sweden University_ ] \
  ],
  date: datetime.today().display("[day]/[month]/[year]"),
  authors: ("Leonardo Barone"),
  theme: "full",
  layout: "medium",
  ratio: 16/9,
  title-color: rgb(123, 23, 26, 255),
  toc: true,
  footer-title: "The WireGuard Protocol",
  count: "number",
)

#set heading(numbering: none)

#let line-wireguard = line(
  length: 100%, 
  stroke: (
    paint: rgb(123, 23, 26, 255), 
    thickness: 1.5pt, 
    dash: "dashed"
  )
)

= Some history...

== ARPANET

#columns(2)[
  \
  in 1969 ARPA (US Dep. of Defense) developed a method to _link distant computers_ $->$ *ARPANET* 
  - first packet-switching technology
  - limitation: computers within the same network

  \
  so how can I connect devices across different networks?
  
  #colbreak()

  #figure(
    image("imgs/arpanet.png", width: 110%),
    caption: [*ARPANET* logical map #footnote[https://www.computerhistory.org/collections/catalog/102646704/]],
    placement: top,
  )
]

== TCP/IP

#columns(2)[

  #figure(
    image("imgs/tcpip.png", width: 110%),
    caption: [TCP/IP architecture#footnote[https://docs.oracle.com/cd/E18752_01/html/816-4554/ipov-29.html]],
    placement: top
  )
  
  #colbreak()

  \
  in the 1970s *TCP/IP* was created, allowing diverse device connections

  in 1983 ARPANET switched to TCP/IP \
  $->$ birth of *Internet*
  \
  \
  \
  something was missing... #text(size: 15pt, weight: "extrabold")[ENCRYPTION!]
]

== IPSec

- by the mid-1990s
- *IPSec*: #emph[*I*]nternet #emph[*P*]rotocol #emph[*Sec*]urity
- #emph[*suite of protocols*] to provide end2end security by *authenticating* and *encrypting* every IP packet in a data stream
  - (securing connections between devices)
\

- complex and over-engineered:

#align(center)[
  #quote(block: true, attribution: [Linus Torvalds])[
    Maybe the code isn't perfect, but I've skimmed it, and compared to the horrors that are OpenVPN and IPSec, it's a work of art. #footnote[while talking about *WireGuard*, we'll get into that later. @torvalds2018wireguard]
  ]
]

// or just put again: "== IPSec" ??
#pagebreak()

#columns(2)[
  #figure(
    image("imgs/ipsec-arch.jpg", width: 95%),
    caption: [IPSec architecture#footnote[https://www.geeksforgeeks.org/computer-networks/ipsec-architecture/]],
    placement: top

  )

  #colbreak()

  \
  - *ESP* : _Encapsulating Security Payload_, \ provides confidentiality, authentication, and integrity for IP packets. @rfc1827
  - *AH* : _Authentication Header_, \ authenticates the IP packet (including parts of the IP header). @rfc1826
  - *IKE* : _Internet Key Exchange_, \ manages the negotiation and setup of security associations between endpoints, automating the exchange of keys and parameters that AH and ESP use. @rfc2409

]

== PPTP

#columns(2)[

  \
  \
  - Point-to-Point Tunneling Protocol
  \
  - in 1996, the *birth* of *VPNs*
  \
  - *virtual tunnel* that allowed data to travel over the public internet as if it were on a private line
  \
  #colbreak()
 
  #figure(
    image("imgs/pptp.webp", width: 100%),
    caption: [PPTP architecture #footnote[https://www.geeksforgeeks.org/computer-networks/pptp-full-form/]],
    placement: bottom
  )
]

too vulnerable! (RC4, MS-CHAP, Snowden revelations..)

== OpenVPN

\
- first major *open-source VPN* protocol (2001)
- the most used between 2005-2020
- both TCP && UDP modes
- SSL/TSL for key exchange (instead of kernel-level IPSec modules) @openvpn_overview

#columns(2)[
  
  \  
  \
  highly flexible and *secure*, but easy to misconfigure, and its user-space architecture introduces *performance overhead*

  #colbreak()

]

== OpenVPN

\
- first major *open-source VPN* protocol (2001)
- the most used between 2005-2020
- both TCP && UDP modes
- SSL/TSL for key exchange (instead of kernel-level IPSec modules) @openvpn_overview

#columns(2)[
  
  \  
  \
  highly flexible and *secure*, but easy to misconfigure, and its user-space architecture introduces *performance overhead*

  #colbreak()

  #figure(
    image("imgs/openvpn_meme.jpg", width: 90%),
    placement: bottom
  )

]

= The WireGuard Protocol

== What is WireGuard?
#align(center + horizon)[
  #box(align(left)[
    "WireGuard® is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography. 
    It aims to be faster, simpler, leaner, and more useful than IPsec, while avoiding the massive headache. 
    It intends to be considerably more performant than OpenVPN"#footnote[from #link("www.wireguard.com")]])
]

#pagebreak()

\
\
\
again..
#align(center)[
  #quote(block: true, attribution: [Linus Torvalds])[
    Maybe the code isn't perfect, but I've skimmed it, and compared to the horrors that are OpenVPN and IPSec, it's a work of art. #footnote[@torvalds2018wireguard]
  ]
]




== WireGuard Simplicity

#columns(2)[

  \
  \
  #align(center)[
    #text(size: 14pt)[*SIMPLE*]
  ]
  \
  - \< 7000 lines of code#footnote[it was $approx$4000 lines]
  - _fixed_ set of cryptographic primitives
  - IP packets incapsulated only in *UDP*
  - minimal configuration

  #colbreak()

  #figure(
    image("imgs/wireguard-loc.jpg", width: 130%),
    caption: [WireGuard LoC #footnote[https://nordvpn.com/blog/wireguard-simplicity-efficiency/]],
    placement: bottom
  )

]

== Configuration

#columns(2)[

  \
  \
  It's a secure network tunnel at *layer 3*, implemented as a kernel virtual interface

  \
  \
  - peers identified by a *public key*
  - keys exchanged out of band like SSH #footnote[@donenfeld2017wireguard]

  
  #colbreak()

  \
  \
  *configuration*:\
  interface private key + list of peers (public key, allowed IPs, optional endpoint)
  ```sh
  $ ip link add dev wg0 type wireguard
  $ ip address add dev wg0 10.192.122.3/24
  $ wg setconf wg0 configuration-1.conf
  $ ip link set wg0 up
  $ ping 10.10.10.230
  ```

]

== WireGuard Security
\
\
#align(center)[
  #text(size: 14pt)[*SECURE*]
  \
  \
    #box(align(left)[
    - #emph[*fixed*] *state-of-the-art* cryptography
    - default configuration does not store persistent user data
    - small codebase $->$ *simple auditing*
    - minimal attack surface
])
]
\


// or "== cryptographic primitives"
#pagebreak()

#columns(2)[
  \
  \
  #text(size: 12pt)[
  - *ChaCha20* and *Poly1305* for AEAD
  - *Curve25519* for ECDH \
    (with ephemeral keys guarantees PFS)
  - *BLAKE2s* for hashing
  - *HKDF* for key derivation
  ]
  \
  all packets sent over #emph[*UDP*]

  #colbreak()

  #figure(
    image("imgs/chacha20.png", width: 110%),
    caption: [ChaCha20 #footnote[https://proton.me/learn/encryption/glossary/chacha20]],
    placement: top,
  )
]

== Cryptokey Routing

\
WireGuard central idea

#columns(2)[

  #table(
    columns: 2,
    [*Peer pub.key*], [*Allowed IPs*],
    [`xTIB...p8Dg`], [`10.192.122.3/32`, `10.192.124.0/24`],
    [`TrMv...WXX0`], [`10.192.122.4/32`, `192.168.0.0/16`],
    [`gN65...z6EA`], [`10.10.10.230/32`],
  )

  #colbreak()

  - peers identified by their *public key*
    - each key has a list of *allowed IPs*
  
  #line-wireguard
  
  - for *sending*, the destination IP selects the peer, and that key encrypts the packet
  - for *receiving*, after decrypting the packet source IP must map back to the same peer, otherwise dropped

]


== Send-Receive flow

#columns(2)[

  \
  \
  #align(center)[
  *Sending*
  ]

  + plaintext packet reaches `wg0`
  + destination IP $->$ peer
  + encrypt with the session key and nonce counter (ChaCha20-Poly1305)
  + prepend the WireGuard header
  + send as UDP to the peer's endpoint

  #colbreak()

  \
  \
  #align(center)[
    *Receiving*
  ]

  + UDP packet arrives on the listen port
  + header $->$ session, check counter, authenticate and decrypt
  + update the peer's endpoint from the outer source IP (for *roaming*)
  + inner source IP must route to _this_ peer
  + insert into the `wg0` receive queue

]


== Handshake

#columns(2)[

  #align(center)[how it works?]
  \
  - *1-RTT* key exchange, Noise *IK* pattern
  - either peer can initiate (*symmetric*)
  - each side picks a random 32-bit index to tie replies to the session
  - *key confirmation:* the responder may send data only after receiving the first data packet from the initiator

  #colbreak()

  #align(center)[what it guarantees?]
  \
  - to prove identity and create *session keys*
  - *replay resistance* (timestamp in the first message)
  - *PFS*: fresh ephemeral keys for every session, changed every $approx$2min.
  - *DoS resistance*: handshake needs Curve25519 multiplication, so with load the responder asks the senders to prove their IP w/ a cookie

]


== Performance
#text(size: 13pt)[
  \
  \
  \
  #table(
    align: center,
    columns: (auto, 1fr, auto, auto),
    [*Protocol*], [*Cipher setup*], [*Mbit/s*], [*Ping (ms)*],
    [WireGuard], [ChaCha20, Poly1305], [1,011], [0.403],
    [IPsec], [AES-256, GCM], [881], [0.508],
    [OpenVPN], [AES-256, HMAC-SHA2-256, UDP], [258], [1.541],
  )
]@donenfeld2017wireguard

= References

== References

#bibliography("refs.bib", style: "ieee")

== #none

#align(center + horizon)[
  #text(size: 2em, weight: "bold")[
    Thank you for the attention :)
  ]
  
  #line-wireguard
  #v(1em)
  
  #text(font: "Iosevka Fixed Extended", size: 13pt, weight: "extrabold", "Leonardo Barone") \
  _Mid Sweden University_ $and$ _University of Bologna_

  #box(align(left)[
    - #link("leonardobarone.com")
    - #link("github.com/leonardonzio")
    - _leonardo.barone3\@studio.unibo.it_
  ])
]



