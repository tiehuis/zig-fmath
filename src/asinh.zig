const fmath = @import("index.zig");

pub fn asinh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(asinhf, x),
        f64 => @inlineCall(asinhd, x),
        else => @compileError("asinh not implemented for " ++ @typeName(T)),
    }
}

// asinh(x) = sign(x) * log(|x| + sqrt(x * x + 1)) ~= x - x^3/6 + o(x^5)
fn asinhf(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const i = u & 0x7FFFFFFF;
    const s = i >> 31;

    var rx = fmath.bitCast(f32, i); // |x|

    // |x| >= 0x1p12 or inf or nan
    if (i >= 0x3F800000 + (12 << 23)) {
        rx = fmath.log(rx) + 0.69314718055994530941723212145817656;
    }
    // |x| >= 2
    else if (i >= 0x3F800000 + (1 << 23)) {
        rx = fmath.log(2 * x + 1 / (fmath.sqrt(x * x + 1) + x));
    }
    // |x| >= 0x1p-12, up to 1.6ulp error
    else if (i >= 0x3F800000 - (12 << 23)) {
        rx = fmath.log1p(x + x * x / (fmath.sqrt(x * x + 1) + 1));
    }
    // |x| < 0x1p-12, inexact if x != 0
    else {
        fmath.forceEval(x + 0x1.0p120);
    }

    if (s != 0) -rx else rx
}

fn asinhd(x: f64) -> f64 {
    const u = fmath.bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;
    const s = u >> 63;

    var rx = fmath.bitCast(f64, u & (@maxValue(u64) >> 1)); // |x|

    // |x| >= 0x1p26 or inf or nan
    if (e >= 0x3FF + 26) {
        rx = fmath.log(rx) + 0.693147180559945309417232121458176568;
    }
    // |x| >= 2
    else if (e >= 0x3FF + 1) {
        rx = fmath.log(2 * x + 1 / (fmath.sqrt(x * x + 1) + x));
    }
    // |x| >= 0x1p-12, up to 1.6ulp error
    else if (e >= 0x3FF - 26) {
        rx = fmath.log1p(x + x * x / (fmath.sqrt(x * x + 1) + 1));
    }
    // |x| < 0x1p-12, inexact if x != 0
    else {
        fmath.forceEval(x + 0x1.0p120);
    }

    if (s != 0) -rx else rx
}

test "asinh" {
    fmath.assert(asinh(f32(0.0)) == asinhf(0.0));
    fmath.assert(asinh(f64(0.0)) == asinhd(0.0));
}

test "asinhf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, asinhf(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(0.2), 0.198690, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(0.8923), 0.803133, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(1.5), 1.194763, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(37.45), 4.316332, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(89.123), 5.183196, epsilon));
    fmath.assert(fmath.approxEq(f32, asinhf(123123.234375), 12.414088, epsilon));
}

test "asinhd" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, asinhd(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(0.2), 0.198690, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(0.8923), 0.803133, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(1.5), 1.194763, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(37.45), 4.316332, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(89.123), 5.183196, epsilon));
    fmath.assert(fmath.approxEq(f64, asinhd(123123.234375), 12.414088, epsilon));
}
