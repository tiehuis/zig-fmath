const fmath = @import("index.zig");

pub fn log10(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => log10f(x),
        f64 => unreachable,
        else => @compileError("log10 not implemented for " ++ @typeName(T)),
    }
}

const ivln10hi: f32  =  4.3432617188e-01;
const ivln10lo: f32  = -3.1689971365e-05;
const log10_2hi: f32 =  3.0102920532e-01;
const log10_2lo: f32 =  7.9034151668e-07;
const Lg1: f32 = 0xaaaaaa.0p-24;
const Lg2: f32 = 0xccce13.0p-25;
const Lg3: f32 = 0x91e9ee.0p-25;
const Lg4: f32 = 0xf89e26.0p-26;

fn log10f(x: f32) -> f32 {
    var u = fmath.bitCast(u32, x);

    var xx = x;
    var ix = u;
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

        k -= 25;
        xx *= 0x1.0p25;
        ix = fmath.bitCast(u32, xx);
    } else if (ix >= 0x7F800000) {
        return x;
    } else if (ix == 0x3F800000) {
        return 0;
    }

    // x into [sqrt(2) / 2, sqrt(2)]
    ix += 0x3F800000 - 0x3F3504F3;
    k += i32(ix >> 23) - 0x7F;
    ix = (ix & 0x007FFFFF) + 0x3F3504F3;
    xx = fmath.bitCast(f32, ix);

    const f = xx - 1.0;
    const s = f / (2.0 + f);
    const z = s * s;
    const w = z * z;
    const t1 = w * (Lg2 + w * Lg4);
    const t2 = z * (Lg1 + w * Lg3);
    const R = t2 + t1;
    const hfsq = 0.5 * f * f;

    var hi = f - hfsq;
    u = fmath.bitCast(u32, hi);
    u &= 0xFFFFF000;
    hi = fmath.bitCast(f32, u);
    const lo = f - hi - hfsq + s * (hfsq + R);
    const dk = f32(k);

    dk * log10_2lo + (lo + hi) * ivln10lo + lo * ivln10hi + hi * ivln10hi + dk * log10_2hi
}

test "log10" {
    fmath.assert(log10(f32(0.2)) == log10f(0.2));
}

test "log10f" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, log10f(0.2), -0.698970, epsilon));
    fmath.assert(fmath.approxEq(f32, log10f(0.8923), -0.049489, epsilon));
    fmath.assert(fmath.approxEq(f32, log10f(1.5), 0.176091, epsilon));
    fmath.assert(fmath.approxEq(f32, log10f(37.45), 1.573452, epsilon));
    fmath.assert(fmath.approxEq(f32, log10f(89.123), 1.94999, epsilon));
    fmath.assert(fmath.approxEq(f32, log10f(123123.234375), 5.09034, epsilon));
}
