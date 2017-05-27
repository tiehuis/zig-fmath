const fmath = @import("index.zig");

pub fn round(comptime T: type, x: T) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        round32(x)
    } else if (T == f64) {
        round64(x)
    } else if (T == c_longdouble) {
        @compileError("round unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn round32(x_: f32) -> f32 {
    var x = x_;
    const u = fmath.bitCast(u32, x);
    const e = (u >> 23) & 0xFF;
    var y: f32 = undefined;

    if (e >= 0x7F+23) {
        return x;
    }
    if (u >> 31 != 0) {
        x = -x;
    }
    if (e < 0x7F-1) {
        fmath.forceEval(x + fmath.f32_toint);
        return 0 * fmath.bitCast(f32, u);
    }

    y = x + fmath.f32_toint - fmath.f32_toint - x;
    if (y > 0.5) {
        y = y + x - 1;
    } else if (y <= -0.5) {
        y = y + x + 1;
    } else {
        y = y + x;
    }

    if (u >> 31 != 0) {
        -y
    } else {
        y
    }
}

fn round64(x_: f64) -> f64 {
    var x = x_;
    const u = fmath.bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;
    var y: f64 = undefined;

    if (e >= 0x3FF+52) {
        return x;
    }
    if (u >> 63 != 0) {
        x = -x;
    }
    if (e < 0x3ff-1) {
        fmath.forceEval(x + fmath.f64_toint);
        return 0 * fmath.bitCast(f64, u);
    }

    y = x + fmath.f64_toint - fmath.f64_toint - x;
    if (y > 0.5) {
        y = y + x - 1;
    } else if (y <= -0.5) {
        y = y + x + 1;
    } else {
        y = y + x;
    }

    if (u >> 63 != 0) {
        -y
    } else {
        y
    }
}

test "round32" {
    fmath.assert(round32(1.3) == 1.0);
    fmath.assert(round32(-1.3) == -1.0);
    fmath.assert(round32(0.2) == 0.0);
    fmath.assert(round32(1.8) == 2.0);
}

test "round64" {
    fmath.assert(round64(1.3) == 1.0);
    fmath.assert(round64(-1.3) == -1.0);
    fmath.assert(round64(0.2) == 0.0);
    fmath.assert(round64(1.8) == 2.0);
}
