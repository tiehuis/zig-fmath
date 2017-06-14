const fmath = @import("index.zig");

pub fn isInf(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            const bits = fmath.bitCast(u32, x);
            bits & 0x7FFFFFFF == 0x7F800000
        },
        f64 => {
            const bits = fmath.bitCast(u64, x);
            bits & (@maxValue(u64) >> 1) == (0x7FF << 52)
        },
        else => {
            @compileError("isInf not implemented for " ++ @typeName(T));
        },
    }
}

pub fn isPositiveInf(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            fmath.bitCast(u32, x) == 0x7F800000
        },
        f64 => {
            fmath.bitCast(u64, x) == 0x7FF << 52
        },
        else => {
            @compileError("isPositiveInf not implemented for " ++ @typeName(T));
        },
    }
}

pub fn isNegativeInf(x: var) -> bool {
    const T = @typeOf(x);
    switch (T) {
        f32 => {
            fmath.bitCast(u32, x) == 0xFF800000
        },
        f64 => {
            fmath.bitCast(u64, x) == 0xFFF << 52
        },
        else => {
            @compileError("isNegativeInf not implemented for " ++ @typeName(T));
        },
    }
}

test "isInf" {
    fmath.assert(!isInf(f32(0.0)));
    fmath.assert(!isInf(f32(-0.0)));
    fmath.assert(!isInf(f64(0.0)));
    fmath.assert(!isInf(f64(-0.0)));
    fmath.assert(isInf(fmath.inf(f32)));
    fmath.assert(isInf(-fmath.inf(f32)));
    fmath.assert(isInf(fmath.inf(f64)));
    fmath.assert(isInf(-fmath.inf(f64)));
}

test "isPositiveInf" {
    fmath.assert(!isPositiveInf(f32(0.0)));
    fmath.assert(!isPositiveInf(f32(-0.0)));
    fmath.assert(!isPositiveInf(f64(0.0)));
    fmath.assert(!isPositiveInf(f64(-0.0)));
    fmath.assert(isPositiveInf(fmath.inf(f32)));
    fmath.assert(!isPositiveInf(-fmath.inf(f32)));
    fmath.assert(isPositiveInf(fmath.inf(f64)));
    fmath.assert(!isPositiveInf(-fmath.inf(f64)));
}

test "isNegativeInf" {
    fmath.assert(!isNegativeInf(f32(0.0)));
    fmath.assert(!isNegativeInf(f32(-0.0)));
    fmath.assert(!isNegativeInf(f64(0.0)));
    fmath.assert(!isNegativeInf(f64(-0.0)));
    fmath.assert(!isNegativeInf(fmath.inf(f32)));
    fmath.assert(isNegativeInf(-fmath.inf(f32)));
    fmath.assert(!isNegativeInf(fmath.inf(f64)));
    fmath.assert(isNegativeInf(-fmath.inf(f64)));
}
