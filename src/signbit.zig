const fmath = @import("index.zig");

pub fn signbit(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    bits >> 63 != 0
}

test "signbit" {
    fmath.assert(!signbit(4.0));
    fmath.assert(signbit(-3.0));
}
