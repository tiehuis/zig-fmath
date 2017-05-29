const fmath = @import("index.zig");

pub fn sqrt(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        sqrt32(x)
    } else if (T == f64) {
        @compileError("sqrt unimplemented for f64");
    } else if (T == c_longdouble) {
        @compileError("sqrt unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn sqrt32(x: f32) -> f32 {
    const tiny: f32 = 1.0e-30;
    const sign: i32 = fmath.bitCast(i32, u32(0x80000000));
    var ix: i32 = fmath.bitCast(i32, x);

    if ((ix & 0x7F800000) == 0x7F800000) {
        return x * x + x;   // sqrt(nan) = nan, sqrt(+inf) = +inf, sqrt(-inf) = snan
    }

    // zero
    if (ix <= 0) {
        if (ix & ~sign == 0) {
            return x;       // sqrt (+-0) = +-0
        }
        if (ix < 0) {
            return (x - x) / (x - x); // sqrt(-ve) = snan
        }
    }

    // normalize
    var m = ix >> 23;
    if (m == 0) {
        // subnormal
        var i: i32 = 0;
        while (ix & 0x00800000 == 0) : (i += 1) {
            ix <<= 1
        }
        m -= i - 1;
    }

    m -= 127;               // unbias exponent
    ix = (ix & 0x007FFFFF) | 0x00800000;

    if (m & 1 != 0) {       // odd m, double x to even
        ix += ix;
    }

    m >>= 1;                // m = [m / 2]

    // sqrt(x) bit by bit
    ix += ix;
    var q: i32 = 0;              // q = sqrt(x)
    var s: i32 = 0;
    var r: i32 = 0x01000000;     // r = moving bit right -> left

    while (r != 0) {
        const t = s + r;
        if (t <= ix) {
            s = t + r;
            ix -= t;
            q += r;
        }
        ix += ix;
        r >>= 1;
    }

    // floating add to find rounding direction
    if (ix != 0) {
        var z = 1.0 - tiny;     // inexact
        if (z >= 1.0) {
            z = 1.0 + tiny;
            if (z > 1.0) {
                q += 2;
            } else {
                if (q & 1 != 0) {
                    q += 1;
                }
            }
        }
    }

    ix = (q >> 1) + 0x3f000000;
    ix += m << 23;
    fmath.bitCast(f32, ix)
}

test "sqrt32" {
    const epsilon = 0.000001;

    fmath.assert(sqrt32(0.0) == 0.0);
    fmath.assert(fmath.approxEq(f32, sqrt32(2.0), 1.414214, epsilon));
    fmath.assert(fmath.approxEq(f32, sqrt32(3.6), 1.897367, epsilon));
    fmath.assert(sqrt32(4.0) == 2.0);
    fmath.assert(fmath.approxEq(f32, sqrt32(7.539840), 2.745877, epsilon));
    fmath.assert(fmath.approxEq(f32, sqrt32(19.230934), 4.385309, epsilon));
    fmath.assert(sqrt32(64.0) == 8.0);
    fmath.assert(fmath.approxEq(f32, sqrt32(64.1), 8.006248, epsilon));
    fmath.assert(fmath.approxEq(f32, sqrt32(8942.230469), 94.563370, epsilon));
}
