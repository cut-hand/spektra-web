struct Input {
    value: array<f32>,
}

struct Characteristic {
    value: array<f32>,
}

struct Base {
    value: array<f32>,
}

struct Integral {
    value: array<f32>,
}

struct Epilogue {
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
var<storage> characteristic: Characteristic;
@group(0) @binding(2) 
var<storage> base_data: Base;
@group(0) @binding(3) 
var<storage> integral_data: Integral;
@group(0) @binding(4) 
var<storage> epilogue: Epilogue;
@group(0) @binding(5) 
var<storage> meta_: Meta;
@group(0) @binding(6) 
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
    let _e23 = gl_GlobalInvocationID_1;
    let _e25 = gl_NumWorkGroups_1;
    let _e30 = gl_GlobalInvocationID_1;
    return ((_e23.y * (_e25.x * 256u)) + _e30.x);
}

fn main_1() {
    var pixel: u32;
    var c0_: f32;
    var c1_: f32;
    var c2_: f32;
    var accumulated: vec3<f32> = vec3(0f);
    var wavelength: u32 = 0u;
    var density: f32;
    var transmission: f32;
    var channel: u32 = 0u;
    var value: f32;

    let _e23 = spk_global_index();
    pixel = _e23;
    let _e25 = pixel;
    let _e29 = meta_.value[0];
    if (_e25 >= _e29) {
        return;
    }
    let _e32 = pixel;
    let _e36 = input_data.value[(3u * _e32)];
    c0_ = _e36;
    let _e39 = pixel;
    let _e45 = input_data.value[((3u * _e39) + 1u)];
    c1_ = _e45;
    let _e48 = pixel;
    let _e54 = input_data.value[((3u * _e48) + 2u)];
    c2_ = _e54;
    loop {
        let _e61 = wavelength;
        let _e65 = meta_.value[1];
        if !((_e61 < _e65)) {
            break;
        }
        {
            let _e71 = c0_;
            let _e73 = wavelength;
            let _e77 = characteristic.value[(3u * _e73)];
            let _e79 = c1_;
            let _e81 = wavelength;
            let _e87 = characteristic.value[((3u * _e81) + 1u)];
            let _e90 = c2_;
            let _e92 = wavelength;
            let _e98 = characteristic.value[((3u * _e92) + 2u)];
            let _e101 = wavelength;
            let _e104 = base_data.value[_e101];
            density = ((((_e71 * _e77) + (_e79 * _e87)) + (_e90 * _e98)) + _e104);
            let _e107 = density;
            transmission = exp2((-(_e107) * 3.321928f));
            let _e114 = accumulated;
            let _e116 = transmission;
            let _e118 = wavelength;
            let _e122 = integral_data.value[(3u * _e118)];
            accumulated.x = (_e114.x + (_e116 * _e122));
            let _e126 = accumulated;
            let _e128 = transmission;
            let _e130 = wavelength;
            let _e136 = integral_data.value[((3u * _e130) + 1u)];
            accumulated.y = (_e126.y + (_e128 * _e136));
            let _e140 = accumulated;
            let _e142 = transmission;
            let _e144 = wavelength;
            let _e150 = integral_data.value[((3u * _e144) + 2u)];
            accumulated.z = (_e140.z + (_e142 * _e150));
        }
        continuing {
            let _e68 = wavelength;
            wavelength = (_e68 + 1u);
        }
    }
    loop {
        let _e155 = channel;
        if !((_e155 < 3u)) {
            break;
        }
        {
            let _e162 = channel;
            let _e164 = accumulated[_e162];
            let _e165 = channel;
            let _e168 = epilogue.value[_e165];
            let _e171 = channel;
            let _e175 = epilogue.value[(3u + _e171)];
            value = (max(((_e164 * _e168) + _e175), 0f) + 0.0000000001f);
            let _e185 = meta_.value[2];
            if (_e185 == 0u) {
                let _e188 = value;
                value = (log(_e188) * 0.4342945f);
            }
            let _e193 = pixel;
            let _e195 = channel;
            let _e199 = value;
            output_data.value[((3u * _e193) + _e195)] = _e199;
        }
        continuing {
            let _e159 = channel;
            channel = (_e159 + 1u);
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
