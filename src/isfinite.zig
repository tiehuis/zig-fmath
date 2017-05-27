const fmath = @import("index.zig");

pub fn isfinite(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    bits & (@maxValue(u64) >> 1) < (0x7FF << 52)
}

test "isfinite" {
    fmath.assert(isfinite(0.0));
    fmath.assert(isfinite(-0.0));
    fmath.assert(!isfinite(fmath.inf()));
    fmath.assert(!isfinite(-fmath.inf()));
}
