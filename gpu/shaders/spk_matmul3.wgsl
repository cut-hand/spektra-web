struct Input {
    value: array<f32>,
}

struct Matrix {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Output {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> input_data: Input;
@group(0) @binding(1) 
var<storage> matrix_data: Matrix;
@group(0) @binding(2) 
var<storage> meta_: Meta;
@group(0) @binding(3) 
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
    let _e14 = gl_GlobalInvocationID_1;
    let _e16 = gl_NumWorkGroups_1;
    let _e21 = gl_GlobalInvocationID_1;
    return ((_e14.y * (_e16.x * 256u)) + _e21.x);
}

fn main_1() {
    var i: u32;
    var a_2: f32;
    var b_2: f32;
    var c: f32;

    let _e14 = spk_global_index();
    i = _e14;
    let _e16 = i;
    let _e20 = meta_.value[0];
    if (_e16 >= _e20) {
        return;
    }
    let _e23 = i;
    let _e28 = input_data.value[(3u * _e23)];
    a_2 = _e28;
    let _e31 = i;
    let _e39 = input_data.value[((3u * _e31) + 1u)];
    b_2 = _e39;
    let _e42 = i;
    let _e50 = input_data.value[((3u * _e42) + 2u)];
    c = _e50;
    let _e53 = i;
    let _e58 = a_2;
    let _e62 = matrix_data.value[0];
    let _e64 = b_2;
    let _e68 = matrix_data.value[3];
    let _e71 = c;
    let _e75 = matrix_data.value[6];
    output_data.value[(3u * _e53)] = (((_e58 * _e62) + (_e64 * _e68)) + (_e71 * _e75));
    let _e79 = i;
    let _e87 = a_2;
    let _e91 = matrix_data.value[1];
    let _e93 = b_2;
    let _e97 = matrix_data.value[4];
    let _e100 = c;
    let _e104 = matrix_data.value[7];
    output_data.value[((3u * _e79) + 1u)] = (((_e87 * _e91) + (_e93 * _e97)) + (_e100 * _e104));
    let _e108 = i;
    let _e116 = a_2;
    let _e120 = matrix_data.value[2];
    let _e122 = b_2;
    let _e126 = matrix_data.value[5];
    let _e129 = c;
    let _e133 = matrix_data.value[8];
    output_data.value[((3u * _e108) + 2u)] = (((_e116 * _e120) + (_e122 * _e126)) + (_e129 * _e133));
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
