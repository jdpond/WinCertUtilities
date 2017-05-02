@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>ShowCER(DER)Details</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description Detailed information from a cetificate
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
	if exist "!CertName!\certs\!CertName!.crt" goto :ValidCertName
)

echo View details on a der encrypted certificate
echo.
set DirNames=
set FNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\certs\*.cer" (
		FOR /F "usebackq delims=" %%j in (`dir /B/A "%%i\certs\*.cer"`) do (
			set /a DirCount += 1
			if !DirCount! GTR 1 Set DirNames=!DirNames!,
			if !DirCount! GTR 1 Set FNames=!FNames!,
			Set DirNames=!DirNames!%%i
			Set FNames=!FNames!%%j
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a valid certificate to view keys.  You need to have a certificate ^(%%name%%\certs\%%name%%.cer^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!FNames!" 1
	set /p CertID=Which key would you like to convert(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
	set Picked_Dir=!Picked_Name!
	call :picklist "!FNames!" !CertID! 1
rem 	set Picked_Name=!Picked_Name:~0,-4!
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCertName
)

:ValidCertName


%OpenSSLExe% x509 -inform der -text -noout -in "%Picked_Dir%/certs/%Picked_Name%"

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
