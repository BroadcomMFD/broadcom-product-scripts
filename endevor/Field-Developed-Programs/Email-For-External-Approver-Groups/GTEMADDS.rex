/*  REXX   */
  Arg ApproverGroup .
  CALL BPXWDYN "INFO FI(GTEMADDS)",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If RESULT = 0 then Trace r
  /* For the named Approver group,  return zero to many   */
  /* email addresses. Where possible, return              */
  /* Group-level email addresses. Individuals are OK.     */
  /*                                                      */
  /* There is no dependency on ESMTPTBL or XIT7MAIL .     */
  /* The number of email addresses can exceed 16.         */
  ApproverGroup = Strip(ApproverGroup)
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
  Return EmailAddresses.ApproverGroup
