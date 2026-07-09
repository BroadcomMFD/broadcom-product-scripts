REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > API-Assembler.moveout
ECHO These items come from the Endevor GitHub at >> API-Assembler.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> API-Assembler.moveout
ECHO ------------------------------------------------------- >> API-Assembler.moveout
ECHO These are asm          : APIAEADD APIAERET APIAESCL APIALAPP APIALBKO APIALDIR APIALDST APIALELM APIALPKG APIALSUM APIAPBKO >> API-Assembler.moveout
ECHO These are jcl          : JCLAEADD JCLAEELM JCLAERET JCLALAPP JCLALDIR JCLALELM JCLALPKG >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIAEADD                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIAEADD.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIAERET                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIAERET.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIAESCL                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIAESCL.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALAPP                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALAPP.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALBKO                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALBKO.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALDIR                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALDIR.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALDST                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALDST.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALELM                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALELM.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALPKG                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALPKG.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIALSUM                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIALSUM.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=APIAPBKO                >> API-Assembler.moveout
TYPE API-Assembler-Examples\APIAPBKO.asm   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLAEADD                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLAEADD.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLAEELM                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLAEELM.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLAERET                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLAERET.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLALAPP                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLALAPP.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLALDIR                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLALDIR.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLALELM                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLALELM.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
ECHO ./  ADD  NAME=JCLALPKG                >> API-Assembler.moveout
TYPE API-Assembler-Examples\JCLALPKG.jcl   >> API-Assembler.moveout
ECHO.          >> API-Assembler.moveout
REM
