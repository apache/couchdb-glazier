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

# ERLANG BUILD SETTINGS

# Download location of the Erlang/OTP Environment for Windows (x64)
$erlVersion = "24.3.4.14"
$erlBuildUri = "https://github.com/erlang/otp/releases/download/OTP-${erlVersion}/otp_win64_${erlVersion}.exe"
$erlBuildFile = Split-Path $erlBuildUri -Leaf
$erlDir = "erl-${erlVersion}"
$erlInstallPath = "C:\tools\${erlDir}"

# ERLANG BUILD SETTINGS

# Download location of the Elixir binaries for Windows (x64)
$elxBuildUri = "https://github.com/elixir-lang/elixir/releases/download/v1.15.7/elixir-otp-24.zip"
$elxBuildFile = Split-Path $elxBuildUri -Leaf
$elxInstallPath = "C:\relax\elixir"

# SPIDERMONKEY SETTINGS

# Donwload location of the SpiderMonkey development files for Windows (x64)
$smBuild = "Windows-mozjs-91"
$smBuildUri = "https://github.com/big-r81/couchdb-sm/releases/download/v0.0.3/$smBuild.tar.xz"
$smBuildFile = Split-Path $smBuildUri -Leaf
$smInstallPath = "C:\relax\vcpkg\installed\x64-windows"

# JAVA 8 SETTINGS

# Donwload location of OpenJDK 8 for Windows (x64)
$java8Build = "zulu8.74.0.17-ca-jre8.0.392-win_x64"
$java8BuildUri = "https://cdn.azul.com/zulu/bin/$java8Build.zip"
$java8BuildFile = Split-Path $java8BuildUri -Leaf

# JAVA 11 SETTINGS

# Donwload location of OpenJDK 11 for Windows (x64)
$java11Build = "zulu11.68.17-ca-jre11.0.21-win_x64"
$java11BuildUri = "https://cdn.azul.com/zulu/bin/$java11Build.zip"
$java11BuildFile = Split-Path $java11BuildUri -Leaf
