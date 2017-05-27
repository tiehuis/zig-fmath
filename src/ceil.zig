const fmath = @import("index.zig");

const toint = 1.0 / fmath.f64_epsilon;

pub fn ceil(x: f64) -> f64 {
    const u = fmath.bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;
    var y: f64 = undefined;

    if (e >= 0x3FF+52 or x == 0) {
        return x;
    }

    if (u >> 63 != 0) {
        y = x - toint + toint - x;
    } else {
        y = x + toint - toint - x;
    }

    if (e <= 0x3FF-1) {
        fmath.forceEval(y);
        if (u >> 63 != 0) {
            return -0.0;    // Compiler requires return.
        } else {
            1.0
        }
    } else if (y < 0) {
        x + y + 1
    } else {
        x + y
    }
}

test "ceil" {
    fmath.assert(ceil(1.3) == 2.0);
    fmath.assert(ceil(-1.3) == -1.0);
    fmath.assert(ceil(0.2) == 1.0);
}
