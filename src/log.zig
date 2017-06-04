const fmath = @import("index.zig");

pub fn log(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => logf(x),
        f64 => unreachable,
        else => @compileError("log not implemented for " ++ @typeName(T)),
    }
}

const ln2_hi: f32 = 6.9313812256e-01;
const ln2_lo: f32 = 9.0580006145e-06;

const Lg1: f32 = 0xaaaaaa.0p-24;
const Lg2: f32 = 0xccce13.0p-25;
const Lg3: f32 = 0x91e9ee.0p-25;
const Lg4: f32 = 0xf89e26.0p-26;

fn logf(x: f32) -> f32 {
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
    const dk = f32(k);

    s * (hfsq + R) + dk * ln2_lo - hfsq + f + dk * ln2_hi
}

test "log" {
    fmath.assert(log(f32(0.2)) == logf(0.2));
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
