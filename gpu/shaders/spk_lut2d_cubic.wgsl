struct Coordinates {
    value: array<f32>,
}

struct Brightness {
    value: array<f32>,
}

struct Lut {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Output {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> tc_data: Coordinates;
@group(0) @binding(1) 
var<storage> brightness_data: Brightness;
@group(0) @binding(2) 
var<storage> lut_data: Lut;
@group(0) @binding(3) 
var<storage> meta_: Meta;
@group(0) @binding(4) 
var<storage, read_write> output_data: Output;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
var<private> gl_NumWorkGroups_1: vec3<u32>;

fn spk_isnan(x: f32) -> bool {
    var x_1: f32;

    x_1 = x;
    let _e2 = x_1;
    return ((bitcast<u32>(_e2) & 2147483647u) > 2139095040u);
}

fn spk_umul_extended(a: u32, b: u32, hi: ptr<function, u32>, lo: ptr<function, u32>) {
    var a_1: u32;
    var b_1: u32;
    var a0_: u32;
    var a1_: u32;
    var b0_: u32;
    var b1_: u32;
    var w0_: u32;
    var t: u32;
    var w1_: u32;
    var w2_: u32;

    a_1 = a;
    b_1 = b;
    let _e6 = a_1;
    a0_ = (_e6 & 65535u);
    let _e10 = a_1;
    a1_ = (_e10 >> 16u);
    let _e14 = b_1;
    b0_ = (_e14 & 65535u);
    let _e18 = b_1;
    b1_ = (_e18 >> 16u);
    let _e22 = a0_;
    let _e23 = b0_;
    w0_ = (_e22 * _e23);
    let _e26 = a1_;
    let _e27 = b0_;
    let _e29 = w0_;
    t = ((_e26 * _e27) + (_e29 >> 16u));
    let _e34 = t;
    w1_ = (_e34 & 65535u);
    let _e38 = t;
    w2_ = (_e38 >> 16u);
    let _e42 = w1_;
    let _e43 = a0_;
    let _e44 = b1_;
    w1_ = (_e42 + (_e43 * _e44));
    let _e47 = a1_;
    let _e48 = b1_;
    let _e50 = w2_;
    let _e52 = w1_;
    (*hi) = (((_e47 * _e48) + _e50) + (_e52 >> 16u));
    let _e56 = a_1;
    let _e57 = b_1;
    (*lo) = (_e56 * _e57);
    return;
}

fn spk_global_index() -> u32 {
    let _e17 = gl_GlobalInvocationID_1;
    let _e19 = gl_NumWorkGroups_1;
    let _e24 = gl_GlobalInvocationID_1;
    return ((_e17.y * (_e19.x * 256u)) + _e24.x);
}

fn mitchell(t_1: f32) -> f32 {
    var t_2: f32;
    var B: f32 = 0.33333334f;
    var C: f32 = 0.33333334f;
    var x_2: f32;

    t_2 = t_1;
    let _e27 = t_2;
    x_2 = abs(_e27);
    let _e30 = x_2;
    if (_e30 < 1f) {
        let _e38 = B;
        let _e42 = C;
        let _e45 = x_2;
        let _e47 = x_2;
        let _e49 = x_2;
        let _e54 = B;
        let _e58 = C;
        let _e61 = x_2;
        let _e63 = x_2;
        let _e68 = B;
        return (0.16666667f * (((((((12f - (9f * _e38)) - (6f * _e42)) * _e45) * _e47) * _e49) + ((((-18f + (12f * _e54)) + (6f * _e58)) * _e61) * _e63)) + (6f - (2f * _e68))));
    }
    let _e73 = x_2;
    if (_e73 < 2f) {
        let _e79 = B;
        let _e82 = C;
        let _e85 = x_2;
        let _e87 = x_2;
        let _e89 = x_2;
        let _e92 = B;
        let _e95 = C;
        let _e98 = x_2;
        let _e100 = x_2;
        let _e105 = B;
        let _e108 = C;
        let _e111 = x_2;
        let _e115 = B;
        let _e118 = C;
        return (0.16666667f * (((((((-(_e79) - (6f * _e82)) * _e85) * _e87) * _e89) + ((((6f * _e92) + (30f * _e95)) * _e98) * _e100)) + (((-12f * _e105) - (48f * _e108)) * _e111)) + ((8f * _e115) + (24f * _e118))));
    }
    return 0f;
}

fn safe_index(index: i32, length_: i32) -> i32 {
    var index_1: i32;
    var length_1: i32;

    index_1 = index;
    length_1 = length_;
    let _e21 = index_1;
    if (_e21 < 0i) {
        let _e24 = index_1;
        return -(_e24);
    }
    let _e26 = index_1;
    let _e27 = length_1;
    if (_e26 >= _e27) {
        let _e30 = length_1;
        let _e34 = index_1;
        return ((2i * (_e30 - 1i)) - _e34);
    }
    let _e36 = index_1;
    return _e36;
}

fn base_frac(coord: f32, length_2: i32, base: ptr<function, i32>, fraction: ptr<function, f32>) {
    var coord_1: f32;
    var length_3: i32;
    var upper: f32;

    coord_1 = coord;
    length_3 = length_2;
    let _e23 = length_3;
    upper = f32((_e23 - 1i));
    let _e28 = coord_1;
    if (_e28 <= 0f) {
        coord_1 = 0f;
    }
    let _e32 = coord_1;
    let _e33 = upper;
    if (_e32 >= _e33) {
        {
            let _e35 = length_3;
            (*base) = (_e35 - 2i);
            (*fraction) = 1f;
            return;
        }
    }
    let _e39 = coord_1;
    (*base) = i32(floor(_e39));
    let _e42 = coord_1;
    let _e43 = (*base);
    (*fraction) = (_e42 - f32(_e43));
    return;
}

fn main_1() {
    var i: u32;
    var length_4: u32;
    var scale: f32;
    var x_3: f32;
    var y: f32;
    var xbase: i32;
    var ybase: i32;
    var xf: f32;
    var yf: f32;
    var wx: array<f32, 4>;
    var wy: array<f32, 4>;
    var accumulated: vec3<f32> = vec3(0f);
    var weight_sum: f32 = 0f;
    var a_2: i32 = 0i;
    var xi: i32;
    var b_2: i32;
    var yj: i32;
    var weight: f32;
    var offset: u32;
    var brightness: f32;

    let _e17 = spk_global_index();
    i = _e17;
    let _e22 = meta_.value[0];
    length_4 = _e22;
    let _e24 = i;
    let _e28 = meta_.value[1];
    if (_e24 >= _e28) {
        return;
    }
    let _e30 = length_4;
    scale = f32((_e30 - 1u));
    let _e37 = i;
    let _e42 = tc_data.value[(2u * _e37)];
    let _e43 = scale;
    x_3 = (_e42 * _e43);
    let _e47 = i;
    let _e55 = tc_data.value[((2u * _e47) + 1u)];
    let _e56 = scale;
    y = (_e55 * _e56);
    let _e63 = x_3;
    let _e64 = length_4;
    base_frac(_e63, i32(_e64), (&xbase), (&xf));
    let _e70 = y;
    let _e71 = length_4;
    base_frac(_e70, i32(_e71), (&ybase), (&yf));
    let _e77 = xf;
    let _e80 = mitchell((_e77 + 1f));
    let _e81 = xf;
    let _e82 = mitchell(_e81);
    let _e83 = xf;
    let _e86 = mitchell((_e83 - 1f));
    let _e87 = xf;
    let _e90 = mitchell((_e87 - 2f));
    wx = array<f32, 4>(_e80, _e82, _e86, _e90);
    let _e93 = yf;
    let _e96 = mitchell((_e93 + 1f));
    let _e97 = yf;
    let _e98 = mitchell(_e97);
    let _e99 = yf;
    let _e102 = mitchell((_e99 - 1f));
    let _e103 = yf;
    let _e106 = mitchell((_e103 - 2f));
    wy = array<f32, 4>(_e96, _e98, _e102, _e106);
    loop {
        let _e116 = a_2;
        if !((_e116 < 4i)) {
            break;
        }
        {
            let _e123 = xbase;
            let _e126 = a_2;
            let _e128 = length_4;
            let _e130 = safe_index(((_e123 - 1i) + _e126), i32(_e128));
            xi = _e130;
            b_2 = 0i;
            loop {
                let _e134 = b_2;
                if !((_e134 < 4i)) {
                    break;
                }
                {
                    let _e141 = ybase;
                    let _e144 = b_2;
                    let _e146 = length_4;
                    let _e148 = safe_index(((_e141 - 1i) + _e144), i32(_e146));
                    yj = _e148;
                    let _e150 = a_2;
                    let _e152 = wx[_e150];
                    let _e153 = b_2;
                    let _e155 = wy[_e153];
                    weight = (_e152 * _e155);
                    let _e158 = weight_sum;
                    let _e159 = weight;
                    weight_sum = (_e158 + _e159);
                    let _e162 = xi;
                    let _e164 = length_4;
                    let _e166 = yj;
                    offset = (3u * ((u32(_e162) * _e164) + u32(_e166)));
                    let _e172 = accumulated;
                    let _e173 = weight;
                    let _e174 = offset;
                    let _e177 = lut_data.value[_e174];
                    let _e178 = offset;
                    let _e184 = lut_data.value[(_e178 + 1u)];
                    let _e185 = offset;
                    let _e191 = lut_data.value[(_e185 + 2u)];
                    accumulated = (_e172 + (_e173 * vec3<f32>(_e177, _e184, _e191)));
                }
                continuing {
                    let _e138 = b_2;
                    b_2 = (_e138 + 1i);
                }
            }
        }
        continuing {
            let _e120 = a_2;
            a_2 = (_e120 + 1i);
        }
    }
    let _e195 = weight_sum;
    if (_e195 != 0f) {
        let _e198 = accumulated;
        let _e199 = weight_sum;
        accumulated = (_e198 / vec3(_e199));
    }
    let _e202 = i;
    let _e205 = brightness_data.value[_e202];
    brightness = _e205;
    let _e208 = i;
    let _e213 = accumulated;
    let _e215 = brightness;
    output_data.value[(3u * _e208)] = (_e213.x * _e215);
    let _e218 = i;
    let _e226 = accumulated;
    let _e228 = brightness;
    output_data.value[((3u * _e218) + 1u)] = (_e226.y * _e228);
    let _e231 = i;
    let _e239 = accumulated;
    let _e241 = brightness;
    output_data.value[((3u * _e231) + 2u)] = (_e239.z * _e241);
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
