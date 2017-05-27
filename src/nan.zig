const fmath = @import("index.zig");

pub fn nan(s: []const u8) -> f64 {
    fmath.bitCast(f64, fmath.nan_u64)
}
