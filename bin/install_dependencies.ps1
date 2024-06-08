# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Sourcing variable definitions
. ${PSScriptRoot}\variables.ps1

# Exclude c:\relax from MS defender to speed up things
Add-MpPreference -ExclusionPath "C:\relax"

# Install build tools - requires English language pack installed
choco install visualstudio2022buildtools "--passive --locale en-US"
choco install visualstudio2022-workload-vctools --package-parameters "--add Microsoft.VisualStudio.Component.VC.ATL --add Microsoft.VisualStudio.Component.VC.Redist.MSM --add Microsoft.Net.Component.4.8.TargetingPack"
choco install make nssm vswhere gnuwin32-coreutils.portable
choco install wixtoolset --version=3.11.2
choco install nodejs --version=18.18.2
choco install python --version=3.11.6
choco install archiver --version=3.1.0
choco install msys2 --version=20240113.0.0

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module VSSetup -Scope CurrentUser -Force

# Explicit workaround that refresnenv is working for this powershell shell
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
refreshenv

Write-Output " ***** Setting up MSYS ******* "
msys2_shell.cmd -defterm -no-start -ucrt64 -lc 'pacman -Syu'
msys2_shell.cmd -defterm -no-start -ucrt64 -lc 'pacman -S --noconfirm --needed base-devel make mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-dlfcn'
Write-Output " ******** Finished setting up MSYS ********"

python -m pip install --upgrade pip
pip install --upgrade sphinx sphinxcontrib-httpdomain sphinx_rtd_theme pygments nose2 hypothesis

# Hide the Download-StatusBar and improve download speed of wget-Cmdlet
$ProgressPreference = 'SilentlyContinue'

# Download and install Erlang/OTP
Write-Output "Downloading Erlang ..."
Invoke-WebRequest -Uri $erlBuildUri -OutFile $erlBuildFile
Write-Output "Installing Erlang ..."
Start-Process -Wait -Filepath "$erlBuildFile" -ArgumentList "/S /D=${erlInstallPath}"

# Download and install Elixir
Write-Output "Downloading Elixir ..."
Invoke-WebRequest -Uri $elxBuildUri -OutFile $elxBuildFile
Write-Output "Installing Elixir ..."
Expand-Archive -Path $elxBuildFile -DestinationPath $elxInstallPath

# Download and install VCPkg
Write-Output "Downloading VCPkg ..."
Invoke-WebRequest -Uri $vcpkgUri -OutFile $vcpkgFile
Write-Output "Installing VCPkg ..."
arc unarchive $vcpkgFile
copy -Recurse -Force "vcpkg-${vcpkgVersion}" $vcpkgInstallPath
& "${vcpkgInstallPath}\bootstrap-vcpkg.bat" -disableMetrics
$vcpkg = "${vcpkgInstallPath}\vcpkg"
& $vcpkg integrate install --triplet x64-windows

Write-Output "Installing ICU ..."
& $vcpkg install icu --triplet x64-windows

Write-Output "Installing OpenSSL ..."
& $vcpkg install openssl --triplet x64-windows

# Download and install SpiderMonkey
Write-Output "Downloading SpiderMonkey ..."
Invoke-WebRequest -Uri $smBuildUri -OutFile $smBuildFile
Write-Output "Installing SpiderMonkey ..."
arc unarchive $smBuildFile
copy -Recurse -Force "$smBuild\*" $vcpkgBase

# Download and install Java 8
Write-Output "Downloading OpenJDK 8 ..."
Invoke-WebRequest -Uri $java8BuildUri -OutFile $java8BuildFile
Write-Output "Installing OpenJDK 8 ..."
arc unarchive $java8BuildFile "C:\tools"

# Download and install Java 11
Write-Output "Downloading OpenJDK 11 ..."
Invoke-WebRequest -Uri $java11BuildUri -OutFile $java11BuildFile
Write-Output "Installing OpenJDK 11 ..."
arc unarchive $java11BuildFile "C:\tools"

# we know what we are doing (, do we really?)
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# start shell
. ${PSScriptRoot}\shell.ps1
