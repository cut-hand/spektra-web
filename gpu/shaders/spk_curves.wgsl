struct Input {
    value: array<f32>,
}

struct XAxis {
    value: array<f32>,
}

struct InverseSteps {
    value: array<f32>,
}

struct YAxis {
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
var<storage> x_axis: XAxis;
@group(0) @binding(2) 
var<storage> inverse_steps: InverseSteps;
@group(0) @binding(3) 
var<storage> y_axis: YAxis;
@group(0) @binding(4) 
var<storage> meta_: Meta;
@group(0) @binding(5) 
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
    let _e20 = gl_GlobalInvocationID_1;
    let _e22 = gl_NumWorkGroups_1;
    let _e27 = gl_GlobalInvocationID_1;
    return ((_e20.y * (_e22.x * 256u)) + _e27.x);
}

fn interpolate(count: u32, channel: u32, value: f32) -> f32 {
    var count_1: u32;
    var channel_1: u32;
    var value_1: f32;
    var x0_: f32;
    var x_last: f32;
    var lo_1: u32 = 0u;
    var hi_1: u32;
    var mid: u32;
    var low: u32;
    var fraction: f32;
    var y0_: f32;
    var y1_: f32;

    count_1 = count;
    channel_1 = channel;
    value_1 = value;
    let _e26 = channel_1;
    let _e29 = x_axis.value[_e26];
    x0_ = _e29;
    let _e31 = count_1;
    let _e36 = channel_1;
    let _e40 = x_axis.value[(((_e31 - 1u) * 3u) + _e36)];
    x_last = _e40;
    let _e42 = value_1;
    let _e43 = x0_;
    if (_e42 <= _e43) {
        let _e45 = channel_1;
        let _e48 = y_axis.value[_e45];
        return _e48;
    }
    let _e49 = value_1;
    let _e50 = x_last;
    if (_e49 >= _e50) {
        let _e52 = count_1;
        let _e57 = channel_1;
        let _e61 = y_axis.value[(((_e52 - 1u) * 3u) + _e57)];
        return _e61;
    }
    let _e64 = count_1;
    hi_1 = _e64;
    loop {
        let _e66 = lo_1;
        let _e67 = hi_1;
        if !((_e66 < _e67)) {
            break;
        }
        {
            let _e70 = lo_1;
            let _e71 = hi_1;
            let _e72 = lo_1;
            mid = (_e70 + ((_e71 - _e72) >> 1u));
            let _e78 = mid;
            let _e81 = channel_1;
            let _e85 = x_axis.value[((_e78 * 3u) + _e81)];
            let _e86 = value_1;
            if (_e85 <= _e86) {
                let _e88 = mid;
                lo_1 = (_e88 + 1u);
            } else {
                let _e91 = mid;
                hi_1 = _e91;
            }
        }
    }
    let _e92 = lo_1;
    low = (_e92 - 1u);
    let _e96 = value_1;
    let _e97 = low;
    let _e100 = channel_1;
    let _e104 = x_axis.value[((_e97 * 3u) + _e100)];
    let _e106 = low;
    let _e109 = channel_1;
    let _e113 = inverse_steps.value[((_e106 * 3u) + _e109)];
    fraction = ((_e96 - _e104) * _e113);
    let _e116 = low;
    let _e119 = channel_1;
    let _e123 = y_axis.value[((_e116 * 3u) + _e119)];
    y0_ = _e123;
    let _e125 = low;
    let _e130 = channel_1;
    let _e134 = y_axis.value[(((_e125 + 1u) * 3u) + _e130)];
    y1_ = _e134;
    let _e136 = y0_;
    let _e137 = fraction;
    let _e138 = y1_;
    let _e139 = y0_;
    return (_e136 + (_e137 * (_e138 - _e139)));
}

fn main_1() {
    var pixel: u32;
    var count_2: u32;
    var channel_2: u32 = 0u;

    let _e20 = spk_global_index();
    pixel = _e20;
    let _e25 = meta_.value[0];
    count_2 = _e25;
    let _e27 = pixel;
    let _e31 = meta_.value[1];
    if (_e27 >= _e31) {
        return;
    }
    loop {
        let _e35 = channel_2;
        if !((_e35 < 3u)) {
            break;
        }
        let _e43 = pixel;
        let _e45 = channel_2;
        let _e49 = count_2;
        let _e50 = channel_2;
        let _e52 = pixel;
        let _e54 = channel_2;
        let _e58 = input_data.value[((3u * _e52) + _e54)];
        let _e59 = interpolate(_e49, _e50, _e58);
        output_data.value[((3u * _e43) + _e45)] = _e59;
        continuing {
            let _e39 = channel_2;
            channel_2 = (_e39 + 1u);
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
