@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreatePasswordlessKey(fromPKCS12)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Extract a private, unencrypted PKCS12 key (pfx) from a full PKCS12 (encrypted)
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call "etc/CertConfig.bat"

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\!CertName!.pfx" goto :ValidCertName
)


FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.pfx" (
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
	echo You do not have a valid certificate set ready for conversion.  You need to have a full key set ^(%%name%%\%%name%%.pfx^)
	echo.
	echo If you have not done so already, you can create a such a set from scratch by following the required instructions by creating a new set command file.
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=From which Certificate set do you wish to create the private unencrypted key ^(by number^)?: 
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

if exist "%CertName%\%CertName%.nopass.pfx" (
	set /p CertConfirm=Are you sure you want to create a new unencrypted private key "%CertName%"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new unencrypted private key "%CertName%"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key set "%CertName%"
	pause
	goto :eof
)

%OpenSSLExe% pkcs12 -in "%CertName%\%CertName%.pfx" -out "%CertName%\%CertName%.nopass.pfx"

echo.
echo The following file has been created:
echo       Private no password PKCS12 (pfx) Key - ^>^>^> %CD%\%CertName%\%CertName%.nopass.pfx ^<^<^<
echo.
pause

:eof

