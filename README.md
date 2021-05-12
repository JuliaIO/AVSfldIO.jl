# AVSfldIO

[![action status][action-img]][action-url]
[![pkgeval status][pkgeval-img]][pkgeval-url]
[![codecov][codecov-img]][codecov-url]
[![coveralls][coveralls-img]][coveralls-url]
[![docs stable][docs-stable-img]][docs-stable-url]
[![docs dev][docs-dev-img]][docs-dev-url]
[![license][license-img]][license-url]

https://github.com/JeffFessler/AVSfldIO.jl.git

File IO for AVS format "field" data files
with extension `.fld`
for the
[Julia language](https://julialang.org),
in conjunction with the
[FileIO package](https://github.com/JuliaIO/FileIO.jl).


## File format overview

The AVS `.fld` data format
comes in two flavors.

In the AVS "internal" format:
* an ASCII header is at the top of the file,
* the header is followed by two "form-feed" (`^L`) characters,
* which are then followed by the data in binary format.

In the AVS "external" format,
the header and the data are in separate files,
and the ASCII header file includes the name of the data file.
The data file can contain either ASCII or binary data.


### AVS internal format

Suppose you have a `128 \times 64`
(first dimension (radial samples) varies fastest)
sinogram consisting of short integers.
Then the format of the AVS internal header would be:
```
# AVS field file
ndim=2
dim1=128
dim2=64
nspace=2
veclen=1
data=short
field=uniform
```
followed by the two form feeds,
and then the $128 \times 64$ short integers
in binary format.

If you have a 3D stack of, say, 20 sinograms (or images)
with short integers,
then you would use
```
# AVS field file
ndim=3
dim1=128
dim2=64
dim3=20
nspace=3
veclen=1
data=short
field=uniform
```

This IO library supports up to 4 dimensions.

The `save` method in this library
writes to the AVS internal format by default,
and the filename must end with the extension `.fld`.

### AVS external format

Now suppose you have stored the above sinogram data
in a binary file named, say, `sino.dat`
with some home-brew header in it that consists
of, say, 1999 bytes.
And suppose you do not want to convert from home-brew format
to AVS internal format.
Then you can use the AVS external format
by creating an ASCII file named, say,
`sino.fld`
containing:
```
# AVS field file
ndim=2
dim1=128
dim2=64
nspace=2
veclen=1
data=short
field=uniform
variable 1 file=sino.dat filetype=binary skip=1999
```

You can add additional comments
to these headers
using lines that begin with `#`.
The `skip=1999` line
indicates that there is a `1999` byte header to be skipped
before reading the binary data.

This format does not allow for additional headers buried within the data.

If there is no binary header,
then you can omit the `skip=0` line altogether.
If your data is in ASCII format (hopefully not),
then you can change
`filetype=binary`
to (you guessed it)
`filetype=ascii`.
However,
for ASCII data,
the `skip=` option
refers to ASCII entries, not bytes.

The allowed types in the
`data=...`
line include:
`byte`,
`short`,
`int`,
`float`,
`double`.
The 
`byte` format is unsigned 8 bits.

The complete AVS `.fld` format
includes other features
that almost certainly are not supported
by this IO library.

This library supports
some extensions that are nonstandard AVS
but very handy,
like a single 3D header file
that points to multiple 2D files
that get treated as a single entity.
More documentation coming on request.


## History

The "application visualization system" (AVS)
https://www.avs.com/
was an application system developed in the early 1990s
an used widely in the medical imaging community.

See the article at https://doi.org/10.1109/38.31462 for an overview.

The data files used in AVS had the extension `.fld`
and many software frameworks provide file IO support
for this format.
* https://doi.org/10.1109/38.31462
* https://www.ks.uiuc.edu/Research/vmd/plugins/molfile/avsplugin.html
* https://dav.lbl.gov/archive/NERSC/Software/express/help6.1/help/reference/dvmac/Field_Fi.htm
* http://paulbourke.net/dataformats/field/
* http://surferhelp.goldensoftware.com/subsys/subsys_avs_field_file_desc.htm
* https://lanl.github.io/LaGriT/pages/docs/read_avs.html



## Author

Jeff Fessler and his group at the University of Michigan.

<!-- URLs -->
[action-img]: https://github.com/JeffFessler/AVSfldIO.jl/workflows/Unit%20test/badge.svg
[action-url]: https://github.com/JeffFessler/AVSfldIO.jl/actions
[build-img]: https://github.com/JeffFessler/AVSfldIO.jl/workflows/CI/badge.svg?branch=main
[build-url]: https://github.com/JeffFessler/AVSfldIO.jl/actions?query=workflow%3ACI+branch%3Amain
[pkgeval-img]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/M/AVSfldIO.svg
[pkgeval-url]: https://juliaci.github.io/NanosoldierReports/pkgeval_badges/M/AVSfldIO.html
[codecov-img]: https://codecov.io/github/JeffFessler/AVSfldIO.jl/coverage.svg?branch=main
[codecov-url]: https://codecov.io/github/JeffFessler/AVSfldIO.jl?branch=main
[coveralls-img]: https://coveralls.io/repos/JeffFessler/AVSfldIO.jl/badge.svg?branch=main
[coveralls-url]: https://coveralls.io/github/JeffFessler/AVSfldIO.jl?branch=main
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JeffFessler.github.io/AVSfldIO.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JeffFessler.github.io/AVSfldIO.jl/dev
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat
[license-url]: LICENSE
