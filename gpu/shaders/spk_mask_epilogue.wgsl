struct B0_ {
    cmy: array<f32>,
}

struct B1_ {
    chd: array<f32>,
}

struct B2_ {
    base: array<f32>,
}

struct B3_ {
    ixs: array<f32>,
}

struct B4_ {
    p: array<f32>,
}

struct B5_ {
    coef: array<f32>,
}

struct B6_ {
    meta_: array<u32>,
}

struct B7_ {
    dst: array<f32>,
}

const kMaskLog2Floor: f32 = -20f;

@group(0) @binding(0) 
var<storage> global: B0_;
@group(0) @binding(1) 
var<storage> global_1: B1_;
@group(0) @binding(2) 
var<storage> global_2: B2_;
@group(0) @binding(3) 
var<storage> global_3: B3_;
@group(0) @binding(4) 
var<storage> global_4: B4_;
@group(0) @binding(5) 
var<storage> global_5: B5_;
@group(0) @binding(6) 
var<storage> global_6: B6_;
@group(0) @binding(7) 
var<storage, read_write> global_7: B7_;
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

fn mask_image_exposure(i: u32, nl: u32) -> vec3<f32> {
    var i_1: u32;
    var nl_1: u32;
    var c0_: f32;
    var c1_: f32;
    var c2_: f32;
    var a0_1: f32 = 0f;
    var a1_1: f32 = 0f;
    var a2_: f32 = 0f;
    var l: u32 = 0u;
    var d: f32;
    var t_1: f32;

    i_1 = i;
    nl_1 = nl;
    let _e22 = i_1;
    let _e25 = global.cmy[(3u * _e22)];
    c0_ = _e25;
    let _e28 = i_1;
    let _e33 = global.cmy[((3u * _e28) + 1u)];
    c1_ = _e33;
    let _e36 = i_1;
    let _e41 = global.cmy[((3u * _e36) + 2u)];
    c2_ = _e41;
    loop {
        let _e51 = l;
        let _e52 = nl_1;
        if !((_e51 < _e52)) {
            break;
        }
        {
            let _e58 = c0_;
            let _e60 = l;
            let _e63 = global_1.chd[(3u * _e60)];
            let _e65 = c1_;
            let _e67 = l;
            let _e72 = global_1.chd[((3u * _e67) + 1u)];
            let _e75 = c2_;
            let _e77 = l;
            let _e82 = global_1.chd[((3u * _e77) + 2u)];
            let _e85 = l;
            let _e87 = global_2.base[_e85];
            d = ((((_e58 * _e63) + (_e65 * _e72)) + (_e75 * _e82)) + _e87);
            let _e90 = d;
            t_1 = exp2((-(_e90) * 3.321928f));
            let _e96 = a0_1;
            let _e97 = t_1;
            let _e99 = l;
            let _e102 = global_3.ixs[(3u * _e99)];
            a0_1 = (_e96 + (_e97 * _e102));
            let _e105 = a1_1;
            let _e106 = t_1;
            let _e108 = l;
            let _e113 = global_3.ixs[((3u * _e108) + 1u)];
            a1_1 = (_e105 + (_e106 * _e113));
            let _e116 = a2_;
            let _e117 = t_1;
            let _e119 = l;
            let _e124 = global_3.ixs[((3u * _e119) + 2u)];
            a2_ = (_e116 + (_e117 * _e124));
        }
        continuing {
            let _e55 = l;
            l = (_e55 + 1u);
        }
    }
    let _e127 = a0_1;
    let _e130 = global_4.p[0];
    let _e132 = a1_1;
    let _e135 = global_4.p[1];
    let _e137 = a2_;
    let _e140 = global_4.p[2];
    return vec3<f32>((_e127 * _e130), (_e132 * _e135), (_e137 * _e140));
}

fn mask_x(a_2: vec3<f32>) -> f32 {
    var a_3: vec3<f32>;
    var s: f32 = 0f;
    var c: u32 = 0u;
    var r: f32;

    a_3 = a_2;
    loop {
        let _e23 = c;
        if !((_e23 < 3u)) {
            break;
        }
        {
            let _e30 = c;
            let _e32 = a_3[_e30];
            let _e34 = c;
            let _e37 = global_4.p[(3u + _e34)];
            r = max((_e32 * _e37), 0f);
            let _e42 = s;
            let _e43 = r;
            s = (_e42 + max(log2(_e43), kMaskLog2Floor));
        }
        continuing {
            let _e27 = c;
            c = (_e27 + 1u);
        }
    }
    let _e47 = s;
    return (_e47 * 0.33333334f);
}

