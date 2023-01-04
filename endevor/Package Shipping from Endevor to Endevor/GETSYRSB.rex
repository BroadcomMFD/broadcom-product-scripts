/*  Rexx  From the package name, get the implied System or Subystem */
PARSE ARG Package
   Trace Off

   pkgpfx4 = Substr(Package,1,4)

   PackageInfo.    = ''
   PackageInfo.ACM#= 'ACM#BILD SBS'
   PackageInfo.CCID= 'CCIDRUSE SBS'
   PackageInfo.CONS= 'CONSOLID SBS'
   PackageInfo.CONT= 'CONTINUO SBS'
   PackageInfo.DYNA= 'DYNAPPRV SBS'
   PackageInfo.ESRC= 'ESRCHFOR SBS'
   PackageInfo.FINA= 'FINANCE  SYS'
   PackageInfo.JCLC= 'JCLCHECK SBS'
   PackageInfo.PACK= 'PACKAGE  SBS'
   PackageInfo.PDA#= 'PDA      SBS'
   PackageInfo.PKGM= 'PKGMAINT SBS'
   PackageInfo.SHIP= 'SHIPPING SBS'
   PackageInfo.UTIL= 'UTILITY  SBS'
   PackageInfo.ZUNI= 'ZUNIT    SBS'

   thisPackageInfo = PackageInfo.pkgpfx4
   this_Sys_Sub = Word(thisPackageInfo,1)
   thisWhichone = Word(thisPackageInfo,2)

   sa=  Package 'S='this_Sys_Sub 'which='thisWhichone

   Return this_Sys_Sub' 'thisWhichone