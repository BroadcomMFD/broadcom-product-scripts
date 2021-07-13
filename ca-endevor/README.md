# CA Endevor Plug-in for Zowe CLI - Sample Scripts

## Storing zUnit Artifacts in CA Endevor
This [sample repository](zunit) contains the artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The REXX scripts and corresponding JCL are used to serialize and deserialize zUnit test cases.  Also included is a JenkinsFile that shows how these scripts can be invoked via Zowe CLI in a Jenkins pipeline.

## CA Gen DevOps Whitepaper sample code and SCL
This [sample repository](ca-gen-whitepaper-sample) contains the artifacts described in the [Building a z/OS CICS Blockmode Application with CA Endevor® and Zowe whitepaper](https://community.broadcom.com/mainframesoftware/communities/community-home/digestviewer/viewthread?GroupId=1513&MessageKey=7a3ba595-6432-48aa-93f4-f18206875d72&CommunityKey=4182c217-4789-4997-8f22-87de25983f6e&tab=digestviewer). There are Python scripts that you can use as-is or modify to better match your organization's DevOps practices. Also included are SCL templates (or skeletons) that show examples of processors you will need to have present in your organization's CA Endevor installation to successfully compile and link your CA Gen applications with CA Endevor.

## Shipments for a Single-Destination
This [sample repository](Shipments-for-a-Single-Destination) contains artifacts described in the [Modern, open source interface for the mainframe](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for an Endevor image that has only one Shipment destination.  The installation steps are fewer and simpler than those necessary for Shipments-for-Multiple-Destinations.

## Shipments for Multiple Destinations
This [sample repository](Shipments-for-Multiple-Destinations) contains artifacts described in the [Modern, open source interface for the mainframe](https://medium.com/zowe/automate-ca-endevor-package-shipments-with-zowe-cli-e15feb61745a) blog on Medium.  The objects are used to initiate package shipments for Endevor images that have multiple Shipment destinations.  Zero to many package shipment destinations are determined, and shipment jobs are submitted based on each Endevor package content.

## Automated Test Facility for Batch Applications
This [sample repository](Automated-Test-Facility-for-Batch-Applications) contains artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The objects are for using CA Endevor processors in Building an Automated Test Facility for Batch Applications in CA Endevor.
