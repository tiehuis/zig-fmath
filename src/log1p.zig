const fmath = @import("index.zig");

pub fn log1p(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        log1pf(x)
    } else if (T == f64) {
        @compileError("log unimplemented for f64");
    } else if (T == c_longdouble) {
        @compileError("log unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

const ln2_hi = 6.9313812256e-01;
const ln2_lo = 9.0580006145e-06;
const Lg1: f32 = 0xaaaaaa.0p-24;
const Lg2: f32 = 0xccce13.0p-25;
const Lg3: f32 = 0x91e9ee.0p-25;
const Lg4: f32 = 0xf89e26.0p-26;

fn log1pf(x: f32) -> f32 {
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
