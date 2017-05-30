const fmath = @import("index.zig");

pub fn log2(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        log2f(x)
    } else if (T == f64) {
        @compileError("log unimplemented for f64");
    } else if (T == c_longdouble) {
        @compileError("log unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

const ivln2hi: f32 =  1.4428710938e+00;
const ivln2lo: f32 = -1.7605285393e-04;
const Lg1: f32 = 0xaaaaaa.0p-24;
const Lg2: f32 = 0xccce13.0p-25;
const Lg3: f32 = 0x91e9ee.0p-25;
const Lg4: f32 = 0xf89e26.0p-26;

fn log2f(x: f32) -> f32 {
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
    (lo + hi) * ivln2lo + lo * ivln2hi + hi * ivln2hi + f32(k)
}

test "log2f" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, log2f(0.2), -2.321928, epsilon));
    fmath.assert(fmath.approxEq(f32, log2f(0.8923), -0.164399, epsilon));
    fmath.assert(fmath.approxEq(f32, log2f(1.5), 0.584962, epsilon));
    fmath.assert(fmath.approxEq(f32, log2f(37.45), 5.226894, epsilon));
    fmath.assert(fmath.approxEq(f32, log2f(123123.234375), 16.909744, epsilon));
}
