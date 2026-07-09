/* REXX */
parse arg dsn

say "==========================================================="
say "|"
say "|  REPORT FROM RUNNING 'LISTDS' MEMBER ON:"
say "|"
say "|    " dsn
say "|"
say "==========================================================="
say " "

"LISTDS '"dsn"' MEMBERS"

EXIT