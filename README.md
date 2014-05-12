Introduction
============

Packman is an easy-to-use tool to manage the installation of packages and setup
of environment in remote server (or local computer). The reasons why this tool
is created are:

- Most server admin is lazy, so the versions of Linux and the softwares (e.g.
  GCC) are fairly low! It causes much headache when porting program.
- Some useful packages are missing, e.g. GIT, NetCDF.
- Fortran compiler messes up package versions.
- Linux package managers (e.g. rpm, apt) are too conservative.

In Mac, we have the wonderful `homebrew`, which is truely addictive, but the
port to Linux `linuxbrew` is not really ready for serious use. With all these
pains in my ass, I decided to create a tool `packman` on my own. The final goal
is no matter how messy the server is (we do not give a shit!), we could use
`packman` to setup the necessary development environment. So we can focus on
our real problems, not install the packages over and over again!

Usage
=====

Grab `packman` in whatever way you like (through git or get zip file). Add the
following line into your BASH configuration file (e.g. .bashrc):
```
source <path_to_packman>/setup.sh
```
First you must collect all the packages from internet by typing:
```
$ packman collect
```
When the remote server can not access internet, you can do this in your local
computer, and upload `packman` with the downloaded packages onto server.
Second you need to edit a configuration for `packman` as:
```
install_root = <where you want to put the built packages>
fortran_compiler = <fortran compiler you like>
exclude_packages = <package1> <package2> ...
include_packages = <package1> <package2> ...
```
where `exclude_packages` is the list for packages that are not to be installed,
and `include_packages` is the opposite. The two parameters can not be set at
the same time. After configuring, run:
```
$ packman install <path_to_config_file>
```
The packages will be built in order. When you want to use the packages
installed by `packman`, you have two options. One is through the following
command:
```
$ packman setup_env <path_to_config_file>
```
You will go into a new BASH session where the packages can be used or linked.
The other may be more convenient in your BASH configuration file (e.g.
.bashrc):
```
source <path_to_install_root>/bashrc
```
By now, you will have fresh packages (no more GCC 4.1.2!).

Available packages
==================

The following is a list of the packages that I have tried to built with success
on two Linux servers and a Mac server:

| package name                      | version   |
|-----------------------------------|-----------|
| antlr                             | 2.7.7     |
| armadillo                         | 4.100.2   |
| cdo                               | 1.6.3     |
| cmake                             | 2.8.12.2  |
| cmor                              | 2.9.1     |
| curl                              | 7.36.0    |
| gcc                               | 4.8.2     |
| git                               | 1.9.2     |
| grib-api (in grib)                | 1.12.1    |
| hdf5  (with C++ and Fortran API)  | 1.8.12    |
| jasper                            | 1.900.1   |
| lapack                            | 3.5.0     |
| ncl                               | 6.2.0     |
| nco                               | 4.4.3     |
| netcdf-c (in netcdf)              | 4.3.1.1   |
| netcdf-cxx4 (in netcdf)           | 4.2.1     |
| netcdf-fortran (in netcdf)        | 4.2       |
| openblas                          | 0.2.9.rc2 |
| szip                              | 2.1       |
| texinfo                           | 5.2       |
| udunits                           | 2.1.24    |
| uuid                              | 1.6.2     |

More packages can be added gradually by me or by community.

Authors
=======

- Li Dong <dongli@lasg.iap.ac.cn>
