@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateNewCertificate</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see 
Rem @description Create a private key and a certificate signing request
Rem
call "etc/CertConfig.bat"
set CertTempl=ServerSSLCertificate.conf

:AllCerts
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	goto :CertNameEntered
)

echo What Certificate Name do you wish to use [please make it descriptive such as the certificate name, ex: "www_yourname_com"]
set /p CertName=Certificate Name? 
if defined CertName goto :CertNameEntered
echo Invalid Response, you must enter a valid name.
pause
goto :eof

:CertNameEntered

if NOT EXIST %CertName% goto :NewDir
set /p FExists=That directory already exists, you might overwrite existing keys.  Are you absolutely sure^(Y/N^)?[N]: 
if not defined FExists goto :AllCerts
if %FExists% == Y goto :NoNewDir
goto :AllCerts

:NewDir
md %CertName%
@cacls %CertName% /T /G "%USERDOMAIN%\%USERNAME%":F > nul < yes.txt


:NoNewDir
rem openssl req -new -newkey rsa:2048 -nodes -out support_lextechaudits_com.csr -keyout support_lextechaudits_com.key -subj "/C=US/ST=Pennsylvania/L=Philadelphia/O=Lexington Technology/OU=Technology Services/CN=support.lextechaudits.com"
rem "c:\Program Files (x86)\OpenSSL\bin\openssl.exe" req -new -newkey rsa:2048 -nodes -out support_lextechaudits_com.csr -keyout support_lextechaudits_com.key -subj "/C=US/ST=Pennsylvania/L=Philadelphia/O=Lexington Technology/OU=Technology Services/CN=support.lextechaudits.com"
rem %OpenSSLExe% req -new -newkey rsa:2048 -keyout "%CertName%\%CertName%.privatekey.pem"  -days 365 -out "%CertName%\%CertName%.csr.txt" -config "%CertTempl%"
rem %OpenSSLExe% req -new -newkey rsa:2048 -x509 -sha256 -out "%CertName%/%CertName%.csr.txt" -keyout "%CertName%/%CertName%.privatekey.pem" -config "%CertTempl%"
%OpenSSLExe% req -newkey rsa:2048 -sha256 -out "%CertName%/%CertName%.csr.txt" -keyout "%CertName%/%CertName%.key" -config "%CertTempl%" -pkeyopt rsa_keygen_bits:2048

FOR /F "usebackq skip=2 tokens=2* delims=\:" %%i in (`cacls "%CertName%"`) do cacls "%CertName%" /E /R %%i >nul

echo.
echo Two files have been created:
echo		%CD%\%CertName%\%CertName%.key - Private Key
echo		%CD%\%CertName%\%CertName%.csr.txt - Certificate Signing Request ^(CSR^)
echo.
echo Copy the following instructions and save them, or use the readme file at:
echo 		%CD%\%CertName%\RequestCertificateInstructions.txt
echo.
echo Please attach the CSR ^( %CD%\%CertName%\%CertName%.csr.txt ^) to an email and your contact information
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
echo Please attach the CSR ^( %CD%\%CertName%\%CertName%.csr.txt ^) to an email and your contact information > "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo and send it to the Certificate Authority (CA) Administrator at: >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo		mailto:%DefaultCAEmail% >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo. >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo The CA Administrator will contact you and verify information - as well as give you a user ID and password where you can >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo complete the registration process and get your certificate in keeping with the Certificate Policy instructions and >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo level of assurance requirements. >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo. >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo Once the certificate request has been authorized, you will receive an email from the CA Administrator with instructions on >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
echo how to obtain your certificate. >> "%CD%\%CertName%\RequestCertificateInstructions.txt"
pause
