# Glazier

Glazier is a set of batch files, scripts and toolchains designed to
ease building CouchDB on Windows. It's as fully automated as
possible, with most of the effort required only once.

Glazier uses the MS Visual Studio 2017 toolchain as much as possible,
to ensure a quality Windows experience and to execute all binary
dependencies within the same runtime.

We hope Glazier simplifies using Erlang and CouchDB for you, giving
a consistent, repeatable build environment.


# Base Requirements

Note that the scripts you'll run will modify your system extensively. We recommend a *dedicated build machine or VM image* for this work:

- 64-bit Windows 7+. *As of CouchDB 2.0 we only support a 64-bit build of CouchDB*.
  - We like 64-bit Windows 10 Enterprise N (missing Media Player, etc.) from MSDN.
  - Apply Windows Updates and reboot until no more updates appear.
  - If using a VM, shutdown and snapshot your VM at this point.

# Install Dependencies

Start an Administrative PowerShell console. Enter the following:

```powershell
mkdir C:\Relax\
cd C:\Relax\
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
git clone https://github.com/apache/couchdb-glazier
&.\couchdb-glazier\bin\install_dependencies.ps1
```

You should go get lunch. The last step will take over an hour, even on a speedy Internet connection.

At this point, you should have the following installed:

* Visual Studio 2017 (Build Tools, Visual C++ workload, native desktop workload)
* Windows 10 SDK (10.1)
* NodeJS (LTS version)
* wget.exe
* NASM
* Cyg-get (for cygwin)
* WiX Toolset
* Python 3
  * Python packages sphinx, docutils, pygments, nose, hypothesis, and `sphinx_rtd_theme`
