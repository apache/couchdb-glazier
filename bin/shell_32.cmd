@echo off
title Time to Relax.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set CYGWIN=nontsec nodosfilewarning
if not exist c:\tmp mkdir c:\tmp
set TEMP=c:\tmp
set TMP=c:\tmp

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: following settings allow Erlang build to locate openssl correctly
:: and CouchDB to find ICU, Curl, and SSL if required
set USE_SSLEAY=1
set USE_OPENSSL=1
if not defined SSL_PATH  set SSL_PATH=%RELAX%\openssl
if not defined ICU_PATH  set ICU_PATH=%RELAX%\icu
if not defined CURL_PATH set CURL_PATH=%RELAX%\curl
if not defined ZLIB_PATH set ZLIB_PATH=%RELAX%\zlib

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: haul in MSVC compiler configuration
:: TODO remove dependency on x86 flag
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: LIB and INCLUDE are preset by Windows SDK and/or Visual C++ shells
:: however VC++ uses LIB & INCLUDE and SDK uses Lib & Include. In Cygwin
:: these are *NOT* the same but when we shell out to CL.exe and LINK.exe
:: all is well again

:: relax for couchdb
:: werldir for building erlang

if not defined RELAX set RELAX=c:\relax
if not defined WERL_DIR set WERL_DIR=c:\werl
setx WERL_DIR %WERL_DIR% > NUL:
setx RELAX %RELAX% > NUL:

set LIB=%RELAX%\VC\VC\lib;%RELAX%\SDK\lib;%LIB%
SET INCLUDE=%RELAX%\VC\VC\Include;%RELAX%\SDK\Include;%RELAX%\SDK\Include\gl;%INCLUDE%

set INCLUDE=%INCLUDE%;%SSL_PATH%\include\openssl;%SSL_PATH%\include;%CURL_PATH%\include\curl;%ICU_PATH%\include;
set LIBPATH=%LIBPATH%;%SSL_PATH%\lib;%CURL_PATH%\lib;%ICU_PATH%\lib;
set LIB=%LIB%;%SSL_PATH%\lib;%CURL_PATH%\lib;%ICU_PATH%\lib;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: check which version of erlang setup we want
:: pick up from jenkins if required
if not defined BUILD_WITH_JENKINS goto select
if not defined OTP_REL goto select
goto %OTP_REL%
:: no default, so let's ask the user instead!
:: choice.exe exists on all windows platforms since MSDOS but not on XP
:select
echo Select an Erlang:
echo       7 for Erlang 17.5 
echo       8 for Erlang 18.3 (default)
echo       9 for Erlang 19.3
set /p choice="Make your selection ===> "
if /i "%choice%"=="0" goto win_shell
if /i "%choice%"=="7" goto 17.5
if /i "%choice%"=="8" goto 18.3
if /i "%choice%"=="9" goto 19.3
:: else
goto 18.3

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:17.5
set ERTS_VSN=6.4
set OTP_REL=17.5
goto shell_select

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:18.3
set ERTS_VSN=7.3
set OTP_REL=18.3
goto shell_select

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:19.3
set ERTS_VSN=8.3
set OTP_REL=19.3
goto shell_select


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:shell_select
for /f "usebackq" %%i in (`c:\cygwin\bin\cygpath.exe %WERL_DIR%`) do @set WERL_PATH=%%i

echo Select a shell:
echo       w for Windows prompt (default)
echo       b for bash prompt
echo       p for PowerShell prompt
set /p choice="Make your selection ===> "
if /i "%choice%"=="w" goto win_shell
if /i "%choice%"=="b" goto unix_shell
if /i "%choice%"=="p" goto ps_shell
:: else
goto :win_shell

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:unix_shell
color
title Building in %ERL_TOP% with OTP %OTP_REL% and Erlang v%ERTS_VSN%
for /f "usebackq" %%i in (`c:\cygwin\bin\cygpath.exe %WERL_DIR%`) do @set WERL_PATH=%%i
set ERL_TOP=%WERL_PATH%/otp_src_%OTP_REL%
c:\cygwin\bin\bash %relax%\bin\shell_32.sh
goto eof

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:win_shell
set ERL_TOP=%WERL_DIR%\otp_src_%OTP_REL%
echo Type exit to stop relaxing.
title On the couch. Type exit to stop relaxing.
:: Need these things on the path to build/run CouchDB
set PATH=%ERL_TOP%\release\win32\erts-%ERTS_VSN%\bin;%ERL_TOP%\bootstrap\bin;%ERL_TOP%\erts\etc\win32\cygwin_tools\vc;%ERL_TOP%\erts\etc\win32\cygwin_tools;%RELAX%\bin;%PATH%;%ICU_PATH%\bin;%RELAX%\js-1.8.5\js\src\dist\bin;%RELAX%\curl\lib;C:\Program files\Python36\Scripts;C:\Program Files\nodejs;C:\Program Files (x86)\WiX Toolset v3.11\bin;C:\cygwin\bin
cmd.exe /k

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
