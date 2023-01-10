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

copy C:\relax\gecko-dev\sm-obj-opt\js\src\build\*.lib C:\relax\vcpkg\installed\x64-windows\lib
copy C:\relax\gecko-dev\sm-obj-opt\dist\bin\*.dll C:\relax\vcpkg\installed\x64-windows\bin
copy C:\relax\gecko-dev\sm-obj-opt\dist\include\* C:\relax\vcpkg\installed\x64-windows\include -Recurse -ErrorAction SilentlyContinue
