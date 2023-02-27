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

@enum LOAD_MODE_NEV begin
    LOAD_MODE_NEV_RAW
    LOAD_MODE_NEV_BIT_TIMESTAMPS
    LOAD_MODE_NEV_BYTE_TIMESTAMPS
    LOAD_MODE_NEV_STRING_TIMESTAMPS
end

const NEVFile = NRDFile{EventBlock}

function load_neuralynx_nev(filename::AbstractString; mode::LOAD_MODE_NEV=LOAD_MODE_NEV_RAW, bit_event::Integer=0, byte_event::Integer=0, string_event::String="")
    raw = NEVFile(filename)
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