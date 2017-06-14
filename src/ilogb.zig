const fmath = @import("index.zig");

pub fn ilogb(x: var) -> i32 {
    const T = @typeOf(x);
    switch (T) {
        f32 => @inlineCall(ilogb32, x),
        f64 => @inlineCall(ilogb64, x),
        else => @compileError("ilogb not implemented for " ++ @typeName(T)),
    }
}

// NOTE: Should these be exposed publically?
const fp_ilogbnan = -1 - i32(@maxValue(u32) >> 1);
const fp_ilogb0 = fp_ilogbnan;

fn ilogb32(x: f32) -> i32 {
    var u = fmath.bitCast(u32, x);
    var e = i32((u >> 23) & 0xFF);

    if (e == 0) {
        u <<= 9;
        if (u == 0) {
            fmath.raiseInvalid();
            return fp_ilogb0;
        }

        // subnormal
        e = -0x7F;
        while (u >> 31 == 0) : (u <<= 1) {
            e -= 1;
        }
        return e;
    }

    if (e == 0xFF) {
        fmath.raiseInvalid();
        if (u << 9 != 0) {
            return fp_ilogbnan;
        } else {
            return @maxValue(i32);
        }
    }

    e - 0x7F
}

fn ilogb64(x: f64) -> i32 {
    var u = fmath.bitCast(u64, x);
    var e = i32((u >> 52) & 0x7FF);

    if (e == 0) {
        u <<= 12;
        if (u == 0) {
            fmath.raiseInvalid();
            return fp_ilogb0;
        }

        // subnormal
        e = -0x3FF;
        while (u >> 63 == 0) : (u <<= 1) {
            e -= 1;
        }
        return e;
    }

    if (e == 0x7FF) {
        fmath.raiseInvalid();
        if (u << 12 != 0) {
            return fp_ilogbnan;
        } else {
            return @maxValue(i32);
        }
    }

    e - 0x3FF
}

test "ilogb" {
    fmath.assert(ilogb(f32(0.2)) == ilogb32(0.2));
    fmath.assert(ilogb(f64(0.2)) == ilogb64(0.2));
}

test "ilogb32" {
    fmath.assert(ilogb32(0.0) == fp_ilogb0);
    fmath.assert(ilogb32(0.5) == -1);
    fmath.assert(ilogb32(0.8923) == -1);
    fmath.assert(ilogb32(10.0) == 3);
    fmath.assert(ilogb32(-123984) == 16);
    fmath.assert(ilogb32(2398.23) == 11);
}

test "ilogb64" {
    fmath.assert(ilogb64(0.0) == fp_ilogb0);
    fmath.assert(ilogb64(0.5) == -1);
    fmath.assert(ilogb64(0.8923) == -1);
    fmath.assert(ilogb64(10.0) == 3);
    fmath.assert(ilogb64(-123984) == 16);
    fmath.assert(ilogb64(2398.23) == 11);
}
