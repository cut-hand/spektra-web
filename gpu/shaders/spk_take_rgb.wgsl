struct Input {
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
var<storage> meta_: Meta;
@group(0) @binding(2) 
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
    let _e11 = gl_GlobalInvocationID_1;
    let _e13 = gl_NumWorkGroups_1;
    let _e18 = gl_GlobalInvocationID_1;
    return ((_e11.y * (_e13.x * 256u)) + _e18.x);
}

fn main_1() {
    var i: u32;
    var n: u32;
    var channels: u32;
    var c: u32 = 0u;

    let _e11 = spk_global_index();
    i = _e11;
    let _e16 = meta_.value[0];
    n = _e16;
    let _e21 = meta_.value[1];
    channels = _e21;
    let _e23 = i;
    let _e24 = n;
    if (_e23 >= _e24) {
        return;
    }
    loop {
        let _e29 = c;
        if !((_e29 < 3u)) {
            break;
        }
        let _e38 = i;
        let _e41 = c;
        let _e45 = channels;
        let _e46 = i;
        let _e48 = c;
        let _e52 = input_data.value[((_e45 * _e46) + _e48)];
        output_data.value[((3u * _e38) + _e41)] = _e52;
        continuing {
            let _e34 = c;
            c = (_e34 + 1u);
        }
    }
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
