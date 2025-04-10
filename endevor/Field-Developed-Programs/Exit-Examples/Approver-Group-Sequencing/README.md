# Approver Group Sequencing

Items in this folder support the "sequencing" of Endevor package approvals. 
It allows sites to designate a chrolnogical order of approvals for Endevor packages following a successful CAST.

You can establish the order for approvals to be collected within a table format within a dataset and member, referenced as YOURSITE.NDVR.PARMLIB(APPROVER) in this documentation. Then, the exit will enforce the order for approvals, and if you are sending emais, will arrange that the emails are sent to a group when required apprvals are already given for listed higher in the table.


## YOURSITE.NDVR.PARMLIB(APPROVER)

    * Environment ApproverGroup          
      PRD         TEAM01               
      PRD         TEAM02               
      PRD         AllOthers              
      PRD         NDVRTEAM               
      PRD         LASTWRD               

Not every approver group is required to be entered into the table. Groups not listed will be considered equivalent to the "AllOthers" entry on the table. You can use any dataset you want. The name of the dataset must be entered as the value given to the **ApproverGroupSequence**
 variable within C1UEXTR7.


## Exit actions

If an approver attempts to approve a package before previous groups have completed their approval, the approval request will be ignored.

If an approver group is an "internal" group, and its time has arrived, then emails to that group will be sent.





