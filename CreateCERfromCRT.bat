@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateCERfromCRT)</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Convert a 509 public certificate (CRT) to Base-64 encoded DER format (CER)
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

echo Convert a 509 public certificate ^(CRT^) to DER format ^(CER^)
echo.
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\certs\%%i.crt" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a CRT public key in your path.  You need to have a unencrypted key ^(%%name%%\%%name%%.crt^)
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

if exist "%Picked_Name%\certs\%Picked_Name%.cer" (
	set /p CertConfirm=Are you sure you want to create a new public DER key "%Picked_Name%.cer"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new public DER key "%Picked_Name%.cer"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create key "%Picked_Name%"
	pause
	goto :eof
)

rem %OpenSSLExe% x509 -outform der -in %Picked_Name%/%Picked_Name%.crt" -out "%Picked_Name%/%Picked_Name%.cer" 
%OpenSSLExe% x509 -outform der -in "%Picked_Name%/certs/%Picked_Name%.crt" -out "%Picked_Name%/certs/%Picked_Name%.cer" 

echo.
echo The following file has been created:
echo       DER (Base-64 encoded) Certificate ^>^>^> %CD%\%Picked_Name%/certs/%Picked_Name%.cer ^<^<^<
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
