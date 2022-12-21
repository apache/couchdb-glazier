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

# MOZILLA BUILD SETTINGS

# Download location of the Mozilla Build Environment for Windows
$mozBuildUri = "https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-3.4.exe"
$mozBuildFile = Split-Path $mozBuildUri -Leaf

# ERLANG BUILD SETTINGS

# Download location of the Erlang/OTP Environment for Windows (x64)
$erlBuildUri = "https://github.com/erlang/otp/releases/download/OTP-24.3.4.6/otp_win64_24.3.4.6.exe"
$erlBuildFile = Split-Path $erlBuildUri -Leaf
$erlDir = "erl24"
$erlInstallPath = "C:\Program Files\${erlDir}"

# ERLANG BUILD SETTINGS

# Download location of the Elixier binaries for Windows (x64)
$elxBuildUri = "https://github.com/elixir-lang/elixir/releases/download/v1.13.4/Precompiled.zip"
$elxBuildFile = Split-Path $elxBuildUri -Leaf
$elxInstallPath = "C:\relax\elixir"
