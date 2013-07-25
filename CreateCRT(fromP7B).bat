@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateCRT(fromP7B)</b> command file.
Rem @author Jack D. Pond
Rem @version 1.0 / Windows Batch Processor
Rem @see 
Rem @description Convert a PKCS#7 key to CRT (X.509) format
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
	if exist "!CertName!\!CertName!.p7b" goto :ValidCertName
)

FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.p7b" (
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
	echo You do not have a signature/certificate ready for conversion.  You need to have a PKCS#7 key ^(%%name%%\%%name%%.p7b^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	echo Such a key usually arrives from an external Certificate Authority ^(such as Digicert^)
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=From which Certificate set do wish to conver to PEM ^(by number^)?: 
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
set AuthKeyName=%CD%\%CertName%\%CertName%.crt
if exist "%AuthKeyName%" (
	set /p CertConfirm=Are you sure you want to create a signature/authorization set "%CertName%.crt"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a signature/authorization set "%CertName%.crt"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create signature/authorization "%CertName%.crt"
	pause
	goto :eof
)

:CertNameEntered
%OpenSSLExe% pkcs7 -print_certs -in "%CertName%\%CertName%.p7b" -out "%CertName%\%CertName%.crt"

echo.
echo The following file was Created:
echo       signature/authorization - %CD%\%CertName%\%CertName%.crt
echo.
pause

:eof

