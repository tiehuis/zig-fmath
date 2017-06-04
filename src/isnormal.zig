const fmath = @import("index.zig");

pub fn isNormal(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            const bits = fmath.bitCast(u32, x);
            (bits + 0x00800000) & 0x7FFFFFFF >= 0x01000000
        },
        f64 => {
            const bits = fmath.bitCast(u64, x);
            (bits + (1 << 52)) & (@maxValue(u64) >> 1) >= (1 << 53)
        },
        else => {
            @compileError("isFinite not implemented for " ++ @typeName(T));
        },
    }
}

test "isNormal" {
    fmath.assert(!isNormal(fmath.nan(f32)));
    fmath.assert(!isNormal(fmath.nan(f64)));
    fmath.assert(isNormal(f32(1.0)));
    fmath.assert(isNormal(f64(1.0)));
}
