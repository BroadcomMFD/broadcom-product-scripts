# Broadcom Product Scripts
This repository houses Zowe CLI sample scripts for use cases involving Broadcom Products.

# Using
Sample scripts for each product are located in the directory that shares its name. For example, Endevor samples are in the [endevor](endevor) directory. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

Alternatively, you can select from the use cases below:

## CA Gen - DevOps Whitepaper sample code and SCL
This [sample repository](endevor/ca-gen-whitepaper-sample) contains the artifacts described in the [Building a z/OS CICS Blockmode Application with Endevor® and Zowe whitepaper](https://community.broadcom.com/mainframesoftware/communities/community-home/digestviewer/viewthread?GroupId=1513&MessageKey=7a3ba595-6432-48aa-93f4-f18206875d72&CommunityKey=4182c217-4789-4997-8f22-87de25983f6e&tab=digestviewer). There are Python scripts that you can use as-is or modify to better match your organization's DevOps practices. Also included are SCL templates (or skeletons) that show examples of processors you will need to have present in your organization's Endevor installation to successfully compile and link your CA Gen applications with Endevor.

## Endevor - Automated Test Facility for Batch Applications
This [sample repository](endevor/Automated-Test-Facility-for-Batch-Applications) contains artifacts described in the [How to Leverage Endevor Processors to Test Batch Applications](https://medium.com/modern-mainframe/how-to-leverage-endevor-processors-to-test-batch-applications-6247a9dfdafa) blog on Medium.  The objects are for using Endevor processors in Building an Automated Test Facility for Batch Applications in Endevor.

## Endevor - Shipments for a Single-Destination
This [sample repository](endevor/Shipments-for-a-Single-Destination) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for an Endevor image that has only one Shipment destination.  The installation steps are fewer and simpler than those necessary for Shipments-for-Multiple-Destinations.

## Endevor - Shipments for Multiple Destinations
This [sample repository](endevor/Shipments-for-Multiple-Destinations) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for Endevor images that have multiple Shipment destinations.  Zero to many package shipment destinations are determined, and shipment jobs are submitted based on each Endevor package content.

## Endevor - Storing zUnit Artifacts in Endevor
This [sample repository](endevor/zunit) contains the artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The REXX scripts and corresponding JCL are used to serialize and deserialize zUnit test cases.  Also included is a JenkinsFile that shows how these scripts can be invoked via Zowe CLI in a Jenkins pipeline.

## Test4z
The [Test4z sample project](https://github.com/BroadcomMFD/test4z) contains client-side installation of Test4z as well as a series of sample tests that use the Test4z API to run tests on data sets on your z/OS system. Test4z leverages z/OSMF and Zowe to facilitate batch application testing for flat files on the z/OS platform. Installing Test4z on your z/OS system lets you perform certain operations on your data sets from a client machine.

# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Rose.Sakach@broadcom.com & Michael.Bauer2@broadcom.com to discuss.**
