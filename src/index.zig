const std = @import("std");
const builtin = @import("builtin");

pub const TypeId = builtin.TypeId;
pub const printf = std.io.stdout.printf;
pub const assert = std.debug.assert;

pub const e         = 2.7182818284590452354;  // e
pub const log2_e    = 1.4426950408889634074;  // log_2(e)
pub const log10_e   = 0.43429448190325182765; // log_10(e)
pub const ln_2      = 0.69314718055994530942; // log_e(2)
pub const ln_10     = 2.30258509299404568402; // log_e(10)
pub const pi        = 3.14159265358979323846; // pi
pub const pi_2      = 1.57079632679489661923; // pi/2
pub const pi_4      = 0.78539816339744830962; // pi/4
pub const r1_pi     = 0.31830988618379067154; // 1/pi
pub const r2_pi     = 0.63661977236758134308; // 2/pi
pub const r2_sqrtpi = 1.12837916709551257390; // 2/sqrt(pi)
pub const sqrt2     = 1.41421356237309504880; // sqrt(2)
pub const r1_sqrt2  = 0.70710678118654752440; // 1/sqrt(2)

// float.h details
pub const f64_true_min = 4.94065645841246544177e-324;
pub const f64_min = 2.22507385850720138309e-308;
pub const f64_max = 1.79769313486231570815e+308;
pub const f64_epsilon = 2.22044604925031308085e-16;
pub const f64_toint = 1.0 / f64_epsilon;

pub const f32_true_min = 1.40129846432481707092e-45;
pub const f32_min = 1.17549435082228750797e-38;
pub const f32_max = 3.40282346638528859812e+38;
pub const f32_epsilon = 1.1920928955078125e-07;
pub const f32_toint = 1.0 / f32_epsilon;

pub const nan_u32 = u32(0x7F800001);
pub const nan_f32 = @bitCast(f32, nan_u32);

pub const inf_u32 = u32(0x7F800000);
pub const inf_f32 = @bitCast(f32, inf_u32);

pub const nan_u64 = u64(0x7FF << 52) | 1;
pub const nan_f64 = @bitCast(f64, nan_u64);

pub const inf_u64 = u64(0x7FF << 52);
pub const inf_f64 = @bitCast(f64, inf_u64);

pub const nan = @import("nan.zig").nan;
pub const inf = @import("inf.zig").inf;

pub fn forceEval(value: var) {
    const T = @typeOf(value);
    switch (T) {
        f32 => {
            var x: f32 = undefined;
            const p = @ptrCast(&volatile f32, &x);
            *p = x;
        },
        f64 => {
            var x: f64 = undefined;
            const p = @ptrCast(&volatile f64, &x);
            *p = x;
        },
        else => {
            @compileError("forceEval not implemented for " ++ @typeName(T));
        },
    }
}

pub fn approxEq(comptime T: type, x: T, y: T, epsilon: T) -> bool {
    assert(@typeId(T) == TypeId.Float);
    fabs(x - y) < epsilon
}

pub fn raiseInvalid() {
    // Raise INVALID fpu exception
}

pub fn raiseUnderflow() {
    // Raise UNDERFLOW fpu exception
}

pub fn raiseOverflow() {
    // Raise OVERFLOW fpu exception
}

pub fn raiseInexact() {
    // Raise INEXACT fpu exception
}

pub fn raiseDivByZero() {
    // Raise INEXACT fpu exception
}

pub const io = @import("io.zig");

pub const isNan = @import("isnan.zig").isNan;
pub const fabs = @import("fabs.zig").fabs;
pub const ceil = @import("ceil.zig").ceil;
pub const floor = @import("floor.zig").floor;
pub const trunc = @import("floor.zig").trunc;
pub const round = @import("round.zig").round;
pub const frexp = @import("frexp.zig").frexp;
pub const frexp32_result = @import("frexp.zig").frexp32_result;
pub const frexp64_result = @import("frexp.zig").frexp64_result;
pub const fmod = @import("fmod.zig").fmod;
pub const modf = @import("modf.zig").modf;
pub const modf32_result = @import("modf.zig").modf32_result;
pub const modf64_result = @import("modf.zig").modf64_result;
pub const copysign = @import("copysign.zig").copysign;
pub const isFinite = @import("isfinite.zig").isFinite;
pub const isInf = @import("isinf.zig").isInf;
pub const isPositiveInf = @import("isinf.zig").isPositiveInf;
pub const isNegativeInf = @import("isinf.zig").isNegativeInf;
pub const isNormal = @import("isnormal.zig").isNormal;
pub const signbit = @import("signbit.zig").signbit;
pub const scalbn = @import("scalbn.zig").scalbn;
pub const pow = @import("pow.zig").pow;
pub const sqrt = @import("sqrt.zig").sqrt;
pub const cbrt = @import("cbrt.zig").cbrt;
pub const acos = @import("acos.zig").acos;
pub const asin = @import("asin.zig").asin;
pub const atan = @import("atan.zig").atan;
pub const atan2 = @import("atan2.zig").atan2;
pub const hypot = @import("hypot.zig").hypot;
pub const exp = @import("exp.zig").exp;
pub const exp2 = @import("exp2.zig").exp2;
pub const expm1 = @import("expm1.zig").expm1;
pub const ilogb = @import("ilogb.zig").ilogb;
pub const log = @import("log.zig").log;
pub const log2 = @import("log2.zig").log2;
pub const log10 = @import("log10.zig").log10;
pub const log1p = @import("log1p.zig").log1p;
pub const fma = @import("fma.zig").fma;
pub const asinh = @import("asinh.zig").asinh;
pub const acosh = @import("acosh.zig").acosh;
pub const atanh = @import("atanh.zig").atanh;
pub const sinh = @import("sinh.zig").sinh;
pub const cosh = @import("cosh.zig").cosh;
pub const tanh = @import("tanh.zig").tanh;
pub const cos = @import("cos.zig").cos;
pub const sin = @import("sin.zig").sin;
pub const tan = @import("tan.zig").tan;

test "fmath" {
    _ = @import("io.zig");
    _ = @import("nan.zig");
    _ = @import("isnan.zig");
    _ = @import("fabs.zig");
    _ = @import("ceil.zig");
    _ = @import("floor.zig");
    _ = @import("trunc.zig");
    _ = @import("round.zig");
    _ = @import("frexp.zig");
    _ = @import("fmod.zig");
    _ = @import("modf.zig");
    _ = @import("copysign.zig");
    _ = @import("isfinite.zig");
    _ = @import("isinf.zig");
    _ = @import("isnormal.zig");
    _ = @import("signbit.zig");
    _ = @import("scalbn.zig");
    _ = @import("pow.zig");
    _ = @import("sqrt.zig");
    _ = @import("cbrt.zig");
    _ = @import("acos.zig");
    _ = @import("asin.zig");
    _ = @import("atan.zig");
    _ = @import("atan2.zig");
    _ = @import("hypot.zig");
    _ = @import("exp.zig");
    _ = @import("exp2.zig");
    _ = @import("expm1.zig");
    _ = @import("ilogb.zig");
    _ = @import("log.zig");
    _ = @import("log2.zig");
    _ = @import("log10.zig");
    _ = @import("log1p.zig");
    _ = @import("fma.zig");
    _ = @import("asinh.zig");
    _ = @import("acosh.zig");
    _ = @import("atanh.zig");
    _ = @import("sinh.zig");
    _ = @import("cosh.zig");
    _ = @import("tanh.zig");
    _ = @import("sin.zig");
    _ = @import("cos.zig");
    _ = @import("tan.zig");
}
