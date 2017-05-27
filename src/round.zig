const fmath = @import("index.zig");

const toint = 1.0 / fmath.f64_epsilon;

pub fn round(x_: f64) -> f64 {
    var x = x_;
    const u = fmath.bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;
    var y: f64 = undefined;

    if (e >= 0x3FF+52) {
        return x;
    }
    if (u >> 63 != 0) {
        x = -x;
    }
    if (e < 0x3ff-1) {
        fmath.forceEval(x + toint);
        return 0 * fmath.bitCast(f64, u);
    }

    y = x + toint - toint - x;
    if (y > 0.5) {
        y = y + x - 1;
    } else if (y <= -0.5) {
        y = y + x + 1;
    } else {
        y = y + x;
    }

    if (u >> 63 != 0) {
        -y
    } else {
        y
    }
}

test "round" {
    fmath.assert(round(1.3) == 1.0);
    fmath.assert(round(-1.3) == -1.0);
    fmath.assert(round(0.2) == 0.0);
    fmath.assert(round(1.8) == 2.0);
}
