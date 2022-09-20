module Neuralynx

include("spec.jl")
include("file_io.jl")

## parse header
function parse_header(header::NRDHeader)
    _raw = String(copy(header.header))
    _entries = filter(x->!isempty(x), split(strip(_raw, '\0'), "\r\n")[2:end])
    
    map(x->begin
        _k, _v = split(x, " ", limit=2)
        String(_k[2:end]) => String(strip(replace(_v, "\""=>""), ' '))
        end, _entries) |> Dict
end

## Event channel retrival
# match on byte values
function retrive_byte_events(eobj, mask; through=identity)
    output = []
    for item in eobj.data
        if item.nttl == mask
            push!(output, through(item))
        end
    end
    output
end

# match on bit values
function retrive_bit_events(eobj, mask; through=identity)
    output = []
    for item in eobj.data
        if item.nttl & mask == mask
            push!(output, through(item))
        end
    end
    output
end
end