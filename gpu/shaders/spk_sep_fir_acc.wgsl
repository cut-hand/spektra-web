struct Input {
    value: array<f32>,
}

struct Weights {
    value: array<f32>,
}

struct Accumulator {
    value: array<f32>,
}

struct MixWeights {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Output {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> image_data: Input;
@group(0) @binding(1) 
var<storage> weights: Weights;
@group(0) @binding(2) 
var<storage> accumulator: Accumulator;
@group(0) @binding(3) 
var<storage> mix_weights: MixWeights;
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

fn reflect_index(index: i32, length_: i32) -> i32 {
    var index_1: i32;
    var length_1: i32;
    var local: u32;
    var folded: u32;
    var period: u32;
    var j: u32;
    var local_1: u32;

    index_1 = index;
    length_1 = length_;
    let _e24 = index_1;
    if (_e24 < 0i) {
        let _e27 = index_1;
        local = u32(-((_e27 + 1i)));
    } else {
        let _e32 = index_1;
        local = u32(_e32);
    }
    let _e35 = local;
    folded = _e35;
    let _e38 = length_1;
    period = (2u * u32(_e38));
    let _e42 = folded;
    let _e43 = period;
    j = (_e42 % _e43);
    let _e46 = j;
    let _e47 = length_1;
    if (_e46 >= u32(_e47)) {
        let _e50 = period;
        let _e53 = j;
        local_1 = ((_e50 - 1u) - _e53);
    } else {
        let _e55 = j;
        local_1 = _e55;
    }
    let _e57 = local_1;
    return i32(_e57);
}

fn mirror_index(index_2: i32, length_2: i32) -> i32 {
    var index_3: i32;
    var length_3: i32;
    var local_2: u32;
    var folded_1: u32;
    var period_1: u32;
    var j_1: u32;
    var local_3: u32;

    index_3 = index_2;
    length_3 = length_2;
    let _e24 = length_3;
    if (_e24 <= 1i) {
        return 0i;
    }
    let _e28 = index_3;
    if (_e28 < 0i) {
        let _e31 = index_3;
        local_2 = (u32(-((_e31 + 1i))) + 1u);
    } else {
        let _e38 = index_3;
        local_2 = u32(_e38);
    }
    let _e41 = local_2;
    folded_1 = _e41;
    let _e44 = length_3;
    period_1 = (2u * u32((_e44 - 1i)));
    let _e50 = folded_1;
    let _e51 = period_1;
    j_1 = (_e50 % _e51);
    let _e54 = j_1;
    let _e55 = length_3;
    if (_e54 >= u32(_e55)) {
        let _e58 = period_1;
        let _e59 = j_1;
        local_3 = (_e58 - _e59);
    } else {
        let _e61 = j_1;
        local_3 = _e61;
    }
    let _e63 = local_3;
    return i32(_e63);
}

fn main_1() {
    var pixel: u32;
    var height: u32;
    var width: u32;
    var radius: i32;
    var axis: u32;
    var accumulate: u32;
    var mirror: u32;
    var y: u32;
    var x_2: u32;
    var local_4: i32;
    var length_4: i32;
    var local_5: i32;
    var base: i32;
    var taps: u32;
    var sum: vec3<f32> = vec3(0f);
    var k: i32;
    var local_6: i32;
    var j_2: i32;
    var local_7: u32;
    var source: u32;
    var tap: u32;
    var sample_value: vec3<f32>;
    var weight: vec3<f32>;

    let _e20 = spk_global_index();
    pixel = _e20;
    let _e25 = meta_.value[0];
    height = _e25;
    let _e30 = meta_.value[1];
    width = _e30;
    let _e32 = pixel;
    let _e33 = height;
    let _e34 = width;
    if (_e32 >= (_e33 * _e34)) {
        return;
    }
    let _e40 = meta_.value[2];
    radius = i32(_e40);
    let _e46 = meta_.value[3];
    axis = _e46;
    let _e51 = meta_.value[4];
    accumulate = _e51;
    let _e56 = meta_.value[5];
    mirror = _e56;
    let _e58 = pixel;
    let _e59 = width;
    y = (_e58 / _e59);
    let _e62 = pixel;
    let _e63 = width;
    x_2 = (_e62 % _e63);
    let _e66 = axis;
    if (_e66 == 0u) {
        let _e69 = height;
        local_4 = i32(_e69);
    } else {
        let _e71 = width;
        local_4 = i32(_e71);
    }
    let _e74 = local_4;
    length_4 = _e74;
    let _e76 = axis;
    if (_e76 == 0u) {
        let _e79 = y;
        local_5 = i32(_e79);
    } else {
        let _e81 = x_2;
        local_5 = i32(_e81);
    }
    let _e84 = local_5;
    base = _e84;
    let _e87 = radius;
    taps = u32(((2i * _e87) + 1i));
    let _e96 = radius;
    k = -(_e96);
    loop {
        let _e99 = k;
        let _e100 = radius;
        if !((_e99 <= _e100)) {
            break;
        }
        {
            let _e106 = mirror;
            if (_e106 != 0u) {
                let _e109 = base;
                let _e110 = k;
                let _e112 = length_4;
                let _e113 = mirror_index((_e109 + _e110), _e112);
                local_6 = _e113;
            } else {
                let _e114 = base;
                let _e115 = k;
                let _e117 = length_4;
                let _e118 = reflect_index((_e114 + _e115), _e117);
                local_6 = _e118;
            }
            let _e120 = local_6;
            j_2 = _e120;
            let _e122 = axis;
            if (_e122 == 0u) {
                let _e125 = j_2;
                let _e127 = width;
                let _e129 = x_2;
                local_7 = ((u32(_e125) * _e127) + _e129);
            } else {
                let _e131 = y;
                let _e132 = width;
                let _e134 = j_2;
                local_7 = ((_e131 * _e132) + u32(_e134));
            }
            let _e138 = local_7;
            source = _e138;
            let _e140 = k;
            let _e141 = radius;
            tap = u32((_e140 + _e141));
            let _e146 = source;
            let _e151 = image_data.value[(3u * _e146)];
            let _e153 = source;
            let _e161 = image_data.value[((3u * _e153) + 1u)];
            let _e163 = source;
            let _e171 = image_data.value[((3u * _e163) + 2u)];
            sample_value = vec3<f32>(_e151, _e161, _e171);
            let _e174 = tap;
            let _e177 = weights.value[_e174];
            let _e178 = taps;
            let _e179 = tap;
            let _e183 = weights.value[(_e178 + _e179)];
            let _e185 = taps;
            let _e188 = tap;
            let _e192 = weights.value[((2u * _e185) + _e188)];
            weight = vec3<f32>(_e177, _e183, _e192);
            let _e195 = sum;
            let _e196 = sample_value;
            let _e197 = weight;
            sum = (_e195 + (_e196 * _e197));
        }
        continuing {
            let _e103 = k;
            k = (_e103 + 1i);
        }
    }
    let _e200 = accumulate;
    if (_e200 != 0u) {
        let _e204 = pixel;
        let _e209 = accumulator.value[(3u * _e204)];
        let _e211 = pixel;
        let _e219 = accumulator.value[((3u * _e211) + 1u)];
        let _e221 = pixel;
        let _e229 = accumulator.value[((3u * _e221) + 2u)];
        let _e231 = sum;
        let _e235 = mix_weights.value[0];
        let _e239 = mix_weights.value[1];
        let _e243 = mix_weights.value[2];
        sum = (vec3<f32>(_e209, _e219, _e229) + (_e231 * vec3<f32>(_e235, _e239, _e243)));
    }
    let _e248 = pixel;
    let _e253 = sum;
    output_data.value[(3u * _e248)] = _e253.x;
    let _e256 = pixel;
    let _e264 = sum;
    output_data.value[((3u * _e256) + 1u)] = _e264.y;
    let _e267 = pixel;
    let _e275 = sum;
    output_data.value[((3u * _e267) + 2u)] = _e275.z;
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
