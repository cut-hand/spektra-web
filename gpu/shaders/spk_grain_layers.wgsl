struct Rng {
    ctr: vec4<u32>,
    key: vec2<u32>,
    buf: vec4<u32>,
    n: i32,
}

struct Cmy {
    cmy: array<f32>,
}

struct Xa {
    xa: array<f32>,
}

struct Inv {
    inv: array<f32>,
}

struct Ylay {
    ylay: array<f32>,
}

struct Lp {
    lp: array<f32>,
}

struct Streams {
    streams: array<u32>,
}

struct Meta {
    meta_: array<u32>,
}

struct Out {
    dst: array<f32>,
}

@group(0) @binding(0) 
var<storage> global: Cmy;
@group(0) @binding(1) 
var<storage> global_1: Xa;
@group(0) @binding(2) 
var<storage> global_2: Inv;
@group(0) @binding(3) 
var<storage> global_3: Ylay;
@group(0) @binding(4) 
var<storage> global_4: Lp;
@group(0) @binding(5) 
var<storage> global_5: Streams;
@group(0) @binding(6) 
var<storage> global_6: Meta;
@group(0) @binding(7) 
var<storage, read_write> global_7: Out;
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

fn philox4x32_10_(ctr: vec4<u32>, key: vec2<u32>) -> vec4<u32> {
    var ctr_1: vec4<u32>;
    var key_1: vec2<u32>;
    var r: i32 = 0i;
    var hi0_: u32;
    var lo0_: u32;
    var hi1_: u32;
    var lo1_: u32;

    ctr_1 = ctr;
    key_1 = key;
    loop {
        let _e6 = r;
        if !((_e6 < 10i)) {
            break;
        }
        {
            let _e18 = ctr_1;
            spk_umul_extended(3528531795u, _e18.x, (&hi0_), (&lo0_));
            let _e25 = ctr_1;
            spk_umul_extended(3449720151u, _e25.z, (&hi1_), (&lo1_));
            let _e31 = hi1_;
            let _e32 = ctr_1;
            let _e35 = key_1;
            let _e38 = lo1_;
            let _e39 = hi0_;
            let _e40 = ctr_1;
            let _e43 = key_1;
            let _e46 = lo0_;
            ctr_1 = vec4<u32>(((_e31 ^ _e32.y) ^ _e35.x), _e38, ((_e39 ^ _e40.w) ^ _e43.y), _e46);
            let _e49 = key_1;
            key_1.x = (_e49.x + 2654435769u);
            let _e54 = key_1;
            key_1.y = (_e54.y + 3144134277u);
        }
        continuing {
            let _e10 = r;
            r = (_e10 + 1i);
        }
    }
    let _e58 = ctr_1;
    return _e58;
}

fn u01_(x_2: u32) -> f32 {
    var x_3: u32;

    x_3 = x_2;
    let _e2 = x_3;
    return ((f32((_e2 >> 8u)) + 0.5f) * 0.000000059604645f);
}

fn rng_init(pixel: u32, stream: u32, seed: u32) -> Rng {
    var pixel_1: u32;
    var stream_1: u32;
    var seed_1: u32;

    pixel_1 = pixel;
    stream_1 = stream;
    seed_1 = seed;
    let _e6 = pixel_1;
    let _e7 = stream_1;
    let _e11 = seed_1;
    return Rng(vec4<u32>(_e6, _e7, 0u, 0u), vec2<u32>(_e11, 0u), vec4(0u), 0i);
}

fn rng_next(rng: ptr<function, Rng>) -> f32 {
    var v: u32;

    let _e1 = (*rng);
    if (_e1.n == 0i) {
        {
            let _e6 = (*rng);
            let _e8 = (*rng);
            let _e10 = philox4x32_10_(_e6.ctr, _e8.key);
            (*rng).buf = _e10;
            let _e13 = (*rng);
            (*rng).ctr.z = (_e13.ctr.z + 1u);
            (*rng).n = 4i;
        }
    }
    let _e20 = (*rng);
    v = _e20.buf.x;
    let _e25 = (*rng);
    (*rng).buf = _e25.buf.yzwx;
    let _e29 = (*rng);
    (*rng).n = (_e29.n - 1i);
    let _e33 = v;
    let _e34 = u01_(_e33);
    return _e34;
}

fn rng_normal(rng_1: ptr<function, Rng>) -> f32 {
    var u1_: f32;
    var u2_: f32;

    let _e3 = rng_next(rng_1);
    u1_ = _e3;
    let _e7 = rng_next(rng_1);
    u2_ = _e7;
    let _e11 = u1_;
    let _e16 = u2_;
    return (sqrt((-2f * log(_e11))) * cos((6.2831855f * _e16)));
}

