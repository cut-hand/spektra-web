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

fn signed_power(value: f32, exponent: f32) -> f32 {
    var value_1: f32;
    var exponent_1: f32;
    var local: f32;
    var local_1: f32;
    var sign_value: f32;

    value_1 = value;
    exponent_1 = exponent;
    let _e18 = value_1;
    if (_e18 < 0f) {
        local_1 = -1f;
    } else {
        let _e23 = value_1;
        if (_e23 > 0f) {
            local = 1f;
        } else {
            local = 0f;
        }
        let _e29 = local;
        local_1 = _e29;
    }
    let _e31 = local_1;
    sign_value = _e31;
    let _e33 = sign_value;
    let _e34 = value_1;
    let _e36 = exponent_1;
    return (_e33 * pow(abs(_e34), _e36));
}

fn encode(value_2: f32, mode: u32) -> f32 {
    var value_3: f32;
    var mode_1: u32;
    var local_2: f32;
    var local_3: f32;
    var alpha: f32 = 1.099f;
    var beta: f32 = 0.018f;
    var local_4: f32;

    value_3 = value_2;
    mode_1 = mode;
    let _e18 = mode_1;
    if (_e18 == 0u) {
        let _e21 = value_3;
        if (_e21 <= 0.0031308f) {
            let _e25 = value_3;
            local_2 = (12.92f * _e25);
        } else {
            let _e28 = value_3;
            let _e32 = signed_power(_e28, 0.41666666f);
            local_2 = ((1.055f * _e32) - 0.055f);
        }
        let _e37 = local_2;
        return _e37;
    }
    let _e38 = mode_1;
    if (_e38 == 1u) {
        let _e41 = value_3;
        if (_e41 < 0.001953125f) {
            let _e46 = value_3;
            local_3 = (_e46 * 16f);
        } else {
            let _e49 = value_3;
            local_3 = pow(_e49, 0.5555556f);
        }
        let _e55 = local_3;
        return _e55;
    }
    let _e56 = mode_1;
    if (_e56 == 2u) {
        let _e59 = value_3;
        return pow(_e59, 0.45470694f);
    }
    let _e64 = mode_1;
    if (_e64 == 3u) {
        {
            let _e71 = beta;
            let _e72 = value_3;
            if (_e71 > _e72) {
                let _e74 = value_3;
                local_4 = (_e74 * 4.5f);
            } else {
                let _e77 = alpha;
                let _e78 = value_3;
                let _e80 = signed_power(_e78, 0.45f);
                let _e82 = alpha;
                local_4 = ((_e77 * _e80) - (_e82 - 1f));
            }
            let _e87 = local_4;
            return _e87;
        }
    }
    let _e88 = value_3;
    return _e88;
}

fn main_1() {
    var pixel: u32;
    var a_2: f32;
    var b_2: f32;
    var c: f32;
    var v: array<f32, 3>;
    var channel: u32 = 0u;

    let _e14 = spk_global_index();
    pixel = _e14;
    let _e16 = pixel;
    let _e20 = meta_.value[0];
    if (_e16 >= _e20) {
        return;
    }
    let _e23 = pixel;
    let _e27 = input_data.value[(3u * _e23)];
    a_2 = _e27;
    let _e30 = pixel;
    let _e36 = input_data.value[((3u * _e30) + 1u)];
    b_2 = _e36;
    let _e39 = pixel;
    let _e45 = input_data.value[((3u * _e39) + 2u)];
    c = _e45;
    let _e47 = a_2;
    let _e51 = matrix_data.value[0];
    let _e53 = b_2;
    let _e57 = matrix_data.value[3];
    let _e60 = c;
    let _e64 = matrix_data.value[6];
    let _e67 = a_2;
    let _e71 = matrix_data.value[1];
    let _e73 = b_2;
    let _e77 = matrix_data.value[4];
    let _e80 = c;
    let _e84 = matrix_data.value[7];
    let _e87 = a_2;
    let _e91 = matrix_data.value[2];
    let _e93 = b_2;
    let _e97 = matrix_data.value[5];
    let _e100 = c;
    let _e104 = matrix_data.value[8];
    v = array<f32, 3>((((_e47 * _e51) + (_e53 * _e57)) + (_e60 * _e64)), (((_e67 * _e71) + (_e73 * _e77)) + (_e80 * _e84)), (((_e87 * _e91) + (_e93 * _e97)) + (_e100 * _e104)));
    loop {
        let _e111 = channel;
        if !((_e111 < 3u)) {
            break;
        }
        let _e119 = pixel;
        let _e121 = channel;
        let _e125 = channel;
        let _e127 = v[_e125];
        let _e131 = meta_.value[1];
        let _e132 = encode(_e127, _e131);
        output_data.value[((3u * _e119) + _e121)] = _e132;
        continuing {
            let _e115 = channel;
            channel = (_e115 + 1u);
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
