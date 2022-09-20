@enum LOAD_MODE_NCS begin
    LOAD_MODE_NCS_RAW
    LOAD_MODE_NCS_TRACE
    LOAD_MODE_NCS_TIMESTAMPS
end

function load_neuralynx_ncs(filename::AbstractString; mode::LOAD_MODE_NCS=LOAD_MODE_NCS_RAW)
    raw = NRDFile{CSCBlock}(filename)

    if mode == LOAD_MODE_NCS_RAW
        raw
    elseif mode == LOAD_MODE_NCS_TRACE
        reduce(vcat, map(x->x.snSamples, raw.data))
    elseif mode == LOAD_MODE_NCS_TIMESTAMPS
        map(x->x.qwTimeStamp, raw.data)
    end
end

