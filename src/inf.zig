const fmath = @import("index.zig");

pub fn inf() -> f64 {
    fmath.bitCast(f64, fmath.inf_u64)
}
