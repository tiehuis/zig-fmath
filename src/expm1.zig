const fmath = @import("index.zig");

pub fn expm1(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => expm1f(x),
        f64 => unreachable,
        else => @compileError("exp1m not implemented for " ++ @typeName(T)),
    }
}

const o_threshold: f32 = 8.8721679688e+01;
const ln2_hi: f32      = 6.9313812256e-01;
const ln2_lo: f32      = 9.0580006145e-06;
const invln2: f32      = 1.4426950216e+00;
const Q1: f32 = -3.3333212137e-2;
const Q2: f32 =  1.5807170421e-3;

fn expm1f(x_: f32) -> f32 {
    var x = x_;
    const ux = fmath.bitCast(u32, x);
    const hx = ux & 0x7FFFFFFF;
    const sign = hx >> 31;

    // |x| >= 27 * ln2
    if (hx >= 0x4195B844) {
        // nan
        if (hx > 0x7F800000) {
            return x;
        }
        if (sign != 0) {
            return -1;
        }
        if (x > o_threshold) {
            x *= 0x1.0p127;
            return x;
        }
    }

    var hi: f32 = undefined;
    var lo: f32 = undefined;
    var c: f32 = undefined;
    var k: i32 = undefined;

    // |x| > 0.5 * ln2
    if (hx > 0x3EB17218) {
        // |x| < 1.5 * ln2
        if (hx < 0x3F851592) {
            if (sign == 0) {
                hi = x - ln2_hi;
                lo = ln2_lo;
                k = 1;
            } else {
                hi = x + ln2_hi;
                lo = -ln2_lo;
                k = -1;
            }
        } else {
            var kf = invln2 * x;
            if (sign != 0) {
                kf -= 0.5;
            } else {
                kf += 0.5;
            }

            k = i32(kf);
            const t = f32(k);
            hi = x - t * ln2_hi;
            lo = t * ln2_lo;
        }

        x = hi - lo;
        c = (hi - x) - lo;
    }
    // |x| < 2^(-25)
    else if (hx < 0x33000000) {
        if (hx < 0x00800000) {
            fmath.forceEval(x * x);
        }
        return x;
    }
    else {
        k = 0;
    }

    const hfx = 0.5 * x;
    const hxs = x * hfx;
    const r1 = 1.0 + hxs * (Q1 + hxs * Q2);
    const t = 3.0 - r1 * hfx;
    var e = hxs * ((r1 - t) / (6.0 - x * t));

    // c is 0
    if (k == 0) {
        return x - (x * e - hxs);
    }

    e = x * (e - c) - c;
    e -= hxs;

    // exp(x) ~ 2^k (x_reduced - e + 1)
    if (k == -1) {
        return 0.5 * (x - e) - 0.5;
    }
    if (k == 1) {
        if (x < -0.25) {
            return -2.0 * (e - (x + 0.5));
        } else {
            return 1.0 + 2.0 * (x - e);
        }
    }

    const twopk = fmath.bitCast(f32, u32(0x7F + k) << 23);

    if (k < 0 or k > 56) {
        var y = x - e + 1.0;
        if (k == 128) {
            y = y * 2.0 * 0x1.0p127;
        } else {
            y = y * twopk;
        }

        return y - 1.0;
    }

    const uf = fmath.bitCast(f32, u32(0x7F - k) << 23);
    if (k < 23) {
        return (x - e + (1 - uf)) * twopk;
    } else {
        return (x - (e + uf) + 1) * twopk;
    }
}

test "exp1m" {
    fmath.assert(expm1(f32(0.0)) == expm1f(0.0));
}

test "expm1f" {
    const epsilon = 0.000001;

    fmath.assert(expm1f(0.0) == 0.0);
    fmath.assert(fmath.approxEq(f32, expm1f(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, expm1f(0.2), 0.221403, epsilon));
    fmath.assert(fmath.approxEq(f32, expm1f(0.8923), 1.440737, epsilon));
    fmath.assert(fmath.approxEq(f32, expm1f(1.5), 3.481689, epsilon));
}
