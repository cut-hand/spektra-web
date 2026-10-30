struct Density {
    value: array<f32>,
}

struct Lut {
    value: array<f32>,
}

struct Lower {
    value: array<f32>,
}

struct InverseSpan {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Output {
    value: array<f32>,
}

@group(0) @binding(0) 
var<storage> density: Density;
@group(0) @binding(1) 
var<storage> lut_data: Lut;
@group(0) @binding(2) 
var<storage> lower: Lower;
@group(0) @binding(3) 
var<storage> inverse_span: InverseSpan;
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

fn metal_clamp01_(x_2: f32) -> f32 {
    var x_3: f32;

    x_3 = x_2;
    let _e22 = x_3;
    let _e23 = spk_isnan(_e22);
    let _e24 = x_3;
    if (_e23 || (_e24 < 0f)) {
        return 0f;
    }
    let _e29 = x_3;
    if (_e29 > 1f) {
        return 1f;
    }
    let _e33 = x_3;
    return _e33;
}

fn main_1() {
    var gid: u32;
    var size: u32;
    var scale: f32;
    var c0_: f32;
    var c1_: f32;
    var c2_: f32;
    var i0_: u32;
    var j0_: u32;
    var k0_: u32;
    var i1_: u32;
    var j1_: u32;
    var k1_: u32;
    var fx: f32;
    var fy: f32;
    var fz: f32;
    var b00_: u32;
    var b01_: u32;
    var b10_: u32;
    var b11_: u32;
    var k0_offset: u32;
    var k1_offset: u32;
    var w0_1: f32;
    var w1_1: f32;
    var v0_: f32;
    var v1_: f32;
    var u0_: f32;
    var u1_: f32;
    var channel: u32 = 0u;
    var c00_: f32;
    var c01_: f32;
    var c10_: f32;
    var c11_: f32;
    var result: f32;

    let _e20 = spk_global_index();
    gid = _e20;
    let _e22 = gid;
    let _e26 = meta_.value[0];
    if (_e22 >= _e26) {
        return;
    }
    let _e31 = meta_.value[1];
    size = _e31;
    let _e33 = size;
    scale = f32((_e33 - 1u));
    let _e39 = gid;
    let _e43 = density.value[(3u * _e39)];
    let _e47 = lower.value[0];
    let _e52 = inverse_span.value[0];
    c0_ = ((_e43 - _e47) * _e52);
    let _e56 = gid;
    let _e62 = density.value[((3u * _e56) + 1u)];
    let _e66 = lower.value[1];
    let _e71 = inverse_span.value[1];
    c1_ = ((_e62 - _e66) * _e71);
    let _e75 = gid;
    let _e81 = density.value[((3u * _e75) + 2u)];
    let _e85 = lower.value[2];
    let _e90 = inverse_span.value[2];
    c2_ = ((_e81 - _e85) * _e90);
    let _e93 = c0_;
    let _e94 = metal_clamp01_(_e93);
    let _e95 = scale;
    c0_ = (_e94 * _e95);
    let _e97 = c1_;
    let _e98 = metal_clamp01_(_e97);
    let _e99 = scale;
    c1_ = (_e98 * _e99);
    let _e101 = c2_;
    let _e102 = metal_clamp01_(_e101);
    let _e103 = scale;
    c2_ = (_e102 * _e103);
    let _e105 = c0_;
    i0_ = u32(floor(_e105));
    let _e109 = c1_;
    j0_ = u32(floor(_e109));
    let _e113 = c2_;
    k0_ = u32(floor(_e113));
    let _e117 = i0_;
    let _e120 = size;
    i1_ = min((_e117 + 1u), (_e120 - 1u));
    let _e125 = j0_;
    let _e128 = size;
    j1_ = min((_e125 + 1u), (_e128 - 1u));
    let _e133 = k0_;
    let _e136 = size;
    k1_ = min((_e133 + 1u), (_e136 - 1u));
    let _e141 = c0_;
    let _e142 = i0_;
    fx = (_e141 - f32(_e142));
    let _e146 = c1_;
    let _e147 = j0_;
    fy = (_e146 - f32(_e147));
    let _e151 = c2_;
    let _e152 = k0_;
    fz = (_e151 - f32(_e152));
    let _e156 = i0_;
    let _e157 = size;
    let _e159 = j0_;
    let _e161 = size;
    b00_ = ((((_e156 * _e157) + _e159) * _e161) * 3u);
    let _e166 = i0_;
    let _e167 = size;
    let _e169 = j1_;
    let _e171 = size;
    b01_ = ((((_e166 * _e167) + _e169) * _e171) * 3u);
    let _e176 = i1_;
    let _e177 = size;
    let _e179 = j0_;
    let _e181 = size;
    b10_ = ((((_e176 * _e177) + _e179) * _e181) * 3u);
    let _e186 = i1_;
    let _e187 = size;
    let _e189 = j1_;
    let _e191 = size;
    b11_ = ((((_e186 * _e187) + _e189) * _e191) * 3u);
    let _e196 = k0_;
    k0_offset = (_e196 * 3u);
    let _e200 = k1_;
    k1_offset = (_e200 * 3u);
    let _e205 = fx;
    w0_1 = (1f - _e205);
    let _e208 = fx;
    w1_1 = _e208;
    let _e211 = fy;
    v0_ = (1f - _e211);
    let _e214 = fy;
    v1_ = _e214;
    let _e217 = fz;
    u0_ = (1f - _e217);
    let _e220 = fz;
    u1_ = _e220;
    loop {
        let _e224 = channel;
        if !((_e224 < 3u)) {
            break;
        }
        {
            let _e231 = b00_;
            let _e232 = k0_offset;
            let _e234 = channel;
            let _e238 = lut_data.value[((_e231 + _e232) + _e234)];
            let _e239 = u0_;
            let _e241 = b00_;
            let _e242 = k1_offset;
            let _e244 = channel;
            let _e248 = lut_data.value[((_e241 + _e242) + _e244)];
            let _e249 = u1_;
            c00_ = ((_e238 * _e239) + (_e248 * _e249));
            let _e253 = b01_;
            let _e254 = k0_offset;
            let _e256 = channel;
            let _e260 = lut_data.value[((_e253 + _e254) + _e256)];
            let _e261 = u0_;
            let _e263 = b01_;
            let _e264 = k1_offset;
            let _e266 = channel;
            let _e270 = lut_data.value[((_e263 + _e264) + _e266)];
            let _e271 = u1_;
            c01_ = ((_e260 * _e261) + (_e270 * _e271));
            let _e275 = b10_;
            let _e276 = k0_offset;
            let _e278 = channel;
            let _e282 = lut_data.value[((_e275 + _e276) + _e278)];
            let _e283 = u0_;
            let _e285 = b10_;
            let _e286 = k1_offset;
            let _e288 = channel;
            let _e292 = lut_data.value[((_e285 + _e286) + _e288)];
            let _e293 = u1_;
            c10_ = ((_e282 * _e283) + (_e292 * _e293));
            let _e297 = b11_;
            let _e298 = k0_offset;
            let _e300 = channel;
            let _e304 = lut_data.value[((_e297 + _e298) + _e300)];
            let _e305 = u0_;
            let _e307 = b11_;
            let _e308 = k1_offset;
            let _e310 = channel;
            let _e314 = lut_data.value[((_e307 + _e308) + _e310)];
            let _e315 = u1_;
            c11_ = ((_e304 * _e305) + (_e314 * _e315));
            let _e319 = c00_;
            let _e320 = v0_;
            let _e322 = c01_;
            let _e323 = v1_;
            let _e326 = w0_1;
            let _e328 = c10_;
            let _e329 = v0_;
            let _e331 = c11_;
            let _e332 = v1_;
            let _e335 = w1_1;
            result = ((((_e319 * _e320) + (_e322 * _e323)) * _e326) + (((_e328 * _e329) + (_e331 * _e332)) * _e335));
            let _e340 = gid;
            let _e342 = channel;
            let _e346 = result;
            output_data.value[((3u * _e340) + _e342)] = _e346;
        }
        continuing {
            let _e228 = channel;
            channel = (_e228 + 1u);
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
