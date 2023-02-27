# define the data block struct and constructor.

abstract type AbstractNRDBlock <: Any end

macro make_nrd_block(name, configs...)
    _io = gensym()
    _field_list = []
    _field_parser = []

    for item in configs
        _f_name, _f_type, _f_size = if length(item.args) == 2
            (item.args..., 1)
        else
            item.args
        end

        if _f_size == 1
            push!(_field_list, :($(_f_name)::$(_f_type)))
        else
            push!(_field_list, :($(_f_name)::Vector{$(_f_type)}))
        end

        push!(_field_parser, :(read_and_parse!($(esc(_io)), $(_f_type), $(_f_size))))
    end

    quote
        struct $(esc(name)) <: AbstractNRDBlock
            $(_field_list...)
        end

        $(esc(name))($(esc(_io))::IO) = $(esc(name))($(_field_parser...))
    end
end

function read(io::IO, ::Type{T}) where {T <: AbstractNRDBlock}
    T(io)
end

function write(io::IO, block::T) where {T <: AbstractNRDBlock}
    for key in fieldnames(T)
        write(io, getfield(block, key))
    end
end

# read NTuple{N, dtype} from io
function read_and_parse!(io, dtype, N)
    _buf = read(io, sizeof(dtype) * N)

    _val = if N == 1
        _val = reinterpret(dtype, _buf) |> collect
        _val[1]
    else
        reinterpret(dtype, _buf) |> collect
    end

    _val
end

@make_nrd_block(NRDHeader,
    (header, UInt8, 16384)) # 16k

@doc raw"""
# File Header

All files contain a 16 kilobyte ASCII text header.
This header can be read using most text editors and is provided for informational purposes only.
It is intended to give information regarding what settings were used when the data in the file was recorded.
The information in the header will vary based on the type of data contained in the file,
and items may be added, changed or removed from the header in newer versions of Cheetah.
If you do use values from the header in your analysis,
avoid hard coding specific strings in the header into your analysis program.

NOTE: `NeuroView` actually uses the data in the header!
"""
NRDHeader


