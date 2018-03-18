@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CASignCSR</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Sign a CSR creating an x.509 (.crt) certificate .
Rem @param CA_SIGN_NAME - Name of the certificate corresponding to directory and CA_SIGN_NAMEs

call "etc/CertConfig.bat"

:PickCA_SIGN_NAME

if "%1" NEQ "" (
	set CA_SIGN_NAME=%1
	set CA_SIGN_NAME=%CA_SIGN_NAME:"=%
	if exist "!CA_SIGN_NAME!\!CA_SIGN_NAME!\db" goto :ValidCAName
)

FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\pending_rqsts\*.csr" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
	)
)
if not defined DirCount ( 
	echo.
	echo You have no more pending CSR requests
	echo To set up a CA, you may want to use the CA INfrastruction Creation Tool^(CreateCAInfrastructure^).
	echo If you have a CA set up, you may need to copy your CSR into the appropriate "pending_rqsts" directory.
	echo.
	pause
	goto :eof
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=With which Certificate Authority do you wish to sign a certificate ^(by number^)[or q to quit]?: 
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
FOR /F "usebackq delims=" %%i in (`dir /B "!CA_SIGN_NAME!\pending_rqsts\*.csr"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%~ni
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCertName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=With which Certificate do you wish to sign ^(by number^)[or q to quit]?: 
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
Set CertName=!Picked_Name!
:GetValidConfName
set /a DirCount = 0
Set DirNames=
FOR /F "usebackq delims=" %%i in (`dir /B "!CA_SIGN_NAME!\etc\CAConfigurations\*.conf"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%i
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidConfName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=With which CA Certificate Configuration do you wish to sign with ^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)
if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount! 
	echo.
	goto :GetValidConfName
)

:ValidConfName
Rem 
Rem Actually performs signature here
Rem 
echo Certificate Authority !CA_SIGN_NAME! Certificate: !CertName! Conf: !Picked_Name!
set CA_NAME=!CA_SIGN_NAME!

"%OpenSSLExe%" ca -config "!CA_SIGN_NAME!/etc/CAConfigurations/!Picked_Name!" -in "!CA_SIGN_NAME!/pending_rqsts/!CertName!.csr" -out "!CA_SIGN_NAME!/certs/!CertName!.crt"
rem Then move from pending_rqsts to rqsts
move "!CA_SIGN_NAME!\pending_rqsts\!CertName!.csr" "!CA_SIGN_NAME!\rqsts\!CertName!.csr"
pause
goto :eof


:parsenames
set list=%1
set list=%list:"=%
set NextNum=%2
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

