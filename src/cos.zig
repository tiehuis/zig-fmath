const fmath = @import("index.zig");

pub fn cos(x: var) -> @typeOf(x) {
    const T = @typeOf(x);
    switch (T) {
        f32 => cos32(x),
        f64 => cos64(x),
        else => @compileError("cos not implemented for " ++ @typeName(T)),
    }
}

// sin polynomial coefficients
const S0 =  1.58962301576546568060E-10;
const S1 = -2.50507477628578072866E-8;
const S2 =  2.75573136213857245213E-6;
const S3 = -1.98412698295895385996E-4;
const S4 =  8.33333333332211858878E-3;
const S5 = -1.66666666666666307295E-1;

// cos polynomial coeffiecients
const C0 = -1.13585365213876817300E-11;
const C1 =  2.08757008419747316778E-9;
const C2 = -2.75573141792967388112E-7;
const C3 =  2.48015872888517045348E-5;
const C4 = -1.38888888888730564116E-3;
const C5 =  4.16666666666665929218E-2;

// NOTE: This is taken from the go stdlib. The musl implementation is much more complex.
//
// This may have slight differences on some edge cases and may need to replaced if so.
fn cos32(x_: f32) -> f32 {
    const pi4a = 7.85398125648498535156e-1;
    const pi4b = 3.77489470793079817668E-8;
    const pi4c = 2.69515142907905952645E-15;
    const m4pi = 1.273239544735162542821171882678754627704620361328125;

    var x = x_;
    if (fmath.isNan(x) or fmath.isInf(x)) {
        return fmath.nan(f32);
    }

    var sign = false;
    if (x < 0) {
        x = -x;
    }

    var y = fmath.floor(x * m4pi);
    var j = i64(y);

    if (j & 1 == 1) {
        j += 1;
        y += 1;
    }

    j &= 7;
    if (j > 3) {
        j -= 4;
        sign = !sign;
    }
    if (j > 1) {
        sign = !sign;
    }

    const z = ((x - y * pi4a) - y * pi4b) - y * pi4c;
    const w = z * z;

    const r = {
        if (j == 1 or j == 2) {
            z + z * w * (S5 + w * (S4 + w * (S3 + w * (S2 + w * (S1 + w * S0)))))
        } else {
            1.0 - 0.5 * w + w * w * (C5 + w * (C4 + w * (C3 + w * (C2 + w * (C1 + w * C0)))))
        }
    };

    if (sign) {
        -r
    } else {
        r
    }
}

fn cos64(x_: f64) -> f64 {
    const pi4a = 7.85398125648498535156e-1;
    const pi4b = 3.77489470793079817668E-8;
    const pi4c = 2.69515142907905952645E-15;
    const m4pi = 1.273239544735162542821171882678754627704620361328125;

    var x = x_;
    if (fmath.isNan(x) or fmath.isInf(x)) {
        return fmath.nan(f64);
    }

    var sign = false;
    if (x < 0) {
        x = -x;
    }

    var y = fmath.floor(x * m4pi);
    var j = i64(y);

    if (j & 1 == 1) {
        j += 1;
        y += 1;
    }

    j &= 7;
    if (j > 3) {
        j -= 4;
        sign = !sign;
    }
    if (j > 1) {
        sign = !sign;
    }

    const z = ((x - y * pi4a) - y * pi4b) - y * pi4c;
    const w = z * z;

    const r = {
        if (j == 1 or j == 2) {
            z + z * w * (S5 + w * (S4 + w * (S3 + w * (S2 + w * (S1 + w * S0)))))
        } else {
            1.0 - 0.5 * w + w * w * (C5 + w * (C4 + w * (C3 + w * (C2 + w * (C1 + w * C0)))))
        }
    };

    if (sign) {
        -r
    } else {
        r
    }
}

test "cos" {
    fmath.assert(cos(f32(0.0)) == cos32(0.0));
    fmath.assert(cos(f64(0.0)) == cos64(0.0));
}

test "cos32" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f32, cos32(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f32, cos32(0.2), 0.980067, epsilon));
    fmath.assert(fmath.approxEq(f32, cos32(0.8923), 0.627623, epsilon));
    fmath.assert(fmath.approxEq(f32, cos32(1.5), 0.070737, epsilon));
    fmath.assert(fmath.approxEq(f32, cos32(37.45), 0.969132, epsilon));
    fmath.assert(fmath.approxEq(f32, cos32(89.123), 0.400798, epsilon));
}

test "cos64" {
    const epsilon = 0.000001;

    fmath.assert(fmath.approxEq(f64, cos64(0.0), 1.0, epsilon));
    fmath.assert(fmath.approxEq(f64, cos64(0.2), 0.980067, epsilon));
    fmath.assert(fmath.approxEq(f64, cos64(0.8923), 0.627623, epsilon));
    fmath.assert(fmath.approxEq(f64, cos64(1.5), 0.070737, epsilon));
    fmath.assert(fmath.approxEq(f64, cos64(37.45), 0.969132, epsilon));
    fmath.assert(fmath.approxEq(f64, cos64(89.123), 0.40080, epsilon));
}
