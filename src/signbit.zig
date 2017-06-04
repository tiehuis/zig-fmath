const fmath = @import("index.zig");

pub fn signbit(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => signbit32(x),
        f64 => signbit64(x),
        else => @compileError("signbit not implemented for " ++ @typeName(T)),
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

test "signbit" {
    fmath.assert(signbit(f32(4.0)) == signbit32(4.0));
    fmath.assert(signbit(f64(4.0)) == signbit64(4.0));
}

test "signbit32" {
    fmath.assert(!signbit32(4.0));
    fmath.assert(signbit32(-3.0));
}

test "signbit64" {
    fmath.assert(!signbit64(4.0));
    fmath.assert(signbit64(-3.0));
}
