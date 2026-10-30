struct B0_ {
    rgb: array<f32>,
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

fn slm_departure(D: f32, H: f32, m: f32) -> f32 {
    var D_1: f32;
    var H_1: f32;
    var m_1: f32;
    var r: f32;

    D_1 = D;
    H_1 = H;
    m_1 = m;
    let _e14 = D_1;
    if !((_e14 > 0f)) {
        return 0f;
    }
    let _e19 = m_1;
    if (_e19 == 2f) {
        {
            let _e22 = H_1;
            let _e23 = H_1;
            let _e25 = D_1;
            let _e26 = D_1;
            r = sqrt(((_e22 * _e23) + (_e25 * _e26)));
            let _e31 = D_1;
            let _e32 = D_1;
            let _e34 = D_1;
            let _e37 = r;
            let _e38 = H_1;
            let _e39 = r;
            return (-(((_e31 * _e32) * _e34)) / (_e37 * (_e38 + _e39)));
        }
    }
    let _e43 = m_1;
    if (_e43 == 1f) {
        let _e46 = D_1;
        let _e47 = D_1;
        let _e50 = H_1;
        let _e51 = D_1;
        return (-((_e46 * _e47)) / (_e50 + _e51));
    }
    let _e54 = D_1;
    let _e55 = H_1;
    let _e56 = H_1;
    let _e57 = m_1;
    let _e58 = spk_pow(_e56, _e57);
    let _e59 = D_1;
    let _e60 = m_1;
    let _e61 = spk_pow(_e59, _e60);
    let _e64 = m_1;
    let _e66 = spk_pow((_e58 + _e61), (1f / _e64));
    return (_e54 * ((_e55 / _e66) - 1f));
}

fn main_1() {
    var i: u32;
    var r_1: f32;
    var g: f32;
    var b_2: f32;
    var cr: f32;
    var cg: f32;
    var cb: f32;
    var v: f32;
    var norm: u32;
    var s2_: f32;
    var local: f32;
    var k: f32 = 1f;
    var n_ref: f32;
    var E: f32;
    var d: f32 = 0f;
    var Kh: f32;
    var Hh: f32;
    var Ks: f32;
    var Hs: f32;
    var w: u32;
    var h: u32;
    var local_1: f32;
    var along: f32;
    var L: f32;

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
    let _e30 = global.rgb[(3u * _e27)];
    r_1 = _e30;
    let _e33 = i;
    let _e38 = global.rgb[((3u * _e33) + 1u)];
    g = _e38;
    let _e41 = i;
    let _e46 = global.rgb[((3u * _e41) + 2u)];
    b_2 = _e46;
    let _e48 = r_1;
    cr = max(_e48, 0f);
    let _e52 = g;
    cg = max(_e52, 0f);
    let _e56 = b_2;
    cb = max(_e56, 0f);
    let _e63 = global_1.p[6];
    norm = u32(_e63);
    let _e66 = norm;
    if (_e66 == 1u) {
        {
            let _e71 = global_1.p[7];
            let _e72 = cr;
            let _e76 = global_1.p[8];
            let _e77 = cg;
            let _e82 = global_1.p[9];
            let _e83 = cb;
            v = (((_e71 * _e72) + (_e76 * _e77)) + (_e82 * _e83));
        }
    } else {
        let _e86 = norm;
        if (_e86 == 2u) {
            {
                let _e89 = cr;
                let _e90 = cg;
                let _e91 = cb;
                v = max(_e89, max(_e90, _e91));
            }
        } else {
            {
                let _e94 = cr;
                let _e95 = cr;
                let _e97 = cg;
                let _e98 = cg;
                let _e101 = cb;
                let _e102 = cb;
                s2_ = (((_e94 * _e95) + (_e97 * _e98)) + (_e101 * _e102));
                let _e106 = s2_;
                if (_e106 > 0f) {
                    let _e109 = cr;
                    let _e110 = cr;
                    let _e112 = cr;
                    let _e114 = cg;
                    let _e115 = cg;
                    let _e117 = cg;
                    let _e120 = cb;
                    let _e121 = cb;
                    let _e123 = cb;
                    let _e126 = s2_;
                    local = (((((_e109 * _e110) * _e112) + ((_e114 * _e115) * _e117)) + ((_e120 * _e121) * _e123)) / _e126);
                } else {
                    local = 0f;
                }
                let _e130 = local;
                v = _e130;
            }
        }
    }
    let _e133 = v;
    let _e136 = v;
    let _e137 = spk_isfinite(_e136);
    if ((_e133 > 0f) && _e137) {
        {
            let _e141 = global_1.p[10];
            n_ref = _e141;
            let _e143 = v;
            let _e144 = n_ref;
            let _e150 = n_ref;
            E = clamp(log2((max(_e143, (_e144 * 0.000000059604645f)) / _e150)), -24f, 24f);
            let _e162 = global_1.p[0];
            Kh = _e162;
            let _e166 = global_1.p[1];
            Hh = _e166;
            let _e170 = global_1.p[2];
            Ks = _e170;
            let _e174 = global_1.p[3];
            Hs = _e174;
            let _e178 = global_1.p[13];
            if (_e178 > 0f) {
                {
                    let _e183 = global_1.p[11];
                    w = u32(_e183);
                    let _e188 = global_1.p[12];
                    h = u32(_e188);
                    let _e191 = w;
                    let _e192 = h;
                    if (_e191 >= _e192) {
                        let _e194 = i;
                        let _e195 = w;
                        let _e200 = w;
                        local_1 = ((f32((_e194 % _e195)) + 0.5f) / f32(_e200));
                    } else {
                        let _e203 = i;
                        let _e204 = w;
                        let _e209 = global_1.p[18];
                        let _e213 = h;
                        local_1 = (((f32((_e203 / _e204)) + _e209) + 0.5f) / f32(_e213));
                    }
                    let _e217 = local_1;
                    along = _e217;
                    let _e219 = along;
                    let _e222 = global_1.p[13];
                    if (_e219 >= _e222) {
                        {
                            let _e226 = global_1.p[14];
                            Kh = _e226;
                            let _e229 = global_1.p[15];
                            Hh = _e229;
                            let _e232 = global_1.p[16];
                            Ks = _e232;
                            let _e235 = global_1.p[17];
                            Hs = _e235;
                        }
                    }
                }
            }
            let _e236 = Hh;
            let _e239 = E;
            let _e240 = Kh;
            if ((_e236 > 0f) && (_e239 > _e240)) {
                let _e243 = E;
                let _e244 = Kh;
                let _e246 = Hh;
                let _e249 = global_1.p[4];
                let _e250 = slm_departure((_e243 - _e244), _e246, _e249);
                d = _e250;
            } else {
                let _e251 = Hs;
                let _e254 = E;
                let _e255 = Ks;
                if ((_e251 > 0f) && (_e254 < _e255)) {
                    let _e258 = Ks;
                    let _e259 = E;
                    let _e261 = Hs;
                    let _e264 = global_1.p[4];
                    let _e265 = slm_departure((_e258 - _e259), _e261, _e264);
                    d = -(_e265);
                }
            }
            let _e267 = d;
            if (_e267 > 0f) {
                {
                    let _e272 = global_1.p[5];
                    L = _e272;
                    let _e274 = d;
                    let _e275 = L;
                    let _e277 = L;
                    let _e278 = L;
                    let _e280 = d;
                    let _e281 = d;
                    d = ((_e274 * _e275) / sqrt(((_e277 * _e278) + (_e280 * _e281))));
                }
            }
            let _e286 = d;
            k = clamp(exp2(_e286), 0.0000000009313226f, 1073741800f);
        }
    }
    let _e295 = i;
    let _e298 = r_1;
    let _e299 = k;
    global_3.dst[(3u * _e295)] = (_e298 * _e299);
    let _e302 = i;
    let _e307 = g;
    let _e308 = k;
    global_3.dst[((3u * _e302) + 1u)] = (_e307 * _e308);
    let _e311 = i;
    let _e316 = b_2;
    let _e317 = k;
    global_3.dst[((3u * _e311) + 2u)] = (_e316 * _e317);
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
