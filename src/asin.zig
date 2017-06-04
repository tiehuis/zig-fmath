const fmath = @import("index.zig");

pub fn asin(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => asin32(x),
        f64 => unreachable,
        else => @compileError("asin not implemented for " ++ @typeName(T)),
    }
}

const pio2 = 1.570796326794896558e+00;
const pS0 =  1.6666586697e-01;
const pS1 = -4.2743422091e-02;
const pS2 = -8.6563630030e-03;
const qS1 = -7.0662963390e-01;

fn r32(z: f32) -> f32 {
    const p = z * (pS0 + z * (pS1 + z * pS2));
    const q = 1.0 + z * qS1;
    p / q
}

fn asin32(x: f32) -> f32 {
    const hx: u32 = fmath.bitCast(u32, x);
    const ix: u32 = hx & 0x7FFFFFFF;

    // |x| >= 1
    if (ix >= 0x3F800000) {
        // |x| >= 1
        if (ix == 0x3F800000) {
            return x * pio2 + 0x1.0p-120;   // asin(+-1) = +-pi/2 with inexact
        } else {
            return 0 / (x - x);             // asin(|x| > 1) is nan
        }
    }

    // |x| < 0.5
    if (ix < 0x3F000000) {
        // 0x1p-126 <= |x| < 0x1p-12
        if (ix < 0x39800000 and ix >= 0x00800000) {
            return x;
        } else {
            return x + x * r32(x * x);
        }
    }

    // 1 > |x| >= 0.5
    const z = (1 - fmath.fabs(x)) * 0.5;
    const s = fmath.sqrt(z);
    const fx = pio2 - 2 * (s + s * r32(z));

    if (hx >> 31 != 0) {
        -fx
    } else {
        fx
    }
}

test "asin" {
    fmath.assert(asin(f32(0.0)) == asin32(0.0));
}

test "asin32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, asin32(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, asin32(0.2), 0.201358, epsilon));
    fmath.assert(fmath.approxEq(f32, asin32(-0.2), -0.201358, epsilon));
    fmath.assert(fmath.approxEq(f32, asin32(0.3434), 0.350535, epsilon));
    fmath.assert(fmath.approxEq(f32, asin32(0.5), 0.523599, epsilon));
    fmath.assert(fmath.approxEq(f32, asin32(0.8923), 1.102415, epsilon));
}
