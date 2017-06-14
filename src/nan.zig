const fmath = @import("index.zig");

pub fn nan(comptime T: type) -> T {
    switch (T) {
        f32 => @bitCast(f32, fmath.nan_u32),
        f64 => @bitCast(f64, fmath.nan_u64),
        else => @compileError("nan not implemented for " ++ @typeName(T)),
    }
}
