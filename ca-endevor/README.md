# CA Endevor Plug-in for Zowe CLI - Sample Scripts

## Storing zUnit Artifacts in CA Endevor
This [sample repository](zunit) contains the artifacts described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The REXX scripts and corresponding JCL are used to serialize and deserialize zUnit test cases.  Also included is a JenkinsFile that shows how these scripts can be invoked via Zowe CLI in a Jenkins pipeline.

## Shipments for a Single-Destination
This [sample repository](Shipments-for-a-Single-Destination) contains artifacts soon to be described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The objects are used to initiate package shipments for an Endevor image that has only one Shipment destination.  The installation steps are fewer and simpler than those necessary for Shipments-for-Multiple-Destinations.

## Shipments for Multiple Destinations
This [sample repository](Shipments-for-Multiple-Destinations) contains artifacts soon to be described in the [Modern Mainframe](https://medium.com/modern-mainframe) blog on Medium.  The objects are used to initiate package shipments for Endevor images that have multiple Shipment destinations.  Zero to many package shipment destinations are determined, and shipment jobs are submitted based on each Endevor package content.
