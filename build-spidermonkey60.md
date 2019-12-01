##Build Environment

Below is environment we are using and we can check whether it is working on Windows 7/8 and Visual Studio 2013/2015 etc.

- Windows 10 
- Visual Studio 2017 update 5 Version 15.9.17
- Windows Universal CRT SDK via "Individual Components" -> "Compiler, build tools, and runtimes" -> "Windows Universal CRT SDK" by running `C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe`
- Windows 10 SDK (10.0.15063.0) via "Universal Windows Platform Development" -> "Optional" -> "Windows 10 SDK (10.0.15063.0)" by running `C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe` # should be older than 10.0.16299.0


##Getting Started

Make a new shortcut on the desktop. The location should be:

```
cmd.exe /E:ON /V:ON /T:1F /K ""C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"" amd64  && color 1f
```

Start by launching a fresh CouchDB SDK prompt, then setup the Mozilla build environment with the command:

```
call cd \mozilla-build-3.2\start-shell.bat
```

mozilla-build-3.2 can be downloaded from `https://ftp.mozilla.org/pub/mozilla/libraries/win32/`


##Build Spidermonkey JavaScript 6.0

Spidermonkey needs to be compiled with the Mozilla Build chain. There are some issues during build, and check the troubleshooting sections and see whether they help.

```
cd /c/relax
tar xvf mozjs-60.1.1pre3.tar.bz2 # from https://ftp.mozilla.org/pub/spidermonkey/prereleases/60/pre3/
cd mozjs-60.1.1pre3/js/src

<replace mozjs-60.1.1pre3\build\win32\vswhere.exe with 
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe. Otherwise we will get WindowsError: [Error 5] Access is denied when running configure>

autoconf2.13 
 
mkdir build_OPT.OBJ
cd build_OPT.OBJ
 ../configure --enable-shared-js  --disable-jemalloc --disable-tests --enable-optimize  --build-backends=RecursiveMake --enable-posix-nspr-emulation --with-visual-studio-version=2017 --disable-debug  --enable-gczeal --target=x86_64-pc-mingw32 --host=x86_64-pc-mingw32 
mozmake
```

Some build targets can be 

- mozjs-60.1.1pre3\js\src\build_OPT.OBJ\dist\include
- mozjs-60.1.1pre3\js\src\build_OPT.OBJ\js\src\build\mozjs-60.lib
- mozjs-60.1.1pre3\js\src\build_OPT.OBJ\js\src\build\mozjs-60.dll


##Troubleshooting

### should use autoconfig 2.13

```
$ autoconf
../../build/autoconf/acwinpaths.m4:10: error: defn: undefined macro: AC_OUTPUT_FILES
../../build/autoconf/acwinpaths.m4:10: the top level
autom4te-2.68: /bin/m4 failed with exit status: 1
```

Note: we need to use autoconfig version 2.13. You might get above error if using new version of autoconfig.


### acgeneral.m4 not found

```
$ autoconf --version
sed: can't read /usr/share/autoconf-2.13/acgeneral.m4: No such file or directory
Autoconf version
```
Note: The autoconf provided in `Mozilla build` is not always working. I download autoconf-2.1.3 and copy them to /usr/share directory and run `/c/autoconf-2.13/autoconf` under `mozjs-60.1.1pre3/js/src` directory.

```
cp -r autoconf-2.13 /usr/share/
```

### "Access is denied" when running configure

```
Traceback (most recent call last):
  File "../../../configure.py", line 127, in <module>
    sys.exit(main(sys.argv))
  File "../../../configure.py", line 29, in main
    sandbox.run(os.path.join(os.path.dirname(__file__), 'moz.configure'))
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 409, in run
    self._value_for(option)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 477, in _value_for
    return self._value_for_option(obj)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
$
    not self._value_for(implied_option.when)):
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 199, in result
    return self._func(resolved_args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 198, in <genexpr>
    for d in self.dependencies)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 122, in result
    for d in self.dependencies]
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 122, in result
    for d in self.dependencies]
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 122, in result
    for d in self.dependencies]
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 122, in result
    for d in self.dependencies]
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 474, in _value_for
    return self._value_for_depends(obj, need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 483, in _value_for_depends
    return obj.result(need_help_dependency)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\util.py", line 944, in method_call
    cache[args] = self.func(instance, *args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 123, in result
    return self._func(*resolved_args)
  File "c:\mozjs-60.1.1pre3\python\mozbuild\mozbuild\configure\__init__.py", line 1003, in wrapped
    return new_func(*args, **kwargs)
  File "c:/mozjs-60.1.1pre3/build/moz.configure/toolchain.configure", line 625, in vc_compiler_path
    all_versions = sorted(get_vc_paths(env.topsrcdir), key=itemgetter(0))
  File "c:/mozjs-60.1.1pre3/build/moz.configure/toolchain.configure", line 572, in get_vc_paths
    for install in vswhere(['-legacy', '-version', '[14.0,15.0)']):
  File "c:/mozjs-60.1.1pre3/build/moz.configure/toolchain.configure", line 568, in vswhere
    ] + args).decode(encoding, 'replace'))
  File "c:\mozilla-build-3.2\python\Lib\subprocess.py", line 216, in check_output
    process = Popen(stdout=PIPE, *popenargs, **kwargs)
  File "c:\mozilla-build-3.2\python\Lib\subprocess.py", line 394, in __init__
    errread, errwrite)
  File "c:\mozilla-build-3.2\python\Lib\subprocess.py", line 644, in _execute_child
    startupinfo)
WindowsError: [Error 5] Access is denied

```

