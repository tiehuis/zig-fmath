const fmath = @import("index.zig");

pub fn fma(comptime T: type, x: T, y: T, z: T) -> T {
    switch (T) {
        f32 => fma32(x, y, z),
        f64 => fma64(x, y ,z),
        else => @compileError("acos not implemented for " ++ @typeName(T)),
    }
}

fn fma32(x: f32, y: f32, z: f32) -> f32 {
    const xy = f64(x) * y;
    const xy_z = xy + z;
    const u = fmath.bitCast(u64, xy_z);
    const e = (u >> 52) & 0x7FF;

    if ((u & 0x1FFFFFFF) != 0x10000000 or e == 0x7FF or xy_z - xy == z) {
        f32(xy_z)
    } else {
        // TODO: Handle inexact case with double-rounding
        f32(xy_z)
    }
}

// TODO: How do we want to handle rounding modes.
fn fma64(x: f64, y: f64, z: f64) -> f64 {
    if (!fmath.isFinite(x) or !fmath.isFinite(y)) {
        return x * y + z;
    }
    if (!fmath.isFinite(z)) {
        return z;
    }
    if (x == 0.0 or y == 0.0) {
        return x * y + z;
    }
    if (z == 0.0) {
        return x * y;
    }

    var ex: i32 = undefined;
    var ey: i32 = undefined;
    var ez: i32 = undefined;
    var xs = fmath.frexp(x, &ex);
    var ys = fmath.frexp(y, &ey);
    var zs = fmath.frexp(z, &ez);
    var spread = ex + ey - ez;

    // TODO: Other rounding modes handled edge cases here.

    if (spread <= 53 * 2) {
        zs = fmath.scalbn(zs, -spread);
    } else {
        // TODO: DBL_MIN
        zs = fmath.copysign(f64, 0.0, zs);
    }

    const xy = dd_mul(xs, ys);
    const r = dd_add(xy.hi, zs);
    spread = ex + ey;

    if (r.hi == 0.0) {
        return xy.hi + zs + fmath.scalbn(xy.lo, spread);
    }

    // TODO: Other rounding modes handled edge cases here.

    const adj = add_adjusted(r.lo, xy.lo);
    if (spread + fmath.ilogb(r.hi) > -1023) {
        fmath.scalbn(r.hi + adj, spread)
    } else {
        add_and_denorm(r.hi, adj, spread)
    }
}

const dd = struct { hi: f64, lo: f64, };

fn dd_add(a: f64, b: f64) -> dd {
    var ret: dd = undefined;
    ret.hi = a + b;
    const s = ret.hi - a;
    ret.lo = (a - (ret.hi - s)) + (b - s);
    ret
}

fn dd_mul(a: f64, b: f64) -> dd {
    var ret: dd = undefined;
    const split: f64 = 0x1.0p27 + 1.0;

    var p = a * split;
    var ha = a - p;
    ha += p;
    var la = a - ha;

    p = b * split;
    var hb = b - p;
    hb += p;
    var lb = b - hb;

    p = ha * hb;
    var q = ha * lb + la * hb;

    ret.hi = p + q;
    ret.lo = p - ret.hi + q + la * lb;
    ret
}

fn add_adjusted(a: f64, b: f64) -> f64 {
    var sum = dd_add(a, b);
    if (sum.lo != 0) {
        var uhii = fmath.bitCast(u64, sum.hi);
        if (uhii & 1 == 0) {
            // hibits += copysign(1.0, sum.hi, sum.lo)
            const uloi = fmath.bitCast(u64, sum.lo);
            uhii += 1 - ((uhii ^ uloi) >> 62);
            sum.hi = fmath.bitCast(f64, uhii);
        }
    }
    sum.hi
}

fn add_and_denorm(a: f64, b: f64, scale: i32) -> f64 {
    var sum = dd_add(a, b);
    if (sum.lo != 0) {
        var uhii = fmath.bitCast(u64, sum.hi);
        const bits_lost = -i32((uhii >> 52) & 0x7FF) - scale + 1;
        if ((bits_lost != 1) == (uhii & 1 != 0)) {
            const uloi = fmath.bitCast(u64, sum.lo);
            uhii += 1 - (((uhii ^ uloi) >> 62) & 2);
            sum.hi = fmath.bitCast(f64, uhii);
        }
    }
    fmath.scalbn(sum.hi, scale)
}

test "fma" {
    fmath.assert(fma(f32, 0.0, 1.0, 1.0) == fma32(0.0, 1.0, 1.0));
    fmath.assert(fma(f64, 0.0, 1.0, 1.0) == fma64(0.0, 1.0, 1.0));
}

test "fma32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, fma32(0.0, 5.0, 9.124), 9.124, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(0.2, 5.0, 9.124), 10.124, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(0.8923, 5.0, 9.124), 13.5855, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(1.5, 5.0, 9.124), 16.624, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(37.45, 5.0, 9.124), 196.374004, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(89.123, 5.0, 9.124), 454.739005, epsilon));
    fmath.assert(fmath.approxEq(f32, fma32(123123.234375, 5.0, 9.124), 615625.295875, epsilon));
}

test "fma64" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, fma64(0.0, 5.0, 9.124), 9.124, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(0.2, 5.0, 9.124), 10.124, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(0.8923, 5.0, 9.124), 13.5855, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(1.5, 5.0, 9.124), 16.624, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(37.45, 5.0, 9.124), 196.374, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(89.123, 5.0, 9.124), 454.739, epsilon));
    fmath.assert(fmath.approxEq(f64, fma64(123123.234375, 5.0, 9.124), 615625.295875, epsilon));
}
