# About this fork

This repository is a fork of d3d8to9. The original is <https://github.com/crosire/d3d8to9>,
by Patrick Mours, under the BSD 2-Clause licence ([LICENSE.md](LICENSE.md), kept as it is).
The fork is maintained by ILuce (<https://github.com/ILuce>). **The source of the library is
not changed.** The fork adds a way to build `d3d8.dll` with llvm-mingw on a machine that does
not run Windows, and publishes that build. It is not the original project's release, and the
original author neither publishes nor supports it.

## How the fork is kept

- The branch `iluce` is an upstream release tag plus the fork's own files: this file,
  `build-llvm-mingw.sh` and a note at the top of `README.md`.
- A change to the library itself is made only for a gap that a real program showed, one
  commit per gap, each listed below. There is none so far.
- A release of the fork is a tag `v<upstream version>+iluce.<N>` on that branch.
- When upstream publishes a release, the branch is rebuilt on it.

## Releases

| Fork release | Upstream base | Changes to the library |
|---|---|---|
| `v1.16.0+iluce.1` | `v1.16.0` (`255338f698c8270b537f0a91a13f795f4f988250`) | none |

## The build

`LLVM_MINGW=/path/to/llvm-mingw ./build-llvm-mingw.sh [out dir]` builds `d3d8.dll` for 32-bit
Windows (Direct3D 8 programs are 32-bit):

- the source list of `CMakeLists.txt`, the export file and the version resource, unchanged;
- the Release configuration (`NDEBUG`, `D3D8TO9NOLOG`): the library writes no `d3d8.log`
  beside the program;
- the C++ runtime linked statically: the library imports `Direct3DCreate9` from `d3d9.dll`,
  Windows' own libraries and the universal C runtime, and nothing else;
- no time stamp and no path of the building machine: the same source and the same toolchain
  give the same bytes.

Release `v1.16.0+iluce.1` was built with llvm-mingw 20261006 (clang and LLD 23.1.3). Its
`d3d8.dll` has 937,984 bytes and the SHA-256
`a2917505140321e7f330b012c1f3ee193ca3298aace9df4beb8c1065d4808e91`.

## Using the build under Wine

A 32-bit program loads this library in place of Wine's own `d3d8.dll` when the file lies
where a native library is found (beside the program, or in the prefix's 32-bit system
directory) and the program has the override `d3d8=n,b`. The library then loads `d3d9.dll`,
whichever Direct3D 9 the Wine in use provides, and `d3dx9_43.dll` for its shader conversion.
