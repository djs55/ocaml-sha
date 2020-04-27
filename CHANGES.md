## v1.13

- Update to dune2, fix Windows compilation, make C fns static @nojb (#42)
- Fix opam lint @djs55 (#44)
- Support platforms without `O_CLOEXEC` @dougmenchen (#41 then #45)

## v1.12

- Build with jbuilder (#38 by @nojb)
- Fix a possible GC crash (#36 by @madroach)
- Fix build with MSVC toolchain (#37 by @nojb)
- Build C with `-fPIC` (#25 by @talex5)

## v1.11

- Relicense to ISC (#22)
- Fix Windows support and test with appveyor (#28)
- Fix FreeBSD support (#12)

## v1.10

- Fix build with OCaml 4.06 (and `-safe-string`)
