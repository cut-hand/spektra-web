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

fn signed_power(value: f32, exponent: f32) -> f32 {
    var value_1: f32;
    var exponent_1: f32;
    var local: f32;
    var local_1: f32;
    var sign_value: f32;

    value_1 = value;
    exponent_1 = exponent;
    let _e15 = value_1;
    if (_e15 < 0f) {
        local_1 = -1f;
    } else {
        let _e20 = value_1;
        if (_e20 > 0f) {
            local = 1f;
        } else {
            local = 0f;
        }
        let _e26 = local;
        local_1 = _e26;
    }
    let _e28 = local_1;
    sign_value = _e28;
    let _e30 = sign_value;
    let _e31 = value_1;
    let _e33 = exponent_1;
    return (_e30 * pow(abs(_e31), _e33));
}

fn decode(value_2: f32, mode: u32) -> f32 {
    var value_3: f32;
    var mode_1: u32;
    var local_2: f32;
    var local_3: f32;
    var local_4: f32;
    var alpha: f32 = 1.099f;
    var beta: f32 = 0.018f;
    var breakpoint: f32;
    var local_5: f32;

    value_3 = value_2;
    mode_1 = mode;
    let _e15 = mode_1;
    if (_e15 == 0u) {
        let _e19 = value_3;
        if (0.040449936f >= _e19) {
            let _e21 = value_3;
            local_2 = (_e21 / 12.92f);
        } else {
            let _e24 = value_3;
            let _e30 = signed_power(((_e24 + 0.055f) / 1.055f), 2.4f);
            local_2 = _e30;
        }
        let _e32 = local_2;
        return _e32;
    }
    let _e33 = mode_1;
    if (_e33 == 1u) {
        let _e36 = value_3;
        if (_e36 < 0.03125f) {
            let _e43 = value_3;
            local_3 = (_e43 / 16f);
        } else {
            let _e46 = value_3;
            local_3 = pow(_e46, 1.8f);
        }
        let _e50 = local_3;
        return _e50;
    }
    let _e51 = mode_1;
    if (_e51 == 2u) {
        let _e54 = value_3;
        if (_e54 < 0f) {
            let _e58 = value_3;
            local_4 = bitcast<f32>((2143289344u | (bitcast<u32>(_e58) & 4194303u)));
        } else {
            let _e64 = value_3;
            local_4 = pow(_e64, 2.1992188f);
        }
        let _e70 = local_4;
        return _e70;
    }
    let _e71 = mode_1;
    if (_e71 == 3u) {
        {
            let _e78 = alpha;
            let _e79 = beta;
            let _e83 = alpha;
            breakpoint = ((_e78 * pow(_e79, 0.45f)) - (_e83 - 1f));
            let _e88 = breakpoint;
            let _e89 = value_3;
            if (_e88 > _e89) {
                let _e91 = value_3;
                local_5 = (_e91 / 4.5f);
            } else {
                let _e94 = value_3;
                let _e95 = alpha;
                let _e99 = alpha;
                let _e104 = signed_power(((_e94 + (_e95 - 1f)) / _e99), 2.2222223f);
                local_5 = _e104;
            }
            let _e106 = local_5;
            return _e106;
        }
    }
    let _e107 = value_3;
    return _e107;
}

fn main_1() {
    var i: u32;

    let _e11 = spk_global_index();
    i = _e11;
    let _e13 = i;
    let _e17 = meta_.value[0];
    if (_e13 >= _e17) {
        return;
    }
    let _e19 = i;
    let _e22 = i;
    let _e25 = input_data.value[_e22];
    let _e29 = meta_.value[1];
    let _e30 = decode(_e25, _e29);
    output_data.value[_e19] = _e30;
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
