#=
fld-write.jl
write AVS .fld to file
2019-05-12, Jeff Fessler, University of Michigan
=#

export fld_write


"""
    fld_write(file, data ; kwargs...)

Write data into AVS format `.fld` file.
See README for file format.

# In
- `file` name of file typically ending in `.fld`
- `data` real data array

# Option
- `check::Bool`         report error if file exists; default `true`
- `dir::String`         directory name to prepend file name; default `""`
- `endian::`Symbol`     `:le` little endian (default), `:be` big endian
- `head::Array{String}` comment information for file header
- `raw::Bool`           put raw data in `name.raw`, header in `name.fld`
                        where `file` = `name.fld`; default `false`
"""
function fld_write(
    file::String,
    data::AbstractArray{<:Real} ;
    check::Bool = true,
    dir::String = "",
    endian::Symbol = :le,
    head::Array{String} = empty([""]),
    warn::Bool = true,
    raw::Bool = false,
)

    data = fld_write_data_fix(data ; warn) # make data suitable for writing in .fld

    endian != :le && endian != :be && throw("endian '$endian' unknown")

    typedict = Dict([
        (Float32, endian === :le ? "float_le" : "xdr_float"),
        (Float64, endian === :le ? "double_le" : "xdr_double"),
        (UInt8, "byte"),
        (Int16, endian === :le ? "short_le" : "short_be"),
        (Int32, endian === :le ? "int_le" : "xdr_int"),
    ])

    datatype = typedict[eltype(data)] # throws error if not there

    file = joinpath(dir, file)
#   @show file

    check && isfile(file) && throw("file '$file' exists")

    if raw # if writing data to separate ".raw" file, ensure it does not exist
        fileraw = file[1:(end-3)] * "raw"
        check && isfile(fileraw) && throw("file $fileraw exists")
    end

    # write header to IOBuffer
    io = IOBuffer()

    ndim = ndims(data)

    println(io, "# AVS field file ($(basename(@__FILE__)))")
    for line in head
        println(io, "# $line")
    end

    println(io, "ndim=$ndim")
    for ii=1:ndim
        println(io, "dim$ii=$(size(data,ii))")
    end
    println(io, "nspace=$ndim")
    println(io, "veclen=1")
    println(io, "data=$datatype")
    println(io, "field=uniform")

    if raw
        println(io, "variable 1 file=$fileraw filetype=binary")
    else
        write(io, "\f\f") # two form feeds: char(12)
    end

    # determine how to write the binary data
    host_is_le = () -> ENDIAN_BOM == 0x04030201
    fun = (host_is_le() == (endian === :le)) ?
        identity : # host/file same endian
        (host_is_le() && (endian === :be)) ?
        hton :
        (!host_is_le() && (endian === :le)) ?
        htol :
        throw("not done")

    # write header from IO buffer to file
    open(file, "w") do fid
        write(fid, take!(io))
    end

    # write binary data to file or fileraw
    if raw
        open(fileraw, "w") do fraw
            write(fraw, fun.(data))
        end
    else
        open(file, "a") do fid
            write(fid, fun.(data))
        end
    end

    return nothing
end


"""
    data = fld_write_data_fix(data)
Convert data to format suitable for writing to `.fld` file.
"""
function fld_write_data_fix(data::AbstractArray{BigFloat} ; warn::Bool=true)
    warn && (@warn "BigFloat downgraded to Float64")
    return Float64.(data)
end

function fld_write_data_fix(data::AbstractArray{Float16} ; warn::Bool=true)
    warn && (@warn "Float16 promoted to Float32")
    return Float32.(data)
end

function fld_write_data_fix(
    data::AbstractArray{T} ;
    warn::Bool=true,
) where {T <: Union{BigInt, Int64}}
    warn && (@warn "$T downgraded to Int32")
    return Int32.(data)
end

function fld_write_data_fix(data::AbstractArray{Bool} ; warn::Bool=true)
    warn && (@warn "Bool promoted to UInt8")
    return UInt8.(data)
end

@inline fld_write_data_fix(data::AbstractArray{T} ; warn::Bool=true) where
    {T <: Union{Float32, Float64, UInt8, Int16, Int32}} = data

fld_write_data_fix(data::AbstractArray{T} ; warn::Bool=true) where {T <: Any} =
    throw(ArgumentError("unsupported type $T"))
