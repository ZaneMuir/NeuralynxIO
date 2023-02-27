@make_nrd_block(CSCBlock,
    (qwTimeStamp, UInt64, 1),
    (dwChannelNumber, UInt32, 1),
    (dwSampleFreq, UInt32, 1),
    (dwNumValidSamples, UInt32, 1),
    (snSamples, Int16, 512))

@enum LOAD_MODE_NCS begin
    LOAD_MODE_NCS_RAW
    LOAD_MODE_NCS_TRACE
    LOAD_MODE_NCS_TIMESTAMPS
end

const NCSFile = NRDFile{CSCBlock}

function load_neuralynx_ncs(filename::AbstractString; mode::LOAD_MODE_NCS=LOAD_MODE_NCS_RAW)
    raw = NCSFile(filename)

    if mode == LOAD_MODE_NCS_RAW
        raw
    elseif mode == LOAD_MODE_NCS_TRACE
        reduce(vcat, map(x->x.snSamples, raw.data))
    elseif mode == LOAD_MODE_NCS_TIMESTAMPS
        map(x->x.qwTimeStamp, raw.data)
    end
end

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