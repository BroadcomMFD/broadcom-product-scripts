# Broadcom TSS Scripts
This repository houses sample scripts for use cases involving Broadcom Products.

# Using
Sample scripts for each product are located in the directory that shares its name. For example, TSS samples are in the subsequent child directories. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

# Folders
1. LISTNAME - LISTNAME REXX example code.  LISTNAME REXX provides the capability to list all ACIDS a specific profile is attached to or all ACIDs with a specific Group, the REXX then obtain the name assigned to each ACID and provides a complete list of ACID/Names in a single file output, then places the user into ISPF Edit mode to allow them to copy/paste the data, create a dataset, scroll using PF7/8, search, etc.

2. CHECKSTC—CHECKSTC REXX example code. CHECKSTC will help you review and validate the STC entries, identifying STC table entries that are defined with an ACID that no longer exists. Additionally, it builds all the TSS commands to remove those STC entries, places the output into a temp dataset, and puts you into ISPF edit mode, where you can copy batch TSS JCL and submit to clean up those entries.

# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
