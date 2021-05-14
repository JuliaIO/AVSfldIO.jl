#=
file-io.jl
test AVSfldIO through FileIO
=#

using FileIO: File, @format_str
using FileIO: add_format, load, save, UUID
#using FileIO: info, unknown, query
#using AVSfldIO

data1 = reshape(Int32.(1:20), 4, 5)
file = tempname() * ".fld"

#ff = File{format"AVSfld"}(file)
#query(ff)

add_format(format"AVSfld", "# AVS", ".fld",
    [:AVSfldIO => UUID("b6189060-daf9-4c28-845a-cc0984b81781")])

save(file, data1)
data2 = load(file)
@assert data2 == data1

rm(file, force=true)
