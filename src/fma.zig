const fmath = @import("index.zig");

pub fn fma(comptime T: type, x: T, y: T, z: T) -> T {
    switch (T) {
        f32 => fma32(x, y, z),
        f64 => unreachable,
        else => @compileError("acos not implemented for " ++ @typeName(T)),
    }
}

fn fma32(x: f32, y: f32, z: f32) -> f32 {
    const xy = f64(x) * y;
    const xy_z = xy + z;
    const u = fmath.bitCast(u64, xy_z);
    const e = (u >> 52) & 0x7FF;

    if ((u & 0x1FFFFFFF) != 0x10000000 or e == 0x7FF or xy_z - xy == z) {
        f32(xy_z)
    } else {
        // TODO: Handle inexact case with double-rounding
        f32(xy_z)
    }
}

test "fma" {
    fmath.assert(fma(f32, 0.0, 1.0, 1.0) == fma32(0.0, 1.0, 1.0));
}

test "fma32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, fma32(0.0, 5.0, 9.124), 9.124, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(0.2, 5.0, 9.124), 10.124, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(0.8923, 5.0, 9.124), 13.5855, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(1.5, 5.0, 9.124), 16.624, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(37.45, 5.0, 9.124), 196.374004, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(89.123, 5.0, 9.124), 454.739005, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(123123.234375, 5.0, 9.124), 615625.295875, epsilon));
}
