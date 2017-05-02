@echo off
setlocal
Rem 
Rem <b>OpenSSL</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description execute the OpenSSL using passed parameters
Rem
call "etc/CertConfig.bat"
set AllParms=%1
:StartLoop
IF "%2" == "" goto OutLoop
Set AllParms=%AllParms% %2
SHIFT
GOTO StartLoop
:OutLoop
echo on
%OpenSSLExe% %AllParms%
@endlocal
