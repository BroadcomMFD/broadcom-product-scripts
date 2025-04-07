/* REXX */
PARSE ARG dsname
OUTPUT = userid()||'.PUBLIC.JCLOUT(REPORT)'

flower.0 = 0
call prnt "==========================================================="
call prnt "|"
call prnt "|  REPORT FROM RUNNING 'LISTDS' MEMBER ON:"
call prnt "|"
call prnt "|    " dsname
call prnt "|"
call prnt "==========================================================="
call prnt " "

X = OUTTRAP("memlst.")
"LISTDS '"dsname"' MEMBERS"
X = OUTTRAP("OFF")

"ALLOC FI(SYSUT2) DA('"||OUTPUT||"') SHR REUSE"
"EXECIO 0 DISKW SYSUT2 (OPEN"
"EXECIO * DISKW SYSUT2 (STEM flower."
"EXECIO * DISKW SYSUT2 (STEM memlst."
"EXECIO 0 DISKW SYSUT2 (FINIS"
"FREE FI(SYSUT2)"

SAY "DSN='"||OUTPUT||"'"
EXIT

prnt:
  arg text
  i = flower.0
  i = i+1
  flower.i = text
  flower.0 = i
  return
