@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateRenewCertificateRequest(CSR)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Create a renewal request from a full 509v3 signed key with certificate chain (fullwithcerts.pem) 
rem @description 	and the original signed request (crt)
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call "etc/CertConfig.bat"

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\private\!CertName!.key" goto :ValidCertName
)

echo Create a certificate renewal request ^(CSR^)
echo .
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\private\%%i.key" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You have any private keys set up in your path ^([key]/private/*.key^)
	echo To set up a CA, you may want to use the CA INfrastruction Creation Tool^(CreateCAInfrastructure^).
	echo If you have a CA set up, you may need to copy your CSR into the appropriate "crl" directory.
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which key would you like to issue a renewal request for^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCertName
)

:ValidCertName

if exist "%Picked_Name%\%Picked_Name%.renew.csr.txt" (
	set /p CertConfirm=Are you sure you want to create a new Certificate Renew Request "%Picked_Name%"^(CSR ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new Certificate Renew Request "%Picked_Name%"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create Certificate Signing Request "%Picked_Name%"
	pause
	goto :eof
)

%OpenSSLExe% x509 -x509toreq -signkey "%Picked_Name%\private\%Picked_Name%.key" -out "%Picked_Name%\%Picked_Name%.renew.csr.txt" -in "%Picked_Name%\%Picked_Name%.crt"

echo.
echo The following file has been created:
echo       Certificate Renewal Request ^>^>^>  %CD%\%Picked_Name%\%Picked_Name%.renew.csr.txt  ^<^<^<
echo.
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
