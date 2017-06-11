const fmath = @import("index.zig");

pub fn log(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(logf, x),
        f64 => @inlineCall(logd, x),
        else => @compileError("log not implemented for " ++ @typeName(T)),
    }
}

fn logf(x_: f32) -> f32 {
    const ln2_hi: f32 = 6.9313812256e-01;
    const ln2_lo: f32 = 9.0580006145e-06;
    const Lg1: f32 = 0xaaaaaa.0p-24;
    const Lg2: f32 = 0xccce13.0p-25;
    const Lg3: f32 = 0x91e9ee.0p-25;
    const Lg4: f32 = 0xf89e26.0p-26;

    var x = x_;
    var ix = fmath.bitCast(u32, x);
    var k: i32 = 0;

    // x < 2^(-126)
    if (ix < 0x00800000 or ix >> 31 != 0) {
        // log(+-0) = -inf
        if (ix << 1 == 0) {
            return -1 / (x * x);
        }
        // log(-#) = nan
        if (ix >> 31 != 0) {
            return (x - x) / 0.0
        }

        // subnormal, scale x
        k -= 25;
        x *= 0x1.0p25;
        ix = fmath.bitCast(u32, x);
    } else if (ix >= 0x7F800000) {
        return x;
    } else if (ix == 0x3F800000) {
        return 0;
    }

    // x into [sqrt(2) / 2, sqrt(2)]
    ix += 0x3F800000 - 0x3F3504F3;
    k += i32(ix >> 23) - 0x7F;
    ix = (ix & 0x007FFFFF) + 0x3F3504F3;
    x = fmath.bitCast(f32, ix);

    const f = x - 1.0;
    const s = f / (2.0 + f);
    const z = s * s;
    const w = z * z;
    const t1 = w * (Lg2 + w * Lg4);
    const t2 = z * (Lg1 + w * Lg3);
    const R = t2 + t1;
    const hfsq = 0.5 * f * f;
    const dk = f32(k);

    s * (hfsq + R) + dk * ln2_lo - hfsq + f + dk * ln2_hi
}

fn logd(x_: f64) -> f64 {
    const ln2_hi: f64 = 6.93147180369123816490e-01;
    const ln2_lo: f64 = 1.90821492927058770002e-10;
    const Lg1: f64 = 6.666666666666735130e-01;
    const Lg2: f64 = 3.999999999940941908e-01;
    const Lg3: f64 = 2.857142874366239149e-01;
    const Lg4: f64 = 2.222219843214978396e-01;
    const Lg5: f64 = 1.818357216161805012e-01;
    const Lg6: f64 = 1.531383769920937332e-01;
    const Lg7: f64 = 1.479819860511658591e-01;

    var x = x_;
    var ix = fmath.bitCast(u64, x);
    var hx = u32(ix >> 32);
    var k: i32 = 0;

    if (hx < 0x00100000 or hx >> 31 != 0) {
        // log(+-0) = -inf
        if (ix << 1 == 0) {
            return -1 / (x * x);
        }
        // log(-#) = nan
        if (hx >> 31 != 0) {
            return (x - x) / 0.0;
        }

        // subnormal, scale x
        k -= 54;
        x *= 0x1.0p54;
        hx = fmath.bitCast(u32, ix >> 32);
    }
    else if (hx >= 0x7FF00000) {
        return x;
    }
    else if (hx == 0x3FF00000 and ix << 32 == 0) {
        return 0;
    }

    // x into [sqrt(2) / 2, sqrt(2)]
    hx += 0x3FF00000 - 0x3FE6A09E;
    k += i32(hx >> 20) - 0x3FF;
    hx = (hx & 0x000FFFFF) + 0x3FE6A09E;
    ix = (u64(hx) << 32) | (ix & 0xFFFFFFFF);
    x = fmath.bitCast(f64, ix);

    const f = x - 1.0;
    const hfsq = 0.5 * f * f;
    const s = f / (2.0 + f);
    const z = s * s;
    const w = z * z;
    const t1 = w * (Lg2 + w * (Lg4 + w * Lg6));
    const t2 = z * (Lg1 + w * (Lg3 + w * (Lg5 + w * Lg7)));
    const R = t2 + t1;
    const dk = f64(k);

    s * (hfsq + R) + dk * ln2_lo - hfsq + f + dk * ln2_hi
}

test "log" {
    fmath.assert(log(f32(0.2)) == logf(0.2));
    fmath.assert(log(f64(0.2)) == logd(0.2));
}

test "logf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, logf(0.2), -1.609438, epsilon));
    fmath.assert(fmath.approxEq(f32, logf(0.8923), -0.113953, epsilon));
    fmath.assert(fmath.approxEq(f32, logf(1.5), 0.405465, epsilon));
    fmath.assert(fmath.approxEq(f32, logf(37.45), 3.623007, epsilon));
    fmath.assert(fmath.approxEq(f32, logf(89.123), 4.490017, epsilon));
    fmath.assert(fmath.approxEq(f32, logf(123123.234375), 11.720941, epsilon));
}

test "logd" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, logd(0.2), -1.609438, epsilon));
    fmath.assert(fmath.approxEq(f64, logd(0.8923), -0.113953, epsilon));
    fmath.assert(fmath.approxEq(f64, logd(1.5), 0.405465, epsilon));
    fmath.assert(fmath.approxEq(f64, logd(37.45), 3.623007, epsilon));
    fmath.assert(fmath.approxEq(f64, logd(89.123), 4.490017, epsilon));
    fmath.assert(fmath.approxEq(f64, logd(123123.234375), 11.720941, epsilon));
}
