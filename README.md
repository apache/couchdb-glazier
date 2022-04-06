# Glazier

Glazier is a set of batch files, scripts and toolchains designed to
ease building CouchDB on Windows. It's as fully automated as
possible, with most of the effort required only once.

Glazier uses the MS Visual Studio 2022 toolchain as much as possible,
to ensure a quality Windows experience and to execute all binary
dependencies within the same runtime.

We hope Glazier simplifies using Erlang and CouchDB for you, giving
a consistent, repeatable build environment.

Of course, you can also use our [previous script collection](README.OLD.md)
to create CouchDB for Windows. Please note that this is currently no longer
tested.

# Base Requirements

Note that the scripts you'll run will modify your system extensively. We recommend a *dedicated build machine or VM image* for this work:

- 64-bit Windows 7+. *As of CouchDB 2.0 we only support a 64-bit build of CouchDB*.
  - We like 64-bit Windows 10 Enterprise N (missing Media Player, etc.) from MSDN.
  - Apply Windows Updates and reboot until no more updates appear.
  - If using a VM, shutdown and snapshot your VM at this point.

# Install Dependencies

Start an Administrative PowerShell console. Enter the following:

```powershell
mkdir C:\relax\
cd C:\relax\
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install git
git config --global auto.crlf false 
git clone https://github.com/apache/couchdb-glazier
&.\couchdb-glazier\bin\install_dependencies.ps1
```

You should go get lunch. The last step will take over an hour, even on a speedy Internet connection.

At this point, you should have the following installed:

* Visual Studio 2022 (Build Tools, Visual C++ workload, native desktop workload)
* Windows 10 SDK (by native desktop workload; 10.0.19041.0)
* NodeJS (LTS version)
* WiX Toolset
* Python 3
  * Python packages sphinx, sphinx_rtd_theme and pygments
* NSSM
* Make
* NuGet
* VSSetup
* VSWhere
* GNU CoreUtils (cp, rm, rmdir, ...)
* MozillaBuild setup
* VCPkg (https://github.com/Microsoft/vcpkg), which built and installed:
  * ICU (at time of writing, 69.1)

# Building SpiderMonkey

This section is not currently automated, due to the need for Mozilla's separate build
environment. It should be possible to automate (PRs welcome!). At time of writing, we
use the `esr91` branch of spidermonkey.

From the same PowerShell prompt, enter the following:

```powershell
C:\mozilla-build\start-shell.bat
```

At the MozillaBuild prompt, enter the following:

```bash
cd /c/relax
git clone https://github.com/mozilla/gecko-dev
cd gecko-dev
git checkout esr91
./mach bootstrap --application-choice js
```

Please answer the following question of `./mach boostrap`. You need this only for the first run.
It downloads a complete build toolchain for Spidermonkey.

* Would you like to create this directory? (Yn): Y
* Would you like to run a few configuration steps to ensure Git is optimally configured? (Yn): Y
* Will you be submitting commits to Mozilla? (Yn): n
* Would you like to enable build system telemetry? (Yn):n


```bash
export MOZCONFIG=/c/relax/couchdb-glazier/moz/sm-opt
./mach build
exit
```
Now you should have built Spidermonkey.
Back in PowerShell, copy the binaries to where our build process expects them:

```powershell
copy C:\relax\gecko-dev\sm-obj-opt\js\src\build\*.pdb C:\relax\vcpkg\installed\x64-windows\bin
copy C:\relax\gecko-dev\sm-obj-opt\js\src\build\*.lib C:\relax\vcpkg\installed\x64-windows\lib
copy C:\relax\gecko-dev\sm-obj-opt\dist\bin\*.dll C:\relax\vcpkg\installed\x64-windows\bin
copy C:\relax\gecko-dev\sm-obj-opt\dist\include\* C:\relax\vcpkg\installed\x64-windows\include -Recurse -ErrorAction SilentlyContinue
```

# Building CouchDB itself

You're finally ready. You should snapshot your VM at this point!

Open a new PowerShell window. Set up your shell correctly (this step works if you've
closed your PowerShell window before any of the previous steps, too):

```powershell
&c:\relax\couchdb-glazier\bin\shell.ps1
```

Then, start the process:

```
cd c:\relax
git clone https://github.com/apache/couchdb
cd couchdb
git checkout <tag or branch of interest goes here>
&.\configure.ps1 -SpiderMonkeyVersion 91
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
