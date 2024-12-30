# Endevor - Sample Scripts

## Automated Test Facility for Batch Applications
This [sample repository](Automated-Test-Facility-for-Batch-Applications) contains artifacts described in the [How to Leverage Endevor Processors to Test Batch Applications](https://medium.com/modern-mainframe/how-to-leverage-endevor-processors-to-test-batch-applications-6247a9dfdafa) blog on Medium.  The objects are for using Endevor processors in Building an Automated Test Facility for Batch Applications in Endevor.

## Building a z/OS CICS Blockmode Application with Endevor®, Zowe, and Gen
This [sample repository](../gen/gen-whitepaper-sample) contains the artifacts described in the [Building a z/OS CICS Blockmode Application with Endevor® and Zowe whitepaper](https://community.broadcom.com/mainframesoftware/communities/community-home/digestviewer/viewthread?GroupId=1513&MessageKey=7a3ba595-6432-48aa-93f4-f18206875d72&CommunityKey=4182c217-4789-4997-8f22-87de25983f6e&tab=digestviewer). There are Python scripts that you can use as-is or modify to better match your organization's DevOps practices. Also included are SCL templates (or skeletons) that show examples of processors you will need to have present in your organization's Endevor installation to successfully compile and link your Gen applications with Endevor.

## Field Developed Programs

This [sample repository](Field-Developed-Programs) contains artifacts created by Broadcom Services and implemented at various sites to meet customer requirements and to increase Endevor functionality.

## Self-servicing Project Workareas in Endevor with Dynamic Environments
This [sample repository](Self-servicing-Project-Workareas-in-Endevor-with-Dynamic-Environments) contains artifacts described in the [Self-servicing Project Workareas in Endevor with Dynamic Environments](https://medium.com/modern-mainframe/self-service-developer-workspaces-in-endevor-3b83c72bdc14) blog on Medium.  The objects are sample processors for enabling self service with Dynamic Environments backed by Deferred File Creation.

## Automated Package Shipping Methods
There are three automated package shipping methods presented in this GitHub. All have some unique software components, but also share many software components with the other methods. Within the README files for each, look for the folder references where shared components may be found. 

#### Package Automation (exit driven)
This [sample repository](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/Package-Automation) contains artifacts described in the [Package Automation - what are you waiting for?](https://community.broadcom.com/blogs/joseph-walther/2023/07/11/package-automation-what-are-you-waiting-for?CommunityKey=592eb6c9-73f7-460f-9aa9-e5194cdafcd2) blog on the Endevor community website. The objects are used to initiate automated package shipments from actions performed in Endevor, triggered by an Endevor package exit. 

The objects may also trigger automated package executions.

#### Shipments for a Single-Destination (zowe)
This [sample repository](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Shipments-for-a-Single-Destination) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments from zowe for an Endevor image that has only one Shipment destination.  The installation steps are fewer and simpler than those necessary for Shipments-for-Multiple-Destinations.

#### Shipments for Multiple Destinations (zowe)
This [sample repository](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Shipments-for-Multiple-Destinations) contains artifacts described in the [Automate Endevor Package Shipments with Zowe CLI](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments from zowe for Endevor images that have multiple Shipment destinations.  Zero to many package shipment destinations are determined, and shipment jobs are submitted based on each Endevor package content.

## Storing zUnit Artifacts in Endevor
This [sample repository](zunit) contains the artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The REXX scripts and corresponding JCL are used to serialize and deserialize zUnit test cases.  Also included is a JenkinsFile that shows how these scripts can be invoked via Zowe CLI in a Jenkins pipeline.
