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


# Helper script for lazy Windows Developers
# Downloading, checking and extracting the sources of a rc candidate for Windows

<#
.SYNOPSIS
    Little helper script for lazy Windows (Release) Developers
.DESCRIPTION
    This command downloads, checks and extract a CouchDB source tarball

    -CouchDBVersion <string>        CouchDB version number to download (e.g. 3.4.2)
    -ReleaseCandidate <string>      Release candidate version number (e.g. rc1)
    -Path <string>                  Directory to store the artifacts (e.g. C:\relax\releases)

.LINK
    https://couchdb.apache.org/
#>

[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [ValidateNotNullOrEmpty()]
   [String]$CouchDBVersion,

   [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [ValidateNotNullOrEmpty()]
   [String]$ReleaseCandidate,

   [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
   [ValidateNotNullOrEmpty()]
   [String]$Path
)

$DOWNLOAD_URL = "https://dist.apache.org/repos/dist/dev/couchdb/source/$CouchDBVersion/$ReleaseCandidate/"
$DOWNLOAD_DIR = Join-Path (Join-Path $Path $CouchDBVersion) $ReleaseCandidate

# start shell
. ${PSScriptRoot}\shell.ps1

if(Test-Path -Path $DOWNLOAD_DIR) {
    Remove-Item -Path $DOWNLOAD_DIR -Recurse -Force
}
New-Item -ItemType Directory -Path $DOWNLOAD_DIR

# Download tarball and checksums
$ProgressPreference = "SilentlyContinue"
Write-Output "####### DOWNLOAD SOURCES ########"
$fileList = Invoke-WebRequest $DOWNLOAD_URL -UseBasicParsing
$fileNames = $($fileList.Links |?{$_.href -match "apache-couchdb"}).href
foreach ($file in $fileNames)
{
    Write-Output $DOWNLOAD_URL$file
    Invoke-WebRequest -Uri "$DOWNLOAD_URL$file" -OutFile $(Join-Path $DOWNLOAD_DIR $file)
}
Write-Output "#################################`n`n"

# Used Software for compiling CouchDB
Write-Output "####### SOFTWARE VERSIONS #######"
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell
elixir --version
python --version
java -version
Write-Output "#################################`n`n"

# Check signature and checksum
Write-Output "######## CHECK SIGNATURE ########"
C:\tools\msys64\msys2_shell.cmd -defterm -no-start -mingw64 -where $DOWNLOAD_DIR -c "curl -s -L https://apache.org/dist/couchdb/KEYS | gpg --import -"
C:\tools\msys64\msys2_shell.cmd -defterm -no-start -mingw64 -where $DOWNLOAD_DIR -c "gpg --verify apache-couchdb-*.tar.gz.asc"
C:\tools\msys64\msys2_shell.cmd -defterm -no-start -mingw64 -where $DOWNLOAD_DIR -c "sha256sum --check apache-couchdb-*.tar.gz.sha256"
Write-Output "#################################`n`n"

# Extract sources
Write-Output "######## EXTRACT SORUCES ########"
arc unarchive $(Join-Path $DOWNLOAD_DIR "apache-couchdb-*.tar.gz" -Resolve) "$DOWNLOAD_DIR"
Write-Output "#################################`n`n"

Set-Location "$DOWNLOAD_DIR\apache-couchdb-$CouchDBVersion"
