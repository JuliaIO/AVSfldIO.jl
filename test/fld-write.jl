# fld-write.jl

using AVSfldIO: fld_write, fld_read
import AVSfldIO: fld_write_data_fix

using Test: @test, @testset, @test_throws, @inferred


"""
    fld_write_test1(file, data, ...)
"""
function fld_write_test1(file, data ;
    raw::Bool=false,
    warn::Bool=false,
    chat::Bool=false, kwarg...
)
    @inferred fld_write(file, data ; raw, warn, kwarg...)
    tmp = fld_read(file ; chat)
    tmp != data && throw("test failed for file = $file")

    rm(file)
    if raw
        tmp = file[1:(end-4)] * ".raw"
        try # because of windows failure here
            rm(tmp)
        catch
            @warn "could not rm raw file $tmp"
            @show isfile(tmp)
        end
    end
    true
end


# test writing and reading AVS `.fld` files of all key types

chat = isinteractive()

@testset "write std" begin
    dir = mktempdir()
    for dtype in (UInt8, Int16, Int32, Float32, Float64)
        for endian in (:le, :be)
            for raw in (false, true)
                chat && @info "dtype=$dtype endian=$endian raw=$raw"
                data = convert.(dtype, [5:8; 1:4])
                # kludge so windows gets new file name every test:
                file = joinpath(dir, "fld-write-test-$dtype-$endian-$raw.fld")
                @test fld_write_test1(file, data ; endian, raw,
                    head = ["dtype=$dtype endian=$endian raw=$raw",],
                    check=true, chat=false)
            end
        end
    end
end

@testset "write odd" begin
    for T in (BigFloat, Float16, BigInt, Int64, Bool)
        data = T.([1 0 1])
        @test fld_write_test1(file, data ; check=true, chat=false)
    end
end

@testset "fld convert" begin
#=
    pairs = (
        (BigFloat, Float64),
        (Float16, Float32),
        (BigInt, Int32),
        (Int64, Int32),
        (Bool, UInt8),
    )
    for (in, out) in pairs
        data = in.([1 0 1])
        @test eltype(fld_write_data_fix(data)) == out
    end
=#
    @test_throws ArgumentError fld_write_data_fix(Rational.([1 0 1]))
end


# for future testing of reading "multi" external files
@testset "write multi" begin
#   file = "../tmp2.fld"
#   file = "tmp.fld"
    data = rand(Float32, 7, 9, 2)
    file1 = "$(basename(file)).part1"
    file2 = "$(basename(file)).part2"
    head = [
        "# AVS field file"
        "ndim=3"
        "dim1=7"
        "dim2=9"
        "dim3=2"
        "nspace=3"
        "veclen=1"
        "data=float"
        "field=uniform"
        "variable 1 file=2 filetype=multi skip=0"
        file1
        file2
    ]

    open(file, "w") do fid
        for line in head
            println(fid, line)
        end
    end

    file1 = joinpath(dirname(file), file1)
    file2 = joinpath(dirname(file), file2)
    write(file1, data[:,:,1])
    write(file2, data[:,:,2])

#=
    run(`cat $file`)
    run(`ls -l $file1`)
    run(`op range $file`)
=#

    @test_throws String tmp = fld_read(file) # todo some day...
end
