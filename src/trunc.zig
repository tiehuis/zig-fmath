const fmath = @import("index.zig");

pub fn trunc(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(trunc32, x),
        f64 => @inlineCall(trunc64, x),
        else => @compileError("trunc not implemented for " ++ @typeName(T)),
    }
}

fn trunc32(x: f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    var e = i32(((u >> 23) & 0xFF)) - 0x7F + 9;
    var m: u32 = undefined;

    if (e >= 23 + 9) {
        return x;
    }
    if (e < 9) {
        e = 1;
    }

    m = @maxValue(u32) >> u32(e);
    if (u & m == 0) {
        x
    } else {
        fmath.forceEval(x + 0x1p120);
        fmath.bitCast(f32, u & ~m)
    }
}

fn trunc64(x: f64) -> f64 {
    const u = fmath.bitCast(u64, x);
    var e = i32(((u >> 52) & 0x7FF)) - 0x3FF + 12;
    var m: u64 = undefined;

    if (e >= 52 + 12) {
        return x;
    }
    if (e < 12) {
        e = 1;
    }

    m = @maxValue(u64) >> u64(e);
    if (u & m == 0) {
        x
    } else {
        fmath.forceEval(x + 0x1p120);
        fmath.bitCast(f64, u & ~m)
    }
}

test "trunc" {
    fmath.assert(trunc(f32(1.3)) == trunc32(1.3));
    fmath.assert(trunc(f64(1.3)) == trunc64(1.3));
}

test "trunc32" {
    fmath.assert(trunc32(1.3) == 1.0);
    fmath.assert(trunc32(-1.3) == -1.0);
    fmath.assert(trunc32(0.2) == 0.0);
}

test "trunc64" {
    fmath.assert(trunc64(1.3) == 1.0);
    fmath.assert(trunc64(-1.3) == -1.0);
    fmath.assert(trunc64(0.2) == 0.0);
}
