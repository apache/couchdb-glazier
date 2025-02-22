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


# Helper script for excluding some tests which fail under Windows
# see https://github.com/apache/couchdb/issues/4398


<#
.SYNOPSIS
    Little helper script to exclude some CouchDB before doing a "make check"

.DESCRIPTION
    This command renames some test files to get excluded/included from running tests

    -IncludeTests       Include already excluded tests for the next test run
    -Path <string>      Path to the CouchDB source tree directory

.LINK
    https://couchdb.apache.org/
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [switch]$IncludeTests = $false     #include tests again
)

$excludeTests = @(
    "src\couch\test\eunit\couchdb_attachments_tests.erl",
    "src\chttpd\test\eunit\chttpd_db_test.erl",
    "src\chttpd\test\eunit\chttpd_dbs_info_test.erl",
    "src\chttpd\test\eunit\chttpd_security_tests.erl",
    "src\chttpd\test\eunit\chttpd_socket_buffer_size_test.erl",
    "src\chttpd\test\eunit\chttpd_bulk_get_test.erl"
)

function renameFile ([string]$file, [bool]$exclude = $true) {
    if($exclude) {
        if( Test-Path -path $file ) {
            Write-Host "$file is excluded during testing..."
            Rename-Item -path $file -NewName "$file.old"
        }
    } else {
        if( Test-Path -path "$file.old" ) {
            Write-Host "$file is considered during testing..."
            Rename-Item -path "$file.old" -NewName "$file"
        }
    }
}

foreach ($test in $excludeTests)
{
    $file = Join-Path (Resolve-Path $Path) $test
    if($IncludeTests) {
        renameFile $file $false
    } else {
        renameFile $file $true
    }
}
