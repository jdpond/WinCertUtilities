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
	if exist "!CertName!\private\!CertName!.key" goto :ValidCertName
)

echo Convert a PKCS#7 key ^(p7b^)
echo.
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.p7b" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a signature/certificate ready for conversion.  You need to have a PKCS#7 key ^(%%name%%\%%name%%.p7b^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	echo Such a key usually arrives from an external Certificate Authority ^(such as Digicert^)
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
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
set AuthKeyName=%CD%\%Picked_Name%\%Picked_Name%.crt
if exist "%Picked_Name%.crt" (
	set /p CertConfirm=Are you sure you want to create a signature/authorization set "%Picked_Name%.crt"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a signature/authorization set "%Picked_Name%.crt"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create signature/authorization "%Picked_Name%.crt"
	pause
	goto :eof
)

:CertNameEntered
%OpenSSLExe% pkcs7 -print_certs -in "%Picked_Name%\%Picked_Name%.p7b" -out "%Picked_Name%\%Picked_Name%.crt"

echo.
echo The following file was Created:
echo       signature/authorization - %CD%\%Picked_Name%\%Picked_Name%.crt
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
