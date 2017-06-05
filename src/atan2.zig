const fmath = @import("index.zig");

pub fn atan2(comptime T: type, x: T, y: T) -> T {
    switch (T) {
        f32 => atan2f(x, y),
        f64 => unreachable,
        else => @compileError("atan2 not implemented for " ++ @typeName(T)),
    }
}

fn atan2f(y: f32, x: f32) -> f32 {
    const pi: f32    =  3.1415927410e+00;
    const pi_lo: f32 = -8.7422776573e-08;

    if (fmath.isNan(x) or fmath.isNan(y)) {
        return x + y;
    }

    var ix = fmath.bitCast(u32, x);
    var iy = fmath.bitCast(u32, y);

    // x = 1.0
    if (ix == 0x3F800000) {
        return fmath.atan(y);
    }

    // 2 * sign(x) + sign(y)
    const m = ((iy >> 31) & 1) | ((ix >> 30) & 2);
    ix &= 0x7FFFFFFF;
    iy &= 0x7FFFFFFF;

    if (iy == 0) {
        switch (m) {
            0, 1 => return  y,          // atan(+-0, +...)
            2    => return  pi,         // atan(+0, -...)
            3    => return -pi,         // atan(-0, -...)
            else => unreachable,
        }
    }

    if (ix == 0) {
        if (m & 1 != 0) {
            return -pi / 2;
        } else {
            return pi / 2;
        }
    }

    if (ix == 0x7F800000) {
        if (iy == 0x7F800000) {
            switch (m) {
                0    => return    pi / 4,   // atan(+inf, +inf)
                1    => return   -pi / 4,   // atan(-inf, +inf)
                2    => return  3*pi / 4,   // atan(+inf, -inf)
                3    => return -3*pi / 4,   // atan(-inf, -inf)
                else => unreachable,
            }
        } else {
            switch (m) {
                0    => return  0.0,   // atan(+..., +inf)
                1    => return -0.0,   // atan(-..., +inf)
                2    => return   pi,   // atan(+..., -inf)
                3    => return  -pi,   // atan(-...f, -inf)
                else => unreachable,
            }
        }
    }

    // |y / x| > 0x1p26
    if (ix + (26 << 23) < iy or iy == 0x7F800000) {
        if (m & 1 != 0) {
            return -pi / 2;
        } else {
            return pi / 2;
        }
    }

    // z = atan(|y / x|) with correct underflow
    var z = {
        if ((m & 2) != 0 and iy + (26 << 23) < ix) {
            0.0
        } else {
            fmath.atan(fmath.fabs(y / x))
        }
    };

    switch (m) {
        0    => return  z,                  // atan(+, +)
        1    => return -z,                  // atan(-, +)
        2    => return pi - (z - pi_lo),    // atan(+, -)
        3    => return (z - pi_lo) - pi,    // atan(-, -)
        else => unreachable,
    }
}

test "atan2" {
    fmath.assert(atan2(f32, 0.2, 0.21) == atan2f(0.2, 0.21));
}

test "atan2f" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, atan2f(0.0, 0.0), 0.0, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(0.2, 0.2), 0.785398, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(-0.2, 0.2), -0.785398, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(0.2, -0.2), 2.356194, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(-0.2, -0.2), -2.356194, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(0.34, -0.4), 2.437099, epsilon));
    fmath.assert(fmath.approxEq(f32, atan2f(0.34, 1.243), 0.267001, epsilon));
}
