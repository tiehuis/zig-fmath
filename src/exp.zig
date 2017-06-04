const fmath = @import("index.zig");

pub fn exp(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => exp32(x),
        f64 => unreachable,
        else => @compileError("exp not implemented for " ++ @typeName(T)),
    }
}

const half = []const f32 { 0.5, -0.5 };
const ln2hi = 6.9314575195e-1;
const ln2lo = 1.4286067653e-6;
const invln2  = 1.4426950216e+0;
const P1 = 1.6666625440e-1;
const P2 = -2.7667332906e-3;

fn exp32(x_: f32) -> f32 {
    var x = x_;
    var hx = fmath.bitCast(u32, x_);
    const sign = hx >> 31;
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
            k = i32(invln2 * x + half[sign]);
        }
        else {
            k = i32(1 - sign - sign);
        }

        hi = x - f32(k) * ln2hi;
        lo = f32(k) * ln2lo;
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

test "exp" {
    fmath.assert(exp(f32(0.0)) == exp32(0.0));
}

test "exp32" {
    const epsilon = 0.000001;

    fmath.assert(exp32(0.0) == 1.0);
    fmath.assert(fmath.approxEq(f32, exp32(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(0.2), 1.221403, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(0.8923), 2.440737, epsilon));
    fmath.assert(fmath.approxEq(f32, exp32(1.5), 4.481689, epsilon));
}
