const fmath = @import("index.zig");
const expo2 = @import("_expo2.zig").expo2;

pub fn cosh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(coshf, x),
        f64 => @inlineCall(coshd, x),
        else => @compileError("cosh not implemented for " ++ @typeName(T)),
    }
}

// cosh(x) = (exp(x) + 1 / exp(x)) / 2
//         = 1 + 0.5 * (exp(x) - 1) * (exp(x) - 1) / exp(x)
//         = 1 + (x * x) / 2 + o(x^4)
fn coshf(x: f32) -> f32 {
    const u = @bitCast(u32, x);
    const ux = u & 0x7FFFFFFF;
    const ax = @bitCast(f32, ux);

    // |x| < log(2)
    if (ux < 0x3F317217) {
        if (ux < 0x3F800000 - (12 << 23)) {
            fmath.raiseOverflow();
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

fn coshd(x: f64) -> f64 {
    const u = @bitCast(u64, x);
    const w = u32(u >> 32);
    const ax = @bitCast(f64, u & (@maxValue(u64) >> 1));

    // |x| < log(2)
    if (w < 0x3FE62E42) {
        if (w < 0x3FF00000 - (26 << 20)) {
            if (x != 0) {
                fmath.raiseInexact();
            }
            return 1.0;
        }
        const t = fmath.expm1(ax);
        return 1 + t * t / (2 * (1 + t));
    }

    // |x| < log(DBL_MAX)
    if (w < 0x40862E42) {
        const t = fmath.exp(ax);
        // NOTE: If x > log(0x1p26) then 1/t is not required.
        return 0.5 * (t + 1 / t);
    }

    // |x| > log(CBL_MAX) or nan
    expo2(ax)
}

test "cosh" {
    fmath.assert(cosh(f32(1.5)) == coshf(1.5));
    fmath.assert(cosh(f64(1.5)) == coshd(1.5));
}

test "coshf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, coshf(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(0.2), 1.020067, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(0.8923), 1.425225, epsilon));
    fmath.assert(fmath.approxEq(f32, coshf(1.5), 2.352410, epsilon));
}

test "coshd" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, coshd(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f64, coshd(0.2), 1.020067, epsilon));
    fmath.assert(fmath.approxEq(f64, coshd(0.8923), 1.425225, epsilon));
    fmath.assert(fmath.approxEq(f64, coshd(1.5), 2.352410, epsilon));
}
