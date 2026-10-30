struct B0_ {
    x: array<f32>,
}

struct B1_ {
    p: array<f32>,
}

struct B2_ {
    n: array<u32>,
}

struct B3_ {
    dst: array<f32>,
}

@group(0) @binding(0) 
var<storage> global: B0_;
@group(0) @binding(1) 
var<storage> global_1: B1_;
@group(0) @binding(2) 
var<storage> global_2: B2_;
@group(0) @binding(3) 
var<storage, read_write> global_3: B3_;
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

fn spk_pow(x_2: f32, y: f32) -> f32 {
    var x_3: f32;
    var y_1: f32;

    x_3 = x_2;
    y_1 = y;
    let _e4 = x_3;
    let _e5 = y_1;
    return pow(_e4, _e5);
}

fn spk_pow_1(x_4: vec3<f32>, y_2: f32) -> vec3<f32> {
    var x_5: vec3<f32>;
    var y_3: f32;

    x_5 = x_4;
    y_3 = y_2;
    let _e4 = x_5;
    let _e5 = y_3;
    return pow(_e4, vec3(_e5));
}

fn spk_log10_(x_6: f32) -> f32 {
    var x_7: f32;

    x_7 = x_6;
    let _e2 = x_7;
    return (log(_e2) * 0.4342945f);
}

fn spk_log10_1(x_8: vec3<f32>) -> vec3<f32> {
    var x_9: vec3<f32>;

    x_9 = x_8;
    let _e2 = x_9;
    return (log(_e2) * 0.4342945f);
}

fn spk_fmod(x_10: f32, y_4: f32) -> f32 {
    var x_11: f32;
    var y_5: f32;

    x_11 = x_10;
    y_5 = y_4;
    let _e4 = x_11;
    let _e5 = y_5;
    let _e6 = x_11;
    let _e7 = y_5;
    return (_e4 - (_e5 * trunc((_e6 / _e7))));
}

fn spk_isfinite(x_12: f32) -> bool {
    var x_13: f32;

    x_13 = x_12;
    let _e2 = x_13;
    return ((bitcast<u32>(_e2) & 2147483647u) < 2139095040u);
}

fn spk_smoothstep01_(t_1: f32) -> f32 {
    var t_2: f32;

    t_2 = t_1;
    let _e10 = t_2;
    t_2 = clamp(_e10, 0f, 1f);
    let _e14 = t_2;
    let _e15 = t_2;
    let _e19 = t_2;
    return ((_e14 * _e15) * (3f - (2f * _e19)));
}

fn main_1() {
    var i: u32;
    var v: vec3<f32>;
    var m: f32;
    var g: f32 = 1f;
    var lm: f32;
    var near_clip: f32;
    var over_floor: f32;

    let _e10 = gl_GlobalInvocationID_1;
    let _e12 = gl_NumWorkGroups_1;
    let _e17 = gl_GlobalInvocationID_1;
    i = ((_e10.y * (_e12.x * 256u)) + _e17.x);
    let _e21 = i;
    let _e24 = global_2.n[0];
    if (_e21 >= _e24) {
        return;
    }
    let _e27 = i;
    let _e31 = global.x[(3u * _e27)];
    let _e33 = i;
    let _e40 = global.x[((3u * _e33) + 1u)];
    let _e42 = i;
    let _e49 = global.x[((3u * _e42) + 2u)];
    v = vec3<f32>(_e31, _e40, _e49);
    let _e52 = v;
    let _e54 = v;
    let _e56 = v;
    m = max(_e52.x, max(_e54.y, _e56.z));
    let _e63 = m;
    if (_e63 > 0f) {
        {
            let _e66 = m;
            lm = log2(_e66);
            let _e69 = lm;
            let _e72 = global_1.p[0];
            let _e77 = global_1.p[1];
            let _e81 = global_1.p[2];
            let _e83 = spk_smoothstep01_((((_e69 + log2(_e72)) - _e77) * _e81));
            near_clip = _e83;
            let _e85 = lm;
            let _e88 = global_1.p[4];
            let _e93 = global_1.p[5];
            let _e97 = global_1.p[6];
            let _e99 = spk_smoothstep01_((((_e85 + log2(_e88)) - _e93) * _e97));
            over_floor = _e99;
            let _e103 = global_1.p[3];
            let _e104 = near_clip;
            let _e106 = over_floor;
            g = exp2(((_e103 * _e104) * _e106));
        }
    }
    let _e110 = i;
    let _e114 = v;
    let _e116 = g;
    global_3.dst[(3u * _e110)] = (_e114.x * _e116);
    let _e119 = i;
    let _e126 = v;
    let _e128 = g;
    global_3.dst[((3u * _e119) + 1u)] = (_e126.y * _e128);
    let _e131 = i;
    let _e138 = v;
    let _e140 = g;
    global_3.dst[((3u * _e131) + 2u)] = (_e138.z * _e140);
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
