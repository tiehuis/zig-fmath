const fmath = @import("index.zig");
const expo2 = @import("_expo2.zig").expo2;

pub fn sinh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => sinhf(x),
        f64 => unreachable,
        else => @compileError("sinh not implemented for " ++ @typeName(T)),
    }
}

// sinh(x) = (exp(x) - 1 / exp(x)) / 2
//         = (exp(x) - 1 + (exp(x) - 1) / exp(x)) / 2
//         = x + x^3 / 6 + o(x^5)
fn sinhf(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const ux = u & 0x7FFFFFFF;
    const ax = fmath.bitCast(f32, ux);

    var h: f32 = 0.5;
    if (u >> 31 != 0) {
        h = -h;
    }

    // |x| < log(FLT_MAX)
    if (ux < 0x42B17217) {
        const t = fmath.expm1(ax);
        if (ux < 0x3F800000) {
            if (ux < 0x3F800000 - (12 << 23)) {
                return x;
            } else {
                return h * (2 * t - t * t / (t + 1));
            }
        }
        return h * (t + t / (t + 1));
    }

    // |x| > log(FLT_MAX) or nan
    2 * h * expo2(ax)
}

test "sinh" {
    fmath.assert(sinh(f32(1.5)) == sinhf(1.5));
}

test "sinhf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, sinhf(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, sinhf(0.2), 0.201336, epsilon));
    fmath.assert(fmath.approxEq(f32, sinhf(0.8923), 1.015512, epsilon));
    fmath.assert(fmath.approxEq(f32, sinhf(1.5), 2.129279, epsilon));
}
