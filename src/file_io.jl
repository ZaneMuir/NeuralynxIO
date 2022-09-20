struct NRDFile{T <: AbstractNRDBlock}
    filepath::String
    header::NRDHeader
    data::Vector{T}
end

const NCSFile = NRDFile{CSCBlock}
const NEVFile = NRDFile{EventBlock}

function load(f::String)
    _, _ext = splitext(f)
    if lowercase(_ext) == ".ncs"
        load(f, NCSFile)
    elseif lowercase(_ext) == ".nev"
        load(f, NEVFile)
    else
        @error("unknown file format: $(_ext)")
    end
end

function load(f::String, ::Type{NRDFile{T}}) where {T <: AbstractNRDBlock}
    open(f) do fio
        _header = NRDHeader(fio)
        _data = T[]
        while !eof(fio)
            push!(_data, T(fio))
        end
        NRDFile{T}(f, _header, _data)
    end

end