fn loggam(x_4: f32) -> f32 {
    var x_5: f32;
    var a0_1: f32 = 0.083333336f;
    var a1_1: f32 = -0.0027777778f;
    var a2_: f32 = 0.0007936508f;
    var a3_: f32 = -0.0005952381f;
    var a4_: f32 = 0.0008417508f;
    var x0_: f32;
    var n: i32 = 0i;
    var x2_: f32;
    var gl0_: f32;
    var gl: f32;
    var k: i32 = 1i;

    x_5 = x_4;
    let _e14 = x_5;
    x0_ = _e14;
    let _e18 = x_5;
    let _e21 = x_5;
    if ((_e18 == 1f) || (_e21 == 2f)) {
        return 0f;
    }
    let _e26 = x_5;
    if (_e26 <= 7f) {
        {
            let _e30 = x_5;
            n = i32((7f - _e30));
            let _e33 = x_5;
            let _e34 = n;
            x0_ = (_e33 + f32(_e34));
        }
    }
    let _e38 = x0_;
    let _e39 = x0_;
    x2_ = (1f / (_e38 * _e39));
    let _e43 = a4_;
    gl0_ = _e43;
    let _e45 = gl0_;
    let _e46 = x2_;
    let _e48 = a3_;
    gl0_ = ((_e45 * _e46) + _e48);
    let _e50 = gl0_;
    let _e51 = x2_;
    let _e53 = a2_;
    gl0_ = ((_e50 * _e51) + _e53);
    let _e55 = gl0_;
    let _e56 = x2_;
    let _e58 = a1_1;
    gl0_ = ((_e55 * _e56) + _e58);
    let _e60 = gl0_;
    let _e61 = x2_;
    let _e63 = a0_1;
    gl0_ = ((_e60 * _e61) + _e63);
    let _e65 = gl0_;
    let _e66 = x0_;
    let _e73 = x0_;
    let _e76 = x0_;
    let _e80 = x0_;
    gl = ((((_e65 / _e66) + 0.9189385f) + ((_e73 - 0.5f) * log(_e76))) - _e80);
    let _e83 = x_5;
    if (_e83 <= 7f) {
        loop {
            let _e88 = k;
            let _e89 = n;
            if !((_e88 <= _e89)) {
                break;
            }
            {
                let _e95 = gl;
                let _e96 = x0_;
                gl = (_e95 - log((_e96 - 1f)));
                let _e101 = x0_;
                x0_ = (_e101 - 1f);
            }
            continuing {
                let _e92 = k;
                k = (_e92 + 1i);
            }
        }
    }
    let _e104 = gl;
    return _e104;
}

fn poisson(rng_2: ptr<function, Rng>, mu: f32) -> f32 {
    var mu_1: f32;
    var slam: f32;
    var loglam: f32;
    var b_2: f32;
    var a_2: f32;
    var invalpha: f32;
    var vr: f32;
    var it: i32 = 0i;
    var U: f32;
    var V: f32;
    var us: f32;
    var k_1: f32;
    var log_accept: f32;
    var log_mass: f32;
    var enlam: f32;
    var X: f32 = 0f;
    var prod: f32 = 1f;
    var it_1: i32 = 0i;

    mu_1 = mu;
    let _e3 = mu_1;
    if (_e3 >= 10f) {
        {
            let _e6 = mu_1;
            slam = sqrt(_e6);
            let _e9 = mu_1;
            loglam = log(_e9);
            let _e14 = slam;
            b_2 = (0.931f + (2.53f * _e14));
            let _e21 = b_2;
            a_2 = (-0.059f + (0.02483f * _e21));
            let _e27 = b_2;
            invalpha = (1.1239f + (1.1328f / (_e27 - 3.4f)));
            let _e35 = b_2;
            vr = (0.9277f - (3.6224f / (_e35 - 2f)));
            loop {
                let _e43 = it;
                if !((_e43 < 64i)) {
                    break;
                }
                {
                    let _e52 = rng_next(rng_2);
                    U = (_e52 - 0.5f);
                    let _e58 = rng_next(rng_2);
                    V = _e58;
                    let _e61 = U;
                    us = (0.5f - abs(_e61));
                    let _e66 = a_2;
                    let _e68 = us;
                    let _e70 = b_2;
                    let _e72 = U;
                    let _e74 = mu_1;
                    k_1 = floor(((((((2f * _e66) / _e68) + _e70) * _e72) + _e74) + 0.43f));
                    let _e80 = us;
                    let _e83 = V;
                    let _e84 = vr;
                    if ((_e80 >= 0.07f) && (_e83 <= _e84)) {
                        let _e87 = k_1;
                        return _e87;
                    }
                    let _e88 = k_1;
                    let _e91 = us;
                    let _e94 = V;
                    let _e95 = us;
                    if ((_e88 < 0f) || ((_e91 < 0.013f) && (_e94 > _e95))) {
                        continue;
                    }
                    let _e99 = V;
                    let _e101 = invalpha;
                    let _e104 = a_2;
                    let _e105 = us;
                    let _e106 = us;
                    let _e109 = b_2;
                    log_accept = ((log(_e99) + log(_e101)) - log(((_e104 / (_e105 * _e106)) + _e109)));
                    let _e114 = mu_1;
                    let _e116 = k_1;
                    let _e117 = loglam;
                    let _e120 = k_1;
                    let _e123 = loggam((_e120 + 1f));
                    log_mass = ((-(_e114) + (_e116 * _e117)) - _e123);
                    let _e126 = log_accept;
                    let _e127 = log_mass;
                    if (_e126 <= _e127) {
                        let _e129 = k_1;
                        return _e129;
                    }
                }
                continuing {
                    let _e47 = it;
                    it = (_e47 + 1i);
                }
            }
            let _e130 = mu_1;
            return floor(_e130);
        }
    }
    let _e132 = mu_1;
    enlam = exp(-(_e132));
    loop {
        let _e142 = it_1;
        if !((_e142 < 512i)) {
            break;
        }
        {
            let _e149 = prod;
            let _e152 = rng_next(rng_2);
            prod = (_e149 * _e152);
            let _e154 = prod;
            let _e155 = enlam;
            if (_e154 > _e155) {
                let _e157 = X;
                X = (_e157 + 1f);
            } else {
                let _e160 = X;
                return _e160;
            }
        }
        continuing {
            let _e146 = it_1;
            it_1 = (_e146 + 1i);
        }
    }
    let _e161 = X;
    return _e161;
}

