struct Input {
    value: array<f32>,
}

struct Parameters {
    value: array<f32>,
}

struct Lut {
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
var<storage> lut_data: Lut;
@group(0) @binding(3) 
var<storage> count_data: Count;
@group(0) @binding(4) 
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
    let _e17 = gl_GlobalInvocationID_1;
    let _e19 = gl_NumWorkGroups_1;
    let _e24 = gl_GlobalInvocationID_1;
    return ((_e17.y * (_e19.x * 256u)) + _e24.x);
}

fn main_1() {
    var i: u32;
    var r: f32;
    var g: f32;
    var b_2: f32;
    var y: f32;
    var toe: f32;
    var shoulder: f32;
    var mapped: f32;
    var count: u32;
    var u: f32;
    var i0_: u32;
    var t_1: f32;
    var scale: f32;

    let _e17 = spk_global_index();
    i = _e17;
    let _e19 = i;
    let _e23 = count_data.value[0];
    if (_e19 >= _e23) {
        return;
    }
    let _e26 = i;
    let _e30 = input_data.value[(3u * _e26)];
    r = _e30;
    let _e33 = i;
    let _e39 = input_data.value[((3u * _e33) + 1u)];
    g = _e39;
    let _e42 = i;
    let _e48 = input_data.value[((3u * _e42) + 2u)];
    b_2 = _e48;
    let _e53 = parameters.value[0];
    let _e54 = r;
    let _e59 = parameters.value[1];
    let _e60 = g;
    let _e66 = parameters.value[2];
    let _e67 = b_2;
    y = max((((_e53 * _e54) + (_e59 * _e60)) + (_e66 * _e67)), 0f);
    let _e76 = parameters.value[5];
    toe = _e76;
    let _e81 = parameters.value[6];
    shoulder = _e81;
    let _e83 = y;
    mapped = _e83;
    let _e85 = y;
    let _e88 = y;
    let _e89 = toe;
    let _e91 = y;
    let _e92 = shoulder;
    if ((_e85 > 0f) && ((_e88 < _e89) || (_e91 > _e92))) {
        {
            let _e99 = parameters.value[7];
            count = max(u32(_e99), 2u);
            let _e104 = y;
            let _e109 = parameters.value[3];
            let _e114 = parameters.value[4];
            let _e119 = count;
            u = (clamp(((log2(_e104) - _e109) * _e114), 0f, 1f) * f32((_e119 - 1u)));
            let _e125 = u;
            let _e128 = count;
            i0_ = min(u32(floor(_e125)), (_e128 - 2u));
            let _e133 = u;
            let _e134 = i0_;
            t_1 = (_e133 - f32(_e134));
            let _e138 = i0_;
            let _e141 = lut_data.value[_e138];
            let _e142 = i0_;
            let _e147 = lut_data.value[(_e142 + 1u)];
            let _e148 = t_1;
            mapped = exp2(mix(_e141, _e147, _e148));
        }
    }
    let _e151 = mapped;
    let _e152 = y;
    scale = (_e151 / (_e152 + 0.0000000001f));
    let _e158 = i;
    let _e162 = r;
    let _e163 = scale;
    output_data.value[(3u * _e158)] = (_e162 * _e163);
    let _e166 = i;
    let _e172 = g;
    let _e173 = scale;
    output_data.value[((3u * _e166) + 1u)] = (_e172 * _e173);
    let _e176 = i;
    let _e182 = b_2;
    let _e183 = scale;
    output_data.value[((3u * _e176) + 2u)] = (_e182 * _e183);
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
