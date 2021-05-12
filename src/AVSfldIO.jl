"""
    AVSfldIO
module for AVS .fld file IO
"""
module AVSfldIO

using FileIO: File, @format_str

include("fld-read.jl")
include("fld-write.jl")

# the two key methods:
load(ff::File{format"FLD"} ; kwargs...) =
   fld_read(ff.filename ; kwargs...)

save(ff::File{format"FLD"}, data ; kwargs...) =
   fld_write(ff.filename, data ; kwargs...)

end # module
