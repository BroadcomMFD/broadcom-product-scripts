REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > TableToolExamples.moveout
ECHO These items come from the Endevor GitHub at >> TableToolExamples.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> TableToolExamples.moveout
ECHO ------------------------------------------------------- >> TableToolExamples.moveout
ECHO These are jcl/JCL : CLEANOVR CSVALENV CSVALTYP EXAMPL#1 EXAMPL#2 EXAMPL#3 EXAMPL#4 EXAMPL#5 EXAMPL#6 EXAMPL#7 EXAMPL#8 EXAMPL1A EXAMPL1B EXAMPL2$ EXAMPL2A EXAMPL2B EXAMPL2P EXAMPL2R LISTDSNS PKGEMNTR >> TableToolExamples.moveout
ECHO These are txt/TXT : DAVE#J01 DAVE#J03 DAVE#J04 DAVE#J05 REX1LINE REXMERGE DAVE#J06 DAVE#J07 DB2MASK$ >> TableToolExamples.moveout
ECHO These are TXT          : DAVE#J02 >> TableToolExamples.moveout
ECHO ./  ADD  NAME=CLEANOVR                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\CLEANOVR.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=CSVALENV                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\CSVALENV.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=CSVALTYP                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\CSVALTYP.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#1                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#1.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#2                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#2.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#3                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#3.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#4                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#4.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#5                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#5.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#6                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#6.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#7                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#7.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL#8                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL#8.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL1A                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL1A.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL1B                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL1B.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL2$                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL2$.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL2A                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL2A.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL2B                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL2B.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL2P                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL2P.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=EXAMPL2R                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\EXAMPL2R.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=LISTDSNS                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\LISTDSNS.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=PKGEMNTR                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\PKGEMNTR.jcl   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J01                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"CSV and TableTool emails element list to a distribution.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J02                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"CSV and TableTool examples in IEBUPDTE format.TXT"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J03                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"CSV and TableTool finds and deletes unused processor groups.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J04                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"CSV and TableTool showing element counts for each inventory area.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J05                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"CSV and TableTool shows processor group usage.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=REX1LINE                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"REX1LINE rexx to put processor group CSV data on one line.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=REXMERGE                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"REXMERGE rexx to merge CSV list element with CSV list processor group.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J06                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"TableTool builds a DB2 bindcard based on inventory area.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DAVE#J07                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"TableTool builds a DB2 bindcard based on YAML control table.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
ECHO ./  ADD  NAME=DB2MASK$                >> TableToolExamples.moveout
TYPE Table-Tool-Examples\"DB2MASK$ rexx to build DB2 bindcards.txt"   >> TableToolExamples.moveout
ECHO.          >> TableToolExamples.moveout
REM
