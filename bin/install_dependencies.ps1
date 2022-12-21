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
choco install wixtoolset make nssm vswhere gnuwin32-coreutils.portable
choco install nodejs --version=16.19.0
choco install python --version=3.10.8
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module VSSetup -Scope CurrentUser -Force

# Explicit workaround that refresnenv is working for this powershell shell
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
refreshenv

python -m pip install --upgrade pip
pip install --upgrade sphinx sphinxcontrib-httpdomain sphinx_rtd_theme pygments nose2 hypothesis

# Hide the Download-StatusBar and improve download speed of wget-Cmdlet
$ProgressPreference = 'SilentlyContinue'

# Download and install MozillaBuild environment
# DON'T USE MozillaBuild 4.0. At time of writing, it fails even to start building sm
Write-Output "Downloading MozillaBuild ..."
Invoke-WebRequest -Uri $mozBuildUri -OutFile $mozBuildFile
Write-Output "Installing MozillaBuild ..."
Start-Process -Wait -Filepath "$mozBuildFile" -ArgumentList "/S"

# Download and install Erlang/OTP 23
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
git clone https://github.com/Microsoft/vcpkg.git
Set-Location vcpkg
Write-Output "Installing VCPkg ..."
.\bootstrap-vcpkg.bat -disableMetrics
.\vcpkg integrate install --triplet x64-windows
.\vcpkg install icu --triplet x64-windows
Set-Location ..

# we know what we are doing (, do we really?)
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# start shell
. ${PSScriptRoot}\shell.ps1
