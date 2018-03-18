@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>AskForCertificate(CSR).bat</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Create a private key and a certificate signing request
Rem
call "etc/CertConfig.bat"

:EnterCertName
echo What Certificate Name do you wish to use [please make it short and descriptive such as a username, ex: "yourname(useage)"]
set /p CertName=Certificate Name? 
if defined CertName goto :SelectCertType
echo Invalid Response, you must enter a valid name.
pause
goto :eof

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
if NOT EXIST "%CertName%/certs" mkdir "%CertName%/certs"
if NOT EXIST "%CertName%/private" mkdir "%CertName%/private"
if NOT EXIST "%CertName%/etc" mkdir "%CertName%/etc"
if NOT EXIST "%CertName%/rqsts" mkdir "%CertName%/rqsts"
copy /Y "etc\ClientConfigurations\%Picked_Name%" "%CertName%\etc\*.*" > nul


set CertNameDir=%CertName%
set /a fcount=0
FOR /F "usebackq delims=" %%i in (`dir /B/A:-D "%CertNameDir%\rqsts\%CertName%*" `) do (
	set /a fcount += 1
	if NOT EXIST "%CertNameDir%\rqsts\%CertName%^(!fcount!^).csr.txt" (
		Set CertName=%CertName%^(!fcount!^)
		goto :CreateCSR
	)
)

:CreateCSR

if "!Picked_Name!" == "RequestServerSSLCertificate.conf" (
	set /p SANValues=Comma delimited Subject Alternative Names^(SAN^) for X509 V3 certifications? ^(e.g. DNS:yourserver.yourdomain.com, DNS:*.yourdomain.com^):  
	if not defined SANValues goto :eof
)

"%OpenSSLExe%" req -newkey rsa:4096 -sha512 -out "%CertNameDir%/rqsts/%CertName%.csr.txt" -keyout "%CertNameDir%/private/%CertName%.key" -config "%CertNameDir%/etc/%Picked_Name%" -pkeyopt rsa_keygen_bits:4096

@cacls %CertNameDir% /T /G "%USERDOMAIN%\%USERNAME%":F > nul < yes.txt

rem FOR /F "usebackq skip=2 tokens=2* delims=\:" %%i in (`cacls "%CertName%"`) do cacls "%CertName%" /E /R %%i >nul

echo.
echo Two files have been created:
echo		%CD%\%CertNameDir%\private\%CertName%.key - Private Key
echo		%CD%\%CertNameDir%\rqsts\%CertName%.csr.txt - Certificate Signing Request ^(CSR^)
echo.
echo Copy the following instructions and save them, or use the readme file at:
echo 		%CD%\%CertNameDir%\RequestCertificateInstructions.txt
echo.
echo Please attach the CSR ^( %CD%\%CertNameDir%\rqsts\%CertName%.csr.txt ^) to an email and your contact information
echo and send it to the Certificate Authority (CA) Administrator at:
echo		mailto:%DefaultCAEmail%
echo.
echo The CA Administrator will contact you and verify information - as well as give you a user ID and password where you can
echo complete the registration process and get your certificate in keeping with the Certificate Policy instructions and
echo level of assurance requirements.
echo.
echo Once the certificate request has been authorized, you will receive an email from the CA Administrator with instructions on
echo how to obtain your certificate.
echo.
echo Please attach the CSR ^( %CD%\%CertNameDir%\rqsts\%CertName%.csr.txt ^) to an email and your contact information > "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo and send it to the Certificate Authority (CA) Administrator at: >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo		mailto:%DefaultCAEmail% >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo. >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo The CA Administrator will contact you and verify information - as well as give you a user ID and password where you can >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo complete the registration process and get your certificate in keeping with the Certificate Policy instructions and >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo level of assurance requirements. >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo. >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo Once the certificate request has been authorized, you will receive an email from the CA Administrator with instructions on >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
echo how to obtain your certificate. >> "%CD%\%CertNameDir%\RequestCertificateInstructions.txt"
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