fn layer_draw(rng_3: ptr<function, Rng>, d: f32, dmax: f32, n_1: f32, u: f32) -> f32 {
    var d_1: f32;
    var dmax_1: f32;
    var n_2: f32;
    var u_1: f32;
    var p: f32;
    var sat: f32;
    var rate: f32;
    var od: f32;

    d_1 = d;
    dmax_1 = dmax;
    n_2 = n_1;
    u_1 = u;
    let _e9 = d_1;
    let _e10 = dmax_1;
    p = (_e9 / _e10);
    let _e13 = p;
    p = clamp(_e13, 0.000001f, 0.999999f);
    let _e20 = p;
    let _e21 = u_1;
    sat = (1f - ((_e20 * _e21) * 0.999999f));
    let _e29 = n_2;
    let _e30 = sat;
    let _e32 = p;
    rate = ((_e29 / _e30) * _e32);
    let _e35 = dmax_1;
    let _e36 = n_2;
    od = (_e35 / _e36);
    let _e40 = rate;
    let _e42 = poisson(rng_3, _e40);
    let _e43 = od;
    let _e44 = sat;
    return (_e42 * (_e43 * _e44));
}

fn spk_global_index() -> u32 {
    let _e18 = gl_GlobalInvocationID_1;
    let _e20 = gl_NumWorkGroups_1;
    let _e25 = gl_GlobalInvocationID_1;
    return ((_e18.y * (_e20.x * 256u)) + _e25.x);
}

fn search_right(K: u32, ch: u32, v_1: f32) -> u32 {
    var K_1: u32;
    var ch_1: u32;
    var v_2: f32;
    var lo_1: u32 = 0u;
    var hi_1: u32;
    var mid: u32;

    K_1 = K;
    ch_1 = ch;
    v_2 = v_1;
    let _e26 = K_1;
    hi_1 = _e26;
    loop {
        let _e28 = lo_1;
        let _e29 = hi_1;
        if !((_e28 < _e29)) {
            break;
        }
        {
            let _e32 = lo_1;
            let _e33 = hi_1;
            let _e34 = lo_1;
            mid = (_e32 + ((_e33 - _e34) >> 1u));
            let _e41 = mid;
            let _e44 = ch_1;
            let _e47 = global_1.xa[((_e41 * 3u) + _e44)];
            let _e48 = v_2;
            if (_e47 <= _e48) {
                let _e50 = mid;
                lo_1 = (_e50 + 1u);
            } else {
                let _e53 = mid;
                hi_1 = _e53;
            }
        }
    }
    let _e54 = lo_1;
    return _e54;
}

