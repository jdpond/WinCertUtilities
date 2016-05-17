@echo off
Rem 
Rem <b>CertConfig</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
Rem @description configuration file.  You may need to modify this configuration file if using a non-standard OpenSSL or other installation
Rem
REM echo Could not find the program ssh-keygen which is part of OpenSSH.
REM echo You can install it from:  http://sourceforge.net/projects/sshwindows/files/OpenSSH%20for%20Windows%20-%20Release/
set DefaultCAEmail="noreply@yourserver.com"

if exist "C:/bin/OpenSSL/bin/openssl.exe" (
      set OpenSSLExe="C:/bin/OpenSSL/bin/openssl.exe"
      set OPENSSL_CONF=C:/bin/OpenSSL/bin/openssl.cfg
  ) else (
  if exist "C:/Program Files (x86)/Git/bin/openssl.exe" (
    set OpenSSLExe="C:/Program Files (x86)/Git/bin/openssl.exe"
    ) else (
      if exist "c:\Program Files (x86)\OpenSSL\bin\openssl.exe" (
        set OpenSSLExe="c:\Program Files (x86)\OpenSSL\bin\openssl.exe"
      ) else (
        echo Could not find the program OpenSSL.
        echo You can install it from:  http://www.slproweb.com/products/Win32OpenSSL.html
        pause
        set OpenSSLExe=""
        exit -1
      )
    )
  )
)

if exist "c:\Program Files (x86)\Git\bin\ssh-keygen.exe" (
	set sshkeygenExe="c:\Program Files (x86)\Git\bin\ssh-keygen.exe"
	) else (
		if exist "c:\Program Files (x86)\MinGW\msys\1.0\bin\ssh-keygen.exe" (
			set sshkeygenExe="c:\Program Files (x86)\MinGW\msys\1.0\bin\ssh-keygen.exe"
		) else (
			if exist "c:\Program Files (x86)\Git\bin\ssh-keygen.exe" (
				set sshkeygenExe="c:\Program Files (x86)\MinGW\msys\1.0\bin\ssh-keygen.exe"
			) else (
				if exist "C:\Program Files (x86)\OpenSSH\bin\ssh-keygen.exe" (
					set sshkeygenExe="C:\Program Files (x86)\OpenSSH\bin\ssh-keygen.exe"
				) else (
					if exist "C:\Program Files\Git\usr\bin" (
						set sshkeygenExe="C:\Program Files\Git\usr\bin"
					) else (
						echo Could Not find the program ssh-keygen
						pause
						set sshkeygenExe=""
					)
				)
			)
		)
	)
)
