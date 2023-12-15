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

# Prerequisites:
# 1. Install JSign (https://ebourg.github.io/jsign/).
# 2. Edit $Storepass variable with your DigiCert One credentials.
#    Be sure to use single quotes and escape the pipe char | with
#    double quotes like "|".
# 3. Edit $Alias variable to match your signing key alias.

Param(
    [Parameter(Mandatory=$True)]
    [string]$MSIFile
    )

# EDIT BOTH VARIABLES ###################################################
$Storepass = '<api-key>"|"<path-to-client-cert>"|"<client-cert-password>'
$Alias = "<your-digicert-alias>"
#########################################################################

# RFC 3161 timestamping URL
New-Variable -Name TSAUrl -Value "http://timestamp.digicert.com" -Option Constant

# call JSign and sign file
jsign --storetype DIGICERTONE --storepass $Storepass --alias $Alias --tsaurl $TSAUrl $MSIFile
