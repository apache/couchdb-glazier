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
$env:PATH += ";${erlInstallPath}\bin"
$env:PATH += ";${elxInstallPath}\bin"
$env:PATH += ";${vcpkgBase}\bin"
$env:PATH += ";C:\Program Files (x86)\WiX Toolset v3.11\bin"
$env:PATH += ";C:\tools\${java11Build}\bin"

$env:LIB = "${vcpkgBase}\lib;" + $env:LIB
$env:INCLUDE = "${vcpkgBase}\include;" + $env:INCLUDE
$env:LIBPATH = "${vcpkgBase}\lib;" + $env:LIBPATH

$env:JAVA_HOME = "C:\tools\${java11Build}"
$env:CLOUSEAU_JAVA_HOME = "C:\tools\${java8Build}"
