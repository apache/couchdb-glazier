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
choco install nodejs-lts wixtoolset make nssm python3 vswhere gnuwin32-coreutils.portable
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module VSSetup -Scope CurrentUser -Force
python -m pip install --upgrade pip
pip install --upgrade sphinx sphinx_rtd_theme pygments nose2 hypothesis

# Hide the Download-StatusBar and improve download speed of wget-Cmdlet
$ProgressPreference = 'SilentlyContinue'

# Download and install MozillaBuild environment
# DON'T USE MozillaBuild 4.0. At time of writing, it fails even to start building sm
wget -Uri $mozBuildUri -OutFile $mozBuildFile
Start-Process -Filepath "$mozBuildFile" -ArgumentList "/S"
sleep 120

# Download and install Erlang/OTP 23
wget -Uri $erlBuildUri -OutFile $erlBuildFile
Start-Process -Filepath "$erlBuildFile" -ArgumentList "/S /D=${erlInstallPath}"
sleep 120

# Download and install Elixier
wget -Uri $elxBuildUri -OutFile $elxBuildFile
Expand-Archive -Path $elxBuildFile -DestinationPath "c:\relax\elixir"
copy "c:\relax\elixir\*" ${erlInstallPath} -Recurse -Force

# Download and install VCPkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat -disableMetrics
.\vcpkg integrate install --triplet x64-windows
.\vcpkg install icu --triplet x64-windows
cd ..

# we know what we are doing (, do we really?)
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force

# start shell
. ${PSScriptRoot}\shell.ps1
