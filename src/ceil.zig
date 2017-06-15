const builtin = @import("builtin");
const fmath = @import("index.zig");

pub fn ceil(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(ceil32, x),
        f64 => @inlineCall(ceil64, x),
        else => @compileError("ceil not implemented for " ++ @typeName(T)),
    }
}

fn ceil32(x: f32) -> f32 {
    var u = @bitCast(u32, x);
    var e = i32((u >> 23) & 0xFF) - 0x7F;
    var m: u32 = undefined;

    if (e >= 23) {
        return x;
    }
    else if (e >= 0) {
        m = 0x007FFFFF >> u32(e);
        if (u & m == 0) {
            return x;
        }
        fmath.forceEval(x + 0x1.0p120);
        if (u >> 31 == 0) {
            u += m;
        }
        u &= ~m;
        @bitCast(f32, u)
    } else {
        fmath.forceEval(x + 0x1.0p120);
        if (u >> 31 != 0) {
            return -0.0;
        } else {
            1.0
        }
    }
}

fn ceil64(x: f64) -> f64 {
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
            return -0.0;    // Compiler requires return.
        } else {
            1.0
        }
    } else if (y < 0) {
        x + y + 1
    } else {
        x + y
    }
}

test "ceil" {
    fmath.assert(ceil(f32(0.0)) == ceil32(0.0));
    fmath.assert(ceil(f64(0.0)) == ceil64(0.0));
}

test "ceil32" {
    fmath.assert(ceil32(1.3) == 2.0);
    fmath.assert(ceil32(-1.3) == -1.0);
    fmath.assert(ceil32(0.2) == 1.0);
}

test "ceil64" {
    fmath.assert(ceil64(1.3) == 2.0);
    fmath.assert(ceil64(-1.3) == -1.0);
    fmath.assert(ceil64(0.2) == 1.0);
}
