const fmath = @import("index.zig");
const printf = @import("std").io.stdout.printf;

fn ilen(n_: u64, base: u8) -> u8 {
    var n = n_;
    if (n == 0) {
        return 1;
    }

    var r: u8 = 0;
    while (n != 0) : (n /= base) {
        r += 1;
    }
    return r;
}

// This is quite minimal and doesn't handle too many cases. Good enough for rough debugging
// and a sanity check when testing other functions.
pub fn printFloat(y_: f64, prec: u8) -> %void {
    var y = y_;
    const prefix = {
        if (fmath.signbit(f64, y)) {
            y = -y;
            "-"
        } else {
            ""
        }
    };

    if (!fmath.isfinite(y)) {
        const sp = if (y != y) "nan" else "inf";
        %return printf("{}\n", sp);
        return;
    }

    const floor = u64(y);
    %return printf("{}", prefix);
    %return printf("{}", floor);
    if (prec == 0) {
        %return printf("\n");
        return;
    }
    %return printf(".");

    var mult: f64 = 1;
    { var i: u8 = 0; while (i < prec) : (i += 1) {
        mult *= 10;
    }}

    const frac = u64(mult * (y - f64(floor)));
    var limit = prec;
    if (y != 0) {
        limit -= 1;
    }
    { var i = ilen(frac, 10); while (i < limit) : (i += 1) {
        %return printf("0");
    }}

    %return printf("{}\n", frac);
}
