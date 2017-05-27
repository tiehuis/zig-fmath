const fmath = @import("index.zig");

pub fn fabs(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        fabs32(x)
    } else if (T == f64) {
        fabs64(x)
    } else if (T == c_longdouble) {
        @compileError("fabs unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn fabs32(x: f32) -> f32 {
    var u = fmath.bitCast(u32, x);
    u &= 0x7FFFFFFF;
    fmath.bitCast(f32, u)
}

fn fabs64(x: f64) -> f64 {
    var u = fmath.bitCast(u64, x);
    u &= @maxValue(u64) >> 1;
    fmath.bitCast(f64, u)
}

test "fabs32" {
    fmath.assert(fabs64(1.0) == 1.0);
    fmath.assert(fabs64(-1.0) == 1.0);
}

test "fabs64" {
    fmath.assert(fabs64(1.0) == 1.0);
    fmath.assert(fabs64(-1.0) == 1.0);
}
