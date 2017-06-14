const fmath = @import("index.zig");

pub fn inf(comptime T: type) -> T {
    switch (T) {
        f32 => @bitCast(f32, fmath.inf_u32),
        f64 => @bitCast(f64, fmath.inf_u64),
        else => @compileError("inf not implemented for " ++ @typeName(T)),
    }
}
