#!/bin/sh

# https://bugzilla.mozilla.org/show_bug.cgi?id=1802675
cd /c/relax/gecko-dev/memory/mozalloc || exit
mv moz.build moz.build2.org
sed 's/if CONFIG\["OS_TARGET"\] == "WINNT":/if CONFIG["MOZ_MEMORY"] and CONFIG["OS_TARGET"] == "WINNT":/g' moz.build2.org > moz.build
