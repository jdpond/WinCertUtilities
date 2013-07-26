@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateNewCertificate</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Create a private key and a certificate signing request
Rem
call "etc/CertConfig.bat"

if exist %OpenSSLExe% goto :PickCertType
echo To use these utilities, you must have a running copy of OpenSSL running at the location specified in CertConfig.bat
echo You can download this open source system from:  http://www.openssl.org/related/binaries.html
echo If you loaded the system into a non-standard directory, you will have to modify CertConfig.bat to specify the proper location
echo.
pause
exit

:PickCertType
echo Which Certificate type do you wish to request?
FOR /F "usebackq delims=" %%i in (`dir etc\*.conf /B`) do (
	set /a N += 1
	set v!N!=%%i
	if "%%~ni" == "%DefaultCertType%" (echo !N!^) %%~ni [Default]
		set /a DefCertPick=!N!
	) else (
		echo !N!^) %%~ni
	)
)
set /p CertType=Certificate type?[%DefCertPick%]: 
if not defined CertType if not defined DefCertPick (
	echo Invalid Response, you must choose a certificate type
	pause
	goto :PickCertType
) else set CertType=%DefCertPick%

if %CertType% GTR 0 if %CertType% LEQ !N! (
	if %CertType% == 1 set CertTempl=!V1!
	if %CertType% == 2 set CertTempl=!V2!
	if %CertType% == 3 set CertTempl=!V3!
	if %CertType% == 4 set CertTempl=!V4!
	if %CertType% == 5 set CertTempl=!V5!
	if %CertType% == 6 set CertTempl=!V6!
	if %CertType% == 7 set CertTempl=!V7!
	if %CertType% == 8 set CertTempl=!V8!
	if %CertType% == 9 set CertTempl=!V9!
	if %CertType% == 10 set CertTempl=!V10!
) else (
	echo Invalid Selection "%CertType%", must be 1-!N!
	goto :PickCertType
)

:AllCerts
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	goto :CertNameEntered
)

echo What Certificate Name do you wish to use [please make it short and descriptive such as a username, ex: "jpond(ITS)"]
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

:NoNewDir
%OpenSSLExe% req -new -keyout "%CertName%\%CertName%.privatekey.pem"  -days 730 -out "%CertName%\%CertName%.csr.txt" -config "etc\%CertTempl%"
FOR /F "usebackq skip=2 tokens=2* delims=\:" %%i in (`cacls "%CertName%"`) do cacls "%CertName%" /E /R %%i >nul

echo.
echo Two files have been created:
echo		%CD%\%CertName%\%CertName%.private.key - Private Key
echo		%CD%\%CertName%\%CertName%.csr.txt - Certificate Signing Request ^(CSR^)
echo.
echo Please attach the CSR ^( %CD%\%CertName%\%CertName%.csr.txt ^) to an email and send it to the Certificate Authority (CA) Administrator.
echo.
echo The CA Administrator will mail back a URL where you can copy your certificate with instructions on how to create your own private/public set.
pause

