# MCP with ISPF

Check out this folder! It really shows off how well an old-school technology like [ISPF](https://www.ibm.com/products/interactive-system-productivity-facility) can team up with the modern [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro). A user who questions something they see on ISFF, can enter **"TSO ASKAI"**,for example, to get help.

## Introduction

ISPF, which has been around since 1974 on z/OS mainframes, is actually a great match for MCP, which just came out in November 2024. MCP has quickly become the go-to open standard for simplifying AI development by letting large language models connect to external data and tools. The blend of the "classic" and the "cutting-edge" his as genuinely looking like a huge success.



ISPF is inherently suited for executing Model Context Protocol AI queries because it can automatically leverage managed ISPF variables to provide query context. Furthermore, the content displayed on the ISPF screen—or a user-specified portion of it can be automatically incorporated into the query text.

This capability allows users to inquire about displayed errors and message codes, get details on options within applications (such as Endevor or Sysview), and navigate seamlessly. ASKAI supports this by either automating the construction of the query text or permitting the user to type their question manually.

The construction of an ASMAI query can be done in  many ways: 
The user migrates to an ISPF screen that needs explanation. ASMAI constructs a query automatically. The cursor acts as a pointer.
From Edit and View sessions, the user can use mainframe CUT and PASTE commands to assist in building a query
The user can replace the text with manually entered text


On the mainframe, both IBM and Broadcom products often operate as applications within the Interactive System Productivity Facility (ISPF) environment.

To manage settings within ISPF, each application uses a unique 1-to-4 character identifier called the APPLID. When a user selects an option from an ISPF panel to start an application, the ZAPPLID variable is typically assigned a  corresponding APPLID value.

The following table provides examples of the relationship between ISPF Application IDs and associated IBM and Broadcom products.


    Application ID
    (ZAPPLID)               Product (Expert)

    CA7@                    CA7 
    CAMR                    InterTest 
    CAWA                    File Master 
    CTLI                    Endevor
    DFS/DFSW                IMS Application
    ESP                     ESP
    GSVX                    SYSVIEW 
    ICHP                    RACF
    ISF                     SDSF
    JCK0                    JCLCheck 
    RC                      DB2 Tools
    RMO                     View/Deliver
    TUNT                    Mainframe Application Tuner 
    XCOM                    XCOM

(there are many more)

**There are two ways to ask for help.** 

- TSO ASKAI
- AIASK 

## ASKAI 

To use the AI Query feature, simply type "TSO ASKAI" on any ISPF command line. ASKAI can automatically build a relevant query by reading the current screen content and evaluating ISPF variables, setting the context for your question.

If your question relates to specific text visible on the screen, position your cursor over that text when you invoke the ASKAI command.

This capability ensures that when a user has a question about what they see, ISPF variables automatically provide the necessary context to the AI Query.

The [ISPF variables](https://www.ibm.com/docs/en/zos/2.5.0?topic=variables-general) available to ASKAI include:



- ZAPPLID contains the ISPF application's 4-byte identifier.
 The value of  ZAPPLID provides the necessary context, linking the value in the left column to the expert name in the second column.
 - ZPANELID - The name of the currently displayed panel. From the panel and application names, ASKAI knows what kind of help you need. 
 - ZSCREENI a variable that contains all the text you see on your ISPF screen (panel). Where is place your cursor points to specific text on your screen. Some or all of the text from the screen can be copied into your ASKAI query,
 - ZSCREENC - Cursor position within the logical screen data.


 By default, ASKAI eliminates the need for the user to copy and paste text into an AI Query. However, the user may elect to replace the query text written by ASKAI, and type the query text manually.  


## AIASK
AIASK is another way to request help. Because it is an edit macro, you can only use it while you are viewing or editing within ISPF.

You can also use the ISPF "EXCLUDE" function before running AIASK to hide any text that is not relevant to your query. Refer to an example of the EXCLUDE function here. Be aware that all unexcluded content, even if it comprises hundreds of lines of code, will be copied into your query.


To maximize your use of AIASK, we recommend modifying Endevor's **ISPF BROWSE OR VIEW MODE** options to View.