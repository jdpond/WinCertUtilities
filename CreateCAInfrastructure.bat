@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateNewCertificate</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description Create a complete CA infrastructure including a CA Root, an email CA, a code signing CA and a TLS (SSL client and server) CA
Rem
call "etc/CertConfig.bat"

:AllCerts

echo What Certificate Authority name do you wish to use [please make it descriptive such as the certificate name, ex: "yourname_com"]
set /p CertName=Certificate Name? 
if defined CertName goto :CertNameEntered
echo Invalid Response, you must enter a valid name.
pause
goto :eof

:CertNameEntered

call :CheckIfExists rootca_%CertName%
call :CheckIfExists emailca_%CertName%
call :CheckIfExists signcodeca_%CertName%
call :CheckIfExists tlsca_%CertName%

:AuthorityDays

echo How long do you wish your root CA certificate to be valid in days.  Default is 10 years in days [3652]
set /p RootCADays=Root CA Validity in days[3652]? 
if defined RootCADays goto :RootCADaysEntered
set RootCADays=3652

:RootCADaysEntered

echo How long do you wish your Registration Authorities ^(RA^) certificates to be valid in days.  Default is 10 years in days [3651]
set /p RADays=Registration Authority ^(RA^)  Validity in days[3651]? 
if defined RADays goto :RADaysEntered
set RADays=3651

:RADaysEntered
if %RootCADays% GTR %RADays% goto :GenKeys
echo The validity period of the Registration Authorities ^(%RADays%^) must be less than your Root Certificate Authority ^(%RootCADays%^).
pause
set RADays=
set RootCADays=
goto :AuthorityDays

:GenKeys

call :NewDir rootca_%CertName%
call :NewDir tlsca_%CertName%
call :NewDir emailca_%CertName%
call :NewDir signcodeca_%CertName%

