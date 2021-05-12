# test/runtests.jl

using AVSfldIO
using Test: @test, @testset, detect_ambiguities

list = [
"fld-read.jl"
"fld-write.jl"
"test-io.jl"
]

for file in list
    @testset "$file" begin
        include(file)
    end
end

@test length(detect_ambiguities(AVSfldIO)) == 0