fn mask_g(d_1: f32, h: f32) -> f32 {
    var d_2: f32;
    var h_1: f32;

    d_2 = d_1;
    h_1 = h;
    let _e21 = d_2;
    let _e22 = h_1;
    let _e24 = h_1;
    let _e25 = h_1;
    let _e27 = d_2;
    let _e28 = d_2;
    return ((_e21 * _e22) * inverseSqrt(((_e24 * _e25) + (_e27 * _e28))));
}

fn mask_delta(b_2: f32) -> f32 {
    var b_3: f32;
    var delta: f32 = 0f;
    var d_3: f32;
    var d_4: f32;
    var lim: f32;

    b_3 = b_2;
    let _e23 = global_4.p[11];
    let _e26 = b_3;
    let _e29 = global_4.p[9];
    if ((_e23 != 0f) && (_e26 < _e29)) {
        {
            let _e34 = global_4.p[9];
            let _e35 = b_3;
            d_3 = (_e34 - _e35);
            let _e38 = d_3;
            let _e39 = d_3;
            let _e42 = global_4.p[10];
            let _e43 = mask_g(_e39, _e42);
            delta = (_e38 - _e43);
        }
    } else {
        let _e47 = global_4.p[14];
        let _e50 = b_3;
        let _e53 = global_4.p[12];
        if ((_e47 != 0f) && (_e50 > _e53)) {
            {
                let _e56 = b_3;
                let _e59 = global_4.p[12];
                d_4 = (_e56 - _e59);
                let _e62 = d_4;
                let _e65 = global_4.p[13];
                let _e66 = mask_g(_e62, _e65);
                let _e67 = d_4;
                delta = (_e66 - _e67);
            }
        }
    }
    let _e71 = global_4.p[15];
    lim = _e71;
    let _e73 = delta;
    let _e74 = lim;
    let _e76 = lim;
    let _e77 = lim;
    let _e79 = delta;
    let _e80 = delta;
    return ((_e73 * _e74) * inverseSqrt(((_e76 * _e77) + (_e79 * _e80))));
}

