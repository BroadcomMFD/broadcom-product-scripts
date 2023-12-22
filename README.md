# Broadcom Product Scripts
This repository houses sample scripts for use cases involving Broadcom Products.

# Using
Sample scripts for each product are located in the directory that shares its name. For example, Endevor samples are in the [endevor](endevor) directory. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

Alternatively, you can select from the use cases below:

## Endevor - Automated Test Facility for Batch Applications
This [sample repository](endevor/Automated-Test-Facility-for-Batch-Applications) contains artifacts described in the [How to Leverage Endevor Processors to Test Batch Applications](https://medium.com/modern-mainframe/how-to-leverage-endevor-processors-to-test-batch-applications-6247a9dfdafa) blog on Medium.  The objects are for using Endevor processors in Building an Automated Test Facility for Batch Applications in Endevor.

## Endevor - Self-servicing Project Workareas in Endevor with Dynamic Environments
This [sample repository](endevor/Self-servicing-Project-Workareas-in-Endevor-with-Dynamic-Environments) contains artifacts described in the [Self-servicing Project Workareas in Endevor with Dynamic Environments](https://medium.com/modern-mainframe/self-service-developer-workspaces-in-endevor-3b83c72bdc14) blog on Medium.  The objects are sample processors for enabling self service with Dynamic Environments backed by Deferred File Creation.

## Endevor - Shipments for a Single-Destination
This [sample repository](endevor/Shipments-for-a-Single-Destination) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for an Endevor image that has only one Shipment destination.  The installation steps are fewer and simpler than those necessary for Shipments-for-Multiple-Destinations.

## Endevor - Shipments for Multiple Destinations
This [sample repository](endevor/Shipments-for-Multiple-Destinations) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for Endevor images that have multiple Shipment destinations.  Zero to many package shipment destinations are determined, and shipment jobs are submitted based on each Endevor package content.

## Endevor - Storing zUnit Artifacts in Endevor
This [sample repository](endevor/zunit) contains the artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The REXX scripts and corresponding JCL are used to serialize and deserialize zUnit test cases.  Also included is a JenkinsFile that shows how these scripts can be invoked via Zowe CLI in a Jenkins pipeline.

## Gen/Endevor - Building a z/OS CICS Blockmode Application with Endevor®, Zowe, and Gen
This [sample repository](gen/gen-whitepaper-sample) contains the artifacts described in the [Building a z/OS CICS Blockmode Application with Endevor® and Zowe whitepaper](https://community.broadcom.com/mainframesoftware/communities/community-home/digestviewer/viewthread?GroupId=1513&MessageKey=7a3ba595-6432-48aa-93f4-f18206875d72&CommunityKey=4182c217-4789-4997-8f22-87de25983f6e&tab=digestviewer). There are Python scripts that you can use as-is or modify to better match your organization's DevOps practices. Also included are SCL templates (or skeletons) that show examples of processors you will need to have present in your organization's Endevor installation to successfully compile and link your Gen applications with Endevor.

## Output Management

The [output-management](output-management) directory contains multiple samples related to Broadcom output management products.

# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Rose.Sakach@broadcom.com & Adam.Wolfe@broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
