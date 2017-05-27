const fmath = @import("index.zig");

pub fn scalbn(x: f64, n_: i32) -> f64 {
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

test "scalbn" {
    fmath.assert(scalbn(1.5, 4) == 24.0);
}
