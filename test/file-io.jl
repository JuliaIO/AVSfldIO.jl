#=
file-io.jl
test AVSfldIO through FileIO
=#

using FileIO: File, @format_str
using FileIO: add_format, load, save, UUID
using FileIO: info, unknown, query
using AVSfldIO

#data1 = rand(Int32, 4, 5)
data1 = reshape(1:20, 4, 5)

file = "tmp.fld"
rm(file, force=true)

ff = File{format"FLD"}(file)
query(ff)

if false # test the methods
	AVSfldIO.save(ff, data1)
	data2 = AVSfldIO.load(ff)
	@assert data2 == data1
end

add_format(format"FLD", "", ".fld", [:AVSfldIO => UUID("b6189060-daf9-4c28-845a-cc0984b81781")])

if true # test FileIO
	save(file, data1)
	data2 = load(file)
	@assert data2 == data1
end
