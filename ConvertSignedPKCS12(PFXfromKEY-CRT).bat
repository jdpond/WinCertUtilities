@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateSignedPKCS12(PFXfromKEY-CRT)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see 
Rem @description Convert x509 key set (private and public) to a PKS#12 (PFX)
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call "etc/CertConfig.bat"

if exist %OpenSSLExe% goto :PickCertName
echo To use these utilities, you must have a running copy of OpenSSL running at the location specified in CertConfig.bat
echo You can download this open source system from:  http://www.openssl.org/related/binaries.html
echo If you loaded the system into a non-standard directory, you will have to modify CertConfig.bat to specify the proper location
echo.
pause
exit

call "etc/CertConfig.bat"

if exist %OpenSSLExe% goto :PickCertName
echo To use these utilities, you must have a running copy of OpenSSL running at the location specified in CertConfig.bat
echo You can download this open source system from:  http://www.openssl.org/related/binaries.html
echo If you loaded the system into a non-standard directory, you will have to modify CertConfig.bat to specify the proper location
echo.
pause
exit

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\private\!CertName!.key" goto :ValidCertName
)

echo Extract a private, unencrypted RSA key (pem) from a full 509v3 password protected key
echo.
set DirNames=
set FNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\private\*.key" (
		FOR /F "usebackq delims=" %%j in (`dir /B/A "%%i\private\*.key"`) do (
			set str1=%%j
			if "!str1:nopass=!"=="!str1!" (
				set /a DirCount += 1
				if !DirCount! GTR 1 Set DirNames=!DirNames!,
				if !DirCount! GTR 1 Set FNames=!FNames!,
				Set DirNames=!DirNames!%%i
				Set FNames=!FNames!%%j
			)
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a valid certificate set ready for conversion.  You need to have a full key set ^(%%name%%\private\%%name%%.key^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCertName
) else (
	call :parsenames "!FNames!" 1
	set /p CertID=Which key would you like to convert(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
	set Picked_Dir=!Picked_Name!
	call :picklist "!FNames!" !CertID! 1
	set Picked_Name=!Picked_Name:~0,-4!
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCertName
)

:ValidCertName
set /p CertConfirm=Are you sure you want to create a new key set for "%Picked_Name%"(y,n)[y]?:
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key set "%Picked_Name%"
	pause
	goto :eof
)

:AllCerts

echo What is the friendly name of the certificate? 
set /p FriendlyName=Friendly Name? 
if defined FriendlyName goto :FriendlyNameEntered
echo Invalid Response, you must enter a friendly name.
pause
goto :AllCerts

:FriendlyNameEntered

set IncludeChain=
if exist "%Picked_Dir%\certs\%Picked_Name%.chain.pem" (
	set IncludeChain=-CAfile "%Picked_Dir%\certs\%Picked_Name%.chain.crt" -chain
)
if exist "%Picked_Dir%\private\%Picked_Name%.pfx" (
	set /p CertConfirm=The key set "%Picked_Dir%\private\%Picked_Name%.pfx" already exists, are you sure you want to overwrite^(y,n^)[n]?:
	if "%CertConfirm%" == "" set CertConfirm=n
	if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
		echo You elected NOT to create key set "%Picked_Dir%\private\%Picked_Name%.pfx"
		pause
		goto :eof
	)
)
rem echo %OpenSSLExe% pkcs12 %IncludeChain% -export -in "%CertName%\%CertName%.crt" -inkey "%CertName%\%CertName%.privatekey.pem" -out "%CertName%\%CertName%.pfx" -name "%FriendlyName%" >trash.txt
%OpenSSLExe% pkcs12 %IncludeChain% -aes256 -export -in "%Picked_Dir%\certs\%Picked_Name%.crt" -inkey "%Picked_Dir%\private\%Picked_Name%.key" -out "%Picked_Dir%\private\%Picked_Name%.pfx" -name "%FriendlyName%"
@echo off
echo.
echo PEM Public/Private 509 Certificate has been converted.  The full public/private PKCS12 certificate is: 
echo 	%CD%\%Picked_Dir%\private\%Picked_Name%.pfx
echo.
echo You can double-click on this file to load it into your Microsoft Certificate store and it will load a certificate with friendly name "%FriendlyName%".
echo Note:  If you want to use this as an IIS web server key, you need to go into IIS, remove the old server key, then import this key
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
