@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateIndividualCertificateRequest</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Create a private key and a certificate signing request
Rem
call "etc/CertConfig.bat"

:EnterCertName
echo What Certificate Name do you wish to use [please make it short and descriptive such as a username, ex: "yourname(useage)"]
set /p CertName=Certificate Name? 
if defined CertName goto :CertNameEntered
echo Invalid Response, you must enter a valid name.
pause
goto :eof

:CertNameEntered
if NOT EXIST %CertName% goto :SelectCertType
set /p FExists=That directory already exists, you might overwrite existing keys.  Are you absolutely sure^(Y/N^)?[N]: 
if not defined FExists goto :EnterCertName
if %FExists% == Y goto :SelectCertType
goto :EnterCertName

:SelectCertType
FOR /F "usebackq delims=" %%i in (`dir /B "etc\ClientConfigurations\*.conf"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%i
)

if not defined DirCount ( 
	echo.
	echo You have no Certificate Request Configurations available.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :NewDir
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which type of certificate are you requesting ^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :SelectCertType
)

:NewDir

if NOT EXIST %CertName% mkdir %CertName%
if NOT EXIST "%CertName%/private" mkdir "%CertName%/private"
if NOT EXIST "%CertName%/etc" mkdir "%CertName%/etc"
copy /Y "etc\ClientConfigurations\%Picked_Name%" "%CertName%\etc\*.*" > nul

%OpenSSLExe% req -new -keyout "%CertName%/private/%CertName%.key" -days 730 -out "%CertName%/%CertName%.csr.txt" -config "etc/ClientConfigurations/%Picked_Name%"

@cacls %CertName% /T /G "%USERDOMAIN%\%USERNAME%":F > nul < yes.txt

rem FOR /F "usebackq skip=2 tokens=2* delims=\:" %%i in (`cacls "%CertName%"`) do cacls "%CertName%" /E /R %%i >nul

echo.
echo Two files have been created:
echo		%CD%\%CertName%\private\%CertName%.key - Private Key
echo		%CD%\%CertName%\%CertName%.csr.txt - Certificate Signing Request ^(CSR^)
echo.
echo Please attach the CSR ^( %CD%\%CertName%\%CertName%.csr.txt ^) to an email and send it to the Certificate Authority (CA) Administrator.
echo.
echo The CA Administrator will mail back a URL where you can copy your certificate with instructions on how to create your own private/public set.
pause

goto :eof

:parsenames
set list=%1
set list=%list:"=%
FOR /f "tokens=1* delims=," %%a IN ("%list%") DO (
	if not "%%a" == "" echo %2^) %%~na
	if not "%%b" == "" (
		set /a NextNum=%2+1
		call :parsenames "%%b" !NextNum!
	)
)
exit /b

:printname
echo %2^) %~s1
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
