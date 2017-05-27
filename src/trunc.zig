const fmath = @import("index.zig");

pub fn trunc(x: f64) -> f64 {
    const u = fmath.bitCast(u64, x);
    var e = i32(((u >> 52) & 0x7FF)) - 0x3FF + 12;
    var m: u64 = undefined;

    if (e >= 52 + 12) {
        return x;
    }
    if (e < 12) {
        e = 1;
    }

    m = @maxValue(u64) >> u64(e);
    if (u & m == 0) {
        x
    } else {
        fmath.forceEval(x + 0x1p120);
        fmath.bitCast(f64, u & ~m)
    }
}

test "trunc" {
    fmath.assert(trunc(1.3) == 1.0);
    fmath.assert(trunc(-1.3) == -1.0);
    fmath.assert(trunc(0.2) == 0.0);
}
