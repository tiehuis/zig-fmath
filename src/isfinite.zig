const fmath = @import("index.zig");

pub fn isFinite(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            const bits = @bitCast(u32, x);
            bits & 0x7FFFFFFF < 0x7F800000
        },
        f64 => {
            const bits = @bitCast(u64, x);
            bits & (@maxValue(u64) >> 1) < (0x7FF << 52)
        },
        else => {
            @compileError("isFinite not implemented for " ++ @typeName(T));
        },
    }
}

test "isFinite" {
    fmath.assert(isFinite(f32(0.0)));
    fmath.assert(isFinite(f32(-0.0)));
    fmath.assert(isFinite(f64(0.0)));
    fmath.assert(isFinite(f64(-0.0)));
    fmath.assert(!isFinite(fmath.inf(f32)));
    fmath.assert(!isFinite(-fmath.inf(f32)));
    fmath.assert(!isFinite(fmath.inf(f64)));
    fmath.assert(!isFinite(-fmath.inf(f64)));
}