Note: `vswhere.exe` provide in `mozjs-60.1.1pre3` is not working. I replace mozjs-60.1.1pre3\build\win32\vswhere.exe with 
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe.

### Header files: No such file or directory

```
c:/mozjs-60.1.1pre3/js/src/build.j/_virtualenv/Scripts/python.exe -m mozbuild.action.cl  cl.exe -FoUnified_cpp_js_src36.obj -c -DDEBUG=1 -DENABLE_WASM_GLOBAL -DWASM_HUGE_MEMORY -DJS_CACHEIR_SPEW -DENABLE_SHARED_ARRAY_BUFFER -DEXPORT_JS_API -DMOZ_HAS_MOZGLUE -Ic:/mozjs-60.1.1pre3/js/src -Ic:/mozjs-60.1.1pre3/js/src/build.j/js/src -Ic:/mozjs-60.1.1pre3/js/src/build.j/dist/include -MDd -FI c:/mozjs-60.1.1pre3/js/src/build.j/js/src/js-confdefs.h -DMOZILLA_CLIENT -utf-8 -TP -nologo -wd4800 -wd4595 -D_CRT_SECURE_NO_WARNINGS -w15038 -wd5026 -wd5027 -Zc:sizedDealloc- -D_HAS_EXCEPTIONS=0 -W3 -Gy -Zc:inline -Gw -wd4244 -wd4267 -wd4251 -we4553 -GR- -Zi -Oy- -wd4805 -wd4661 -we4067 -we4258 -we4275 -wd4146 -wd4577 -wd4312    -Fdgenerated.pdb -FS  c:/mozjs-60.1.1pre3/js/src/build.j/js/src/Unified_cpp_js_src36.cpp
Unified_cpp_js_src36.cpp
c:/mozjs-60.1.1pre3/js/src/vm/PosixNSPR.cpp(14): fatal error C1083: Cannot open include file: 'sys/time.h': No such file or directory
mozmake[3]: *** [c:/mozjs-60.1.1pre3/config/rules.mk:1049: Unified_cpp_js_src36.obj] Error 2
```

```
c:/mozjs-60.1.1pre3/js/src/build.j/_virtualenv/Scripts/python.exe -m mozbuild.action.cl  cl.exe -FoUnified_cpp_js_src39.obj -c -DDEBUG=1 -DENABLE_WASM_GLOBAL -DWASM_HUGE_MEMORY -DJS_CACHEIR_SPEW -DENABLE_SHARED_ARRAY_BUFFER -DEXPORT_JS_API -DMOZ_HAS_MOZGLUE -Ic:/mozjs-60.1.1pre3/js/src -Ic:/mozjs-60.1.1pre3/js/src/build.j/js/src -Ic:/mozjs-60.1.1pre3/js/src/build.j/dist/include -MDd -FI c:/mozjs-60.1.1pre3/js/src/build.j/js/src/js-confdefs.h -DMOZILLA_CLIENT -utf-8 -TP -nologo -wd4800 -wd4595 -D_CRT_SECURE_NO_WARNINGS -w15038 -wd5026 -wd5027 -Zc:sizedDealloc- -D_HAS_EXCEPTIONS=0 -W3 -Gy -Zc:inline -Gw -wd4244 -wd4267 -wd4251 -we4553 -GR- -Zi -Oy- -wd4805 -wd4661 -we4067 -we4258 -we4275 -wd4146 -wd4577 -wd4312    -Fdgenerated.pdb -FS  c:/mozjs-60.1.1pre3/js/src/build.j/js/src/Unified_cpp_js_src39.cpp
Unified_cpp_js_src39.cpp
c:/mozjs-60.1.1pre3/js/src/vm/Time.cpp(30): fatal error C1083: Cannot open include file: 'prinit.h': No such file or directory
```

