@echo off
setLocal EnableDelayedExpansion
Rem <b>CAUpdateCRLs</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki and http://pki-tutorial.readthedocs.org/en/latest/index.html#
Rem @description Update Certificate Revocation lists.
Rem @param CA_SIGN_NAME - Name of the certificate corresponding to directory and CA_SIGN_NAMEs

call "etc/CertConfig.bat"

:PickCA_SIGN_NAME
if "%1" NEQ "" (
	set CA_SIGN_NAME=%1
	set CA_SIGN_NAME=%CA_SIGN_NAME:"=%
	if exist "!CA_SIGN_NAME!\!CA_SIGN_NAME!\db" goto :ValidCAName
)
echo Update Certificate Revocation Lists ^(CSLs^)
echo .
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\etc\CAConfigurations\*.conf" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
	)
)
if !DirCount! == 0 ( 
	echo.
	echo You have no Certificate Revocation Lists^(CRLs^)
	echo To set up a CA, you may want to use the CA Infrastruction Creation Tool^(CreateCAInfrastructure^).
	echo If you have a CA set up, you may need to copy your CSR into the appropriate "crl" directory.
	echo.
	pause
	goto :eof
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCAName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=For which Certificate Authority do you wish to generate a new Certificate Revocation List ^(CRL^) ^(by number^)[or a for all or q to quit]?: 
	if "!CertID!" == "q" goto :eof
	if "!CertID!" == "a" (
		set AllDirNames=!DirNames!
		echo.
		echo The Certificate Revocation List^(CRL^) has been created for Certificate Authority^(s^).  You need to upload it into your Certificate Distribution Point ^(CDP^)^:
		call :doCRLItem "!AllDirNames!" 1
		pause
		goto :eof
	)
)

if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount!
	echo.
	goto :PickCA_SIGN_NAME
)

:ValidCAName
Set CA_SIGN_NAME=!Picked_Name!
echo.
echo The Certificate Revocation List^(CRL^) has been created for Certificate Authority.  You need to upload it into your Certificate Distribution Point ^(CDP^):
call :DoAllCRLS
pause
goto :eof

:DoAllCRLs

:GetValidConfName
set /a DirCount = 0
set DirNames=
FOR /F "usebackq delims=" %%i in (`dir /B "!CA_SIGN_NAME!\etc\CAConfigurations\*.conf"`) do (
	set /a DirCount += 1
	if !DirCount! GTR 1 Set DirNames=!DirNames!,
	Set DirNames=!DirNames!%%i
)
if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidConfName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=With which CA Certificate Configuration do you wish to create the Certificate Revocation list ^(CRL^) with^(by number^)[or q to quit]?: 
	if "!CertID!" == "q" goto :eof
)
if !CertID! GTR 0 if !CertID! LEQ !DirCount! (
	call :picklist "!DirNames!" !CertID! 1
) else (
	echo.
	echo Invalid Selection, must be 1-!DirCount! 
	echo.
	goto :GetValidConfName
)

:ValidConfName
Rem 
Rem Actually performs CRL update here
Rem 
set CA_NAME=!CA_SIGN_NAME!
%OpenSSLExe% ca -gencrl -config "!CA_SIGN_NAME!/etc/CAConfigurations/!Picked_Name!"  -out "!CA_SIGN_NAME!/crl/!CA_SIGN_NAME!.pem"
if !errorlevel! NEQ 0 echo ERRORLEVEL: !errorlevel!
%OpenSSLExe% crl -inform PEM -in "!CA_SIGN_NAME!/crl/!CA_SIGN_NAME!.pem" -outform DER -out "!CA_SIGN_NAME!/crl/!CA_SIGN_NAME!.crl"
if !errorlevel! NEQ 0 echo ERRORLEVEL: !errorlevel!
echo		^<^<^< %cd%/!CA_SIGN_NAME!/crl/!CA_SIGN_NAME!.crl ^>^>^> - Updated CRL for Certificate Authority !CA_SIGN_NAME!
echo.
exit /b

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


:doCRLItem
set dlist=%1
set dlist=%dlist:"=%
FOR /f "tokens=1* delims=," %%a IN ("%dlist%") DO (
	if not "%%a" == "" (
		Set CA_SIGN_NAME=%%a
		call :DoAllCRLs
	)
	if not "%%b" == "" (
		call :doCRLItem "%%b"
	)
)
exit /b
