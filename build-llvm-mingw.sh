#!/bin/sh
# Build d3d8.dll for 32-bit Windows with llvm-mingw (https://github.com/mstorsjo/llvm-mingw),
# on any machine that toolchain runs on. No file of the library's source is changed.
#
# Usage: LLVM_MINGW=/path/to/llvm-mingw ./build-llvm-mingw.sh [out dir]
#
# What the build is:
#   - the source list of CMakeLists.txt, the export file res/d3d8.def and the version
#     resource res/d3d8to9.rc;
#   - the Release configuration: NDEBUG and D3D8TO9NOLOG (the library writes no d3d8.log
#     beside the program and shows no message about it), optimised;
#   - the options CMakeLists.txt gives a compiler that is not MSVC, and the system libraries a
#     CMake build for MinGW adds by itself (gdi32, shell32, user32);
#   - the C++ runtime linked statically, so the library needs nothing but Windows' own
#     libraries, the universal C runtime and d3d9.dll;
#   - no time stamp and no path of the building machine in the file, so the same source and
#     the same toolchain give the same bytes.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
bin=${LLVM_MINGW:?set LLVM_MINGW to the directory of an llvm-mingw toolchain}/bin
out=${1:-$here/build}
mkdir -p "$out/obj"
CXXFLAGS="-std=c++17 -O2 -DNDEBUG -DD3D8TO9NOLOG -Wall -Wno-delete-non-virtual-dtor -Wno-unknown-pragmas -ffile-prefix-map=$here=."
objects=""
for name in d3d8to9 d3d8to9_base d3d8to9_device d3d8to9_index_buffer d3d8to9_surface \
            d3d8to9_swap_chain d3d8to9_texture d3d8to9_vertex_buffer d3d8to9_volume \
            d3d8types interface_query; do
    # shellcheck disable=SC2086
    "$bin/i686-w64-mingw32-clang++" $CXXFLAGS -c "$here/source/$name.cpp" -o "$out/obj/$name.o"
    objects="$objects $out/obj/$name.o"
done
"$bin/i686-w64-mingw32-windres" -I "$here/res" "$here/res/d3d8to9.rc" -O coff -o "$out/obj/d3d8to9.res.o"
# shellcheck disable=SC2086
"$bin/i686-w64-mingw32-clang++" -shared -static -O2 -o "$out/d3d8.dll" $objects "$out/obj/d3d8to9.res.o" \
    "$here/res/d3d8.def" -ld3d9 -lgdi32 -lshell32 -luser32 \
    -Wl,--enable-stdcall-fixup -Wl,--no-insert-timestamp
"$bin/i686-w64-mingw32-strip" "$out/d3d8.dll"
echo "built: $out/d3d8.dll"
