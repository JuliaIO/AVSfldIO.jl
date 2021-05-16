#=
test-io.jl
test AVSfldIO. through FileIO
=#

using FileIO: File, @format_str
using Test: @test, @testset, @test_throws
import AVSfldIO

@testset "loadsave" begin
     data1 = reshape(Int32.(1:20), 4, 5)

     file = tempname() * ".fld"

     ff = File{format"AVSfld"}(file)
     AVSfldIO.save(ff, data1)
     data2 = AVSfldIO.load(ff)
     @test data2 == data1

     rm(file, force=true)
end

@testset "save type" begin
    file = tempname() * ".fld"
    ff = File{format"AVSfld"}(file)
    @test_throws ArgumentError AVSfldIO.save(ff, "string")
end
