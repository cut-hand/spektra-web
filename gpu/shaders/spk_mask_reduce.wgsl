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
    meta_: array<u32>,
}

struct B6_ {
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
var<storage, read_write> global_6: B6_;
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
    let _e20 = i_1;
    let _e23 = global.cmy[(3u * _e20)];
    c0_ = _e23;
    let _e26 = i_1;
    let _e31 = global.cmy[((3u * _e26) + 1u)];
    c1_ = _e31;
    let _e34 = i_1;
    let _e39 = global.cmy[((3u * _e34) + 2u)];
    c2_ = _e39;
    loop {
        let _e49 = l;
        let _e50 = nl_1;
        if !((_e49 < _e50)) {
            break;
        }
        {
            let _e56 = c0_;
            let _e58 = l;
            let _e61 = global_1.chd[(3u * _e58)];
            let _e63 = c1_;
            let _e65 = l;
            let _e70 = global_1.chd[((3u * _e65) + 1u)];
            let _e73 = c2_;
            let _e75 = l;
            let _e80 = global_1.chd[((3u * _e75) + 2u)];
            let _e83 = l;
            let _e85 = global_2.base[_e83];
            d = ((((_e56 * _e61) + (_e63 * _e70)) + (_e73 * _e80)) + _e85);
            let _e88 = d;
            t_1 = exp2((-(_e88) * 3.321928f));
            let _e94 = a0_1;
            let _e95 = t_1;
            let _e97 = l;
            let _e100 = global_3.ixs[(3u * _e97)];
            a0_1 = (_e94 + (_e95 * _e100));
            let _e103 = a1_1;
            let _e104 = t_1;
            let _e106 = l;
            let _e111 = global_3.ixs[((3u * _e106) + 1u)];
            a1_1 = (_e103 + (_e104 * _e111));
            let _e114 = a2_;
            let _e115 = t_1;
            let _e117 = l;
            let _e122 = global_3.ixs[((3u * _e117) + 2u)];
            a2_ = (_e114 + (_e115 * _e122));
        }
        continuing {
            let _e53 = l;
            l = (_e53 + 1u);
        }
    }
    let _e125 = a0_1;
    let _e128 = global_4.p[0];
    let _e130 = a1_1;
    let _e133 = global_4.p[1];
    let _e135 = a2_;
    let _e138 = global_4.p[2];
    return vec3<f32>((_e125 * _e128), (_e130 * _e133), (_e135 * _e138));
}

fn mask_x(a_2: vec3<f32>) -> f32 {
    var a_3: vec3<f32>;
    var s: f32 = 0f;
    var c: u32 = 0u;
    var r: f32;

    a_3 = a_2;
    loop {
        let _e21 = c;
        if !((_e21 < 3u)) {
            break;
        }
        {
            let _e28 = c;
            let _e30 = a_3[_e28];
            let _e32 = c;
            let _e35 = global_4.p[(3u + _e32)];
            r = max((_e30 * _e35), 0f);
            let _e40 = s;
            let _e41 = r;
            s = (_e40 + max(log2(_e41), kMaskLog2Floor));
        }
        continuing {
            let _e25 = c;
            c = (_e25 + 1u);
        }
    }
    let _e45 = s;
    return (_e45 * 0.33333334f);
}

fn mask_g(d_1: f32, h: f32) -> f32 {
    var d_2: f32;
    var h_1: f32;

    d_2 = d_1;
    h_1 = h;
    let _e19 = d_2;
    let _e20 = h_1;
    let _e22 = h_1;
    let _e23 = h_1;
    let _e25 = d_2;
    let _e26 = d_2;
    return ((_e19 * _e20) * inverseSqrt(((_e22 * _e23) + (_e25 * _e26))));
}

