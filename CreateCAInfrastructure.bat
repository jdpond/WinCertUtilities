@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateCAInfrastructure</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Create a complete CA infrastructure including a CA Root, an email CA, a code signing CA and a TLS (SSL client and server) CA
Rem @param If parameter passed, must correspond to a valid conf file (without the extension) for building a CA.
Rem
call "etc/CertConfig.bat"

if "%1" == "" (
	set CA_Build=ALL
) else (
	set CA_Build=%1
)	

:AllCerts

echo What Certificate Authority name do you wish to use [please make it descriptive such as the certificate name, ex: "yourname_com"]
set /p CertName=Certificate Name? 
if defined CertName goto :CertNameEntered
echo Invalid Response, you must enter a valid name.
pause
goto :eof

:CertNameEntered

call :CheckIfExists rootca %CertName%
call :CheckIfExists emailca %CertName%
call :CheckIfExists signcodeca %CertName%
call :CheckIfExists tlsca %CertName%
call :CheckIfExists developerca %CertName%

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
call :NewDir rootca %CertName%
call :NewDir tlsca %CertName%
call :NewDir emailca %CertName%
call :NewDir signcodeca %CertName%
call :NewDir developerca %CertName%



call :MakeRoot rootca %CertName% %RADays% 
call :MakeOtherCAs signcodeca %CertName% %RADays% 
call :MakeOtherCAs tlsca %CertName% %RADays% 
call :MakeOtherCAs emailca %CertName% %RADays% 
call :MakeOtherCAs developerca %CertName% %RADays% 

pause
exit /b

echo.
echo Three files have been created:
echo		%CD%\%CertName%\%CertName%Root.key - Private Key ^(Required when used to generate further CAs^)
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
if %1 == %CA_BUILD% (
	call :SCheckIfExists %1 %2
) else (
	if %1 == ALL call :SCheckIfExists %1 %2
)
exit /b

:SCheckIfExists
if NOT EXIST %1_%2 goto :eof
echo That CA directory ^(%1_%2^) already exists, you might overwrite an existing Certificate Authority - THIS COULD BE REALLY BAD. 
set /p FExists=Are you absolutely sure^(Y/N^)?[N]: 
if not defined FExists goto :AllCerts
if %FExists% == Y goto :eof
exit -1

:NewDir

if %1 == %CA_BUILD% (
	call :SNewDir %1 %2
) else (
	if %CA_BUILD% == ALL call :SNewDir %1 %2
)
exit /b

:SNewDir
set _caname=%1
set _certname=%2

if NOT EXIST %1_%2 mkdir %1_%2
if NOT EXIST "%1_%2/db" mkdir "%1_%2/db"
if NOT EXIST "%1_%2/crl" 	mkdir "%1_%2/crl"
if NOT EXIST "%1_%2/certs" mkdir "%1_%2/certs"
if NOT EXIST "%1_%2/private" mkdir "%1_%2/private"
if NOT EXIST "%1_%2/etc" mkdir "%1_%2/etc"
if NOT EXIST "%1_%2/etc/ClientConfigurations" mkdir "%1_%2/etc/ClientConfigurations"
if NOT EXIST "%1_%2/etc/CAConfigurations" mkdir "%1_%2/etc/CAConfigurations"
if NOT EXIST "%1_%2/rqsts" mkdir "%1_%2/rqsts"
if NOT EXIST "%1_%2/pending_rqsts" mkdir "%1_%2/pending_rqsts"
copy /Y "etc\CAConfigurations\%1.conf" "%1_%2\etc\CAConfigurations" > nul
type NUL > "%1_%2\etc\CAConfigurations\openssl.conf"
for /f "usebackq tokens=* delims=" %%f in (etc\CAConfigurations\%1.conf) do call :parseit %%f

type NUL > "%1_%2/db/%1_%2.db"
type NUL > "%1_%2/db/%1_%2.db.attr"
@echo 01 > "%1_%2/db/%1_%2.crt.srl"
@echo 01 > "%1_%2/db/%1_%2.crl.srl"
@cacls %1_%2 /T /G "%USERDOMAIN%\%USERNAME%":F > nul < yes.txt
exit /b

:MakeRoot

