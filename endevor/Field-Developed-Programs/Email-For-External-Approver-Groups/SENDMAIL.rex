/* rexx */
/* For the individuals associated in the ApproverGroup
   send an email to alert them of the PackageCondition  */
  Trace  Off
  CALL BPXWDYN "INFO FI(SENDMAIL)",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If RESULT = 0 then Trace r
  Arg ApproverGroup Package PackageCondition TSOIds
  ApproverGroup = Strip(ApproverGroup)
  whattime = TIME('L')
  EmailDDNAMESuffix = Substr(whattime,4,2) || Substr(whattime,10,5)
  SonarWorkfile = ''
  CALL BPXWDYN "INFO FI(SONAROPT)",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If RESULT = 0 then,
     Do
     "EXECIO * DISKR SONAROPT (stem sonar. Finis"
      Do so# = 1 to sonar.0
         If Word(sonar.so#,1) = 'SonarWorkfile' then,
            Do
            SonarWorkfile = Strip(Word(sonar.so#,3),'B',"'")
            Leave
      End /* Do so# = 1 to sonar.0 */
     End /* If RESULT = 0 then */
  /* Individuals for receiving email are defined here     */
  /* There is no dependency on ESMTPTBL or XIT7MAIL .     */
  EmailAddresses. = ''
  EmailAddresses.GROUP01     = 'First1.Last1@yoursite.com ',
                               'First2.Last2@yoursite.com ',
                               'First3.Last3@yoursite.com ',
                               'First4.Last4@yoursite.com '
  EmailAddresses.GROUP02     = 'First2.Last2@yoursite.com '
  EmailAddresses.GROUP03   = ' '
  EmailAddresses.GROUP04     = ' '
  EmailAddresses.GROUP05       = ' '
  EmailAddresses.GROUP06  = ' '
  EmailAddresses.GROUP07 = 'First4.Last4@yoursite.com'
  EmailAddresses.GROUP08     = 'First3.Last3@yoursite.com ',
                               'First4.Last4@yoursite.com '
  EmailAddresses.GROUP09        = 'First1.Last1@yoursite.com ',
                               'First2.Last2@yoursite.com ',
                               'First4.Last4@yoursite.com '
  EmailAddresses.GROUP10         = ''
  sa = ApproverGroup
  EmailAddressList = EmailAddresses.ApproverGroup
  If EmailAddressList = '' then Exit
  myLrecl = 80
  Body.0 =  0
  If PackageCondition = 'NEEDS-APPROVAL' then,
     Do
     Subject_Line = 'Please Approve Package' Package
     Body.1 = "      "
     Body.2 = "CC:" EmailAddressList
     Body.3 = "Package"  Package "is ready for your approval."
     Body.4 = "      "
     Body.5 ="http://mstrsvw.your.site.com:" || ,
          "7080/endevorui/app/packages/" || Package
     Body.0 = 5
     If SonarWorkfile /= '' then,
        Do
        ALLOC_CMD = "ALLOC FI(SONAR)",
                    "DA("SonarWorkfile".RESULTS) SHR REUSE"
        rc = BPXWDYN(ALLOC_CMD)
        "EXECIO * DISKR Sonar (Stem sonar. Finis"
        Call BPXWDYN "FREE FI(SONAR)"
        IncludeCount = Min(80,sonar.0)
        bdy# = Body.0 +  1
        Body.bdy# = "============ SonarQube Analysis =========="
        sonar# = 0
        Do IncludeCount
           bdy# = bdy# +  1
           sonar# = sonar# + 1
           Body.bdy# = sonar.sonar#
        End ; /* Do IncludeCount  */
        End /* If SonarQubed = 'Y'  */
     Body.0 = bdy#
     End  /*  If PackageCondition = 'Needs-Approval' */
  /* For each person in the Approver group, send an Email */
  Do e# = 1 to Words(EmailAddressList)
     EMAIL_ADDRESS = Word(EmailAddressList,e#)
     Call SendAnEmail
  End;
  Exit
SendAnEmail:
  email.0=0
  Call SMTP "helo DEVRSVW"
  Call SMTP "Mail From:<DEVRSVW@yoursite.com> "
  Call SMTP "Rcpt To:<"EMAIL_ADDRESS">"
  Call SMTP "data "
  Call SMTP "To: "EMAIL_ADDRESS" "
  Call SMTP "Subject: " Subject_Line
  Call SMTP "MIME-VERSION: 1.0 "
  Call SMTP "CONTENT-TYPE: TEXT/HTML"
  Call SMTP "<html> "
  Call SMTP "<head> "
  Call SMTP "<style> "
  Call SMTP "PRE {FONT-SIZE: 12PT; FONT=FAMILY: IBM3270 COURIER;} "
  Call SMTP "DIV {PADDING-RIGHT:5PX; PADDING-LEFT:5PX;} "
  Call SMTP "HR{COLOR: FIREBRICK; BACKGROUND: FIREBRICK; HEIGHT=1PX} "
  Call SMTP "HR.TOP{COLOR: DARKBLUE; BACKGROUND: DARKBLUE; HEIGHT=1PX} "
  Call SMTP "</style> "
  Call SMTP "</head> "
  Call SMTP "<body> "
  Call SMTP "    <p>      "
  Call SMTP " <table>     "
  Call SMTP "   <tr>      "
  Call SMTP "    <td>     "
  Call SMTP "    <td width="5">&nbsp;</td> "
  Call SMTP '    <td style="font: 1.2em Arial, Helvetica, sans-serif">'
  Call SMTP "   </tr>     "
  Call SMTP " </table>    "
  Call SMTP,
   ' <hr style="color: firebrick; background: firebrick; height=1px"/>'
  Call SMTP " <p>         "
  Call SMTP " <pre>       "
  Call SMTP "             "
  DO B# =  1 to Body.0
     Call SMTP Body.B#
  End
  Call SMTP " </pre>      "
  Call SMTP " </p>        "
  Call SMTP "</html>      "
  Call SMTP ".            "
  EmailDDNAME = 'E' || EmailDDNAMESuffix
  String = "ALLOC DD("EmailDDNAME") ",
           "SYSOUT(A) WRITER(SMTP) REUSE"
  Call BPXWDYN String
  "EXECIO * DISKW "EmailDDNAME" (Stem email. finis"
  Call BPXWDYN "FREE  DD("EmailDDNAME")"
  EmailDDNAMESuffix = EmailDDNAMESuffix + 1
  Return
smtp: procedure expose email.
   parse arg aline
   al# = email.0 + 1
   email.al# = aline
   email.0  = al#
   Return
