@echo off
setLocal EnableDelayedExpansion
Rem 
Rem <b>CASignCSR</b> command file.
Rem @author Jack D. Pond
Rem @version 0.2 / Windows Batch Processor
if "%1" == "" goto :CommandInstructions
:CommandLoop
set _param=%1
set _param2=%2

if "%_param%"=="" goto :CommandParsed
if "%_param:~0,1%" NEQ "-" goto :CommandError

set /a PingStart=1
set /a PingMaxAddr=256
set PingRange=127.0.0


:CASE
goto :CASE_%_param:~1,1%
IF NOT %ERRORLEVEL% == 0 goto :CommandError

:CASE_r
	if "%_param2:~0,1%" == "-" goto :CommandError
	set PingRange=%_param2%
	SHIFT
	SHIFT
	goto :ENDCASE

:CASE_s
	if "%_param2:~0,1%" == "-" goto :CommandError
	set /a PingStart=%_param2%
	SHIFT
	SHIFT
	goto :ENDCASE

:CASE_h
	goto :CommandInstructions
	goto :ENDCASE

:CASE_n
	if "%_param2:~0,1%" == "-" goto :CommandError
	set /a PingMaxAddr=%_param2%
	SHIFT
	SHIFT
	goto :ENDCASE

:ENDCASE

goto :CommandLoop

:CommandParsed
echo The following addresses replied for %PingRange%.1 through %PingRange%.%PingMaxAddr%: > "RepliedAddrs%PingRange%.txt"

:StartLoop
if %PingStart% GTR %PingMaxAddr% goto :ExitHere
	echo Testing %PingRange%.%PingStart%
	ping -n 1 -w 1000 %PingRange%.%PingStart% > nul
	IF %ERRORLEVEL% EQU 0 Echo Replied at %PingRange%.%PingStart% >> ""RepliedAddrs%PingRange%.txt"
	set /a PingStart += 1
goto :StartLoop

:CommandError
echo.
echo The parameter %_param% was invalid.
:CommandInstructions
echo.
echo PingRange -r x.y.z [-s start] [-n end]
echo.
echo The following parameters are available for PingRange:
echo   -h		This help message
echo   -r		IP Range of the class C in the format x.y.z eg. 127.0.0
echo   -s		Start range number ^(greater than 0^) ^[1^]
echo   -n		end range number ^(less than 256^) ^[256^]
echo.
echo. Example:
echo		PingRange -r 127.0.0 -s 2 -n 3
echo.
echo		Example Pings 127.0.0.2 through 127.0.0.3
echo.

:ExitHere
pause