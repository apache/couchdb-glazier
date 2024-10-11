# Glazier

Glazier is a set of batch files, scripts and toolchains designed to
ease building CouchDB on Windows. It's as fully automated as
possible, with most of the effort required only once.

Glazier uses the MS Visual Studio 2013 toolchain as much as possible,
to ensure a quality Windows experience and to execute all binary
dependencies within the same runtime.

We hope Glazier simplifies using Erlang and CouchDB for you, giving
a consistent, repeatable build environment.


# Base Requirements

- 64-bit Windows 7 or 8.1. *This is required for Mozilla build setup*.
  - We like 64-bit Windows 7, 8.1 or 10 Enterprise N (missing Media Player, etc.) from MSDN.
- If prompted, reboot after installing the .NET framework.
- [Visual Studio 2013 x86 Community Edition](https://www.visualstudio.com/vs/older-downloads/) installed on the *C: drive*. Downloading requires a free Dev Essentials subscription from Microsoft.
- [Chocolatey](https://chocolatey.org). From an *administrative* __cmd.exe__ command prompt, run:

```dos
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
```

- Apply Windows Updates and reboot until no more updates appear.
- If using a VM, shutdown and snapshot your VM at this point.

# Install Pre-requisites

## Clean Package Installs with Chocolatey, Cygwin and pip

These packages install silently, without intervention. Cut and paste them
into an **Administrator** command prompt.

```dos
choco install -y git 7zip.commandline StrawberryPerl nasm wixtoolset aria2 make
choco install -y nodejs.install --version=12.22.12
choco install -y python --version=3.8.7
choco install -y nssm --version 2.24.101-g897c7ad --x86
python -m ensurepip --upgrade
python -m pip install sphinx docutils pygments
```

For Cygwin, install the 32bit version.
```dos
setup-x86 --allow-unsupported-windows --site http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/2022/11/23/063457
```

Required packages:

- cyg-get (install apt-cyg with wget in the cygwin console if cyg-get cannot be found)
- p7zip
- autoconf
- binutils
- bison
- gcc-code
- gcc- g++
- gdb
- git
- libtool
- make
- patchutils
- pkg-config
- readline
- file
- renameutils
- socat
- time
- tree
- util-linux
- wget

*Note: Do NOT install curl or help2man inside CygWin!*
*Note: If you have problems compiling erlang, I recommend you check most of the devel packages and hope for the best!*

## Mozilla build
Fetch [Mozilla Build 2.2](https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-2.2.0.exe) from
https://wiki.mozilla.org/MozillaBuild and install to c:\mozilla-build
with all defaults.

## Make a new prompt shortcut

Make a new shortcut on the desktop. The location should be:

```dos
cmd.exe /E:ON /V:ON /T:1F /K ""C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"" x86 && color 1f
```

Name it "CouchDB SDK Prompt".

Right-click on the icon, select Properties, click the `Advanced...`
button, and tick the `Run as administrator` checkbox. Click OK twice.

I suggest you pin it to the Start menu. We'll use this all the time.

Install Windows SDK 8.1 from the Microsoft SDK Archive.

Start a CouchDB SDK Prompt window and run 
`where cl mc mt link lc rc nmake make`. Make sure the output matches the
following:

```dos
C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\cl.exe
C:\Program Files (x86)\Windows Kits\8.1\bin\x86\mc.exe
C:\Program Files (x86)\Windows Kits\8.1\bin\x86\mt.exe
C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\link.exe
C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A\bin\NETFX 4.5.1 Tools\lc.exe
C:\Program Files (x86)\Windows Kits\8.1\bin\x86\rc.exe
C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\nmake.exe
C:\ProgramData\chocolatey\bin\make.exe
```

Stop here if your results are not *identical*. If you are unable to
reproduce these results, please open an issue on this repository for
assistance.

## Set up required convenience links & environment variable

In the CouchDB SDK Prompt, run the following commands:

```dos
mkdir c:\relax    
cd c:\relax
rd /s/q SDK VC nasm inno5 nsis strawberry
mklink /j c:\relax\bin c:\relax\couchdb-glazier\bin
mklink /j c:\relax\nasm "c:\Program Files (x86)\NASM" //this could also be "c:\Program Files\NASM"
mklink /j c:\relax\SDK "C:\Program Files (x86)\Microsoft SDKs\Windows\v8.1A"
mklink /j c:\relax\VC "C:\Program Files (x86)\Microsoft Visual Studio 12.0"
mklink /j c:\openssl c:\relax\openssl
setx RELAX c:\relax
```

*Note: The SDK version might vary base on your OS. This was done with Windows 10 Professional*

Close all open command prompts. Now we're ready to go!

# Building CouchDB Pre-requisites

## Downloading glazier and dependency sources

Open a new `CouchDB SDK Prompt` and run the following:

```dos
cd c:\relax
git config --global core.autocrlf input
git clone https://github.com/apache/couchdb-glazier
cd couchdb-glazier
git checkout wip/2.x-win32
cd ..
aria2c --force-sequential=false --max-connection-per-server=5 --check-certificate=false --auto-file-renaming=false --allow-overwrite=true --input-file=couchdb-glazier/downloads_32.md --max-concurrent-downloads=5 --dir=bits --save-session=bits/a2session.txt
color 1f
```
You can try it with additional arguments if aria2c downloads fail:
```dos
aria2c --force-sequential=false --max-connection-per-server=5 --check-certificate=false --auto-file-renaming=false --allow-overwrite=true --input-file=couchdb-glazier/downloads_32.md --max-concurrent-downloads=5 --dir=bits --save-session=bits/a2session.txt --async-dns-server=8.8.8.8,8.8.4.4 --disable-ipv6 --max-tries=10 --log-level=debug --log=aria2c.log
```
As of 2017-07-08, this will download the source for the following versions of our dependencies:

* MS Visual C++ x86 Redistributable for VC12 with patches
* OpenSSL 1.0.2l
* curl 7.49.1
* Erlang:
  * 17.5
  * 18.3
  * 19.3
* ICU4C 57.1 (*Note*: this is the last version to support building in VS2013)
* SpiderMonkey 1.8.5


## Build & Test 32-bit OpenSSL

In the same `CouchDB SDK Prompt`, run the following:

```dos
cd %RELAX%\bin && build_openssl_32.cmd
```

Close your `CouchDB SDK Prompt`.

## Build 32-bit libcurl

Open a new `CouchDB SDK Prompt` and run the following:

```dos
cd %RELAX%\bin && build_curl_32.cmd
```

## Build 32-bit ICU
    
In the same `CouchDB SDK Prompt` run the following:

```dos
cd %RELAX%\bin && build_icu_32.cmd
```
Close the window.

Note: If this shell script hasn't been able to build all these tools successfully, try the following: 
* Open C:\relax\icu\source\allinone\allinone.sln in Visual Studio (17)
* Set Release Mode
* Select all projects, right-click "Properties" - "VC++ Directories"
* "Include Directories": Add path to ucrt folder, e.g. C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt
* "Include Libraries": Add path to ucrt folder, e.g. C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x86
* Run from menu "Build" - "Rebuild Solution"

## Start a UNIX-friendly shell with MS compilers

1. Start your `CouchDB SDK Prompt` as above
2. Launch a cygwin erl-ified shell via `C:\relax\bin\shell_32.cmd`
3. Select 18.3 (unless you know what you are doing!)
4. Select `b for bash prompt`.

For more detail on why this is necessary, see
[UNIX-friendly shell details](#unix-friendly-shell-details) below.

## Unpack, configure and build Erlang/OTP 18.3

At the bash prompt, enter the following commands:

```bash
ln -s /cygdrive/c/relax /relax
cd .. && tar xzf /relax/bits/otp_src_18.3.tar.gz
cd $ERL_TOP
echo "skipping gs" > lib/gs/SKIP
echo "skipping wx" > lib/wx/SKIP
echo "skipping ic" > lib/ic/SKIP
echo "skipping jinterface" > lib/jinterface/SKIP
eval `$ERL_TOP/otp_build env_win32`
```

At this point, check your paths. Run `which cl link mc lc mt nmake rc`.
The output should match the following:

```bash
/cygdrive/c/relax/VC/VC/bin/cl
/cygdrive/c/relax/VC/VC/bin/link
/cygdrive/c/Program Files (x86)/Windows Kits/8.1/bin/x86/mc
/cygdrive/c/relax/SDK/bin/NETFX 4.5.1 Tools/lc
/cygdrive/c/Program Files (x86)/Windows Kits/8.1/bin/x86/mt
/cygdrive/c/relax/VC/VC/bin/nmake
/cygdrive/c/Program Files (x86)/Windows Kits/8.1/bin/x86/rc
```

If it does not, stop and diagnose.

Now you can proceed to build Erlang, closing the window when
done:

```bash
erl_config_32.sh
# Ensure OpenSSL is found by the configure script.
# If you see any warnings, stop and diagnose.
erl_build.sh
exit
exit
```

## Build Spidermonkey JavaScript 1.8.5

Spidermonkey needs to be compiled with the Mozilla Build chain.
To build it with VS2013 requires a few patches contained in this
repository.

Start by launching a fresh `CouchDB SDK prompt`, then setup the
Mozilla build environment with the command:

```dos
call c:\mozilla-build\start-shell-msvc2013.bat
```

Now, ensure the output of `which cl lc link mt rc make` matches
the following:

```dos
/c/Program Files (x86)/Microsoft Visual Studio 12.0/VC/BIN/amd64_x86/cl.exe
/c/Program Files (x86)/Microsoft SDKs/Windows/v8.1A/bin/NETFX 4.5.1 Tools/x64/lc.exe
/c/Program Files (x86)/Microsoft Visual Studio 12.0/VC/BIN/amd64_x86/link.exe
/c/Program Files (x86)/Windows Kits/8.1/bin/x64/mt.exe
/c/Program Files (x86)/Windows Kits/8.1/bin/x64/rc.exe
/local/bin/make.exe
```

If this does not match *exactly*, stop and diagnose.

Now, proceed to patch and build SpiderMonkey 1.8.5:

```bash
cd /c/relax
tar xzf bits/js185-1.0.0.tar.gz
patch -p0 </c/relax/couchdb-glazier/bits/js185-msvc2013.patch
cd js-1.8.5/js/src
autoconf-2.13
./configure --enable-static --enable-shared-js --disable-debug-symbols --disable-debug --disable-debugger-info-modules
make
```

If desired, tests can be run at this point. This is optional,
takes a while, and the math-jit-tests may fail. For more detail
as to why, see https://bugzilla.mozilla.org/show_bug.cgi?id=1076670
Also, one jsapi test has been disabled that crashes; this exercises
a call CouchDB doesn't use.

To run the tests:

```bash
make check
```

Close the prompt window by entering `exit` twice.

## Building CouchDB itself

Before compiling CouchDB, you need to make sure that rebar is installed on your system and accessible via your %PATH% environment.

Start a new `SDK prompt`, then run `c:\relax\bin\shell.cmd`.
Select `Erlang 18.3` and `w for a Windows prompt`.
Then, run the following commands to download and build CouchDB
from the master repository:

```dos
cd \relax && git clone https://github.com/apache/couchdb
cd couchdb
# optionally, switch to a different tag or branch for building with:
# git checkout --track origin/2.0.x
git clean -fdx && git reset --hard
powershell -ExecutionPolicy Bypass .\configure.ps1 -WithCurl
make -f Makefile.win check
```

This will build a development version of CouchDB runnable via

```dos
python dev\run <-n1> <--with-admin-party-please>
```

To build a self-contained CouchDB installation (also known as an Erlang
_release_), after running the above use:

```dos
    make -f Makefile.win release
```

To build an installer using WiX to create a full Windows .msi, run:

```dos
    make -f Makefile.win release
    cd \relax\couchdb-glazier
    bin\build_installer_32.cmd
```

You made it! Time to relax. :D

# Appendix

## Why Glazier?

@dch first got involved with CouchDB around 0.7. Only having a low-spec Windows
PC to develop on, and no CouchDB Cloud provider being available, he tried
to build CouchDB himself. It was hard going, and most of the frustration was
trying to get the core Erlang environment set up and compiling without needing
to buy Microsoft's expensive but excellent Visual Studio tools. Once
Erlang was working he found many of the pre-requisite modules such as cURL,
Zlib, OpenSSL, Mozilla's SpiderMonkey JavaScript engine, and IBM's ICU were
not available at a consistent compiler and VC runtime release.

There is a branch of glazier that has been used to build each CouchDB release.

## UNIX-friendly shell details

Our goal is to get the path set up in this order:

1. erlang and couchdb build helper scripts
2. Microsoft VC compiler, linker, etc from Windows SDK
3. cygwin path for other build tools like make, autoconf, libtool
4. the remaining windows system path

It seems this is a challenge for most environments, so `glazier` just
assumes you're using [chocolatey] and takes care of the rest.

Alternatively, you can launch your own cmd prompt, and ensure that your system
path is correct first in the win32 side before starting cygwin. Once in cygwin
go to the root of where you installed erlang, and run the Erlang/OTP script:

        eval `./otp_build env_win32 x64`
        echo $PATH | /bin/sed 's/:/\n/g'
        which cl link mc lc mt nmake rc

Confirm that output of `which` returns only MS versions from VC++ or the SDK.
This is critical and if not correct will cause confusing errors much later on.
Overall, the desired order for your $PATH is:

- Erlang build helper scripts
- Visual C++ / .NET framework / SDK
- Ancillary Erlang and CouchDB packaging tools
- Usual cygwin unix tools such as make, gcc
- Ancillary glazier/relax tools for building dependent libraries
- Usual Windows folders `%windir%;%windir%\system32` etc
- Various settings form the `otp_build` script

More details are at [erlang INSTALL-Win32.md on github](https://github.com/erlang/otp/blob/master/HOWTO/INSTALL-WIN32.md)
