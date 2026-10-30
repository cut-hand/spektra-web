struct Input {
    value: array<f32>,
}

struct Parameters {
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
var<storage> parameters: Parameters;
@group(0) @binding(2) 
var<storage> count_data: Count;
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
    var x_2: f32;
    var raw_x0_: f32;
    var inv_max_raw: f32;
    var a_2: f32;
    var boost_scale: f32;
    var dx: f32;

    let _e14 = spk_global_index();
    i = _e14;
    let _e16 = i;
    let _e20 = count_data.value[0];
    if (_e16 >= _e20) {
        return;
    }
    let _e22 = i;
    let _e25 = input_data.value[_e22];
    x_2 = _e25;
    let _e30 = parameters.value[0];
    raw_x0_ = _e30;
    let _e35 = parameters.value[1];
    inv_max_raw = _e35;
    let _e40 = parameters.value[2];
    a_2 = _e40;
    let _e45 = parameters.value[3];
    boost_scale = _e45;
    let _e47 = x_2;
    let _e48 = raw_x0_;
    if (_e47 <= _e48) {
        {
            let _e50 = i;
            let _e53 = x_2;
            output_data.value[_e50] = _e53;
            return;
        }
    }
    let _e54 = x_2;
    let _e55 = raw_x0_;
    let _e57 = inv_max_raw;
    dx = ((_e54 - _e55) * _e57);
    let _e60 = i;
    let _e63 = x_2;
    let _e64 = boost_scale;
    let _e65 = a_2;
    let _e66 = dx;
    let _e69 = a_2;
    let _e70 = dx;
    output_data.value[_e60] = (_e63 + (_e64 * ((exp((_e65 * _e66)) - (_e69 * _e70)) - 1f)));
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