fn mask_delta(b_2: f32) -> f32 {
    var b_3: f32;
    var delta: f32 = 0f;
    var d_3: f32;
    var d_4: f32;
    var lim: f32;

    b_3 = b_2;
    let _e21 = global_4.p[11];
    let _e24 = b_3;
    let _e27 = global_4.p[9];
    if ((_e21 != 0f) && (_e24 < _e27)) {
        {
            let _e32 = global_4.p[9];
            let _e33 = b_3;
            d_3 = (_e32 - _e33);
            let _e36 = d_3;
            let _e37 = d_3;
            let _e40 = global_4.p[10];
            let _e41 = mask_g(_e37, _e40);
            delta = (_e36 - _e41);
        }
    } else {
        let _e45 = global_4.p[14];
        let _e48 = b_3;
        let _e51 = global_4.p[12];
        if ((_e45 != 0f) && (_e48 > _e51)) {
            {
                let _e54 = b_3;
                let _e57 = global_4.p[12];
                d_4 = (_e54 - _e57);
                let _e60 = d_4;
                let _e63 = global_4.p[13];
                let _e64 = mask_g(_e60, _e63);
                let _e65 = d_4;
                delta = (_e64 - _e65);
            }
        }
    }
    let _e69 = global_4.p[15];
    lim = _e69;
    let _e71 = delta;
    let _e72 = lim;
    let _e74 = lim;
    let _e75 = lim;
    let _e77 = delta;
    let _e78 = delta;
    return ((_e71 * _e72) * inverseSqrt(((_e74 * _e75) + (_e77 * _e78))));
}

fn main_1() {
    var W: u32;
    var H: u32;
    var gw: u32;
    var gh: u32;
    var nl_2: u32;
    var cell: u32;
    var cy: u32;
    var cx: u32;
    var x0_: u32;
    var x1_: u32;
    var y0_: u32;
    var y1_: u32;
    var acc: f32 = 0f;
    var y_6: u32;
    var x_14: u32;

    let _e17 = global_5.meta_[0];
    W = _e17;
    let _e21 = global_5.meta_[1];
    H = _e21;
    let _e25 = global_5.meta_[2];
    gw = _e25;
    let _e29 = global_5.meta_[3];
    gh = _e29;
    let _e33 = global_5.meta_[4];
    nl_2 = _e33;
    let _e37 = gl_GlobalInvocationID_1;
    let _e39 = gl_NumWorkGroups_1;
    let _e44 = gl_GlobalInvocationID_1;
    cell = ((_e37.y * (_e39.x * 256u)) + _e44.x);
    let _e48 = cell;
    let _e49 = gw;
    let _e50 = gh;
    if (_e48 >= (_e49 * _e50)) {
        return;
    }
    let _e53 = cell;
    let _e54 = gw;
    cy = (_e53 / _e54);
    let _e57 = cell;
    let _e58 = gw;
    cx = (_e57 % _e58);
    let _e61 = cx;
    let _e62 = W;
    let _e64 = gw;
    x0_ = ((_e61 * _e62) / _e64);
    let _e67 = cx;
    let _e70 = W;
    let _e72 = gw;
    let _e74 = x0_;
    x1_ = max((((_e67 + 1u) * _e70) / _e72), (_e74 + 1u));
    let _e79 = cy;
    let _e80 = H;
    let _e82 = gh;
    y0_ = ((_e79 * _e80) / _e82);
    let _e85 = cy;
    let _e88 = H;
    let _e90 = gh;
    let _e92 = y0_;
    y1_ = max((((_e85 + 1u) * _e88) / _e90), (_e92 + 1u));
    let _e97 = x1_;
    let _e98 = W;
    x1_ = min(_e97, _e98);
    let _e100 = y1_;
    let _e101 = H;
    y1_ = min(_e100, _e101);
    let _e105 = y0_;
    y_6 = _e105;
    loop {
        let _e107 = y_6;
        let _e108 = y1_;
        if !((_e107 < _e108)) {
            break;
        }
        let _e114 = x0_;
        x_14 = _e114;
        loop {
            let _e116 = x_14;
            let _e117 = x1_;
            if !((_e116 < _e117)) {
                break;
            }
            let _e123 = acc;
            let _e124 = y_6;
            let _e125 = W;
            let _e127 = x_14;
            let _e129 = nl_2;
            let _e130 = mask_image_exposure(((_e124 * _e125) + _e127), _e129);
            let _e131 = mask_x(_e130);
            acc = (_e123 + _e131);
            continuing {
                let _e120 = x_14;
                x_14 = (_e120 + 1u);
            }
        }
        continuing {
            let _e111 = y_6;
            y_6 = (_e111 + 1u);
        }
    }
    let _e133 = cell;
    let _e135 = acc;
    let _e136 = x1_;
    let _e137 = x0_;
    let _e139 = y1_;
    let _e140 = y0_;
    global_6.dst[_e133] = (_e135 / f32(((_e136 - _e137) * (_e139 - _e140))));
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
