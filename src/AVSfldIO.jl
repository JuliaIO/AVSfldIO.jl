"""
    AVSfldIO
module for AVS .fld file IO
"""
module AVSfldIO

using FileIO: File, @format_str

include("fld-read.jl")
include("fld-write.jl")

# the two key methods that will be used by FileIO:

"""
    data = load(ff::File{format"AVSfld"} ; kwargs...)
AVSfld load method
"""
load(ff::File{format"AVSfld"} ; kwargs...) =
   fld_read(ff.filename ; kwargs...)

"""
    save(ff::File{format"AVSfld"}, data::AbstractArray{<:Real} ; kwargs...)
AVSfld save method
"""
save(ff::File{format"AVSfld"}, data::AbstractArray{<:Real} ; kwargs...) =
   fld_write(ff.filename, data ; kwargs...)

save(ff::File{format"AVSfld"}, data ; kwargs...) =
    throw(ArgumentError("data must be an array of reals for AVSfld"))

end # module
