"""
    AVSfldIO
module for AVS .fld file IO
"""
module AVSfldIO

using FileIO

include("fld-read.jl")
include("fld-write.jl")

# the two key methods:
load = fld_read
save = fld_write

end # module
