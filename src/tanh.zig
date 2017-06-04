const fmath = @import("index.zig");
const expo2 = @import("_expo2.zig").expo2;

pub fn tanh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => tanhf(x),
        f64 => unreachable,
        else => @compileError("tanh not implemented for " ++ @typeName(T)),
    }
}

// tanh(x) = (exp(x) - exp(-x)) / (exp(x) + exp(-x))
//         = (exp(2x) - 1) / (exp(2x) - 1 + 2)
//         = (1 - exp(-2x)) / (exp(-2x) - 1 + 2)
fn tanhf(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const ux = u & 0x7FFFFFFF;
    const ax = fmath.bitCast(f32, ux);

    var t: f32 = undefined;

    // |x| < log(3) / 2 ~= 0.5493 or nan
    if (ux > 0x3F0C9F54) {
        // |x| > 10
        if (ux > 0x41200000) {
            t = 1.0 + 0 / x;
        } else {
            t = fmath.expm1(2 * x);
            t = 1 - 2 / (t + 2);
        }
    }
    // |x| > log(5 / 3) / 2 ~= 0.2554
    else if (ux > 0x3E82C578) {
        t = fmath.expm1(2 * x);
        t = t / (t + 2);
    }
    // |x| >= 0x1.0p-126
    else if (ux >= 0x00800000) {
        t = fmath.expm1(-2 * x);
        t = -t / (t + 2);
    }
    // |x| is subnormal
    else {
        fmath.forceEval(x * x);
        t = x;
    }

    if (u >> 31 != 0) {
        -t
    } else {
        t
    }
}

test "tanh" {
    fmath.assert(tanh(f32(1.5)) == tanhf(1.5));
}

test "tanhf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, tanhf(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, tanhf(0.2), 0.197375, epsilon));
    fmath.assert(fmath.approxEq(f32, tanhf(0.8923), 0.712528, epsilon));
    fmath.assert(fmath.approxEq(f32, tanhf(1.5), 0.905148, epsilon));
    fmath.assert(fmath.approxEq(f32, tanhf(37.45), 1.0, epsilon));
}