* GNU Make
* NSSM
* GPG4Win (for signing releases)
* checksum
* archiver
* Dependency Walker
* unzip
* NSIS
* NuGet
* VSSetup
* MozillaBuild setup (3.3)
* VCPkg (https://github.com/Microsoft/vcpkg), which built and installed:
  * OpenSSL (at time of writing, 1.1.1)
  * ICU (at time of writing, 61)
  * libcurl (at time of writing, 7.68.0)
* Cygwin (used for building Erlang), plus some packages required for Erlang builds

# Building Erlang

This section is not presently automated because it requires switching between PowerShell
and Cygwin. It should be possible to automate (PRs welcome!)

We generally need to build a version of Erlang that is not distributed directly
by Ericsson. This may be because we require patches that are released after the
binaries are built.

For CouchDB 3.0, we build against Erlang 20.3.8.25.

In the same PowerShell session, enter the following:

```powershell
cd c:\relax
git clone https://github.com/erlang/otp
cd otp
git checkout OTP-20.3.8.25
cygwin
export PATH="/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/x64:/cygdrive/c/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64:/cygdrive/c/Program Files (x86)/NSIS:$PATH"
which cl link mc lc mt nmake rc
```

This should produce the following output:

```
/cygdrive/c/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/cl
/cygdrive/c/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/link
/cygdrive/c/Program Files (x86)/Windows Kits/10/bin/10.0.18362.0/x64/mc
/cygdrive/c/Program Files (x86)/Microsoft SDKs/Windows/v10.0A/bin/NETFX 4.8 Tools/x64/lc
/cygdrive/c/Program Files (x86)/Windows Kits/10/bin/10.0.18362.0/x64/mt
/cygdrive/c/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools/VC/Tools/MSVC/14.16.27023/bin/HostX64/x64/nmake
/cygdrive/c/Program Files (x86)/Windows Kits/10/bin/10.0.18362.0/x64/rc
```

Continue by entering the following. This takes a while, maybe 30-60 minutes at the `otp_build` steps, so be sure to have your favourite beverage on hand while you watch.

```
cd /cygdrive/c/relax/otp
eval `./otp_build env_win32 x64`
./otp_build autoconf 2>&1 | tee build_autoconf.txt
./otp_build configure --with-ssl=/cygdrive/c/relax/vcpkg/installed/x64-windows --without-javac --without-debugger --without-wx --without-ic --without-odbc --without-et --without-cosEvent --without-cosEventDomain --without-cosFileTransfer --without-cosNotification --without-cosProperty --without-cosTime --without-cosTransactions --without-orber --without-observer 2>&1 | tee build_configure.txt
./otp_build boot -a  2>&1 | tee build_boot.txt
./otp_build release -a  2>&1 | tee build_release.txt
./otp_build installer_win32  2>&1 | tee build_installer_win32.txt
release/win32/otp_win64_*.exe /S
exit
```

You now have a full install of Erlang on your system.

# Installing Elixir

CouchDB uses Elixir for tests. If you intend to run the test suite (you should!), install
Elixir now by running the following in the same PowerShell prompt:

```
wget.exe https://github.com/elixir-lang/elixir/releases/download/v1.9.4/Precompiled.zip
arc unarchive .\Precompiled.zip
copy .\Precompiled\* 'C:\Program Files\erl9.3.3.14\' -Recurse  -Force
del Precompiled -Recurse
del Precompiled.zip
```

# Building SpiderMonkey

This section is not currently automated, due to the need for Mozilla's separate build
environment. It should be possible to automate (PRs welcome!)

From the same PowerShell prompt, enter the following:

```
C:\mozilla-build\start-shell.bat
```

At the MozillaBuild prompt, enter the following:

```
cd /c/relax
git clone https://github.com/mozilla/gecko-dev
cd gecko-dev
git checkout esr68
sed -i -E "s/(VC\.Tools\.x86\.x64')/\1, '-products', '*'/g" build/moz.configure/toolchain.configure
git cherry-pick b444ca8
export MOZCONFIG=/c/relax/couchdb-glazier/sm-opt.mozconfig
./mach bootstrap
```

The `sed` command adds support for building with just the VS Build Tools, which are
sufficient for just SpiderMonkey. And the `git cherry-pick` pulls in a patch to fix
building against newer versions of Rust.


This will prompt you a few times. Be sure to answer that you want to build:

* `2. Firefox for Desktop` (NOT the Artifact Mode)
* `n` to _"Would you like to run a few configuration steps to ensure Git is..."_
* `n` to _"Would you like to enable build system telemetry?"_

Then, exit the shell (as instructed) and start a new PowerShell. In that PowerShell:

```
&c:\relax\couchdb-glazier\bin\shell.ps1
C:\mozilla-build\start-shell.bat
cd /c/relax/gecko-dev
export MOZCONFIG=/c/relax/couchdb-glazier/sm-opt.mozconfig
./mach build
exit
```

The build should take about 15 minutes. It may show an error at the end similar to this - it's
just a test failure and can **safely be ignored**:

```
17:44.29 js/src/build/spidermonkey_checks.stub
17:51.15 Traceback (most recent call last):
17:51.15   File "c:/relax/gecko-dev/config/check_spidermonkey_style.py", line 799, in <module>
17:51.15     main()
17:51.15   File "c:/relax/gecko-dev/config/check_spidermonkey_style.py", line 782, in main
17:51.15     ok = check_style(fixup)
17:51.15   File "c:/relax/gecko-dev/config/check_spidermonkey_style.py", line 316, in check_style
17:51.15     code = read_file(f)
17:51.15   File "c:/relax/gecko-dev/config/check_spidermonkey_style.py", line 621, in read_file
17:51.15     raise ValueError("unmatched #if")
17:51.15 ValueError: unmatched #if
17:51.17 Traceback (most recent call last):
17:51.17   File "c:\mozilla-build\python\Lib\runpy.py", line 174, in _run_module_as_main
17:51.17     "__main__", fname, loader, pkg_name)
17:51.17   File "c:\mozilla-build\python\Lib\runpy.py", line 72, in _run_code
17:51.17     exec code in run_globals
17:51.17   File "c:\relax\gecko-dev\python\mozbuild\mozbuild\action\file_generate.py", line 120, in <module>
17:51.17     sys.exit(main(sys.argv[1:]))
17:51.17   File "c:\relax\gecko-dev\python\mozbuild\mozbuild\action\file_generate.py", line 71, in main
17:51.17     ret = module.__dict__[method](output, *args.additional_arguments, **kwargs)
17:51.17   File "c:/relax/gecko-dev/config/run_spidermonkey_checks.py", line 15, in main
17:51.17     raise Exception(script + " failed")
17:51.17 Exception: c:/relax/gecko-dev/config/check_spidermonkey_style.py failed
17:51.17 mozmake.EXE[4]: *** [backend.mk;11: .deps/spidermonkey_checks.stub] Error 1
17:51.17 mozmake.EXE[3]: *** [c:/relax/gecko-dev/config/recurse.mk;101: js/src/build/misc] Error 2
17:51.17 mozmake.EXE[2]: *** [c:/relax/gecko-dev/config/recurse.mk;34: misc] Error 2
17:51.17 mozmake.EXE[1]: *** [c:/relax/gecko-dev/config/rules.mk;413: default] Error 2
17:51.17 mozmake.EXE: *** [client.mk;125: build] Error 2
```

Back in the PowerShell, copy the binaries to where our build process expects them:

```
copy C:\relax\gecko-dev\obj-x86_64-pc-mingw32\js\src\build\*.pdb C:\relax\vcpkg\installed\x64-windows\bin
copy C:\relax\gecko-dev\obj-x86_64-pc-mingw32\dist\bin\*.dll C:\relax\vcpkg\installed\x64-windows\bin
copy C:\relax\gecko-dev\obj-x86_64-pc-mingw32\dist\bin\js.exe C:\relax\vcpkg\installed\x64-windows\bin\js68.exe
copy C:\relax\gecko-dev\obj-x86_64-pc-mingw32\dist\include\* C:\relax\vcpkg\installed\x64-windows\include -Recurse -ErrorAction SilentlyContinue
```

# Building CouchDB itself

You're finally ready. You should snapshot your VM at this point!

Open a new PowerShell window. Set up your shell correctly (this step works if you've
closed your PowerShell window before any of the previous steps, too):

```
&c:\relax\couchdb-glazier\bin\shell.ps1
```

Then, start the process:

```
cd c:\relax
git clone https://github.com/apache/couchdb
cd couchdb
git checkout <tag or branch of interest goes here>
&.\configure.ps1 -WithCurl -SpiderMonkeyVersion 68
make -f Makefile.win
```

You now have built CouchDB!

To run the tests:

```
make -f Makefile.win check
```

Finally, to build a CouchDB installer:

```
make -f Makefile.win release
cd c:\relax
&couchdb-glazier\bin\build_installer.ps1
```

The installer will be placed in your current working directory.

You made it! Time to relax. :D

If you're a release engineer, you may find the following commands useful too:

```
checksum -t sha256 apache-couchdb.#.#.#-RC#.tar.gz
checksum -t sha512 apache-couchdb.#.#.#-RC#.tar.gz
gpg --verify apache-couchdb.#.#.#-RC#.tar.gz.asc
```

# Appendices

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

It seems this is a challenge for most environments, so `glazier` gets this all right for
you by running the MSVC environment, then tacking on the things Erlang expects at the end
of the path.

Overall, the desired order for your $PATH is:

- Erlang build helper scripts
- Visual C++ / .NET framework / SDK
- Ancillary Erlang and CouchDB packaging tools
- Usual cygwin unix tools such as make, gcc
- Ancillary glazier/relax tools for building dependent libraries
- Usual Windows folders `%windir%;%windir%\system32` etc
- Various settings form the `otp_build` script

More details are at [erlang INSTALL-Win32.md on github](https://github.com/erlang/otp/blob/master/HOWTO/INSTALL-WIN32.md)

## Windows silent installs

Here are some sample commands, supporting the new features of the 3.0 installer.

Install CouchDB without a service, but with an admin user:password of `admin:hunter2`:

```
msiexec /i apache-couchdb-3.0.0.msi /quiet ADMINUSER=admin ADMINPASSWORD=hunter2 /norestart
```

The same as above, but also install and launch CouchDB as a service:

```
msiexec /i apache-couchdb-3.0.0.msi /quiet INSTALLSERVICE=1 ADMINUSER=admin ADMINPASSWORD=hunter2 /norestart
```

Unattended uninstall of CouchDB:

```
msiexec /x apache-couchdb-3.0.0.msi /quiet /norestart
```

Unattended uninstall if the installer file is unavailable:

```
msiexec /x {4CD776E0-FADF-4831-AF56-E80E39F34CFC} /quiet /norestart
```

Add `/l* log.txt` to any of the above to generate a useful logfile for debugging.
