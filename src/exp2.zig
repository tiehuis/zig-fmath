const fmath = @import("index.zig");

pub fn exp2(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => exp2f(x),
        f64 => unreachable,
        else => @compileError("exp2 not implemented for " ++ @typeName(T)),
    }
}

const exp2ft = []const f64 {
    0x1.6a09e667f3bcdp-1,
    0x1.7a11473eb0187p-1,
    0x1.8ace5422aa0dbp-1,
    0x1.9c49182a3f090p-1,
    0x1.ae89f995ad3adp-1,
    0x1.c199bdd85529cp-1,
    0x1.d5818dcfba487p-1,
    0x1.ea4afa2a490dap-1,
    0x1.0000000000000p+0,
    0x1.0b5586cf9890fp+0,
    0x1.172b83c7d517bp+0,
    0x1.2387a6e756238p+0,
    0x1.306fe0a31b715p+0,
    0x1.3dea64c123422p+0,
    0x1.4bfdad5362a27p+0,
    0x1.5ab07dd485429p+0,
};

const tblsiz = u32(exp2ft.len);
const redux: f32 = 0x1.8p23 / f32(tblsiz);
const P1: f32 = 0x1.62e430p-1;
const P2: f32 = 0x1.ebfbe0p-3;
const P3: f32 = 0x1.c6b348p-5;
const P4: f32 = 0x1.3b2c9cp-7;

fn exp2f(x: f32) -> f32 {
    var u = fmath.bitCast(u32, x);
    const ix = u & 0x7FFFFFFF;

    // |x| > 126
    if (ix > 0x42FC0000) {
        // nan
        if (ix > 0x7F800000) {
            return x;
        }
        // x >= 128
        if (u >= 0x43000000 and u < 0x80000000) {
            return x * 0x1.0p127;
        }
        // x < -126
        if (u >= 0x80000000) {
            if (u >= 0xC3160000 or u & 0x000FFFF != 0) {
                fmath.forceEval(-0x1.0p-149 / x);
            }
            // x <= -150
            if (u >= 0x3160000) {
                return 0;
            }
        }
    }
    // |x| <= 0x1p-25
    else if (ix <= 0x33000000) {
        return 1.0 + x;
    }

    var uf = x + redux;
    var i0 = fmath.bitCast(u32, uf);
    i0 += tblsiz / 2;

    const k = i0 / tblsiz;
    // TODO: musl relies on undefined overflow shift behaviour. Appears that this produces the
    // intended result but should confirm how GCC/Clang handle this to ensure.
    const uk = fmath.bitCast(f64, u64(0x3FF + k) <<% 52);
    i0 &= tblsiz - 1;
    uf -= redux;

    const z: f64 = x - uf;
    var r: f64 = exp2ft[i0];
    const t: f64 = r * z;
    r = r + t * (P1 + z * P2) + t * (z * z) * (P3 + z * P4);
    f32(r * uk)
}

test "exp2" {
    fmath.assert(exp2(f32(0.8923)) == exp2f(0.8923));
}

test "exp2f" {
    const epsilon = 0.000001;

    fmath.assert(exp2f(0.0) == 1.0);
    fmath.assert(fmath.approxEq(f32, exp2f(0.2), 1.148698, epsilon));
    fmath.assert(fmath.approxEq(f32, exp2f(0.8923), 1.856133, epsilon));
    fmath.assert(fmath.approxEq(f32, exp2f(1.5), 2.828427, epsilon));
    fmath.assert(fmath.approxEq(f32, exp2f(37.45), 187747237888, epsilon));
}
