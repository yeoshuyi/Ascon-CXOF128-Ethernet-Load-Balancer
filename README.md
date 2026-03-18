# Ascon-CXOF128 Ethernet Load Balancer targeting 25GbE SmartNIC
![Static Badge](https://img.shields.io/badge/Ascon_Core_Integration-WIP-brightgreen?style=flat)

> *This is currently a proof-of-concept project, not meant for commercial deployment.*

GitHub Repository: https://github.com/yeoshuyi/Ascon-CXOF128-Ethernet-Load-Balancer

NIST Specification: https://csrc.nist.gov/pubs/sp/800/232/final

## Highlights

* Ascon-CXOF128 core with 13-cycle deterministic latency @ 125Mhz.
* Scalable to meet 25GbE line rate hashing of Ethernet 5-tuple.

## Introduction

Ascon-CXOF128 SystemVerilog implementation for hardware accelerated Ethernet 5-tuple hashing, used for HashDos protected packet load balancing. The NIST XOF128 specification allows for user-defined digest length, which makes it suitable to produce 64bit digest tags to route Ethernet packages downstream. The customizable variant (CXOF128) allows for the integration of a secret key, which helps to prevent offline-calculated HashDos attempts through an epoch-based secret key rotation.

The Ascon-CXOF128 cores is built to be scalable to different Ethernet line rates, with a round-robbin like arbiter to distribute packets to each core. The digest from each Ascon core is queued to a single digest buffer, and used to distribute load between downstream logic.

This specific implementation targets a 125MHz Frequency (Common for SmartNIC logic layer), on a Kintex Ultrascale+ architecture. The specific evaluation board used is the AS02MC04 board with 2x SFP28 ports.

## Documentation

### Block Diagram
> WIP.

### RTL Modules
> WIP.

## Testing
Running the testbench requires cocotb and Icarus Verilog via Makefile.

## Publication
> Hopefully haha.