fn main_1() {
    var i: u32;
    var K_2: u32;
    var n_3: u32;
    var positive: u32;
    var seed_2: u32;
    var ch_2: u32 = 0u;
    var v_3: f32;
    var x0_1: f32;
    var xN: f32;
    var low: u32;
    var t_1: f32;
    var mode: i32;
    var idx: u32;
    var acc: f32;
    var sl: u32;
    var col: u32;
    var d_2: f32;
    var y0_: f32;
    var y1_: f32;
    var rng_4: Rng;

    let _e18 = spk_global_index();
    i = _e18;
    let _e22 = global_6.meta_[0];
    K_2 = _e22;
    let _e26 = global_6.meta_[1];
    n_3 = _e26;
    let _e30 = global_6.meta_[2];
    positive = _e30;
    let _e34 = global_6.meta_[3];
    seed_2 = _e34;
    let _e36 = i;
    let _e37 = n_3;
    if (_e36 >= _e37) {
        return;
    }
    loop {
        let _e41 = ch_2;
        if !((_e41 < 3u)) {
            break;
        }
        {
            let _e49 = i;
            let _e51 = ch_2;
            let _e54 = global.cmy[((3u * _e49) + _e51)];
            v_3 = _e54;
            let _e56 = positive;
            if (_e56 != 0u) {
                let _e59 = v_3;
                v_3 = -(_e59);
            }
            let _e61 = ch_2;
            let _e63 = global_1.xa[_e61];
            x0_1 = _e63;
            let _e65 = K_2;
            let _e70 = ch_2;
            let _e73 = global_1.xa[(((_e65 - 1u) * 3u) + _e70)];
            xN = _e73;
            low = 0u;
            t_1 = 0f;
            let _e80 = v_3;
            let _e81 = x0_1;
            if (_e80 <= _e81) {
                mode = 0i;
            } else {
                let _e84 = v_3;
                let _e85 = xN;
                if (_e84 >= _e85) {
                    mode = 1i;
                } else {
                    {
                        let _e88 = K_2;
                        let _e89 = ch_2;
                        let _e90 = v_3;
                        let _e91 = search_right(_e88, _e89, _e90);
                        idx = _e91;
                        let _e93 = idx;
                        low = (_e93 - 1u);
                        let _e96 = v_3;
                        let _e97 = low;
                        let _e100 = ch_2;
                        let _e103 = global_1.xa[((_e97 * 3u) + _e100)];
                        let _e105 = low;
                        let _e108 = ch_2;
                        let _e111 = global_2.inv[((_e105 * 3u) + _e108)];
                        t_1 = ((_e96 - _e103) * _e111);
                        mode = 2i;
                    }
                }
            }
            acc = 0f;
            sl = 0u;
            loop {
                let _e118 = sl;
                if !((_e118 < 3u)) {
                    break;
                }
                {
                    let _e125 = ch_2;
                    let _e128 = sl;
                    col = ((_e125 * 3u) + _e128);
                    let _e132 = mode;
                    if (_e132 == 0i) {
                        let _e135 = col;
                        let _e137 = global_3.ylay[_e135];
                        d_2 = _e137;
                    } else {
                        let _e138 = mode;
                        if (_e138 == 1i) {
                            let _e141 = K_2;
                            let _e146 = col;
                            let _e149 = global_3.ylay[(((_e141 - 1u) * 9u) + _e146)];
                            d_2 = _e149;
                        } else {
                            {
                                let _e150 = low;
                                let _e153 = col;
                                let _e156 = global_3.ylay[((_e150 * 9u) + _e153)];
                                y0_ = _e156;
                                let _e158 = low;
                                let _e163 = col;
                                let _e166 = global_3.ylay[(((_e158 + 1u) * 9u) + _e163)];
                                y1_ = _e166;
                                let _e168 = y0_;
                                let _e169 = t_1;
                                let _e170 = y1_;
                                let _e171 = y0_;
                                d_2 = (_e168 + (_e169 * (_e170 - _e171)));
                            }
                        }
                    }
                    let _e175 = d_2;
                    let _e177 = col;
                    let _e180 = global_4.lp[(4u * _e177)];
                    d_2 = (_e175 + _e180);
                    let _e182 = i;
                    let _e183 = col;
                    let _e185 = global_5.streams[_e183];
                    let _e186 = seed_2;
                    let _e187 = rng_init(_e182, _e185, _e186);
                    rng_4 = _e187;
                    let _e189 = acc;
                    let _e191 = d_2;
                    let _e193 = col;
                    let _e198 = global_4.lp[((4u * _e193) + 1u)];
                    let _e200 = col;
                    let _e205 = global_4.lp[((4u * _e200) + 2u)];
                    let _e207 = col;
                    let _e212 = global_4.lp[((4u * _e207) + 3u)];
                    let _e214 = layer_draw((&rng_4), _e191, _e198, _e205, _e212);
                    acc = (_e189 + _e214);
                }
                continuing {
                    let _e122 = sl;
                    sl = (_e122 + 1u);
                }
            }
            let _e217 = i;
            let _e219 = ch_2;
            let _e222 = acc;
            global_7.dst[((3u * _e217) + _e219)] = _e222;
        }
        continuing {
            let _e45 = ch_2;
            ch_2 = (_e45 + 1u);
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
