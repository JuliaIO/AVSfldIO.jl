# AVSfldIO

[![action status][action-img]][action-url]
[![pkgeval status][pkgeval-img]][pkgeval-url]
[![codecov][codecov-img]][codecov-url]
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


## Methods

Following the
[FileIO API](https://juliaio.github.io/FileIO.jl/stable/implementing),
this package provides (but does not export) methods
* `AVSfldIO.load(filename)`
* `AVSfldIO.save(filename, data)`

It does export the following methods:
* `header, is_external_file, fid = fld_open(file ; dir="", chat=false)`
* `header = fld_header(file::String ; dir="", chat=false)`
* `data = fld_read(file::String ; dir="", chat=false)`
* `fld_write(file, data ; kwargs...)`

Use `chat=true` for verbose debugging output.
Use `dir=somepath` to prepend a path to `file`.
See docstrings for more details.


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

For a `128 × 64` array
(first dimension varies fastest)
consisting of short integers
(`Int16` in Julia),
the format of the AVS internal header would be:
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
and then the $128 × 64$ short integers
in binary format.

For a 3D array of size `128 × 64 × 20`
of short integers,
the header is
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


## Magic bytes

It is convention that an AVS `.fld` file begins with
`# AVS` in the first line,
as illustrated in the examples above,
so the interface to this library
in
[FileIO.jl](https://github.com/JuliaIO/FileIO.jl)
uses that 5-byte string
as the
["magic bytes"](https://en.wikipedia.org/wiki/List_of_file_signatures)
or
["magic number"](https://en.wikipedia.org/wiki/File_format#Magic_number)
for this file type.
If you have a file that does not have that string as the start of its header,
then simply add it with an editor
(including a newline at the end).


## Data types

The following table shows the supported options
for the `data=` field in the header.
The options that end in `_le` or `_be` or `_sun` are "extensions"
designed for portability, because options like `int`
are not portable between hosts with different
[endianness](https://en.wikipedia.org/wiki/Endianness).

| format | Julia type | endian | bytes |
| :--- | :--- | :---: | :---: |
| `byte` | `UInt8` | n/a | `1` |
| `short_be` | `UInt16` | `be` | `2` |
| `short_sun` | `UInt16` | `be` | `2` |
| `xdr_short` | `UInt16` | `be` | `2` |
| `short_le` | `UInt16` | `le` | `2` |
| `int` | `Int32` | `?` | `4` |
| `int_le` | `Int32` | `le` | `4` |
| `int_be` | `Int32` | `be` | `4` |
| `xdr_int` | `Int32` | `be` | `4` |
| `float` | `Float32` | `?` | `4` |
| `float_le` | `Float32` | `le` | `4` |
| `float_be` | `Float32` | `be` | `4` |
| `xdr_float` | `Float32` | `be` | `4` |
| `double` | `Float64` | `?` | `8` |
| `double_le` | `Float64` | `le` | `8` |
| `double_be` | `Float64` | `be` | `8` |
| `xdr_double` | `Float64` | `be` | `8` |

Entries with `?` are native to the host CPU and thus not portable.


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



## Authors

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
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JeffFessler.github.io/AVSfldIO.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JeffFessler.github.io/AVSfldIO.jl/dev
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat
[license-url]: LICENSE
<!--
[![coveralls][coveralls-img]][coveralls-url]
[coveralls-img]: https://coveralls.io/repos/JeffFessler/AVSfldIO.jl/badge.svg?branch=main
[coveralls-url]: https://coveralls.io/github/JeffFessler/AVSfldIO.jl?branch=main
-->
