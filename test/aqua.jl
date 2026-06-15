using AVSfldIO: AVSfldIO
import Aqua
using Test: @testset

@testset "aqua" begin
    Aqua.test_all(AVSfldIO)
end
