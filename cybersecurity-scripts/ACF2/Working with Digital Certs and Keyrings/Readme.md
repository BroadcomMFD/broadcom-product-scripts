# Broadcom ACF2 REXX Script for Roles

LSTCERTS – ACF2 List All Digital Certificates - A single-line command to list all Digital Certificates into a temp dataset to allow you search, scroll, and review.
LSTRINGS - ACF2 List All Keyrings - A single-line command to list all Keyrings into a temp dataset to allow you search, scroll, and review.
CERTRPT - ACF2 Interactive SAFCRRPT - Full list of all Digital Certs and Trusted CA Certificate Chains.  Interactive, no JCL submitted/required.

The challenge:  Simplify management and provide REXX examples to be more efficient.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.  Upload the LSTCERTS.rexx.txt as LSTCERTS into your CLIST/REXX library.
2.  Upload the LSTRINGS.rexx.txt as LSTRINGS into your CLIST/REXX library.
3.  Upload the CERTRPT.rexx.txt as CERTRPT into your CLIST/REXX library.

Syntax:
LSTCERTS:
1. TSO LSTCERTS - this will list all Digital Certificates, placing output into a temp dataset, allowing you to scroll, find/search, review the output. PF3 would exit and cleanup the temp dataset.
2. TSO LSTCERTS A- this will list all Digital Certificate records that begin with the Letter A, placing output into temp dataset, etc.

LSTRINGS:
1. TSO LSTRINGS - this will list all Keyrings, placing the output into a temp dataset and you into ISPF Edit to review, scroll/search.

CERTRPT: 
1. TSO CERTRPT - this is the same thing as running PGM=SAFCRRPT with JCL in a batch job, but interactive.  By default, it uses "RECORDID(-) DETAIL EXT" as the input.
2. TSO CERTRPT RECORDID(CERT-) DETAIL EXT   - this would give you the report for all recordids that start with CERT*.
3. TSO CERTRPT RECORDID(A-) DETAIL EXT - this would give you the report for all recordids that start with A*.
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
