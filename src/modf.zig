const fmath = @import("index.zig");

pub fn modf(comptime T: type, x: T, intpart: &T) -> T {
    switch (T) {
        f32 => modf32(x, intpart),
        f64 => modf64(x, intpart),
        else => @compileError("modf not implemented for " ++ @typeName(T)),
    }
}

fn modf32(x: f32, intpart: &f32) -> f32 {
    const u = fmath.bitCast(u32, x);
    const e = i32((u >> 23) & 0xFF) - 0x7F;
    const us = u & 0x80000000;

    // no fractional part
    if (e >= 23) {
        *intpart = x;
        if (e == 0x80 and u << 9 != 0) { // nan
            return x;
        }
        return fmath.bitCast(f32, us);
    }

    // no integral part
    if (e < 0) {
        *intpart = fmath.bitCast(f32, us);
        return x;
    }

    const mask = 0x007FFFFF >> u32(e);
    if (u & mask == 0) {
        *intpart = x;
        return fmath.bitCast(f32, us);
    }

    const uf = fmath.bitCast(f32, u & ~mask);
    *intpart = uf;
    return x - uf;
}

fn modf64(x: f64, intpart: &f64) -> f64 {
    const u = fmath.bitCast(u64, x);
    const e = i32((u >> 52) & 0x7FF) - 0x3FF;
    const us = u & (1 << 63);

    // no fractional part
    if (e >= 52) {
        *intpart = x;
        if (e == 0x400 and u << 12 != 0) { // nan
            return x;
        }
        return fmath.bitCast(f64, us);
    }

    // no integral part
    if (e < 0) {
        *intpart = fmath.bitCast(f64, us);
        return x;
    }

    const mask = @maxValue(u64) >> 12 >> u64(e);
    if (u & mask == 0) {
        *intpart = x;
        return fmath.bitCast(f64, us);
    }

    const uf = fmath.bitCast(f64, u & ~mask);
    *intpart = uf;
    return x - uf;
}

test "modf" {
    var ip1: f32 = undefined;
    var ip2: f32 = undefined;
    fmath.assert(modf(f32, 1.0, &ip1) == modf32(1.0, &ip2));
    fmath.assert(ip1 == ip2);

    var ip3: f64 = undefined;
    var ip4: f64 = undefined;
    fmath.assert(modf(f64, 1.0, &ip3) == modf64(1.0, &ip4));
    fmath.assert(ip3 == ip4);
}

test "modf32" {
    const epsilon = 0.000001;

    var ip: f32 = undefined;
    var r: f32 = undefined;

    r = modf32(1.0, &ip);
    fmath.assert(fmath.approxEq(f32, ip, 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, r, 0.0, epsilon));

    r = modf32(2.545, &ip);
    fmath.assert(fmath.approxEq(f32, ip, 2.0, epsilon));
    fmath.assert(fmath.approxEq(f32, r, 0.545, epsilon));

    r = modf32(3.978123, &ip);
    fmath.assert(fmath.approxEq(f32, ip, 3.0, epsilon));
    fmath.assert(fmath.approxEq(f32, r, 0.978123, epsilon));

    r = modf32(43874.3, &ip);
    fmath.assert(fmath.approxEq(f32, ip, 43874, epsilon));
    fmath.assert(fmath.approxEq(f32, r, 0.300781, epsilon));

    r = modf32(1234.340780, &ip);
    fmath.assert(fmath.approxEq(f32, ip, 1234, epsilon));
    fmath.assert(fmath.approxEq(f32, r, 0.340820, epsilon));
}

test "modf64" {
    const epsilon = 0.000001;

    var ip: f64 = undefined;
    var r: f64 = undefined;

    r = modf64(1.0, &ip);
    fmath.assert(fmath.approxEq(f64, ip, 1.0, epsilon));
    fmath.assert(fmath.approxEq(f64, r, 0.0, epsilon));

    r = modf64(2.545, &ip);
    fmath.assert(fmath.approxEq(f64, ip, 2.0, epsilon));
    fmath.assert(fmath.approxEq(f64, r, 0.545, epsilon));

    r = modf64(3.978123, &ip);
    fmath.assert(fmath.approxEq(f64, ip, 3.0, epsilon));
    fmath.assert(fmath.approxEq(f64, r, 0.978123, epsilon));

    r = modf64(43874.3, &ip);
    fmath.assert(fmath.approxEq(f64, ip, 43874, epsilon));
    fmath.assert(fmath.approxEq(f64, r, 0.3, epsilon));

    r = modf64(1234.340780, &ip);
    fmath.assert(fmath.approxEq(f64, ip, 1234, epsilon));
    fmath.assert(fmath.approxEq(f64, r, 0.340780, epsilon));
}
