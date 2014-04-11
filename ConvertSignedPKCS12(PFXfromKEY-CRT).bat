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

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\!CertName!.key" goto :ValidCertName
)

FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.key"  if exist "%%i\%%i.crt" (
		set /a DirCount += 1
		set v!DirCount!=%%i
		echo !DirCount!^) %%~ni
		if !DirCount! GTR 20 (
			echo.
			echo This utility can only handle up to 20 keys.  You will only be able to select up to the first 20 keys.
			echo.
			pause
		)
	)
)


if not defined DirCount ( 
	echo.
	echo You do not have a valid certificate pair ready for conversion.  You need to have a private key ^(%%name%%\%%name%%.key^) and
	echo a signed certificate ^(%%name%%\%%name%%.crt^) from a certificate authority in a named sub directory ^(%%name%%^).
	echo.
	echo If you have not done so already, you can create a private certificate and follow the required instructions by using the NewCert.bat command file.
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=From which Certificate pair do you wish to create a key set ^(by number^)?: 
)

if %CertID% GTR 0 if %CertID% LEQ !DirCount! if %CertID% LEQ 20 (
	if !CertID! == 1 set CertName=!V1!
	if !CertID! == 2 set CertName=!V2!
	if !CertID! == 3 set CertName=!V3!
	if !CertID! == 4 set CertName=!V4!
	if !CertID! == 5 set CertName=!V5!
	if !CertID! == 6 set CertName=!V6!
	if !CertID! == 7 set CertName=!V7!
	if !CertID! == 8 set CertName=!V8!
	if !CertID! == 9 set CertName=!V9!
	if !CertID! == 10 set CertName=!V10!
	if !CertID! == 11 set CertName=!V11!
	if !CertID! == 12 set CertName=!V12!
	if !CertID! == 13 set CertName=!V13!
	if !CertID! == 14 set CertName=!V14!
	if !CertID! == 15 set CertName=!V15!
	if !CertID! == 16 set CertName=!V16!
	if !CertID! == 17 set CertName=!V17!
	if !CertID! == 18 set CertName=!V18!
	if !CertID! == 19 set CertName=!V19!
	if !CertID! == 20 set CertName=!V20!
) else (
	echo Invalid Selection, must be 1-!%DirCount%! and Less than or equal to 20
	echo.
	goto :PickCertName
)

:ValidCertName
set /p CertConfirm=Are you sure you want to create a new key set for "%CertName%"(y,n)[y]?:
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key set "%CertName%"
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
if exist "%CertName%\%CertName%.chain.pem" (
	set IncludeChain=-CAfile ^"%CertName%\%CertName%.chain.crt" -chain
)

if exist "%CertName%\%CertName%.pfx" (
	set /p CertConfirm=The key set "%CertName%\%CertName%.pfx" already exists, are you sure you want to overwrite^(y,n^)[n]?:
	if "%CertConfirm%" == "" set CertConfirm=n
	if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
		echo You elected NOT to create key set "%CertName%\%CertName%.pfx"
		pause
		goto :eof
	)
)
rem echo %OpenSSLExe% pkcs12 %IncludeChain% -export -in "%CertName%\%CertName%.crt" -inkey "%CertName%\%CertName%.privatekey.pem" -out "%CertName%\%CertName%.pfx" -name "%FriendlyName%" >trash.txt
%OpenSSLExe% pkcs12 %IncludeChain% -aes256 -export -in "%CertName%\%CertName%.crt" -inkey "%CertName%\%CertName%.key" -out "%CertName%\%CertName%.pfx" -name "%FriendlyName%"
@echo off
echo.
echo PEM Public/Private 509 Certificate has been converted.  The full public/private PKCS12 certificate is: 
echo 	%CD%\%CertName%\%CertName%.pfx
echo.
echo You can double-click on this file to load it into your Microsoft Certificate store and it will load a certificate with friendly name %FriendlyName%.
echo Note:  If you want to use this as an IIS web server key, you need to go into IIS, remove the old server key, then import this key
echo.
pause

:eof
