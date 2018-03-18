@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>ShowPKCS12Details(fromPFX)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki/Home
Rem @description Output PKCS12 (PFX) Information
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call "etc/CertConfig.bat"
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
	if exist "%%i\private\*.pfx" (
		FOR /F "usebackq delims=" %%j in (`dir /B/A "%%i\private\*.pfx"`) do (
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
	echo You do not have any valid PKCS12 keys that I can find
	echo in a named sub directory ^(%%private%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!FNames!
	set Picked_Dir=!DirNames!
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
rem 	set Picked_Name=!Picked_Name:~0,-4!
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCertName
)

:ValidCertName


set IncludeChain=
rem if exist "%CertName%\%CertName%.chain.crt" (
rem 	set IncludeChain=-CAfile ^"%CertName%\%CertName%.chain.crt" -chain
rem )


echo %OpenSSLExe% pkcs12 %IncludeChain% -in "%Picked_Dir%/private/%Picked_Name%" -nokeys 
echo on
%OpenSSLExe% pkcs12 %IncludeChain% -in "%Picked_Dir%/private/%Picked_Name%" -info -nokeys
echo off 

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
