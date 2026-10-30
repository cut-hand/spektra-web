struct Input {
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
var<storage> count_data: Count;
@group(0) @binding(2) 
var<storage, read_write> output_data: Output;
var<workgroup> scratch: array<f32, 256>;
var<private> gl_LocalInvocationID_1: vec3<u32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
var<private> gl_NumWorkGroups_1: vec3<u32>;
var<private> gl_WorkGroupID_1: vec3<u32>;

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

fn main_1() {
    var local_id: u32;
    var best: f32;
    var grid_size: u32;
    var i: u32;
    var stride: u32 = 128u;

    let _e11 = gl_LocalInvocationID_1;
    local_id = _e11.x;
    let _e16 = gl_GlobalInvocationID_1;
    best = bitcast<f32>((4286578688u | (_e16.x & 0u)));
    let _e24 = gl_NumWorkGroups_1;
    grid_size = (_e24.x * 256u);
    let _e29 = gl_GlobalInvocationID_1;
    i = _e29.x;
    loop {
        let _e32 = i;
        let _e36 = count_data.value[0];
        if !((_e32 < _e36)) {
            break;
        }
        let _e42 = best;
        let _e43 = i;
        let _e46 = input_data.value[_e43];
        best = max(_e42, _e46);
        continuing {
            let _e39 = i;
            let _e40 = grid_size;
            i = (_e39 + _e40);
        }
    }
    let _e48 = local_id;
    let _e50 = best;
    scratch[_e48] = _e50;
    workgroupBarrier();
    loop {
        let _e55 = stride;
        if !((_e55 > 0u)) {
            break;
        }
        {
            let _e62 = local_id;
            let _e63 = stride;
            if (_e62 < _e63) {
                let _e65 = local_id;
                let _e67 = local_id;
                let _e69 = scratch[_e67];
                let _e70 = local_id;
                let _e71 = stride;
                let _e74 = scratch[(_e70 + _e71)];
                scratch[_e65] = max(_e69, _e74);
            }
            workgroupBarrier();
        }
        continuing {
            let _e59 = stride;
            stride = (_e59 >> 1u);
        }
    }
    let _e76 = local_id;
    if (_e76 == 0u) {
        let _e80 = gl_WorkGroupID_1;
        let _e86 = scratch[0];
        output_data.value[_e80.x] = _e86;
        return;
    } else {
        return;
    }
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(local_invocation_id) gl_LocalInvocationID: vec3<u32>, @builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>) {
    gl_LocalInvocationID_1 = gl_LocalInvocationID;
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    gl_WorkGroupID_1 = gl_WorkGroupID;
    main_1();
    return;
}
