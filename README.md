Introduction
============

Packman is an easy-to-use tool to manage the installation of packages and setup
of environment in remote server (or local computer). The reasons why this tool
is created are:

- Most server admin is lazy, so the versions of Linux and the softwares (e.g.
  GCC) are fairly low! It causes much headache when porting program.
- Some useful packages are missing, e.g. GIT, NetCDF.
- Fortran compiler messes up package versions.

With all these pains in my ass, I decided to create a tool. The final goal is
no matter how messy ther server is, we could use packman to setup the necessary
development environment. So we can focus on our real problems, not install the
packages over and over again!

Available packages
==================

The following is a list of the packages that I have tried to built with success
on a Linux server:

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
| grib-api                          | 1.12.1    |
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

Authors
=======

- Li Dong <dongli@lasg.iap.ac.cn>
