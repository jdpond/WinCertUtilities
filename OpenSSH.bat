@echo off
setlocal
Rem 
Rem <b>ssh-keygen</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see http://wiki.lextechaudits.com/MediaWiki/index.php?title=Get_a_Certificate
Rem @description execute the OpenSSH using passed parameters
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
%ssh-keygen% %AllParms%
@endlocal
