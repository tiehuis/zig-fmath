const fmath = @import("index.zig");

pub fn isnormal(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    (bits + (1 << 52)) & (@maxValue(u64) >> 1) >= (1 << 53)
}

test "isnormal" {
    fmath.assert(!isnormal(fmath.nan("")));
    fmath.assert(isnormal(1.0));
}
