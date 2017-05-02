@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CARevokeCRT</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Revoke an x.509 (.crl) certificate .
Rem @param CA_SIGN_NAME - Name of the certificate corresponding to directory and CA_SIGN_NAMEs

call "etc/CertConfig.bat"

:PickCA_SIGN_NAME

if "%1" NEQ "" (
	set CA_SIGN_NAME=%1
	set CA_SIGN_NAME=%CA_SIGN_NAME:"=%
	if exist "!CA_SIGN_NAME!\!CA_SIGN_NAME!\db" goto :ValidCAName
)

FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\crl\*.crl" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
	)
)
if not defined DirCount ( 
	echo.
	echo You have no Certificate Revocation Lists^(CRLs^)
	echo To set up a CA, you may want to use the CA INfrastruction Creation Tool^(CreateCAInfrastructure^).
	echo If you have a CA set up, you may need to copy your CRL into the appropriate "crl" directory.
	echo.
	pause
	goto :eof
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=For which Certificate Authority do you wish to see a Certificate Revocation List^(CRL^)^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCA_SIGN_NAME
)

:ValidCAName
Set CA_SIGN_NAME=!Picked_Name!
:GetValidCertName
set /a DirCount = 0
Set DirNames=
FOR /F "usebackq delims=" %%i in (`dir /B "!CA_SIGN_NAME!\crl\*.crl"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%~ni
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCertName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which Certificate Revocation List^(CRL^) do wish to see details for^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)
if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount! 
	echo.
	goto :GetValidCertName
)

:ValidCertName
Rem 
Rem Actually shows the details here
Rem 
echo Certificate Authority !CA_SIGN_NAME! crl: !CertName!
set CA_NAME=!CA_SIGN_NAME!
%OpenSSLExe% crl -inform DER -in "!CA_SIGN_NAME!/crl/!Picked_Name!.crl" -text
if !errorlevel! NEQ 0 echo ERRORLEVEL: !errorlevel!
pause
goto :eof


:parsenames
set list=%1
set list=%list:"=%
FOR /f "tokens=1* delims=," %%a IN ("%list%") DO (
	if not "%%a" == "" echo %2^) %%a
	if not "%%b" == "" (
		set /a NextNum=%2+1
		call :parsenames "%%b" !NextNum!
	)
)
exit /b

:printname
echo %2^) %1
exit /b

:picklist
set list=%1
set list=%list:"=%
set NextNum=%3
FOR /f "tokens=1* delims=," %%a IN ("%list%") DO (
	if !NextNum! == %2 (
		Set Picked_Name=%%a
		exit /b 
	)
	if not "%%b" == "" (
		set /a NextNum += 1
		call :picklist "%%b" %2 !NextNum! 
	)
)
exit /b