Note: we might have to create some patches for `mozjs-60.1.1pre3` windows version. Now just commented out these.

### Failed to build nspr

```
c:/mozjs/mozjs-60.1.1pre3/js/src/build.a/_virtualenv/Scripts/python.exe -m mozbuild.action.cl  cl.exe -Foprdir.obj -c -DDEBUG=1 -D_NSPR_BUILD_ -DWIN32 -DXP_PC -D_PR_GLOBAL_THREADS_ONLY -DWIN95 -UWINNT -DDO_NOT_WAIT_FOR_CONNECT_OVERLAPPED_OPERATIONS -D_AMD64_ -Ic:/mozjs/mozjs-60.1.1pre3/config/external/nspr/pr -Ic:/mozjs/mozjs-60.1.1pre3/js/src/build.a/config/external/nspr/pr -Ic:/mozjs/mozjs-60.1.1pre3/config/external/nspr -Ic:/mozjs/mozjs-60.1.1pre3/nsprpub/pr/include -Ic:/mozjs/mozjs-60.1.1pre3/nsprpub/pr/include/private -Ic:/mozjs/mozjs-60.1.1pre3/js/src/build.a/dist/include -Ic:/mozjs/mozjs-60.1.1pre3/js/src/build.a/dist/include/nspr -MD -FI c:/mozjs/mozjs-60.1.1pre3/js/src/build.a/js/src/js-confdefs.h -DMOZILLA_CLIENT -utf-8 -TC -nologo -D_HAS_EXCEPTIONS=0 -W3 -Gy -Zc:inline -Gw -wd4244 -wd4267 -we4553 -Zi -O2 -Oy-    -Fdgenerated.pdb -FS  c:/mozjs/mozjs-60.1.1pre3/nsprpub/pr/src/io/prdir.c
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\shared\stralign.h(120): warning C4090: 'argument': different '__unaligned' qualifiers
prdir.c
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\shared\kernelspecs.h(58): warning C4005: 'HIGH_LEVEL': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\shared\kernelspecs.h(55): note: see previous definition of 'HIGH_LEVEL'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7531): warning C4005: 'CONTEXT_CONTROL': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3808): note: see previous definition of 'CONTEXT_CONTROL'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7532): warning C4005: 'CONTEXT_INTEGER': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3809): note: see previous definition of 'CONTEXT_INTEGER'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7533): warning C4005: 'CONTEXT_SEGMENTS': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3810): note: see previous definition of 'CONTEXT_SEGMENTS'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7534): warning C4005: 'CONTEXT_FLOATING_POINT': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3811): note: see previous definition of 'CONTEXT_FLOATING_POINT'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7535): warning C4005: 'CONTEXT_DEBUG_REGISTERS': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3812): note: see previous definition of 'CONTEXT_DEBUG_REGISTERS'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7539): warning C4005: 'CONTEXT_FULL': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3815): note: see previous definition of 'CONTEXT_FULL'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7543): warning C4005: 'CONTEXT_ALL': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3819): note: see previous definition of 'CONTEXT_ALL'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7545): warning C4005: 'CONTEXT_XSTATE': macro redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3821): note: see previous definition of 'CONTEXT_XSTATE'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(7597): error C2011: '_CONTEXT': 'struct' type redefinition
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\um\winnt.h(3886): note: see declaration of '_CONTEXT'
C:\Program Files (x86)\Windows Kits\10\include\10.0.18362.0\shared\stralign.h(120): warning C4090: 'function': different '__unaligned' qualifiers
mozmake[3]: *** [c:/mozjs/mozjs-60.1.1pre3/config/rules.mk:774: prdir.obj] Error 2
mozmake[3]: Leaving directory 'c:/mozjs/mozjs-60.1.1pre3/js/src/build.a/config/external/nspr/pr'
mozmake[2]: *** [c:/mozjs/mozjs-60.1.1pre3/config/recurse.mk:73: config/external/nspr/pr/target] Error 2
```

Note: NSPR is not easy to build in windows. I use --enable-posix-nspr-emulation

### New Windows 10 SDK
```
ERROR: Found SDK version 10.0.18362.0 but clang-cl builds currently don't work with SDK version 10.0.16299.0 and later. You should use an older SDK, either by uninstalling the broken one or setting a custom WINDOWSSDKDIR
```

Note: we might get above error when running configure. Need to use proper window SDK.

### Windows Universal CRT SDK

```
Cannot open include file corecrt.h
```
Note: we need to install "Windows Universal CRT SDK"
