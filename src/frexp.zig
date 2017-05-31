const fmath = @import("index.zig");

pub fn frexp(comptime T: type, x: T, e: &i32) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        frexp32(x, e)
    } else if (T == f64) {
        frexp64(x, e)
    } else if (T == c_longdouble) {
        @compileError("frexp unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn frexp32(x_: f32, e: &i32) -> f32 {
    var x = x_;
    var y = fmath.bitCast(u32, x);
    const ee = i32(y >> 23) & 0xFF;

    if (ee == 0) {
        if (x != 0) {
            x = frexp32(x * 0x1.0p64, e);
            *e -= 64;
        } else {
            *e = 0;
        }
        return x;
    } else if (ee == 0xFF) {
        return x;
    }

    *e = ee - 0x7E;
    y &= 0x807FFFFF;
    y |= 0x3F000000;
    fmath.bitCast(f32, y)
}

fn frexp64(x_: f64, e: &i32) -> f64 {
    var x = x_;
    var y = fmath.bitCast(u64, x);
    const ee = i32(y >> 52) & 0x7FF;

    if (ee == 0) {
        if (x != 0) {
            x = frexp64(x * 0x1.0p64, e);
            *e -= 64;
        } else {
            *e = 0;
        }
        return x;
    } else if (ee == 0x7FF) {
        return x;
    }

    *e = ee - 0x3FE;
    y &= 0x800FFFFFFFFFFFFF;
    y |= 0x3FE0000000000000;
    fmath.bitCast(f64, y)
}

test "frexp32" {
    const epsilon = 0.000001;
    var i: i32 = undefined;
    var d: f32 = undefined;

    d = frexp32(1.3, &i);
    fmath.assert(fmath.approxEq(f32, d, 0.65, epsilon) and i == 1);

    d = frexp32(78.0234, &i);
    fmath.assert(fmath.approxEq(f32, d, 0.609558, epsilon) and i == 7);
}

test "frexp64" {
    const epsilon = 0.000001;
    var i: i32 = undefined;
    var d: f64 = undefined;

    d = frexp64(1.3, &i);
    fmath.assert(fmath.approxEq(f64, d, 0.65, epsilon) and i == 1);

    d = frexp64(78.0234, &i);
    fmath.assert(fmath.approxEq(f64, d, 0.609558, epsilon) and i == 7);
}