if %1 == %CA_BUILD% (
	call :SMakeRoot %1 %2 %3
) else (
	if %CA_BUILD% == ALL call :SMakeRoot %1 %2 %3
)
exit /b

:SMakeRoot
echo #################################################################################
echo ###
echo ###       You are creating a %1 authority named %1_%2
echo ###
echo #################################################################################
set CA_NAME=%1_%2
Rem Create the key and request
Rem set OPENSSL_CONF="%1_%2/etc/CAConfigurations/%1.conf" 
"%OpenSSLExe%" req -new -days %3 -config "%1_%2/etc/CAConfigurations/%1.conf" -out "%1_%2/private/%1_%2.csr" -keyout "%1_%2/private/%1_%2.key" 
REM Self-sign the request 
"%OpenSSLExe%" ca -selfsign -config "%1_%2/etc/CAConfigurations/%1.conf" -name %1 -in "%1_%2/private/%1_%2.csr" -out "%1_%2/certs/%1_%2.crt" -extensions %1_ext -enddate 310101000000Z
REM Generate the empty CRL
"%OpenSSLExe%" ca -gencrl -config "%1_%2/etc/CAConfigurations/%1.conf" -out "%1_%2/crl/%1_%2.crl"
"%OpenSSLExe%" x509 -outform der -in "%1_%2/certs/%1_%2.crt" -out "%1_%2/certs/%1_%2.cer" 
"%OpenSSLExe%" crl -outform der -in "%1_%2\crl\%1_%2.crl" -out "%1_%2\crl\%1_%2.crl" 
exit /b

:MakeOtherCAs
if %1 == %CA_BUILD% (
	call :SMakeOtherCAs %1 %2 %3
) else (
	if %CA_BUILD% == ALL call :SMakeOtherCAs %1 %2 %3
)
exit /b

:SMakeOtherCAs

set CA_NAME=%1_%2
echo #################################################################################
echo ### 
echo ###       You are creating a %1 authority named %1_%2
echo ###
echo #################################################################################
Rem Create the key and request
"%OpenSSLExe%" req -new -days %3 -config "%1_%2/etc/CAConfigurations/%1.conf" -out "%1_%2/private/%1_%2.csr" -keyout "%1_%2/private/%1_%2.key" 
REM sign the request
set CA_NAME=rootca_%2
"%OpenSSLExe%" ca -config "rootca_%2/etc/CAConfigurations/rootca.conf" -name signingca -extensions signingca_ext -days %3 -in "%1_%2/private/%1_%2.csr" -out "%1_%2/certs/%1_%2.crt"
REM Generate the empty and DER versions of both (required for publication according to RFC 2585, http://tools.ietf.org/html/rfc2585.html#section-4.2
set CA_NAME=%1_%2
"%OpenSSLExe%" ca -gencrl -config "%1_%2/etc/CAConfigurations/%1.conf" -out "%1_%2/crl/%1_%2.crl"
copy /b /Y "%1_%2\certs\%1_%2.crt"+"rootca_%2\rootca_%2.crt" "%1_%2\certs\%1_%2.chain.pem" >nul
"%OpenSSLExe%" x509 -outform der -in "%1_%2/certs/%1_%2.crt" -out "%1_%2/certs/%1_%2.cer" 
"%OpenSSLExe%" crl -outform der -in "%1_%2/crl/%1_%2.crl" -out "%1_%2/crl/%1_%2.crl"
exit /b

FOR /F "usebackq tokens=* delims=" %%a in (`"findstr /n ^^ \etc\CAConfigurations\!_caname!.conf"`) do (
)

:parseit
set _line=%*
if "!_line:~0,7!" == "CRL_URL" (
	echo CRL_URL					= !CRL_URL!			^# Base URL for CRL Distribution Point >> "!_caname!_!_certname!\etc\CAConfigurations\!_caname!.conf"
) else (
	if "!_line:~0,8!" == "CIDP_URL" (
		echo CIDP_URL				= %CIDP_URL%			^# Base address for Certificate Issuer^'s Distribution Point >> "!_caname!_!_certname!\etc\CAConfigurations\!_caname!.conf"
	) else (
		if "!_line!" == "" (
			echo .
		) else (
			echo !_line! >> "!_caname!_!_certname!\etc\CAConfigurations\!_caname!.conf"
		)
	)
)
exit /b
