const fmath = @import("index.zig");

pub fn atanh(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        atanhf(x)
    } else if (T == f64) {
        @compileError("atanh unimplemented for f64");
    } else if (T == c_longdouble) {
        @compileError("atanh unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

// atanh(x) = log((1 + x) / (1 - x)) / 2 = log1p(2x / (1 - x)) / 2 ~= x + x^3 / 3 + o(x^5)
fn atanhf(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const i = u & 0x7FFFFFFF;
    const s = u >> 31;

    var y = fmath.bitCast(f32, i); // |x|

    if (u < 0x3F800000 - (1 << 23)) {
        if (u < 0x3F800000 - (32 << 23)) {
            // underflow
            if (u < (1 << 23)) {
                fmath.forceEval(y * y)
            }
        }
        // |x| < 0.5
        else {
            y = 0.5 * fmath.log1p(f32, 2 * y + 2 * y * y / (1 - y));
        }
    } else {
        // avoid overflow
        y = 0.5 * fmath.log1p(f32, 2 * (y / (1 - y)));
    }

    if (s != 0) -y else y
}

test "atanhf" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, atanhf(0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, atanhf(0.2), 0.202733, epsilon));
    fmath.assert(fmath.approxEq(f32, atanhf(0.8923), 1.433099, epsilon));
    //fmath.assert(fmath.approxEq(f32, atanhf(1.5), 0.962424, epsilon));
    //fmath.assert(fmath.approxEq(f32, atanhf(37.45), 4.315976, epsilon));
    //fmath.assert(fmath.approxEq(f32, atanhf(89.123), 5.183133, epsilon));
    //fmath.assert(fmath.approxEq(f32, atanhf(123123.234375), 12.414088, epsilon));
}
