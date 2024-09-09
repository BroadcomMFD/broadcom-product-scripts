# Broadcom ACF2 SDSF Scripts
The SDACFUID and SDACFROL REXX scripts will process the output from IBM SDSF conversion utility ISFACR into ACF2 Commands, placing the output into a dataset, allowing scrolling (PF7/8), review, and editing as needed.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:
1. For UID Implementations: SDACFUID - SDACFUID REXX example code.  SDACFUID will process the output from IBM SDSF conversion utility ISFACR into ACF2 Commands with UID, placing the output into a dataset, allowing scrolling (PF7/8), review, and editing as needed.

    a.	Complete the ISFACR utility.
    b.	Take the output file into SDACFUID by executing:  SDACFUID file_name
    c.	Review the output and make desired changes before executing via a batch job. 

2. SDACFROL - SDACFROL REXX example code.  SDACFROL will process the output from IBM SDSF conversion utility ISFACR into ACF2 Commands with ROLE, placing the output into a dataset, allowing scrolling (PF7/8), review, and editing as needed.

    a.	Complete the ISFACR utility.
    b.	Take the output file into SDACFROL by executing:  SDACFROL file_name
    c.	Review the output and make desired changes before executing via a batch job.

# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
