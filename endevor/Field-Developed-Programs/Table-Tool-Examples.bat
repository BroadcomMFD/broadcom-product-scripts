REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > TableToolExamples.moveout
ECHO These items come from the Endevor GitHub at >> TableToolExamples.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> TableToolExamples.moveout
ECHO ------------------------------------------------------- >> TableToolExamples.moveout
ECHO These are jcl          : CLEANOVR CSVALENV CSVALTYP EXAMPL#1 EXAMPL#2 EXAMPL#3 EXAMPL#4 EXAMPL#5 EXAMPL#6 EXAMPL#7 EXAMPL#8 EXAMPL1A EXAMPL1B EXAMPL2$ EXAMPL2A EXAMPL2B EXAMPL2P EXAMPL2R LISTDSNS PKGEMNTR >> TableToolExamples.moveout
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
REM
