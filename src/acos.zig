const fmath = @import("index.zig");

pub fn acos(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => acos32(x),
        f64 => unreachable,
        else => @compileError("acos not implemented for " ++ @typeName(T)),
    }
}

const pio2_hi = 1.5707962513e+00; // 0x3FC90FDA
const pio2_lo = 7.5497894159e-08; // 0x33A22168
const pS0 =  1.6666586697e-01;
const pS1 = -4.2743422091e-02;
const pS2 = -8.6563630030e-03;
const qS1 = -7.0662963390e-01;

fn r32(z: f32) -> f32 {
    const p = z * (pS0 + z * (pS1 + z * pS2));
    const q = 1.0 + z * qS1;
    p / q
}

fn acos32(x: f32) -> f32 {
    const hx: u32 = fmath.bitCast(u32, x);
    const ix: u32 = hx & 0x7FFFFFFF;

    // |x| >= 1 or nan
    if (ix >= 0x3F800000) {
        if (ix == 0x3F800000) {
            if (hx >> 31 != 0) {
                return 2.0 * pio2_hi + 0x1.0p-120;
            } else {
                return 0;
            }
        } else {
            return 0 / (x - x);
        }
    }

    // |x| < 0.5
    if (ix < 0x3F000000) {
        if (ix <= 0x32800000) { // |x| < 2^(-26)
            return pio2_hi + 0x1.0p-120;
        } else {
            return pio2_hi - (x - (pio2_lo - x * r32(x * x)));
        }
    }

    // x < -0.5
    if (hx >> 31 != 0) {
        const z = (1 + x) * 0.5;
        const s = fmath.sqrt(z);
        const w = r32(z) * s - pio2_lo;
        return 2 * (pio2_hi - (s + w));
    }

    // x > 0.5
    const z = (1 - x) * 0.5;
    const s = fmath.sqrt(z);
    const jx = fmath.bitCast(u32, s);
    const df = fmath.bitCast(f32, jx & 0xFFFFF000);
    const c = (z - df * df) / (s + df);
    const w = r32(z) * s + c;
    2 * (df + w)
}

test "acos" {
    fmath.assert(acos(f32(0.0)) == acos32(0.0));
}

test "acos32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, acos32(0.0), 1.570796, epsilon));
    fmath.assert(fmath.approxEq(f32, acos32(0.2), 1.369438, epsilon));
    fmath.assert(fmath.approxEq(f32, acos32(0.3434), 1.220262, epsilon));
    fmath.assert(fmath.approxEq(f32, acos32(0.5), 1.047198, epsilon));
    fmath.assert(fmath.approxEq(f32, acos32(0.8923), 0.468382, epsilon));
    fmath.assert(fmath.approxEq(f32, acos32(-0.2), 1.772154, epsilon));
}
