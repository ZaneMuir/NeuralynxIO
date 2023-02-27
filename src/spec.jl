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

@make_nrd_block(CSCBlock,
    (qwTimeStamp, UInt64, 1),
    (dwChannelNumber, UInt32, 1),
    (dwSampleFreq, UInt32, 1),
    (dwNumValidSamples, UInt32, 1),
    (snSamples, Int16, 512))

@make_nrd_block(EventBlock,
    (nstx, Int16, 1),
    (npkt_id, Int16, 1),
    (npkt_data_size, Int16, 1),
    (qwTimeStamp, UInt64, 1),
    (nevent_id, Int16, 1),
    (nttl, Int16, 1),
    (ncrc, Int16, 1),
    (ndummy1, Int16, 1),
    (ndummy2, Int16, 1),
    (dnExtra, Int32, 8),
    (EventString, UInt8, 128))

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

@doc raw"""
# Continuously Sampled Record

Storage format for continuously sampled channel (CSC) recorded data.
These files end in the NCS extension.

- `qwTimeStamp::UInt64`: Cheetah timestamp for this record. This corresponds to the sample time for the first data point in the snSamples array. This value is in microseconds.
- `dwChannelNumber::UInt32`: The channel number for this record. This is NOT the A/D channel number.
- `dwSampleFreq::UInt32`: The sampling frequency (Hz) for the data stored in the snSamples Field in this record.
- `dwNumValidSamples::UInt32`: Number of values in snSamples containing valid data.
- `snSamples::Int16[512]`: Data points for this record. Cheetah currently supports 512 data points per record. At this time, the snSamples array is a [512] array.
"""
CSCBlock
