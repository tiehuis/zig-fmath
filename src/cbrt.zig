const fmath = @import("index.zig");

pub fn cbrt(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => cbrt32(x),
        f64 => unreachable,
        else => @compileError("cbrt not implemented for " ++ @typeName(T)),
    }
}

const B1 = 709958130; // (127 - 127.0 / 3 - 0.03306235651) * 2^23
const B2 = 642849266; // (127 - 127.0 / 3 - 24 / 3 - 0.03306235651) * 2^23

fn cbrt32(x: f32) -> f32 {
    var u = fmath.bitCast(u32, x);
    var hx = u & 0x7FFFFFFF;

    // cbrt(nan, inf) = itself
    if (hx >= 0x7F800000) {
        return x + x;
    }

    // cbrt to ~5bits
    if (hx < 0x00800000) {
        // cbr(+-0) = itself
        if (hx == 0) {
            return x;
        }
        u = fmath.bitCast(u32, x * 0x1.0p24);
        hx = u & 0x7FFFFFFF;
        hx = hx / 3 + B2;
    } else {
        hx = hx / 3 + B1;
    }

    u &= 0x80000000;
    u |= hx;

    // first step newton to 16 bits
    var t: f64 = fmath.bitCast(f32, u);
    var r: f64 = t * t * t;
    t = t * (f64(x) + x + r) / (x + r + r);

    // second step newton to 47 bits
    r = t * t * t;
    t = t * (f64(x) + x + r) / (x + r + r);

    f32(t)
}

test "cbrt" {
    fmath.assert(cbrt(f32(0.0)) == cbrt32(0.0));
}

test "cbrt32" {
    const epsilon = 0.000001;

    fmath.assert(cbrt32(0.0) == 0.0);
    fmath.assert(fmath.approxEq(f32, cbrt32(0.2), 0.584804, epsilon));
    fmath.assert(fmath.approxEq(f32, cbrt32(0.8923), 0.962728, epsilon));
    fmath.assert(fmath.approxEq(f32, cbrt32(1.5), 1.144714, epsilon));
    fmath.assert(fmath.approxEq(f32, cbrt32(37.45), 3.345676, epsilon));
    fmath.assert(fmath.approxEq(f32, cbrt32(123123.234375), 49.748501, epsilon));
}
