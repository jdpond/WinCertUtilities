@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateEncryptedKey(fromPasswordless)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description Create a private, encrypted (aes256) RSA key (pem) from a 509v3 unencrypted key
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call "etc/CertConfig.bat"

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\!CertName!.nopass.key" goto :ValidCertName
)


FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.nopass.key" (
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
	echo You do not have a valid certificate set ready for conversion.  You need to have a passwordless key ^(%%name%%\%%name%%.nopass.pem^)
	echo.
	echo If you have not done so already, you can create a such a set from scratch by following the required instructions by using the RequestNewCert.bat command file.
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=From which Certificate set do you wish to create the private encrypted key ^(by number^)?: 
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

if exist "%CertName%\%CertName%.private.key" (
	set /p CertConfirm=Are you sure you want to create a new encrypted private key "%CertName%"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new encrypted private key "%CertName%"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key "%CertName%"
	pause
	goto :eof
)

%OpenSSLExe% rsa -aes256 -in "%CertName%\%CertName%.nopass.key" -out "%CertName%\%CertName%.private.key" 

echo.
echo The following file has been created:
echo       Private no password RSA Key - ^>^>^> %CD%\%CertName%\%CertName%.private.key ^<^<^<
echo.
pause

:eof

