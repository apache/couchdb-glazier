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

# requires English language pack installed
choco install visualstudio2017buildtools "--passive --locale en-US"
choco install visualstudio2017-workload-vctools --package-parameters "--includeRecommended --add Microsoft.VisualStudio.Component.VC.ATLMFC"
choco install visualstudio2017-workload-nativedesktop
choco install windows-sdk-10.1 nodejs-lts wget nasm cyg-get wixtoolset python3 make nssm gpg4win checksum archiver dependencywalker unzip vcpython27
choco install nsis --version=2.51
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module VSSetup -Scope CurrentUser -Force
python -m pip install --upgrade pip
pip install --upgrade sphinx docutils pygments nose hypothesis sphinx_rtd_theme
cyg-get -upgrade p7zip autoconf binutils bison gcc-code gcc-g++ gdb git libtool make patchutils pkg-config readline file renameutils socat time tree util-linux wget

wget.exe https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-3.3.exe
.\MozillaBuildSetup-3.3.exe /S
sleep 120
del MozillaBuildSetup-3.3.exe

git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat -disableMetrics -win64
.\vcpkg integrate install --triplet x64-windows
.\vcpkg remove openssl icu curl[openssl,tool] --triplet x64-windows
.\vcpkg install openssl icu curl[openssl,tool] --triplet x64-windows
cd ..

# below is for Erlang compile to be successful - not required for too long, see:
#   https://github.com/erlang/otp/pull/2456

New-Item -Path C:\relax\vcpkg\installed\x64-windows\lib\libeay32.lib -ItemType HardLink -Value C:\relax\vcpkg\installed\x64-windows\lib\libcrypto.lib
New-Item -Path C:\relax\vcpkg\installed\x64-windows\lib\ssleay32.lib -ItemType HardLink -Value C:\relax\vcpkg\installed\x64-windows\lib\libssl.lib
New-Item -Path C:\relax\vcpkg\installed\x64-windows\lib\VC -ItemType SymbolicLink -Value C:\relax\vcpkg\installed\x64-windows\lib

. ${PSScriptRoot}\shell.ps1
