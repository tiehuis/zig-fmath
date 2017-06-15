const builtin = @import("builtin");
const fmath = @import("index.zig");

pub fn floor(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(floor32, x),
        f64 => @inlineCall(floor64, x),
        else => @compileError("floor not implemented for " ++ @typeName(T)),
    }
}

fn floor32(x: f32) -> f32 {
    var u = @bitCast(u32, x);
    const e = i32((u >> 23) & 0xFF) - 0x7F;
    var m: u32 = undefined;

    if (e >= 23) {
        return x;
    }

    if (e >= 0) {
        m = 0x007FFFFF >> u32(e);
        if (u & m == 0) {
            return x;
        }
        fmath.forceEval(x + 0x1.0p120);
        if (u >> 31 != 0) {
            u += m;
        }
        @bitCast(f32, u & ~m)
    } else {
        fmath.forceEval(x + 0x1.0p120);
        if (u >> 31 == 0) {
            return 0.0; // Compiler requires return
        } else {
            -1.0
        }
    }
}

fn floor64(x: f64) -> f64 {
    const u = @bitCast(u64, x);
    const e = (u >> 52) & 0x7FF;
    var y: f64 = undefined;

    if (e >= 0x3FF+52 or x == 0) {
        return x;
    }

    if (u >> 63 != 0) {
        @setFloatMode(this, builtin.FloatMode.Strict);
        y = x - fmath.f64_toint + fmath.f64_toint - x;
    } else {
        @setFloatMode(this, builtin.FloatMode.Strict);
        y = x + fmath.f64_toint - fmath.f64_toint - x;
    }

    if (e <= 0x3FF-1) {
        fmath.forceEval(y);
        if (u >> 63 != 0) {
            return -1.0;    // Compiler requires return.
        } else {
            0.0
        }
    } else if (y > 0) {
        x + y - 1
    } else {
        x + y
    }
}

test "floor" {
    fmath.assert(floor(f32(1.3)) == floor32(1.3));
    fmath.assert(floor(f64(1.3)) == floor64(1.3));
}

test "floor32" {
    fmath.assert(floor32(1.3) == 1.0);
    fmath.assert(floor32(-1.3) == -2.0);
    fmath.assert(floor32(0.2) == 0.0);
}

test "floor64" {
    fmath.assert(floor64(1.3) == 1.0);
    fmath.assert(floor64(-1.3) == -2.0);
    fmath.assert(floor64(0.2) == 0.0);
}
