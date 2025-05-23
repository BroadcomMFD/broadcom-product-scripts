# Table-Tool-Examples

A collection of JCL and processor members that demonstrate the use of Table Tool. 
These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).
If you are new to Table Tool see these links for more information:

- [Techdocs Documentation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/table-tool.html)
- [Programming results without writing any code](https://www.youtube.com/watch?v=41tPGWpxm3s)
- [Community Website Table Tool Examples Library ](https://community.broadcom.com/viewdocument/table-tool-examples-2020-june?CommunityKey=592eb6c9-73f7-460f-9aa9-e5194cdafcd2&tab=librarydocuments)


Examples in this folder include:

   - CLEANOVR  Report processor group Overrides                              
   - CSVALENV  Convert ENVIRONMENT info into REXX stem array data            
   - CSVALTYP  Report TYPE definition information                            
   - EXAMPL#1  To Report and delete very old elements from Test              
   - EXAMPL#2  To Report Packages created over nnn days ago                  
   - EXAMPL#3  Add members of a PDS into Endevor                             
   - EXAMPL#4  Execute PDM to update elements out of sync.                   
   - EXAMPL#5  Report the total Track consumption of a list of datasets      
   - EMPL#7XA  Example processor that uses Table Tool to process JCLCheck data
   - EXAMPL#8  Report processor usage including  UnUsed processors.          
   - EXAMPLEG  Report of counts for each processor group reference
   - EXAMPL1A  Report Elements in DEV signed out to one userid               
   - EXAMPL1B  Report Elements in DEV, flagging those in parallel development
   - EXAMPL2$  To Report Packages created over nnn days (a primitive solution not using the extracted CSV format)                  
   - EXAMPL2A  To Report Element changes within a date range                 
   - EXAMPL2B  To Report Elements Moved within a date span                  
   - EXAMPL2P  To Report Packages created over nnn days ago (using CSV data)                                  
   - LISTDSNS  From a Dataset mask, lists dataset names and attributes
   - PKGEMNTR  To run the Package Monitor report    
   - Commonly requested utilities and the rexx which support them: 
      * CSV and TableTool emails element list to a distribution - need a report of what's in QA? need it emailed as an attachment? 
      * CSV and TableTool shows processor group usage - too many processor groups? want to know which ones are used / not used?  
      * CSV and TableTool finds and deletes unused processor groups - too many processor groups? want to find & delete the unused? 
      * CSV and TableTool showing element counts for each inventory area - easy to read report of elements and key data fields.
      * TableTool builds a DB2 bindcard based on inventory area - dynamically build the bindcards based on system, stage, overrides, etc. 
      * TableTool builds a DB2 bindcard based on YAML control tablen - dynamically build the bindcards based on a YAML control table.
      * CSV and TableTool examples in IEBUPDTE format - All of the above examples in singe member used as input to an IEBUPDTE job. 
      * DB2MASK$ rexx to build DB2 bindcards - masking utility used by the DB2 bindcard utility
      * REX1LINE rexx to put processor group CSV data on one line - utility used by the processor group utiliites
      * REXMERGE rexx to merge CSV list element with CSV list processor group - utility used by the processor group utiliites
      * YAML2REX rexx to reformat YAML syntax to REXX - conversion utility used by the DB2 YAML bindcard utility. Find the source code for [YAML2REXX here](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/YAML2REX.rex)
   
   The **Table-Tool-CSV-Sorting** folder contains items that allow you to SORT CSV data prior to a Table Tool Execution                         





