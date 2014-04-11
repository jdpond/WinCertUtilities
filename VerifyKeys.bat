@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>VerifyKeys</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Verify Certificates
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
	if exist "!CertName!\!CertName!.crt" goto :ValidCertName
)

echo Verify Certificates ^(key^)
echo.
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.crt" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a valid certificate set ready for validation.  You need to have a full key set ^(%%name%%\%%name%%.crt^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which key would you like to verify(by number^)[or q to quit]?: 
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

rem echo "%CertName%\%CertName%.pem" Modulus:
rem %penSSLExe% x509 -noout -text -in "%CertName%\%CertName%.pem" -modulus 
rem echo "%CertName%\%CertName%.key" Modulus:
rem openssl rsa -noout -text -in "%CertName%\%CertName%.key" -modulus
rem IF ERRORLEVEL NEQ 0 goto :noerror
rem pause

:noerror

set IncludeChain=
if exist "%Picked_Name%\%Picked_Name%.chain.crt" (
	set IncludeChain=-CAfile ^"%Picked_Name%\%Picked_Name%.chain.crt" -chain
)

%OpenSSLExe% verify -CAfile "%Picked_Name%\%Picked_Name%.chain.crt" "%CertName%\%Picked_Name%.crt" 

echo Verification complete.
set IncludeChain=
if not exist "%Picked_Name%\%Picked_Name%.chain.crt" (
	echo If your verification failed, it may be because you did not download or specify the certificate validation chain.
	echo The chain file was unavailable: "%CD\%Picked_Name%\%Picked_Name%.chain.crt"
)

pause

echo x509 public certificate information:
%OpenSSLExe% x509 -text -in "%Picked_Name%\%Picked_Name%.crt" -noout
pause

rem echo rsa Information:
rem %OpenSSLExe% rsa -text -in "%Picked_Name%\%Picked_Name%.key" -noout
Rem echo.
Rem echo.
Rem pause

:eof

