const fmath = @import("index.zig");

pub fn signbit(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        signbit32(x)
    } else if (T == f64) {
        signbit64(x)
    } else if (T == c_longdouble) {
        @compileError("signbit unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn signbit32(x: f32) -> bool {
    const bits = fmath.bitCast(u32, x);
    bits >> 31 != 0
}

fn signbit64(x: f64) -> bool {
    const bits = fmath.bitCast(u64, x);
    bits >> 63 != 0
}

test "signbit32" {
    fmath.assert(!signbit32(4.0));
    fmath.assert(signbit32(-3.0));
}

test "signbit64" {
    fmath.assert(!signbit64(4.0));
    fmath.assert(signbit64(-3.0));
}
