@echo off
setlocal
Rem 
Rem <b>OpenSSL</b> command file.
Rem @author Jack D. Pond
Rem @version 1.0 / Windows Batch Processor
Rem @see http://wiki.montcopa.org/MediaWiki/index.php?title=Get_a_MontCo_Certificate
Rem @description execute the OpenSSL using passed parameters
Rem
call CertConfig.bat
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
