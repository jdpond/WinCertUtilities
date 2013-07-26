@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateSSH2DESPairFromPrivateKey</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see 
Rem @description Create an SSH2 keyset(3DES encrypted) from an encrypted 509 key (private.key).
Rem @description   This key type is commonly used in Linux connection utilities such as PuTTY and WinSCP.
Rem @description   Additionally, it creates the public key x.509v3 key (.pub) and optionally creates the authorized_key ssh2
Rem @param CA_Name - Name of the certificate corresponding to directory and CA_Names

call "etc/CertConfig.bat"

:PickCA_Name

if "%1" NEQ "" (
	set CA_Name=%1
	set CA_Name=%CA_Name:"=%
	if exist "!CA_Name!\!CA_Name!\db" goto :ValidCAName
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
	goto :PickCA_Name
)

:ValidCAName
Set CA_Name=!Picked_Name!
:GetValidCertName
set /a DirCount = 0
Set DirNames=
FOR /F "usebackq delims=" %%i in (`dir /B "!CA_Name!\pending_rqsts\*.csr"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%i
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
echo Certificate Authority !CA_Name! Certificate: !Picked_Name!
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

