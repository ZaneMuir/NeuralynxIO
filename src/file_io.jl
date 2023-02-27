# common structure for Neuralynx files
struct NRDFile{T <: AbstractNRDBlock}
    filename::String
    header::NRDHeader
    data::Vector{T}

    NRDFile{T}(filename::AbstractString) where {T <: AbstractNRDBlock} = begin
        open(filename) do fio
            _header = NRDHeader(fio)
            _data = T[]
            while !eof(fio)
                push!(_data, T(fio))
            end
            new(filename, _header, _data)
        end
    end
end

function load_neuralynx_file(filename::AbstractString; kwargs...)
    _, _ext = splitext(filename)
    if lowercase(_ext) == ".ncs"
        load_neuralynx_ncs(filename; kwargs...)
    elseif lowercase(_ext) == ".nev"
        load_neuralynx_nev(filename; kwargs...)
    elseif lowercase(_ext) == ".nse"
        load_neuralynx_nse(filename; kwargs...)
    else
        @error("file format ($(_ext)) is not currently supported.")
    end
end

function load_neuralynx_header(filename::AbstractString)
    _header = open(filename) do fio
        NRDHeader(fio)
    end
    parse_header(_header)
end

function parse_header(header::NRDHeader)
    _raw = String(copy(header.header))
    _entries = filter(x->!isempty(x), split(strip(_raw, '\0'), "\r\n")[2:end])

    map(x->begin
        _k, _v = split(x, " ", limit=2)
        String(_k[2:end]) => String(strip(replace(_v, "\""=>""), ' '))
        end, _entries) |> Dict
end

include("io_ncs.jl")
include("io_nev.jl")
include("io_nse.jl")
