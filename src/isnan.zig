const fmath = @import("index.zig");

pub fn isnan(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    (bits & (@maxValue(u64) >> 1)) > (u64(0x7FF) << 52)
}

test "isnan" {
    fmath.assert(isnan(fmath.nan("")));
    fmath.assert(!isnan(1.0));
}
