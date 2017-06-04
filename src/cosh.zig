const fmath = @import("index.zig");
const expo2 = @import("_expo2.zig").expo2;

pub fn cosh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => coshf(x),
        f64 => unreachable,
        else => @compileError("cosh not implemented for " ++ @typeName(T)),
    }
}

// cosh(x) = (exp(x) + 1 / exp(x)) / 2
//         = 1 + 0.5 * (exp(x) - 1) * (exp(x) - 1) / exp(x)
//         = 1 + (x * x) / 2 + o(x^4)
fn coshf(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const ux = u & 0x7FFFFFFF;
    const ax = fmath.bitCast(f32, ux);

    // |x| < log(2)
    if (ux < 0x3F317217) {
        if (ux < 0x3F800000 - (12 << 23)) {
            // TODO: Signal overflow here?
            // fmath.forceEval(x + 0x1.0p120f);
            return 1.0;
        }
        const t = fmath.expm1(ax);
        return 1 + t * t / (2 * (1 + t));
    }

    // |x| < log(FLT_MAX)
    if (ux < 0x42B17217) {
        const t = fmath.exp(ax);
        return 0.5 * (t + 1 / t);
    }

    // |x| > log(FLT_MAX) or nan
    expo2(ax)
}

test "cosh" {
    fmath.assert(cosh(f32(1.5)) == coshf(1.5));
}

test "coshf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, coshf(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(0.2), 1.020067, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(0.8923), 1.425225, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(1.5), 2.352410, epsilon));
}
