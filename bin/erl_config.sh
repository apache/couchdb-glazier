#!/bin/sh
pushd $ERL_TOP
./otp_build autoconf 2>&1 | tee $ERL_TOP/build_autoconf.txt
# from Erlang/OTP R14B03 onwards, Erlang by default is built with
# *static* OpenSSL. Uncomment following, and change build_openssl.cmd
# to revert this.
## ./otp_build configure --enable-dynamic-ssl-lib --with-ssl=/cygdrive/c/openssl 2>&1 | tee $ERL_TOP/build_configure.txt
export SSL_INCDIR='/cygdrive/c/OpenSSL-Win64'
export SSL_INCLUDE='-I/cygdrive/c/OpenSSL-Win64/include'
export SSL_LIBDIR='/cygdrive/c/OpenSSL-Win64/lib'
export SSL_CRYPTO_LIBNAME='libeay32'
export SSL_SSL_LIBNAME='ssleay32'
mkdir /cygdrive/c/OpenSSL-Win64/lib/VC
./otp_build configure --with-ssl=/cygdrive/c/OpenSSL-Win64 --without-javac 2>&1 | tee $ERL_TOP/build_configure.txt
popd
