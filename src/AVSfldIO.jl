"""
    AVSfldIO
module for AVS .fld file IO
"""
module AVSfldIO

using FileIO: File, @format_str

include("fld-read.jl")
include("fld-write.jl")

# the two key methods:
load(filename::File{format"FLD"} ; kwargs...) =
   fld_read(filename ; kwargs...)

save(filename::File{format"FLD"}, data ; kwargs...) =
   fld_write(filename, data ; kwargs...)

end # module
