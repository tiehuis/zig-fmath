const fmath = @import("index.zig");

pub fn log1p(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(log1pf, x),
        f64 => @inlineCall(log1pd, x),
        else => @compileError("log1p not implemented for " ++ @typeName(T)),
    }
}

fn log1pf(x: f32) -> f32 {
    const ln2_hi = 6.9313812256e-01;
    const ln2_lo = 9.0580006145e-06;
    const Lg1: f32 = 0xaaaaaa.0p-24;
    const Lg2: f32 = 0xccce13.0p-25;
    const Lg3: f32 = 0x91e9ee.0p-25;
    const Lg4: f32 = 0xf89e26.0p-26;

    const u = fmath.bitCast(u32, x);
    var ix = u;
    var k: i32 = 1;
    var f: f32 = undefined;
    var c: f32 = undefined;

    // 1 + x < sqrt(2)+
    if (ix < 0x3ED413D0 or ix >> 31 != 0) {
        // x <= -1.0
        if (ix >= 0xBF800000) {
            // log1p(-1) = +inf
            if (x == -1) {
                return x / 0.0;
            }
            // log1p(x < -1) = nan
            else {
                return (x - x) / 0.0;
            }
        }
        // |x| < 2^(-24)
        if ((ix << 1) < (0x33800000 << 1)) {
            // underflow if subnormal
            if (ix & 0x7F800000 == 0) {
                fmath.forceEval(x * x);
            }
            return x;
        }
        // sqrt(2) / 2- <= 1 + x < sqrt(2)+
        if (ix <= 0xBE95F619) {
            k = 0;
            c = 0;
            f = x;
        }
    } else if (ix >= 0x7F800000) {
        return x;
    }

    if (k != 0) {
        const uf = 1 + x;
        var iu = fmath.bitCast(u32, uf);
        iu += 0x3F800000 - 0x3F3504F3;
        k = i32(iu >> 23) - 0x7F;

        // correction to avoid underflow in c / u
        if (k < 25) {
            c = if (k >= 2) 1 - (uf - x) else x - (uf - 1);
            c /= uf;
        } else {
            c = 0;
        }

        // u into [sqrt(2)/2, sqrt(2)]
        iu = (iu & 0x007FFFFF) + 0x3F3504F3;
        f = fmath.bitCast(f32, iu) - 1;
    }

    const s = f / (2.0 + f);
    const z = s * s;
    const w = z * z;
    const t1 = w * (Lg2 + w * Lg4);
    const t2 = z * (Lg1 + w * Lg3);
    const R = t2 + t1;
    const hfsq = 0.5 * f * f;
    const dk = f32(k);

    s * (hfsq + R) + (dk * ln2_lo + c) - hfsq + f + dk * ln2_hi
}

fn log1pd(x: f64) -> f64 {
    const ln2_hi: f64 = 6.93147180369123816490e-01;
    const ln2_lo: f64 = 1.90821492927058770002e-10;
    const Lg1: f64 = 6.666666666666735130e-01;
    const Lg2: f64 = 3.999999999940941908e-01;
    const Lg3: f64 = 2.857142874366239149e-01;
    const Lg4: f64 = 2.222219843214978396e-01;
    const Lg5: f64 = 1.818357216161805012e-01;
    const Lg6: f64 = 1.531383769920937332e-01;
    const Lg7: f64 = 1.479819860511658591e-01;

    var ix = fmath.bitCast(u64, x);
    var hx = u32(ix >> 32);
    var k: i32 = 1;
    var c: f64 = undefined;
    var f: f64 = undefined;

    // 1 + x < sqrt(2)
    if (hx < 0x3FDA827A or hx >> 31 != 0) {
        // x <= -1.0
        if (hx >= 0xBFF00000) {
            // log1p(-1) = -inf
            if (x == 1) {
                return x / 0.0;
            }
            // log1p(x < -1) = nan
            else {
                return (x - x) / 0.0;
            }
        }
        // |x| < 2^(-53)
        if ((hx << 1) < (0x3CA00000 << 1)) {
            if ((hx & 0x7FF00000) == 0) {
                fmath.raiseUnderflow();
            }
            return x;
        }
        // sqrt(2) / 2- <= 1 + x < sqrt(2)+
        if (hx <= 0xBFD2BEC4) {
            k = 0;
            c = 0;
            f = x;
        }
    }
    else if (hx >= 0x7FF00000) {
        return x;
    }

    if (k != 0) {
        const uf = 1 + x;
        const hu = fmath.bitCast(u64, uf);
        var iu = u32(hu >> 32);
        iu += 0x3FF00000 - 0x3FE6A09E;
        k = i32(iu >> 20) - 0x3FF;

        // correction to avoid underflow in c / u
        if (k < 54) {
            c = if (k >= 2) 1 - (uf - x) else x - (uf - 1);
            c /= uf;
        } else {
            c = 0;
        }

        // u into [sqrt(2)/2, sqrt(2)]
        iu = (iu & 0x000FFFFF) + 0x3FE6A09E;
        const iq = (u64(iu) << 32) | (hu & 0xFFFFFFFF);
        f = fmath.bitCast(f64, iq) - 1;
    }

    const hfsq = 0.5 * f * f;
    const s = f / (2.0 + f);
    const z = s * s;
    const w = z * z;
    const t1 = w * (Lg2 + w * (Lg4 + w * Lg6));
    const t2 = z * (Lg1 + w * (Lg3 + w * (Lg5 + w * Lg7)));
    const R = t2 + t1;
    const dk = f64(k);

    s * (hfsq + R) + (dk * ln2_lo + c) - hfsq + f + dk * ln2_hi
}

test "log1p" {
    fmath.assert(log1p(f32(0.0)) == log1pf(0.0));
    fmath.assert(log1p(f64(0.0)) == log1pd(0.0));
}

test "log1pf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, log1pf(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(0.2), 0.182322, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(0.8923), 0.637793, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(1.5), 0.916291, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(37.45), 3.649359, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(89.123), 4.501175, epsilon));
    fmath.assert(fmath.approxEq(f32, log1pf(123123.234375), 11.720949, epsilon));
}

test "log1pd" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, log1pd(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(0.2), 0.182322, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(0.8923), 0.637793, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(1.5), 0.916291, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(37.45), 3.649359, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(89.123), 4.501175, epsilon));
    fmath.assert(fmath.approxEq(f64, log1pd(123123.234375), 11.720949, epsilon));
}
