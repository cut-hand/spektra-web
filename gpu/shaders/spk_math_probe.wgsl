struct Input {
    value: array<f32>,
}

struct Output {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> input_data: Input;
@group(0) @binding(1) 
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
    let _e8 = gl_GlobalInvocationID_1;
    let _e10 = gl_NumWorkGroups_1;
    let _e15 = gl_GlobalInvocationID_1;
    return ((_e8.y * (_e10.x * 256u)) + _e15.x);
}

fn main_1() {
    var i: u32;
    var a_2: f32;
    var b_2: f32;
    var rounded: f32;
    var residual: f32;

    let _e8 = spk_global_index();
    i = _e8;
    let _e11 = i;
    let _e16 = input_data.value[(2u * _e11)];
    a_2 = _e16;
    let _e19 = i;
    let _e27 = input_data.value[((2u * _e19) + 1u)];
    b_2 = _e27;
    let _e29 = a_2;
    let _e30 = b_2;
    rounded = (_e29 * _e30);
    let _e33 = a_2;
    let _e34 = b_2;
    let _e35 = rounded;
    residual = fma(_e33, _e34, -(_e35));
    let _e39 = i;
    let _e42 = residual;
    output_data.value[_e39] = _e42;
    return;
}

@compute @workgroup_size(1, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
