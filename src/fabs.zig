const fmath = @import("index.zig");

pub fn fabs(s: f64) -> f64 {
    var u = fmath.bitCast(u64, s);
    u &= @maxValue(u64) >> 1;
    fmath.bitCast(f64, u)
}

test "fabs" {
    fmath.assert(fabs(1.0) == 1.0);
    fmath.assert(fabs(-1.0) == 1.0);
}
