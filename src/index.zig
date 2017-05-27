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

// Insufficient comptime support for floating points cast?
pub const nan_u64 = u64((0x7FF << 52) | 1);
pub const inf_u64 = u64(0x7FF << 52);
pub const nan = @import("nan.zig").nan;
pub const inf = @import("inf.zig").inf;

pub fn forceEval(value: var) {
    var _ = value;
    // Should evaluate the input expression for its side-effects and not be optimized out.
}

pub fn bitCast(comptime DestType: type, value: var) -> DestType {
    assert(@sizeOf(DestType) == @sizeOf(@typeOf(value)));
    return *@ptrCast(&const DestType, &value);
}


// Re-export all internal functions
pub const isnan = @import("isnan.zig").isnan;
pub const fabs = @import("fabs.zig").fabs;
pub const ceil = @import("ceil.zig").ceil;
pub const floor = @import("floor.zig").floor;
pub const trunc = @import("floor.zig").trunc;
pub const round = @import("round.zig").round;
pub const isfinite = @import("isfinite.zig").isfinite;
pub const isinf = @import("isinf.zig").isinf;
pub const isnormal = @import("isnormal.zig").isnormal;
pub const signbit = @import("signbit.zig").signbit;
pub const scalbn = @import("scalbn.zig").scalbn;

// Re-export all functions
test "fmath" {
    _ = @import("nan.zig");
    _ = @import("isnan.zig");
    _ = @import("fabs.zig");
    _ = @import("ceil.zig");
    _ = @import("floor.zig");
    _ = @import("trunc.zig");
    _ = @import("round.zig");
    _ = @import("isfinite.zig");
    _ = @import("isinf.zig");
    _ = @import("isnormal.zig");
    _ = @import("signbit.zig");
    _ = @import("scalbn.zig");
}
