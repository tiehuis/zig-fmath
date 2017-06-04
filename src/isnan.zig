const fmath = @import("index.zig");

pub fn isNan(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            const bits = fmath.bitCast(u32, x);
            bits & 0x7FFFFFFF > 0x7F800000
        },
        f64 => {
            const bits = fmath.bitCast(u64, x);
            (bits & (@maxValue(u64) >> 1)) > (u64(0x7FF) << 52)
        },
        else => {
            @compileError("isFinite not implemented for " ++ @typeName(T));
        },
    }
}

test "isNan" {
    fmath.assert(isNan(fmath.nan(f32)));
    fmath.assert(isNan(fmath.nan(f64)));
    fmath.assert(!isNan(f32(1.0)));
    fmath.assert(!isNan(f64(1.0)));
}
