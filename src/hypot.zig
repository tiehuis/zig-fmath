const fmath = @import("index.zig");

pub fn hypot(comptime T: type, x: T, y: T) -> T {
    switch (T) {
        f32 => hypot32(x, y),
        f64 => unreachable,
        else => @compileError("hypot not implemented for " ++ @typeName(T)),
    }
}

fn hypot32(x: f32, y: f32) -> f32 {
    var ux = fmath.bitCast(u32, x);
    var uy = fmath.bitCast(u32, y);

    ux &= @maxValue(u32) >> 1;
    uy &= @maxValue(u32) >> 1;
    if (ux < uy) {
        const tmp = ux;
        ux = uy;
        uy = tmp;
    }

    var xx = fmath.bitCast(f32, ux);
    var yy = fmath.bitCast(f32, uy);
    if (uy == 0xFF << 23) {
        return yy;
    }
    if (ux >= 0xFF << 23 or uy == 0 or ux - uy >= (25 << 23)) {
        return xx + yy;
    }

    var z: f32 = 1.0;
    if (ux >= (0x7F+60) << 23) {
        z = 0x1.0p90;
        xx *= 0x1.0p-90;
        yy *= 0x1.0p-90;
    } else if (uy < (0x7F-60) << 23) {
        z = 0x1.0p-90;
        xx *= 0x1.0p-90;
        yy *= 0x1.0p-90;
    }

    z * fmath.sqrt(f32(f64(x) * x + f64(y) * y))
}

test "hypot" {
    fmath.assert(hypot(f32, 0.0, -1.2) == hypot32(0.0, -1.2));
}

test "hypot32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, hypot32(0.0, -1.2), 1.2, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(0.2, -0.34), 0.394462, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(0.8923, 2.636890), 2.783772, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(1.5, 5.25), 5.460083, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(37.45, 159.835), 164.163742, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(89.123, 382.028905), 392.286865, epsilon));
    fmath.assert(fmath.approxEq(f32, hypot32(123123.234375, 529428.707813), 543556.875, epsilon));
}
