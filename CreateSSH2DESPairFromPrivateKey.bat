@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateSSH2DESPairFromPrivateKey</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see 
Rem @description Create an SSH2 keyset(3DES encrypted) from an encrypted 509 key (private.key).
Rem @description   This key type is commonly used in Linux connection utilities such as PuTTY and WinSCP.
Rem @description   Additionally, it creates the public key x.509v3 key (.pub) and optionally creates the authorized_key ssh2
Rem @param CertName - Name of the certificate corresponding to directory and certnames

call CertConfig.bat
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
	echo You do not have a valid private certificate ready for conversion.  You need to have a private key ^(%%name%%\%%name%%.privatekey.pem^)
	echo in a named sub directory ^(%%name%%^).
	echo.
	echo If you have not done so already, you can create a private certificate and follow the required instructions by using the CreateServerSSLCertRequest.bat command file.
	echo.
	pause
	goto :eof
)

if %DirCount% == 1 (
	set CertID=1
) else (
	set /p CertID=From which Certificate do you wish to create a key set ^(by number^)?: 
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
if exist "%CertName%\%CertName%.SSH2.des.key" (
	set /p CertConfirm=Are you sure you want to create a new SSH2 key "%CertName%"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new SSH2 key "%CertName%"^(y,n^)[y]?:
)
if "%CertConfirm%" == "" set CertConfirm=y
if not "%CertConfirm%" == "y" if not "%CertConfirm%" == "Y" (
	echo You elected NOT to create and SSH2 key "%CertName%"
	pause
	goto :eof
)

:CertNameEntered

set /p FriendlyName=What comment (friendly name?) do you wish to associate with this certificate? 
if not defined FriendlyName (
	set FriendlyName=
) else (
	set FriendlyName=-C "%FriendlyName%"
)

rem <nul: set /p PassPhrase=What is the passphrase on "%CertName%.privatekey.pem" (will also be set on ssh key):
rem for /f "delims=" %%i in ('cscript /nologo GetPassPhrase.vbs') do set PassPhrase=%%i


%OpenSSLExe% rsa -inform PEM -in "%CertName%\%CertName%.private.key" -outform PEM -out "%CertName%\%CertName%.SSH2.3des.key"

if not %sshkeygenExe% == "" (
	%sshkeygenExe% -f "%CertName%\%CertName%.SSH2.des.key" -y %FriendlyName% >"%CD%\%CertName%\%CertName%.SSH2.3des.pub"
)

:NoAuthKey

echo.
echo The following files have been created:
echo		%CD%\%CertName%\%CertName%.SSH2.des.key - Private SSH2 Key
if not %sshkeygenExe% == "" (
	echo		%CD%\%CertName%\%CertName%.SSH2.des.pub - Public RSA Key
) else (
	echo.
	echo Unable to create the public RSA/SSH2 key.  Couldn't find a version of ssh-keygen.
	echo You may want to install it from https://sourceforge.net/projects/mingw/files/latest/download?source=files
)

:NoAuthKeyPrint
echo.
pause

:eof