echo Where would you like to distribute your public certificates [e.g: http://www.yoursite.com/certs]
set /p CIDP_URL=Public Certificate Distribution Point? 
if defined CIDP_URL goto :CIDPURL
echo Invalid Response, you must enter a valid name.
pause
goto :eof

:CIDPURL

echo Where would you like to distribute your certificate revocation lists [e.g: http://www.yoursite.com/crl]
set /p CRL_URL=Certificate Revocation List Distribution Point^(CDP^)[%CIDP_URL%]? 
if defined CRL_URL goto :CRLURL
set CRL_URL=%CIDPURL%

:CRLURL

call :MakeRoot rootca %CertName% %RADays% 
call :MakeOtherCAs signcodeca %CertName% %RADays% 
call :MakeOtherCAs tlsca %CertName% %RADays% 
call :MakeOtherCAs emailca %CertName% %RADays% 

pause
goto :eof

%OpenSSLExe% genrsa -des3 -out "%CertName%/%CertName%.key" 4096
%OpenSSLExe% req -new -x509 -days 1826 -key "%CertName%/%CertName%.key" -out "%CertName%/%CertName%_root.crt"
%OpenSSLExe% genrsa -des3 -out "%CertName%/%CertName%.ia.key" 4096
%OpenSSLExe% req -new -key "%CertName%/%CertName%.ia.key" -out "%CertName%/%CertName%.ia.csr"
pause
%OpenSSLExe% x509 -req -days 730 -in "%CertName%/%CertName%.ia.csr" -CA "%CertName%/%CertName%.crt" -CAkey "%CertName%/%CertName%.key" -set_serial 01 -out "%CertName%/%CertName%.ia.crt"

FOR /F "usebackq skip=2 tokens=2* delims=\:" %%i in (`cacls "%CertName%"`) do cacls "%CertName%" /E /R %%i >nul

echo.
echo Three files have been created:
echo		%CD%\%CertName%\%CertName%Root.private.key - Private Key ^(Required when used to generate further CAs^)
echo		%CD%\%CertName%\%CertName%Root.csr.txt - Certificate Signing Request ^(CSR^)
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
goto :eof

:CheckIfExists
if NOT EXIST %1 goto :eof
echo That CA directory ^(%1^) already exists, you might overwrite an existing Certificate Authority - THIS COULD BE REALLY BAD. 
set /p FExists=Are you absolutely sure^(Y/N^)?[N]: 
if not defined FExists goto :AllCerts
if %FExists% == Y goto :eof
exit -1

:NewDir
if NOT EXIST %1 mkdir %1
if NOT EXIST "%1/db" mkdir "%1/db"
if NOT EXIST "%1/crl" 	mkdir "%1/crl"
if NOT EXIST "%1/certs" mkdir "%1/certs"
if NOT EXIST "%1/private" mkdir "%1/private"
if NOT EXIST "%1/etc" mkdir "%1/etc"
copy /Y "etc\*.conf" "%1\etc\*.*" > nul
type NUL > "%1/db/%1.db"
type NUL > "%1/db/%1.db.attr"
@echo 01 > "%1/db/%1.crt.srl"
@echo 01 > "%1/db/%1.crl.srl"
@cacls %1 /T /G "%USERDOMAIN%\%USERNAME%":F > nul < yes.txt
goto :eof

:MakeRoot
echo #################################################################################
echo ###
echo ###       You are creating a %1 authority named %1_%2
echo ###
echo #################################################################################
set CA_NAME=%1_%2
Rem Create the key and request
%OpenSSLExe% req -new -days %3 -config "%1_%2/etc/%1.conf" -out "%1_%2/private/%1_%2.csr" -keyout "%1_%2/private/%1_%2.key" 
REM Self-sign the request 
%OpenSSLExe% ca -selfsign -config "%1_%2/etc/%1.conf" -name %1 -in "%1_%2/private/%1_%2.csr" -out "%1_%2/%1_%2.crt" -extensions %1_ext -enddate 310101000000Z
REM Generate the empty CRL
%OpenSSLExe% ca -gencrl -config "%1_%2/etc/%1.conf" -out "%1_%2/crl/%1_%2.crl"
%OpenSSLExe% x509 -outform der -in "%1_%2\%1_%2.crt" -out "%1_%2\%1_%2.cer" 
%OpenSSLExe% crl -outform der -in "%1_%2\crl\%1_%2.crl" -out "%1_%2\crl\%1_%2.crl"
goto :eof

:MakeOtherCAs
set CA_NAME=%1_%2
echo #################################################################################
echo ### 
echo ###       You are creating a %1 authority named %1_%2
echo ###
echo #################################################################################
Rem Create the key and request
%OpenSSLExe% req -new -days %3 -config "%1_%2/etc/%1.conf" -out "%1_%2/private/%1_%2.csr" -keyout "%1_%2/private/%1_%2.key" 
REM sign the request
set CA_NAME=rootca_%2
%OpenSSLExe% ca -config "rootca_%2/etc/rootca.conf" -name signingca -extensions signingca_ext -days %3 -in "%1_%2/private/%1_%2.csr" -out "%1_%2/%1_%2.crt"
REM Generate the empty and DER versions of both (required for publication according to RFC 2585, http://tools.ietf.org/html/rfc2585.html#section-4.2
set CA_NAME=%1_%2
%OpenSSLExe% ca -gencrl -config "%1_%2/etc/%1.conf" -out "%1_%2/crl/%1_%2.crl"
copy /b /Y %1_%2\%1_%2.crt+rootca_%2\rootca_%2.crt %1_%2\%1_%2.chain.pem >nul
%OpenSSLExe% x509 -outform der -in "%1_%2\%1_%2.crt" -out "%1_%2\%1_%2.cer" 
%OpenSSLExe% crl -outform der -in "%1_%2\crl\%1_%2.crl" -out "%1_%2\crl\%1_%2.crl"
goto :eof