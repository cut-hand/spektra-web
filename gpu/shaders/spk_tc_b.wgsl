struct Input {
    value: array<f32>,
}

struct Matrix {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Coordinates {
    value: array<f32>,
}

struct Brightness {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> rgb_data: Input;
@group(0) @binding(1) 
var<storage> matrix_data: Matrix;
@group(0) @binding(2) 
var<storage> meta_: Meta;
@group(0) @binding(3) 
var<storage, read_write> tc_data: Coordinates;
@group(0) @binding(4) 
var<storage, read_write> brightness_data: Brightness;
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

fn main_1() {
    var i: u32;
    var r: f32;
    var g: f32;
    var blue: f32;
    var X: f32;
    var Y: f32;
    var Z: f32;
    var brightness: f32;
    var local: f32;
    var denom: f32;
    var x_2: f32;
    var y: f32;
    var one_minus_x: f32;
    var local_1: f32;
    var ty: f32;
    var tx: f32;
    var local_2: f32;

    let _e17 = spk_global_index();
    i = _e17;
    let _e19 = i;
    let _e23 = meta_.value[0];
    if (_e19 >= _e23) {
        return;
    }
    let _e26 = i;
    let _e31 = rgb_data.value[(3u * _e26)];
    r = _e31;
    let _e34 = i;
    let _e42 = rgb_data.value[((3u * _e34) + 1u)];
    g = _e42;
    let _e45 = i;
    let _e53 = rgb_data.value[((3u * _e45) + 2u)];
    blue = _e53;
    let _e58 = matrix_data.value[0];
    let _e59 = r;
    let _e64 = matrix_data.value[1];
    let _e65 = g;
    let _e71 = matrix_data.value[2];
    let _e72 = blue;
    X = (((_e58 * _e59) + (_e64 * _e65)) + (_e71 * _e72));
    let _e79 = matrix_data.value[3];
    let _e80 = r;
    let _e85 = matrix_data.value[4];
    let _e86 = g;
    let _e92 = matrix_data.value[5];
    let _e93 = blue;
    Y = (((_e79 * _e80) + (_e85 * _e86)) + (_e92 * _e93));
    let _e100 = matrix_data.value[6];
    let _e101 = r;
    let _e106 = matrix_data.value[7];
    let _e107 = g;
    let _e113 = matrix_data.value[8];
    let _e114 = blue;
    Z = (((_e100 * _e101) + (_e106 * _e107)) + (_e113 * _e114));
    let _e118 = X;
    let _e119 = Y;
    let _e121 = Z;
    brightness = ((_e118 + _e119) + _e121);
    let _e124 = brightness;
    if (_e124 > 0.0000000001f) {
        let _e127 = brightness;
        local = _e127;
    } else {
        local = 0.0000000001f;
    }
    let _e130 = local;
    denom = _e130;
    let _e132 = X;
    let _e133 = denom;
    x_2 = (_e132 / _e133);
    let _e136 = Y;
    let _e137 = denom;
    y = (_e136 / _e137);
    let _e141 = x_2;
    one_minus_x = (1f - _e141);
    let _e144 = y;
    let _e145 = one_minus_x;
    if (_e145 > 0.0000000001f) {
        let _e148 = one_minus_x;
        local_1 = _e148;
    } else {
        local_1 = 0.0000000001f;
    }
    let _e151 = local_1;
    ty = (_e144 / _e151);
    let _e154 = one_minus_x;
    let _e155 = one_minus_x;
    tx = (_e154 * _e155);
    let _e159 = i;
    let _e164 = tx;
    tc_data.value[(2u * _e159)] = clamp(_e164, 0f, 1f);
    let _e169 = i;
    let _e177 = ty;
    tc_data.value[((2u * _e169) + 1u)] = clamp(_e177, 0f, 1f);
    let _e181 = i;
    let _e184 = brightness;
    let _e185 = spk_isnan(_e184);
    if _e185 {
        local_2 = 0f;
    } else {
        let _e187 = brightness;
        local_2 = _e187;
    }
    let _e189 = local_2;
    brightness_data.value[_e181] = _e189;
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
