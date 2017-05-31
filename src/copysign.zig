const fmath = @import("index.zig");

pub fn copysign(comptime T: type, x: T, y: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        copysign32(x, y)
    } else if (T == f64) {
        copysign64(x, y)
    } else if (T == c_longdouble) {
        @compileError("copysign unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn copysign32(x: f32, y: f32) -> f32 {
    const ux = fmath.bitCast(u32, x);
    const uy = fmath.bitCast(u32, y);

    const h1 = ux & (@maxValue(u32) / 2);
    const h2 = uy & (u32(1) << 31);
    fmath.bitCast(f32, h1 | h2)
}

fn copysign64(x: f64, y: f64) -> f64 {
    const ux = fmath.bitCast(u64, x);
    const uy = fmath.bitCast(u64, y);

    const h1 = ux & (@maxValue(u64) / 2);
    const h2 = uy & (u64(1) << 63);
    fmath.bitCast(f64, h1 | h2)
}

test "copysign32" {
    fmath.assert(copysign32(5.0, 1.0) == 5.0);
    fmath.assert(copysign32(5.0, -1.0) == -5.0);
    fmath.assert(copysign32(-5.0, -1.0) == -5.0);
    fmath.assert(copysign32(-5.0, 1.0) == 5.0);
}

test "copysign64" {
    fmath.assert(copysign64(5.0, 1.0) == 5.0);
    fmath.assert(copysign64(5.0, -1.0) == -5.0);
    fmath.assert(copysign64(-5.0, -1.0) == -5.0);
    fmath.assert(copysign64(-5.0, 1.0) == 5.0);
}
