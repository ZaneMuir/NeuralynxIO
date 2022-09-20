@enum LOAD_MODE_NEV begin
    LOAD_MODE_NEV_RAW
    LOAD_MODE_NEV_BIT_TIMESTAMPS
    LOAD_MODE_NEV_BYTE_TIMESTAMPS
    LOAD_MODE_NEV_STRING_TIMESTAMPS
end

function load_neuralynx_nev(filename::AbstractString; mode::LOAD_MODE_NEV=LOAD_MODE_NEV_RAW, bit_event::Integer=0, byte_event::Integer=0, string_event::String="")
    raw = NRDFile{EventBlock}(filename)
    if mode == LOAD_MODE_NEV_RAW
        raw
    elseif mode == LOAD_MODE_NEV_BIT_TIMESTAMPS
        @assert 1 <= bit_event <= 8 "ttl only has 8 pins." #TODO: check if it is true.
        _bit_mask = 1 << (bit_event-1)
        map(xx->xx.qwTimeStamp, filter(x->(x.nttl & _bit_mask) == _bit_mask, raw.data))
    elseif mode == LOAD_MODE_NEV_BYTE_TIMESTAMPS
        @assert 0 <= byte_event <= typemax(UInt8) "ttl only has 8 pins."
        map(xx->xx.qwTimeStamp, filter(x->x.nttl == byte_event, raw.data))
    elseif mode == LOAD_MODE_NEV_STRING_TIMESTAMPS
        map(xx->xx.qwTimeStamp, filter(x->strip(String(x.EventString), '\0') == string_event, raw.data))
    end
end