const fmath = @import("index.zig");

pub fn isinf(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    bits & (@maxValue(u64) >> 1) == (0x7FF << 52)
}

test "isinf" {
    fmath.assert(!isinf(0.0));
    fmath.assert(!isinf(-0.0));
    fmath.assert(isinf(fmath.inf()));
    fmath.assert(isinf(-fmath.inf()));
}
