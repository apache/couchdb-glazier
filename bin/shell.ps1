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

# Visual Studio Version Numbers:
# 2015: 15.x
# 2019: 16.x
# 2022: 17.x

$installationPath = vswhere.exe -prerelease -products Microsoft.VisualStudio.Product.BuildTools -version '[17.0,18.0)' -property InstallationPath
if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
  & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`" -arch=amd64 -no_logo && set" | foreach-object {
    $name, $value = $_ -split '=', 2
    set-content env:\"$name" $value
  }
}
Import-Module ${PSScriptRoot}\which.psm1

$env:VCPKG_BIN = "${vcpkgBase}\bin"
$env:COUCHDB_MOZJS_BIN = "${smInstallPath}\bin"

$env:PATH += ";${erlInstallPath}\bin"
$env:PATH += ";${elxInstallPath}\bin"
$env:PATH += ";${vcpkgBase}\bin"
$env:PATH += ";${env:wix}\bin"
$env:PATH += ";${smInstallPath}\bin"
$env:PATH += ";${toolsDir}\${java21Build}\bin"
$env:PATH += ";${toolsDir}\msys64;${toolsDir}\msys64\ucrt64\bin"

$env:LIB = "${vcpkgBase}\lib;${smInstallPath}\lib;" + $env:LIB
$env:INCLUDE = "${vcpkgBase}\include;${smInstallPath}\include;" + $env:INCLUDE
$env:LIBPATH = "${vcpkgBase}\lib;${smInstallPath}\lib;" + $env:LIBPATH

# Needed for Nouveau
$env:JAVA_HOME = "${toolsDir}\${java21Build}"
$env:PATH += ";${env:JAVA_HOME}\bin"

# Needed for Closeau
$env:CLOUSEAU_JAVA_HOME = "${toolsDir}\${java8Build}"
