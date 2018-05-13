#!/bin/bash
# inspired by https://github.com/erlang/otp/blob/master/HOWTO/INSTALL-WIN32.md
# written by joan touzet (@wohali) and dave cottlehuber (@dch)

# first, a base default path for cygwin
PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin:\
/cygdrive/c/windows/system32:/cygdrive/c/windows:\
/cygdrive/c/windows/system32/Wbem

# utility functions from INSTALL-WIN32.md, forced to cygwin mode
make_winpath()
{
  P=$1
  cygpath -d "$P"
}

make_upath()
{
  P=$1
  cygpath "$P"
}


# build for the right version of erlang
echo Using Erlang $ERTS_VSN OTP $OTP_VER in $ERL_TOP
echo

# convenience variables
C_DRV=/cygdrive/c
PRG_FLS=$C_DRV/Program\ Files\ \(x86\)
PRG_FLS64=$C_DRV/Program\ Files

# MSVS 2013
VISUAL_STUDIO_ROOT=$PRG_FLS/Microsoft\ Visual\ Studio\ 12.0
MS_SDK_ROOT=$PRG_FLS/Windows\ Kits/8.1
NETFX_ROOT=$PRG_FLS/Microsoft\ SDKs/Windows/v8.1A/bin/NETFX\ 4.5.1\ Tools
# Okay, now mangle the paths and get rid of spaces by using short names
WIN_VCROOT=`make_winpath "$VISUAL_STUDIO_ROOT"`
VCROOT=`make_upath $WIN_VCROOT`
WIN_SDKROOT=`make_winpath "$MS_SDK_ROOT"`
SDKROOT=`make_upath $WIN_SDKROOT`
WIN_NETFXROOT=`make_winpath "$NETFX_ROOT"`
NETFXROOT=`make_upath $WIN_NETFXROOT`
WIN_PROGRAMFILES=`make_winpath "$PRG_FLS"`
PROGRAMFILES=`make_upath $WIN_PROGRAMFILES`


# nsis
NSIS_BIN=$PRG_FLS/NSIS
# openssl
OPENSSL_BIN=/cygdrive/c/relax/openssl/bin
# skipping java

# now a path to everything we are about to build
ERL_PATH=$ERL_TOP/release/win32/erts-$ERTS_VSN/bin:\
$ERL_TOP/bootstrap/bin:\
$ERL_TOP/erts/etc/win32/cygwin_tools/vc:\
$ERL_TOP/erts/etc/win32/cygwin_tools

# path to everything Visual Studio 2013
VC_PATH=$VCROOT/Common7/IDE:$VCROOT/VC/BIN:$VCROOT/Common7/Tools:\
$VCROOT/VC/VCPackages:$NETFXROOT:$SDKROOT/bin/x86

# .Net framework which we need to have clean manifests and SxS for Win7 x86
DOTNET_PATH=/cygdrive/c/WINDOWS/Microsoft.NET/Framework:/cygdrive/c/WINDOWS/Microsoft.NET/Framework/v4.0.30319:/cygdrive/c/WINDOWS/Microsoft.NET/Framework/v3.5

# glazier tools
GLAZIER_PATH=$PATH:/relax/bin:/relax/bits

# put it all together
PATH=$NSIS_BIN:$OPENSSL_BIN:$VC_PATH:$PATH:$DOTNET_PATH:$ERL_PATH:$GLAZIER_PATH

LIBPATH="$LIBPATH:$VCROOT\\VC\\lib"

LIB="$LIB:$VCROOT\\VC\\lib\\;$SDKROOT\\lib\\winv6.3\\um\\x86"

INCLUDE="$INCLUDE:$VCROOT\\VC\\include\\;$SDKROOT\\include\\shared\\;\
$SDKROOT\\include\\um;$SDKROOT\\include\\winrt\\;$SDKROOT\\include\\um\\gl"


# Microsoft SDK libpaths are set by setup.cmd

CC_SH_DEBUG_LOG=$TMP/cc_r$OTP_VER.log
LD_SH_DEBUG_LOG=$TMP/ld_r$OTP_VER.log
RC_SH_DEBUG_LOG=$TMP/rc_r$OTP_VER.log
MD_SH_DEBUG_LOG=$TMP/md_r$OTP_VER.log
MC_SH_DEBUG_LOG=$TMP/mc_r$OTP_VER.log

TERM=xterm

export INCLUDE LIB LIBPATH PATH TMP ERL_TOP ERTS_VSN OTP_VER SHELL RELAX TERM CC_SH_DEBUG_LOG LD_SH_DEBUG_LOG RC_SH_DEBUG_LOG MD_SH_DEBUG_LOG MC_SH_DEBUG_LOG

# ensure we have an ERL_TOP to go to
mkdir -p $ERL_TOP > /dev/null 2>&1

# add in otp_build settings
eval `$ERL_TOP/otp_build env_win32`

echo doing sanity checks...
echo current path:
echo $PATH | /bin/sed 's/:/\n/g'
echo
echo please check the toolkit paths point to Microsoft versions:
which mc lc cl link mt rc cvtres
echo

echo Ready to build Erlang and CouchDB using Erlang $ERTS_VSN OTP $OTP_VER in $ERL_TOP
echo Time to Relax.

if [ -z "$BUILD_WITH_JENKINS" ] ; then
  pushd $ERL_TOP
  bash -i
else
	echo Working directory is: `pwd`
	git clean -fdx
	git reset --hard
	./bootstrap
	/relax/bin/couchdb_config.sh
	/relax/bin/couchdb_build.sh
fi

