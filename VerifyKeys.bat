@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>VerifyKeys</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Verify Certificates
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call CertConfig.bat

:PickCertName
if "%1" NEQ "" (
	set CertName=%1
	set TestVar=!CertName:~0,1!
	set TestVar2="
	if !TestVar!==!TestVar2! set CertName=!CertName:~1,-1!
	if exist "!CertName!\!CertName!.private.key" goto :ValidCertName
)


FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\%%i.private.key" (
		set /a DirCount += 1
		set v!DirCount!=%%i
		echo !DirCount!^) %%~ni
		if !DirCount! GTR 20 (
			echo.
			echo This utility can only handle up to 20 keys.  You will only be able to select up to the first 20 keys.
			echo.
			pause
		)
	)
)


if not defined DirCount ( 
	echo.
	echo You do not have a valid certificate set ready for conversion.  You need to have a full x509 private key ^(%%name%%\%%name%%.private.key^)
	echo.
	echo If you have not done so already, you can create a such a set from scratch by following the required instructions by using the CreateServerSSLCertRequest.bat command file.
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=Which Certificate set do you wish to validate ^(by number^)?: 
)

if %CertID% GTR 0 if %CertID% LEQ !DirCount! if %CertID% LEQ 20 (
	if !CertID! == 1 set CertName=!V1!
	if !CertID! == 2 set CertName=!V2!
	if !CertID! == 3 set CertName=!V3!
	if !CertID! == 4 set CertName=!V4!
	if !CertID! == 5 set CertName=!V5!
	if !CertID! == 6 set CertName=!V6!
	if !CertID! == 7 set CertName=!V7!
	if !CertID! == 8 set CertName=!V8!
	if !CertID! == 9 set CertName=!V9!
	if !CertID! == 10 set CertName=!V10!
	if !CertID! == 11 set CertName=!V11!
	if !CertID! == 12 set CertName=!V12!
	if !CertID! == 13 set CertName=!V13!
	if !CertID! == 14 set CertName=!V14!
	if !CertID! == 15 set CertName=!V15!
	if !CertID! == 16 set CertName=!V16!
	if !CertID! == 17 set CertName=!V17!
	if !CertID! == 18 set CertName=!V18!
	if !CertID! == 19 set CertName=!V19!
	if !CertID! == 20 set CertName=!V20!
) else (
	echo Invalid Selection, must be 1-!%DirCount%! and Less than or equal to 20
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
if exist "%CertName%\%CertName%.chain.crt" (
	set IncludeChain=-CAfile ^"%CertName%\%CertName%.chain.crt" -chain
)

%OpenSSLExe% verify -CAfile "%CertName%\%CertName%.chain.crt" "%CertName%\%CertName%.crt" 

echo Verification complete.
set IncludeChain=
if not exist "%CertName%\%CertName%.chain.crt" (
	echo If your verification failed, it may be because you did not download or specify the certificate validation chain.
	echo The chain file was unavailable: "%CD\%CertName%\%CertName%.chain.crt"
)

pause

echo x509 public certificate information:
%OpenSSLExe% x509 -text -in "%CertName%\%CertName%.crt" -noout
pause

rem echo rsa Information:
rem %OpenSSLExe% rsa -text -in "%CertName%\%CertName%.private.key" -noout
Rem echo.
Rem echo.
Rem pause

:eof

