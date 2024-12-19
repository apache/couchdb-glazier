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

# Installation directory for build tools
$toolsDir = "C:\tools"
$artifactDir = "${toolsDir}\ArtifactDownloads"

# VCPKG SETTINGS

# Download location of Vcpkg for Windows
$vcpkgVersion = "2024.07.12"
$vcpkgUri = "https://github.com/microsoft/vcpkg/archive/refs/tags/${vcpkgVersion}.zip"
$vcpkgFile = "${artifactDir}\$(Split-Path $vcpkgUri -Leaf)"
$vcpkgInstallPath = "${toolsDir}\vcpkg-${vcpkgVersion}"
$vcpkgBase = "${vcpkgInstallPath}\installed\x64-windows"

# ERLANG BUILD SETTINGS

# Download location of the Erlang/OTP Environment for Windows (x64)
$erlVersion = "25.3.2.15"
$erlBuildUri = "https://github.com/erlang/otp/releases/download/OTP-${erlVersion}/otp_win64_${erlVersion}.exe"
$erlBuildFile = "${artifactDir}\$(Split-Path $erlBuildUri -Leaf)"
$erlDir = "erl-${erlVersion}"
$erlInstallPath = "${toolsDir}\${erlDir}"

# ERLANG BUILD SETTINGS

# Download location of the Elixir binaries for Windows (x64)
$elxVersion = "1.15.7"
$elxBuildUri = "https://github.com/elixir-lang/elixir/releases/download/v${elxVersion}/elixir-otp-25.zip"
$elxBuildFile = "${artifactDir}\$(Split-Path $elxBuildUri -Leaf)"
$elxDir = "elixir-${elxVersion}"
$elxInstallPath = "${toolsDir}\${elxDir}"

# SPIDERMONKEY SETTINGS

# Download location of the pre-build SpiderMonkey development files for Windows (x64)
$smBuild = "Windows-mozjs-128"
$smBuildVersion = "0.0.9"
$smBuildUri = "https://github.com/big-r81/couchdb-sm/releases/download/v${smBuildVersion}/${smBuild}.tar.xz"
$smBuildFile = "${artifactDir}\$(Split-Path $smBuildUri -Leaf)"
$smInstallPath = "${toolsDir}\${smBuild}"

# JAVA 8 SETTINGS

# Donwload location of OpenJDK 8 for Windows (x64)
$java8Build = "zulu8.82.0.21-ca-jdk8.0.432-win_x64"
$java8BuildUri = "https://cdn.azul.com/zulu/bin/$java8Build.zip"
$java8BuildFile = "${artifactDir}\$(Split-Path $java8BuildUri -Leaf)"

# JAVA 21 SETTINGS

# Donwload location of OpenJDK 21 for Windows (x64)
$java21Build = "zulu21.38.21-ca-jdk21.0.5-win_x64"
$java21BuildUri = "https://cdn.azul.com/zulu/bin/$java21Build.zip"
$java21BuildFile = "${artifactDir}\$(Split-Path $java21BuildUri -Leaf)"
