@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CreateSSH2PairFromPrivateKey</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @see https://github.com/jdpond/WinCertUtilities/wiki
Rem @description Create an SSH2 keyset from an encrypted 509 key (private.key).
Rem @description   This key type is commonly used in Linux connection utilities such as PuTTY and WinSCP.
Rem @description   Additionally, it creates the public key x.509v3 key (.pub) and optionally creates the authorized_key ssh2
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
	if exist "!CertName!\private\!CertName!.key" goto :ValidCertName
)

echo Create an SSH2 keyset from an encrypted 509 key ^(private.key^)
echo.
set DirNames=
set /a DirCount=0
FOR /F "usebackq delims=" %%i in (`dir /B/AD`) do (
	if exist "%%i\private\%%i.key" (
		set /a DirCount += 1
		if !DirCount! GTR 1 Set DirNames=!DirNames!,
		Set DirNames=!DirNames!%%i
		)
	)
)

if !DirCount! == 0 ( 
	echo.
	echo You do not have a valid certificate set ready for conversion.  You need to have a full key set ^(%%name%%\private\%%name%%.key^)
	echo in a named sub directory ^(%%private%%^).
	echo.
	pause
	goto :eof
)

if !DirCount! == 1 (
	set Picked_Name=!DirNames!
	goto :ValidCertName
) else (
	call :parsenames "!DirNames!" 1
	set /p CertID=Which key would you like to convert(by number^)[or q to quit]?: 
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
if exist "%CertName%\private\%CertName%.SSH2.key" (
	set /p CertConfirm=Are you sure you want to create a new SSH2 key "%CertName%.SSH2.key"^(KEY ALREADY EXISTS^)^(y,n^)[y]?:
) else (
	set /p CertConfirm=Are you sure you want to create a new SSH2 key "%CertName%.SSH2.key"^(y,n^)[y]?:
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


%OpenSSLExe% rsa -aes256 -inform PEM -in "%Picked_Name%\private\%Picked_Name%.key" -outform PEM -out "%Picked_Name%\private\%Picked_Name%.SSH2.key"

if not %sshkeygenExe% == "" (
	%sshkeygenExe% -f "%Picked_Name%\private\%Picked_Name%.SSH2.key" -y %FriendlyName% >"%CD%\%Picked_Name%\%Picked_Name%.SSH2.pub"
)

:NoAuthKey

echo.
echo The following files have been created:
echo		%CD%\%Picked_Name%\private\%Picked_Name%.SSH2.key - Private SSH2 Key
if not %sshkeygenExe% == "" (
	echo		%CD%\%Picked_Name%\%CertName%.SSH2.pub - Public RSA Key
) else (
	echo.
	echo Unable to create the public RSA/SSH2 key.  Couldn't find a version of ssh-keygen.
	echo You may want to install it from https://sourceforge.net/projects/mingw/files/latest/download?source=files
)

:NoAuthKeyPrint
echo.
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
