const fmath = @import("index.zig");

pub fn atan(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => atan32(x),
        f64 => unreachable,
        else => @compileError("atan not implemented for " ++ @typeName(T)),
    }
}

const atanhi = []const f32 {
    4.6364760399e-01, // atan(0.5)hi 0x3eed6338
    7.8539812565e-01, // atan(1.0)hi 0x3f490fda
    9.8279368877e-01, // atan(1.5)hi 0x3f7b985e
    1.5707962513e+00, // atan(inf)hi 0x3fc90fda
};

const atanlo = []const f32 {
    5.0121582440e-09, // atan(0.5)lo 0x31ac3769
    3.7748947079e-08, // atan(1.0)lo 0x33222168
    3.4473217170e-08, // atan(1.5)lo 0x33140fb4
    7.5497894159e-08, // atan(inf)lo 0x33a22168
};

const aT = []const f32 {
    3.3333328366e-01,
    -1.9999158382e-01,
    1.4253635705e-01,
    -1.0648017377e-01,
    6.1687607318e-02,
};

fn atan32(x_: f32) -> f32 {
    var x = x_;
    var ix: u32 = fmath.bitCast(u32, x);
    const sign = ix >> 31;
    ix &= 0x7FFFFFFF;

    // |x| >= 2^26
    if (ix >= 0x4C800000) {
        if (fmath.isNan(x)) {
            return x;
        } else {
            const z = atanhi[3] + 0x1.0p-120;
            return if (sign != 0) -z else z;
        }
    }

    var id: ?usize = undefined;

    // |x| < 0.4375
    if (ix < 0x3EE00000) {
        // |x| < 2^(-12)
        if (ix < 0x39800000) {
            if (ix < 0x00800000) {
                fmath.forceEval(x * x);
            }
            return x;
        }
        id = null;
    } else {
        x = fmath.fabs(x);
        // |x| < 1.1875
        if (ix < 0x3F980000) {
            // 7/16 <= |x| < 11/16
            if (ix < 0x3F300000) {
                id = 0;
                x = (2.0 * x - 1.0) / (2.0 + x);
            }
            // 11/16 <= |x| < 19/16
            else {
                id = 1;
                x = (x - 1.0) / (x + 1.0);
            }
        }
        else {
            // |x| < 2.4375
            if (ix < 0x401C0000) {
                id = 2;
                x = (x - 1.5) / (1.0 + 1.5 * x);
            }
            // 2.4375 <= |x| < 2^26
            else {
                id = 3;
                x = -1.0 / x;
            }
        }
    }

    const z = x * x;
    const w = z * z;
    const s1 = z * (aT[0] + w * (aT[2] + w * aT[4]));
    const s2 = w * (aT[1] + w * aT[3]);

    if (id == null) {
        x - x * (s1 + s2)
    } else {
        const zz = atanhi[??id] - ((x * (s1 + s2) - atanlo[??id]) - x);
        if (sign != 0) -zz else zz
    }
}

test "atan" {
    fmath.assert(atan(f32(0.2)) == atan32(0.2));
}

test "atan32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, atan32(0.2), 0.197396, epsilon));
    fmath.assert(fmath.approxEq(f32, atan32(-0.2), -0.197396, epsilon));
    fmath.assert(fmath.approxEq(f32, atan32(0.3434), 0.330783, epsilon));
    fmath.assert(fmath.approxEq(f32, atan32(0.8923), 0.728545, epsilon));
    fmath.assert(fmath.approxEq(f32, atan32(1.5), 0.982794, epsilon));
}
