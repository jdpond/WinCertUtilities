@echo off
Rem 
Rem <b>CertConfig</b> command file.
Rem @author Jack D. Pond
Rem @version 0.3 / Windows Batch Processor
Rem @description configuration file.  You may need to modify this configuration file if using a non-standard OpenSSL or other installation
Rem
set DefaultCAEmail="noreply@yourserver.com"
setlocal enableextensions enabledelayedexpansion

set OpenSSLexe=
set sshkeygenExe=
call :find_exe OpenSSLexe openssl AltSSLExe "http://www.slproweb.com/products/Win32OpenSSL.html" 
call :file_name_from_path OPENSSL_CONF !OpenSSLExe!
call :find_exe sshkeygenExe "ssh-keygen" AltSSHKeyGenExe "http://sourceforge.net/projects/sshwindows/files/OpenSSH%20for%20Windows%20-%20Release/" 
endlocal &set OpenSSLexe=%OpenSSLexe%&SET OPENSSL_CONF=%OPENSSL_CONF%&SET sshkeygenExe=%sshkeygenExe%
EXIT /B

:find_exe <result> <namesansexe> <altlist> <wherefromsansconf>
(
	set first=1
	set found_here=
	where /Q "%~2.exe"
	if NOT errorlevel 1 (
		for /f "usebackq delims=" %%i in (`where "%~2.exe"`) do (
			if !first!==1 set found_here=%%i
			set first=0
		) 
	)
	if NOT defined found_here (
		if EXIST "%0\..\%~3.conf" (
			for /f "delims=" %%i in (%0\..\AltSSLExe.conf) do (
				set xtest=%%i
				set xtest=!xtest:~0,1!
				if NOT !xtest!==# (
					if NOT defined found_here (
						 set found_here=%%i
					)
				)
			)
		)
		if NOT defined found_here (
			echo Could not find the program %~2.exe.
			echo You can install it from:  %~4
			set found_here="%~2.exe"
			pause
		)
	)
	set "%~1=!found_here!"
    exit /b
)


:file_name_from_path <result> <filewithpath>
(
    set "%~1=%~dp2"
    exit /b
)
