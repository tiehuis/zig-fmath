const fmath = @import("index.zig");

pub fn acosh(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(acoshf, x),
        f64 => @inlineCall(acoshd, x),
        else => @compileError("acosh not implemented for " ++ @typeName(T)),
    }
}

// acosh(x) = log(x + sqrt(x * x - 1))
fn acoshf(x: f32) -> f32 {
    const u = @bitCast(u32, x);
    const i = u & 0x7FFFFFFF;

    // |x| < 2, invalid if x < 1 or nan
    if (i < 0x3F800000 + (1 << 23)) {
        fmath.log1p(x - 1 + fmath.sqrt((x - 1) * (x - 1) + 2 * (x - 1)))
    }
    // |x| < 0x1p12
    else if (i < 0x3F800000 + (12 << 23)) {
        fmath.log(2 * x - 1 / (x + fmath.sqrt(x * x - 1)))
    }
    // |x| >= 0x1p12
    else {
        fmath.log(x) + 0.693147180559945309417232121458176568
    }
}

fn acoshd(x: f64) -> f64 {
    const u = @bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;

    // |x| < 2, invalid if x < 1 or nan
    if (e < 0x3FF + 1) {
        fmath.log1p(x - 1 + fmath.sqrt((x - 1) * (x - 1) + 2 * (x - 1)))
    }
    // |x| < 0x1p26
    else if (e < 0x3FF + 26) {
        fmath.log(2 * x - 1 / (x + fmath.sqrt(x * x - 1)))
    }
    // |x| >= 0x1p26 or nan
    else {
        fmath.log(x) + 0.693147180559945309417232121458176568
    }
}

test "acosh" {
    fmath.assert(acosh(f32(1.5)) == acoshf(1.5));
    fmath.assert(acosh(f64(1.5)) == acoshd(1.5));
}

test "acoshf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, acoshf(1.5), 0.962424, epsilon));
    fmath.assert(fmath.approxEq(f32, acoshf(37.45), 4.315976, epsilon));
    fmath.assert(fmath.approxEq(f32, acoshf(89.123), 5.183133, epsilon));
    fmath.assert(fmath.approxEq(f32, acoshf(123123.234375), 12.414088, epsilon));
}

test "acoshd" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, acoshd(1.5), 0.962424, epsilon));
    fmath.assert(fmath.approxEq(f64, acoshd(37.45), 4.315976, epsilon));
    fmath.assert(fmath.approxEq(f64, acoshd(89.123), 5.183133, epsilon));
    fmath.assert(fmath.approxEq(f64, acoshd(123123.234375), 12.414088, epsilon));
}
