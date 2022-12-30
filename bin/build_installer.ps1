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

# PLEASE EDIT ME AND CHANGE $CouchDB_Root to the CouchDB folder on disk ####
# Example:
# $CouchDB_Root = "C:\relax\apache-couchdb-3.3.0"
$CouchDB_Root = "PLEASE_SET_PATH_TO_COUCHDB_DIR"
# ###################

$CouchDB = "${CouchDB_Root}\rel\couchdb"
if ($CouchDB_Root -eq "PLEASE_SET_PATH_TO_COUCHDB_DIR")
{
   Write-Error "Please set the env variable CouchDB_Root in this script. Exiting..."
   exit 1
}
if (-Not ((Test-Path $CouchDB) -and ($CouchDB.EndsWith("rel\couchdb"))))
{
   Write-Error "CouchDB release directory not found. Have you run make release? Exiting..."
   exit 1
}
if (! $env:VCPKG_BIN)
{
   Write-Error "Your VCPKG_BIN environment variable is not set! Exiting..."
   exit 1
}

$Glazier = "${PSScriptRoot}\.."
$CouchDBVersion = Get-Content "${CouchDB}\releases\start_erl.data" |
      ForEach-Object {$_.Split(" ")[1]}
$RelNotesVersion = $CouchDBVersion -replace "^(\d+\.\d+)\..*", '$1'

# clean up from previous runs
Push-Location $Glazier\installer
Remove-Item release -Recurse -ErrorAction Ignore
Remove-Item *.wixobj, *.wixpdb, couchdb.wxs, couchdbfiles.wxs, *.ini -ErrorAction Ignore
Remove-Item "${CouchDB}\bin\*.dll", "${CouchDB}\bin\nssm.exe" -ErrorAction Ignore

# add build assets we need in the package
Copy-Item -Path "${env:VCPKG_BIN}\*.dll" -Destination "${CouchDB}\bin"
Copy-Item -Path "C:\ProgramData\Chocolatey\lib\nssm\tools\nssm.exe" -Destination "${CouchDB}\bin"
Move-Item -Path "${CouchDB}\etc\default.ini" -Destination "."
Move-Item -Path "${CouchDB}\etc\local.ini" -Destination "${CouchDB}\etc\local.ini.dist"
Move-Item -Path "${CouchDB}\etc\vm.args" -Destination "${CouchDB}\etc\vm.args.dist"

# customize a few files in the install for Windows
(Get-Content "couchdb.wxs.in") `
      -replace "###VERSION###", "${CouchDBVersion}" `
      -replace "###RELNOTESVERSION###", "${RelNotesVersion}" |
      Set-Content "couchdb.wxs"
(Get-Content "default.ini") `
      -replace "^;file =.*", "file = ./var/log/couchdb.log" `
      -replace "^;writer = stderr", "writer = file" |
      Out-File "default.ini" -Encoding ascii
Move-Item -Path ".\default.ini" -Destination "${CouchDB}\etc\default.ini"
# WiX skips empty directories, so we create a dummy logfile
Out-File -FilePath "${CouchDB}\var\log\couchdb.log" -Encoding ascii

# Build our custom action.
Push-Location CustomAction
Remove-Item obj -Recurse -ErrorAction Ignore
MSBuild /p:Configuration=Release
Pop-Location

# We don't want to re-run heat unless files have changed. And even then,
# we'd want to manually merge. heat will regenerate all GUIDS and that will
# cause problems in the field if we ever start upgrading rather than
# uninstall/reinstall. It's the -gg flag that results in this behaviour.
heat dir "${CouchDB}" -dr APPLICATIONFOLDER -cg CouchDBFilesGroup -gg -g1 -sfrag -srd -sw5150 -var "var.CouchDir" -out couchdbfiles.wxs

# Build MSI for installation
candle -arch x64 -ext WiXUtilExtension couchdb.wxs
candle -arch x64 "-dCouchDir=${CouchDB}" couchdbfiles.wxs
candle -arch x64 -ext WiXUtilExtension couchdb_wixui.wxs
candle -arch x64 -ext WiXUtilExtension adminprompt.wxs
candle -arch x64 -ext WiXUtilExtension cookieprompt.wxs
candle -arch x64 -ext WiXUtilExtension customexit.wxs
candle -arch x64 -ext WiXUtilExtension CouchInstallDirDlg.wxs
light -sw1076 -sice:ICE17 -ext WixUIExtension -ext WiXUtilExtension "-cultures:en-us;en;neutral" adminprompt.wixobj cookieprompt.wixobj couchdb.wixobj couchdbfiles.wixobj couchdb_wixui.wixobj customexit.wixobj CouchInstallDirDlg.wixobj -out apache-couchdb-${CouchDBVersion}.msi

Pop-Location

Move-Item -Path "${CouchDB}\etc\local.ini.dist" -Destination "${CouchDB}\etc\local.ini"
Move-Item -Path "${CouchDB}\etc\vm.args.dist" -Destination "${CouchDB}\etc\vm.args"
Move-Item -Path "${Glazier}\installer\apache-couchdb-${CouchDBVersion}.msi" -Destination "." -Force
