Overview
========

Using the following instructions, you will cross-compile perl 5.26.1 for rumprun on a NetBSD 7.1 Host.

Maintainer
----------

* Dominik Winter, dominik.winter@tum.de
* Github: @domWinter


Patches
=======

The build process will apply the patches required for cross-compilation support
and a static Perl build. Patches are found in the `patches/` directory.

The patch for a static Perl build will support the core modules out of the box,
but not everything. For further modules that depend on C libraries you will have
to compile these statically and add them manually during the build process to the 
compiling step.

Instructions
============

Run `make` from a root account on a NetBSD 7.1 host in `/root/perl-for-rump`. 

The build script requires `git`,  `wget` and `gmake` to create the perl supporting
rump unikernel binary.

Run `make` from the python package directory:

```
cd perl-for-rump
make
```

Examples
========


You are now ready to run the Perl example. To run the rumpkernel using KVM, the following will work:

```
rumprun kvm -i -- perl.bin -e "print "Hello World!\n";"
```

You will have to replace `kvm` with `xen` to run under Xen.