fn main_1() {
    var n: u32;
    var nl_2: u32;
    var W: u32;
    var H: u32;
    var row0_: u32;
    var gw: u32;
    var gh: u32;
    var i_2: u32;
    var a_4: vec3<f32>;
    var px: u32;
    var py: u32;
    var u: f32;
    var v: f32;
    var u0_: u32;
    var v0_: u32;
    var u1_: u32;
    var v1_: u32;
    var tu: f32;
    var tv: f32;
    var c00_: vec2<f32>;
    var c01_: vec2<f32>;
    var c10_: vec2<f32>;
    var c11_: vec2<f32>;
    var ab: vec2<f32>;
    var b_4: f32;
    var k: f32;
    var v0e: f32;
    var v1e: f32;
    var v2e: f32;

    let _e19 = global_6.meta_[0];
    n = _e19;
    let _e23 = global_6.meta_[1];
    nl_2 = _e23;
    let _e27 = global_6.meta_[2];
    W = _e27;
    let _e31 = global_6.meta_[3];
    H = _e31;
    let _e35 = global_6.meta_[4];
    row0_ = _e35;
    let _e39 = global_6.meta_[5];
    gw = _e39;
    let _e43 = global_6.meta_[6];
    gh = _e43;
    let _e47 = gl_GlobalInvocationID_1;
    let _e49 = gl_NumWorkGroups_1;
    let _e54 = gl_GlobalInvocationID_1;
    i_2 = ((_e47.y * (_e49.x * 256u)) + _e54.x);
    let _e58 = i_2;
    let _e59 = n;
    if (_e58 >= _e59) {
        return;
    }
    let _e61 = i_2;
    let _e62 = nl_2;
    let _e63 = mask_image_exposure(_e61, _e62);
    a_4 = _e63;
    let _e65 = i_2;
    let _e66 = W;
    px = (_e65 % _e66);
    let _e69 = row0_;
    let _e70 = i_2;
    let _e71 = W;
    py = (_e69 + (_e70 / _e71));
    let _e75 = px;
    let _e79 = gw;
    let _e82 = W;
    let _e88 = gw;
    u = clamp(((((f32(_e75) + 0.5f) * f32(_e79)) / f32(_e82)) - 0.5f), 0f, f32((_e88 - 1u)));
    let _e94 = py;
    let _e98 = gh;
    let _e101 = H;
    let _e107 = gh;
    v = clamp(((((f32(_e94) + 0.5f) * f32(_e98)) / f32(_e101)) - 0.5f), 0f, f32((_e107 - 1u)));
    let _e113 = u;
    u0_ = u32(floor(_e113));
    let _e117 = v;
    v0_ = u32(floor(_e117));
    let _e121 = u0_;
    let _e124 = gw;
    u1_ = min((_e121 + 1u), (_e124 - 1u));
    let _e129 = v0_;
    let _e132 = gh;
    v1_ = min((_e129 + 1u), (_e132 - 1u));
    let _e137 = u;
    let _e138 = u0_;
    tu = (_e137 - f32(_e138));
    let _e142 = v;
    let _e143 = v0_;
    tv = (_e142 - f32(_e143));
    let _e148 = v0_;
    let _e149 = gw;
    let _e151 = u0_;
    let _e155 = global_5.coef[(2u * ((_e148 * _e149) + _e151))];
    let _e157 = v0_;
    let _e158 = gw;
    let _e160 = u0_;
    let _e166 = global_5.coef[((2u * ((_e157 * _e158) + _e160)) + 1u)];
    c00_ = vec2<f32>(_e155, _e166);
    let _e170 = v0_;
    let _e171 = gw;
    let _e173 = u1_;
    let _e177 = global_5.coef[(2u * ((_e170 * _e171) + _e173))];
    let _e179 = v0_;
    let _e180 = gw;
    let _e182 = u1_;
    let _e188 = global_5.coef[((2u * ((_e179 * _e180) + _e182)) + 1u)];
    c01_ = vec2<f32>(_e177, _e188);
    let _e192 = v1_;
    let _e193 = gw;
    let _e195 = u0_;
    let _e199 = global_5.coef[(2u * ((_e192 * _e193) + _e195))];
    let _e201 = v1_;
    let _e202 = gw;
    let _e204 = u0_;
    let _e210 = global_5.coef[((2u * ((_e201 * _e202) + _e204)) + 1u)];
    c10_ = vec2<f32>(_e199, _e210);
    let _e214 = v1_;
    let _e215 = gw;
    let _e217 = u1_;
    let _e221 = global_5.coef[(2u * ((_e214 * _e215) + _e217))];
    let _e223 = v1_;
    let _e224 = gw;
    let _e226 = u1_;
    let _e232 = global_5.coef[((2u * ((_e223 * _e224) + _e226)) + 1u)];
    c11_ = vec2<f32>(_e221, _e232);
    let _e235 = c00_;
    let _e236 = c01_;
    let _e237 = tu;
    let _e240 = c10_;
    let _e241 = c11_;
    let _e242 = tu;
    let _e245 = tv;
    ab = mix(mix(_e235, _e236, vec2(_e237)), mix(_e240, _e241, vec2(_e242)), vec2(_e245));
    let _e249 = ab;
    let _e251 = a_4;
    let _e252 = mask_x(_e251);
    let _e254 = ab;
    b_4 = ((_e249.x * _e252) + _e254.y);
    let _e258 = b_4;
    let _e259 = mask_delta(_e258);
    k = exp2(_e259);
    let _e262 = k;
    let _e263 = a_4;
    let _e268 = global_4.p[6];
    v0e = (max(((_e262 * _e263.x) + _e268), 0f) + 0.0000000001f);
    let _e275 = k;
    let _e276 = a_4;
    let _e281 = global_4.p[7];
    v1e = (max(((_e275 * _e276.y) + _e281), 0f) + 0.0000000001f);
    let _e288 = k;
    let _e289 = a_4;
    let _e294 = global_4.p[8];
    v2e = (max(((_e288 * _e289.z) + _e294), 0f) + 0.0000000001f);
    let _e302 = i_2;
    let _e305 = v0e;
    let _e306 = spk_log10_(_e305);
    global_7.dst[(3u * _e302)] = _e306;
    let _e308 = i_2;
    let _e313 = v1e;
    let _e314 = spk_log10_(_e313);
    global_7.dst[((3u * _e308) + 1u)] = _e314;
    let _e316 = i_2;
    let _e321 = v2e;
    let _e322 = spk_log10_(_e321);
    global_7.dst[((3u * _e316) + 2u)] = _e322;
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
