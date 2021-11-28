dfx in nix
==========

This repository tries to provide nix packaging of
[`dfx`](https://github.com/dfinity/sdk).

Usage
-----

This repositories' `default.nix` exports a `dfx` attribute.

It also has a `shell.nix` that brings `dfx` into your PATH.

Only read on if you are curious.

The problem
-----------

The official `dfx` binary releases have their ELF linker path patched to
`/lib64/ld-linux-x86-64.so.2`, which does not exist on NixOS.

Moreover, it's not just the `dfx` binary itself (which could be `patchelf`'ed),
but the binary itself contains other binaries (`replica`, `moc`...) which it
extracts at runtime, and some of which _also_ have the ELF linker path set to
this unhelpful value.

The current solution
--------------------

nixpkgs comes with a `steam-run` program that wraps other programs in a more
typical environment. So currently, we just create a `dfx` wrapper script that
runs `dfx` with `steam-run`.

This is quite an unelegant hammer, so:

The better solution
-------------------

Now that the `sdk` repository is open source, we could make it behave more
nicely on NixOS. One possible approach is to

 * patch `dfx` to not include binaries, nor to extract this confusing "cache".
   Instead, invoke the relevant binaries based on a `DFX_replica` etc.
   environment variable.

 * fetch and patchelf, or just build, the dependencies in nix

 * produce a wrapped `dfx` that sets the environment variables accordingly.

*Patches welcome!*
