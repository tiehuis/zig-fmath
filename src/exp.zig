const fmath = @import("index.zig");

pub fn exp(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => exp32(x),
        f64 => exp64(x),
        else => @compileError("exp not implemented for " ++ @typeName(T)),
    }
}

fn exp32(x_: f32) -> f32 {
    const half = []const f32 { 0.5, -0.5 };
    const ln2hi = 6.9314575195e-1;
    const ln2lo = 1.4286067653e-6;
    const invln2  = 1.4426950216e+0;
    const P1 = 1.6666625440e-1;
    const P2 = -2.7667332906e-3;

    var x = x_;
    var hx = fmath.bitCast(u32, x);
    const sign = i32(hx >> 31);
    hx &= 0x7FFFFFFF;

    // |x| >= -87.33655 or nan
    if (hx >= 0x42AEAC50) {
        // nan
        if (hx > 0x7F800000) {
            return x;
        }
        // x >= 88.722839
        if (hx >= 0x42b17218 and sign == 0) {
            return x * 0x1.0p127;
        }
        if (sign != 0) {
            fmath.forceEval(-0x1.0p-149 / x);   // overflow
            // x <= -103.972084
            if (hx >= 0x42CFF1B5) {
                return 0;
            }
        }
    }

    var k: i32 = undefined;
    var hi: f32 = undefined;
    var lo: f32 = undefined;

    // |x| > 0.5 * ln2
    if (hx > 0x3EB17218) {
        // |x| > 1.5 * ln2
        if (hx > 0x3F851592) {
            k = i32(invln2 * x + half[usize(sign)]);
        }
        else {
            k = 1 - sign - sign;
        }

        const fk = f32(k);
        hi = x - fk * ln2hi;
        lo = fk * ln2lo;
        x = hi - lo;
    }
    // |x| > 2^(-14)
    else if (hx > 0x39000000) {
        k = 0;
        hi = x;
        lo = 0;
    }
    else {
        fmath.forceEval(0x1.0p127 + x); // inexact
        return 1 + x;
    }

    const xx = x * x;
    const c = x - xx * (P1 + xx * P2);
    const y = 1 + (x * c / (2 - c) - lo + hi);

    if (k == 0) {
        y
    } else {
        fmath.scalbn(y, k)
    }
}

fn exp64(x_: f64) -> f64 {
    const half = []const f64 { 0.5, -0.5 };
    const ln2hi: f64 = 6.93147180369123816490e-01;
    const ln2lo: f64 = 1.90821492927058770002e-10;
    const invln2: f64 = 1.44269504088896338700e+00;
    const P1: f64   =  1.66666666666666019037e-01;
    const P2: f64   = -2.77777777770155933842e-03;
    const P3: f64   =  6.61375632143793436117e-05;
    const P4: f64   = -1.65339022054652515390e-06;
    const P5: f64   =  4.13813679705723846039e-08;

    var x = x_;
    var ux = fmath.bitCast(u64, x);
    var hx = ux >> 32;
    const sign = i32(hx >> 31);
    hx &= 0x7FFFFFFF;

    // |x| >= 708.39 or nan
    if (hx >= 0x4086232B) {
        // nan
        if (hx > 0x7FF00000) {
            return x;
        }
        // TODO: Compare against exact u64 value.
        if (x > 709.782712893383973096) {
            // overflow if x != inf
            return x; // TODO: * 0x1.0p1023;
        }
        if (x < -708.39641853226410622) {
            // underflow if x != -inf
            // fmath.forceEval(f32(-0x1.0p-149 / x));
            if (x < -745.13321910194110842) {
                return 0;
            }
        }
    }

    // argument reduction
    var k: i32 = undefined;
    var hi: f64 = undefined;
    var lo: f64 = undefined;

    // |x| > 0.5 * ln2
    if (hx > 0x3EB17218) {
        // |x| >= 1.5 * ln2
        if (hx > 0x3FF0A2B2) {
            k = i32(invln2 * x + half[usize(sign)]);
        }
        else {
            k = 1 - sign - sign;
        }

        const dk = f64(k);
        hi = x - dk * ln2hi;
        lo = dk * ln2lo;
        x = hi - lo;
    }
    // |x| > 2^(-28)
    else if (hx > 0x3E300000) {
        k = 0;
        hi = x;
        lo = 0;
    }
    else {
        // inexact if x != 0
        // fmath.forceEval(0x1.0p1023 + x);
        return 1 + x;
    }

    const xx = x * x;
    const c = x - xx * (P1 + xx * (P2 + xx * (P3 + xx * (P4 + xx * P5))));
    const y = 1 + (x * c / (2 - c) - lo + hi);

    if (k == 0) {
        y
    } else {
        fmath.scalbn(y, k)
    }
}

test "exp" {
    fmath.assert(exp(f32(0.0)) == exp32(0.0));
    fmath.assert(exp(f64(0.0)) == exp64(0.0));
}

test "exp32" {
    const epsilon = 0.000001;

    fmath.assert(exp32(0.0) == 1.0);
    fmath.assert(fmath.approxEq(f32, exp32(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(0.2), 1.221403, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(0.8923), 2.440737, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(1.5), 4.481689, epsilon));
}

test "exp64" {
    const epsilon = 0.000001;

    fmath.assert(exp64(0.0) == 1.0);
    fmath.assert(fmath.approxEq(f64, exp64(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f64, exp64(0.2), 1.221403, epsilon));
    fmath.assert(fmath.approxEq(f64, exp64(0.8923), 2.440737, epsilon));
    fmath.assert(fmath.approxEq(f64, exp64(1.5), 4.481689, epsilon));
}
