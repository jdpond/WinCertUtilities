@echo off
Rem 
Rem <b>CertConfig</b> command file.
Rem @author Jack D. Pond
Rem @version 0.1 / Windows Batch Processor
Rem @see http://wiki.montcopa.org/MediaWiki/index.php?title=Get_a_MontCo_Certificate
Rem @description configuration file.  You may need to modify this configuration file if using a non-standard OpenSSL or other installation
Rem

set DefaultCertType=ServerSSLCertificate
set DefaultCAEmail="ca@lextechaudits.com"

if not exist "c:\Program Files\OpenSSL\bin\openssl.exe" (
	if not exist "c:\Program Files (x86)\OpenSSL\bin\openssl.exe" (
		echo Could not find the program OpenSSL.  You can install it from:  http://www.slproweb.com/products/Win32OpenSSL.html
		pause
		set OpenSSLExe=Echo Could not find the program OpenSSL.  You can install it from:  http://www.slproweb.com/products/Win32OpenSSL.html
		exit -1
	) else (
		set OpenSSLExe="c:\Program Files (x86)\OpenSSL\bin\openssl.exe"
	)
) else (
	set OpenSSLExe="c:\Program Files\OpenSSL\bin\openssl.exe"
)

if not exist "c:\Program Files\PuTTY\puttygen.exe" (
	if not exist "c:\Program Files (x86)\PuTTY\puttygen.exe" (
		echo Could not find the program OpenSSL.  You can install it from:  http://www.slproweb.com/products/Win32OpenSSL.html
		pause
		set PuTTYgenExe=Echo Could not find the program PuTTYgen.  You can install it from:  http://www.slproweb.com/products/Win32OpenSSL.html
		exit -1
	) else (
		set PuTTYgenExe="c:\Program Files (x86)\PuTTY\puttygen.exe"
	)
) else (
	set PuTTYgenExe="c:\Program Files\PuTTY\puttygen.exe"
)

if not exist "c:\Program Files (x86)\Git\bin\ssh-keygen.exe" (
	if not exist "c:\Program Files (x86)\MinGW\msys\1.0\bin\ssh-keygen.exe" (
		set sshkeygenExe=""
	) else (
		set sshkeygenExe="c:\Program Files (x86)\MinGW\msys\1.0\bin\ssh-keygen.exe"
	)
) else (
	set sshkeygenExe="c:\Program Files (x86)\Git\bin\ssh-keygen.exe"
)

