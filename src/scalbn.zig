const fmath = @import("index.zig");

pub fn scalbn(comptime T: type, x: T, n: i32) -> T {
    fmath.assert(@typeId(T) == fmath.TypeId.Float);
    if (T == f32) {
        scalbn32(x, n)
    } else if (T == f64) {
        scalbn64(x, n)
    } else if (T == c_longdouble) {
        @compileError("scalbn unimplemented for c_longdouble");
    } else {
        unreachable;
    }
}

fn scalbn32(x: f32, n_: i32) -> f32 {
    var y = x;
    var n = n_;

    if (n > 127) {
        // TODO: Determine how to do the following.
        y *= 0x1.0p127;
        n -= 127;
        if (n > 1023) {
            y *= 0x1.0p127;
            n -= 127;
            if (n > 127) {
                n = 127;
            }
        }
    } else if (n < -126) {
        y *= 0x1.0p-126 * 0x1.0p24;
        n += 126 - 24;
        if (n < -126) {
            y *= 0x1.0p-126 * 0x1.0p24;
            n += 126 - 24;
            if (n < -126) {
                n = -126;
            }
        }
    }

    const u = (u32(n) + 0x7F) << 23;
    y * fmath.bitCast(f32, u)
}

fn scalbn64(x: f64, n_: i32) -> f64 {
    var y = x;
    var n = n_;

    if (n > 1023) {
        // TODO: Determine how to do the following.
        // y *= 0x1.0p1023;
        n -= 1023;
        if (n > 1023) {
            // y *= 0x1.0p1023;
            n -= 1023;
            if (n > 1023) {
                n = 1023;
            }
        }
    } else if (n < -1022) {
        y *= 0x1.0p-1022 * 0x1.0p53;
        n += 1022 - 53;
        if (n < -1022) {
            y *= 0x1.0p-1022 * 0x1.0p53;
            n += 1022 - 53;
            if (n < -1022) {
                n = -1022;
            }
        }
    }

    const u = (u64(n) + 0x3FF) << 52;
    y * fmath.bitCast(f64, u)
}

test "scalbn32" {
    fmath.assert(scalbn32(1.5, 4) == 24.0);
}

test "scalbn64" {
    fmath.assert(scalbn64(1.5, 4) == 24.0);
}