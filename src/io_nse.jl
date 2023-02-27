@make_nrd_block(NSEBlock,
    (qwTimeStamp, UInt64, 1),
    (dwScNumber, UInt32, 1),
    (dwCellNumber, UInt32, 1),
    (dnParams, UInt32, 8),
    (snData, Int16, 32),
)

@enum LOAD_MODE_NSE begin
    LOAD_MODE_NSE_RAW
    LOAD_MODE_NSE_TIMESTAMPS
    LOAD_MODE_NSE_WAVEFORM
end

function load_neuralynx_nse(filename::AbstractString; mode::LOAD_MODE_NSE=LOAD_MODE_NSE_RAW)
    raw = NRDFile{NSEBlock}(filename)
    if mode == LOAD_MODE_NSE_RAW
        raw
    elseif mode == LOAD_MODE_NSE_TIMESTAMPS
        map(x->x.qwTimeStamp, raw.data)
    elseif mode == LOAD_MODE_NSE_WAVEFORM
        reduce(hcat, map(x->x.snData, raw.data))
    end
end