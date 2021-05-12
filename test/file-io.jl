#=
file-io.jl
test AVSfldIO through FileIO
=#

using FileIO: add_format, load, save
using AVSfldIO

add_format(format"FLD", "", ".fld", [:AVSfldIO => UUID("b6189060-daf9-4c28-845a-cc0984b81781")])
