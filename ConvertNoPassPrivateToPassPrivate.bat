@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>ConvertNoPassPrivateToPassPrivate</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description Create a private, encrypted (aes256) RSA key (pem) from a 509v3 unencrypted key
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
	if exist "!CertName!\private\!CertName!.nopass.key" goto :ValidCertName
)

echo Create a private, encrypted ^(aes256^) RSA key ^(pem^) from a 509v3 unencrypted key
echo.
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\private\%%i.nopass.key" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have and unprotected key in your path.  You need to have a unencrypted password protected key ^(%%name%%\private\%%name%%.nopass.key^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCertName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which key would you like to convert(by number^)[or q to quit]?: 
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

if exist "%Picked_Name%\private\%Picked_Name%.key" (
	set /p CertConfirm=Are you sure you want to create a new encrypted private key "%Picked_Name%.key"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new encrypted private key "%Picked_Name%.key"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key "%Picked_Name%"
	pause
	goto :eof
)

%OpenSSLExe% rsa -aes256 -in "%Picked_Name%\private\%Picked_Name%.nopass.key" -out "%Picked_Name%\private\%Picked_Name%.key" 

echo.
echo The following file has been created:
echo       Private with password Key - ^>^>^> %CD%\%CertName%\Private\%CertName%.key ^<^<^<
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
