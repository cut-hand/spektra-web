struct Input {
    value: array<f32>,
}

struct Matrix {
    value: array<f32>,
}

struct DMax {
    value: array<f32>,
}

struct Positive {
    value: array<u32>,
}

struct Shift {
    value: array<f32>,
}

struct Count {
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
var<storage> dmax_data: DMax;
@group(0) @binding(3) 
var<storage> positive_data: Positive;
@group(0) @binding(4) 
var<storage> shift_data: Shift;
@group(0) @binding(5) 
var<storage> count_data: Count;
@group(0) @binding(6) 
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
    let _e23 = gl_GlobalInvocationID_1;
    let _e25 = gl_NumWorkGroups_1;
    let _e30 = gl_GlobalInvocationID_1;
    return ((_e23.y * (_e25.x * 256u)) + _e30.x);
}

fn main_1() {
    var pixel: u32;
    var c: vec3<f32>;
    var shift: f32;

    let _e23 = spk_global_index();
    pixel = _e23;
    let _e25 = pixel;
    let _e29 = count_data.value[0];
    if (_e25 >= _e29) {
        return;
    }
    let _e32 = pixel;
    let _e36 = input_data.value[(3u * _e32)];
    let _e38 = pixel;
    let _e44 = input_data.value[((3u * _e38) + 1u)];
    let _e46 = pixel;
    let _e52 = input_data.value[((3u * _e46) + 2u)];
    c = vec3<f32>(_e36, _e44, _e52);
    let _e58 = positive_data.value[0];
    if (_e58 != 0u) {
        let _e64 = dmax_data.value[0];
        let _e68 = dmax_data.value[1];
        let _e72 = dmax_data.value[2];
        let _e74 = c;
        c = (vec3<f32>(_e64, _e68, _e72) - _e74);
    }
    let _e79 = shift_data.value[0];
    shift = _e79;
    let _e81 = c;
    let _e82 = shift;
    let _e83 = c;
    let _e85 = c;
    c = (_e81 + ((_e82 * _e83) * _e85));
    let _e89 = pixel;
    let _e93 = c;
    let _e98 = matrix_data.value[0];
    let _e100 = c;
    let _e105 = matrix_data.value[3];
    let _e108 = c;
    let _e113 = matrix_data.value[6];
    output_data.value[(3u * _e89)] = (((_e93.x * _e98) + (_e100.y * _e105)) + (_e108.z * _e113));
    let _e117 = pixel;
    let _e123 = c;
    let _e128 = matrix_data.value[1];
    let _e130 = c;
    let _e135 = matrix_data.value[4];
    let _e138 = c;
    let _e143 = matrix_data.value[7];
    output_data.value[((3u * _e117) + 1u)] = (((_e123.x * _e128) + (_e130.y * _e135)) + (_e138.z * _e143));
    let _e147 = pixel;
    let _e153 = c;
    let _e158 = matrix_data.value[2];
    let _e160 = c;
    let _e165 = matrix_data.value[5];
    let _e168 = c;
    let _e173 = matrix_data.value[8];
    output_data.value[((3u * _e147) + 2u)] = (((_e153.x * _e158) + (_e160.y * _e165)) + (_e168.z * _e173));
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
