struct Input {
    value: array<f32>,
}

struct Geometry {
    value: array<f32>,
}

struct Meta {
    value: array<u32>,
}

struct Output {
    value: array<f32>,
}

@id(0) override SPK_FUSED_FMA: bool = true;

@group(0) @binding(0) 
var<storage> image_data: Input;
@group(0) @binding(1) 
var<storage> geometry: Geometry;
@group(0) @binding(2) 
var<storage> meta_: Meta;
@group(0) @binding(3) 
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
    let _e15 = gl_GlobalInvocationID_1;
    let _e17 = gl_NumWorkGroups_1;
    let _e22 = gl_GlobalInvocationID_1;
    return ((_e15.y * (_e17.x * 256u)) + _e22.x);
}

fn two_sum(a_2: f32, b_2: f32) -> vec2<f32> {
    var a_3: f32;
    var b_3: f32;
    var s: f32;
    var bb: f32;
    var e: f32;

    a_3 = a_2;
    b_3 = b_2;
    let _e19 = a_3;
    let _e20 = b_3;
    s = (_e19 + _e20);
    let _e23 = s;
    let _e24 = a_3;
    bb = (_e23 - _e24);
    let _e27 = a_3;
    let _e28 = s;
    let _e29 = bb;
    let _e32 = b_3;
    let _e33 = bb;
    e = ((_e27 - (_e28 - _e29)) + (_e32 - _e33));
    let _e37 = s;
    let _e38 = e;
    return vec2<f32>(_e37, _e38);
}

fn quick_two_sum(a_4: f32, b_4: f32) -> vec2<f32> {
    var a_5: f32;
    var b_5: f32;
    var s_1: f32;
    var e_1: f32;

    a_5 = a_4;
    b_5 = b_4;
    let _e19 = a_5;
    let _e20 = b_5;
    s_1 = (_e19 + _e20);
    let _e23 = b_5;
    let _e24 = s_1;
    let _e25 = a_5;
    e_1 = (_e23 - (_e24 - _e25));
    let _e29 = s_1;
    let _e30 = e_1;
    return vec2<f32>(_e29, _e30);
}

fn two_prod(a_6: f32, b_6: f32) -> vec2<f32> {
    var a_7: f32;
    var b_7: f32;
    var p: f32;
    var e_2: f32;
    var ca: f32;
    var ahi: f32;
    var alo: f32;
    var cb: f32;
    var bhi: f32;
    var blo: f32;
    var e_3: f32;

    a_7 = a_6;
    b_7 = b_6;
    let _e19 = a_7;
    let _e20 = b_7;
    p = (_e19 * _e20);
    if SPK_FUSED_FMA {
        {
            let _e23 = a_7;
            let _e24 = b_7;
            let _e25 = p;
            e_2 = fma(_e23, _e24, -(_e25));
            let _e29 = p;
            let _e30 = e_2;
            return vec2<f32>(_e29, _e30);
        }
    }
    let _e33 = a_7;
    ca = (4097f * _e33);
    let _e36 = ca;
    let _e37 = ca;
    let _e38 = a_7;
    ahi = (_e36 - (_e37 - _e38));
    let _e42 = a_7;
    let _e43 = ahi;
    alo = (_e42 - _e43);
    let _e47 = b_7;
    cb = (4097f * _e47);
    let _e50 = cb;
    let _e51 = cb;
    let _e52 = b_7;
    bhi = (_e50 - (_e51 - _e52));
    let _e56 = b_7;
    let _e57 = bhi;
    blo = (_e56 - _e57);
    let _e60 = ahi;
    let _e61 = bhi;
    let _e63 = p;
    let _e65 = ahi;
    let _e66 = blo;
    let _e69 = alo;
    let _e70 = bhi;
    let _e73 = alo;
    let _e74 = blo;
    e_3 = (((((_e60 * _e61) - _e63) + (_e65 * _e66)) + (_e69 * _e70)) + (_e73 * _e74));
    let _e78 = p;
    let _e79 = e_3;
    return vec2<f32>(_e78, _e79);
}

fn df_add(a_8: vec2<f32>, b_8: vec2<f32>) -> vec2<f32> {
    var a_9: vec2<f32>;
    var b_9: vec2<f32>;
    var s_2: vec2<f32>;
    var t_1: vec2<f32>;
    var lo_1: f32;
    var final_lo: f32;

    a_9 = a_8;
    b_9 = b_8;
    let _e19 = a_9;
    let _e21 = b_9;
    let _e23 = two_sum(_e19.x, _e21.x);
    s_2 = _e23;
    let _e25 = a_9;
    let _e27 = b_9;
    let _e29 = two_sum(_e25.y, _e27.y);
    t_1 = _e29;
    let _e31 = s_2;
    let _e33 = t_1;
    lo_1 = (_e31.y + _e33.x);
    let _e37 = s_2;
    let _e39 = lo_1;
    let _e40 = quick_two_sum(_e37.x, _e39);
    s_2 = _e40;
    let _e41 = s_2;
    let _e43 = t_1;
    final_lo = (_e41.y + _e43.y);
    let _e47 = s_2;
    let _e49 = final_lo;
    let _e50 = quick_two_sum(_e47.x, _e49);
    return _e50;
}

fn df_sub(a_10: vec2<f32>, b_10: vec2<f32>) -> vec2<f32> {
    var a_11: vec2<f32>;
    var b_11: vec2<f32>;

    a_11 = a_10;
    b_11 = b_10;
    let _e19 = a_11;
    let _e20 = b_11;
    let _e22 = df_add(_e19, -(_e20));
    return _e22;
}

fn df_mul(a_12: vec2<f32>, b_12: vec2<f32>) -> vec2<f32> {
    var a_13: vec2<f32>;
    var b_13: vec2<f32>;
    var p_1: vec2<f32>;
    var cross_terms: f32;
    var lo_2: f32;

    a_13 = a_12;
    b_13 = b_12;
    let _e19 = a_13;
    let _e21 = b_13;
    let _e23 = two_prod(_e19.x, _e21.x);
    p_1 = _e23;
    let _e25 = a_13;
    let _e27 = b_13;
    let _e30 = a_13;
    let _e32 = b_13;
    cross_terms = ((_e25.x * _e27.y) + (_e30.y * _e32.x));
    let _e37 = p_1;
    let _e39 = cross_terms;
    lo_2 = (_e37.y + _e39);
    let _e42 = p_1;
    let _e44 = lo_2;
    let _e45 = quick_two_sum(_e42.x, _e44);
    return _e45;
}

fn df_mul_f(a_14: vec2<f32>, b_14: f32) -> vec2<f32> {
    var a_15: vec2<f32>;
    var b_15: f32;
    var p_2: vec2<f32>;
    var lo_3: f32;

    a_15 = a_14;
    b_15 = b_14;
    let _e19 = a_15;
    let _e21 = b_15;
    let _e22 = two_prod(_e19.x, _e21);
    p_2 = _e22;
    let _e24 = p_2;
    let _e26 = a_15;
    let _e28 = b_15;
    lo_3 = (_e24.y + (_e26.y * _e28));
    let _e32 = p_2;
    let _e34 = lo_3;
    let _e35 = quick_two_sum(_e32.x, _e34);
    return _e35;
}

fn pair_at(index: u32) -> vec2<f32> {
    var index_1: u32;

    index_1 = index;
    let _e18 = index_1;
    let _e22 = geometry.value[(2u * _e18)];
    let _e24 = index_1;
    let _e30 = geometry.value[((2u * _e24) + 1u)];
    return vec2<f32>(_e22, _e30);
}

fn main_1() {
    var i: u32;
    var sh: u32;
    var sw: u32;
    var oh: u32;
    var ow: u32;
    var turns: u32;
    var flips: u32;
    var oy: u32;
    var ox: u32;
    var u: f32;
    var v: f32;
    var t_2: f32;
    var px: vec2<f32>;
    var py: vec2<f32>;
    var ca_1: vec2<f32>;
    var sa: vec2<f32>;
    var fx: vec2<f32>;
    var fy: vec2<f32>;
    var w1_1: f32;
    var h1_: f32;
    var x0f: f32;
    var y0f: f32;
    var tx: f32;
    var ty: f32;
    var x0_: u32;
    var y0_: u32;
    var x1_: u32;
    var y1_: u32;
    var c: u32 = 0u;
    var a_16: f32;
    var b_16: f32;
    var d: f32;
    var e_4: f32;
    var top: f32;
    var bot: f32;
    var result: f32;

    let _e15 = spk_global_index();
    i = _e15;
    let _e20 = meta_.value[0];
    sh = _e20;
    let _e25 = meta_.value[1];
    sw = _e25;
    let _e30 = meta_.value[2];
    oh = _e30;
    let _e35 = meta_.value[3];
    ow = _e35;
    let _e40 = meta_.value[4];
    turns = _e40;
    let _e45 = meta_.value[5];
    flips = _e45;
    let _e47 = i;
    let _e48 = oh;
    let _e49 = ow;
    if (_e47 >= (_e48 * _e49)) {
        return;
    }
    let _e52 = i;
    let _e53 = ow;
    oy = (_e52 / _e53);
    let _e56 = i;
    let _e57 = ow;
    ox = (_e56 % _e57);
    let _e60 = ox;
    u = (f32(_e60) + 0.5f);
    let _e65 = oy;
    v = (f32(_e65) + 0.5f);
    let _e70 = flips;
    if ((_e70 & 1u) != 0u) {
        let _e75 = ow;
        let _e77 = u;
        u = (f32(_e75) - _e77);
    }
    let _e79 = flips;
    if ((_e79 & 2u) != 0u) {
        let _e84 = oh;
        let _e86 = v;
        v = (f32(_e84) - _e86);
    }
    let _e89 = turns;
    switch _e89 {
        case 1u: {
            let _e90 = u;
            t_2 = _e90;
            let _e91 = v;
            u = _e91;
            let _e92 = ow;
            let _e94 = t_2;
            v = (f32(_e92) - _e94);
        }
        case 2u: {
            let _e96 = ow;
            let _e98 = u;
            u = (f32(_e96) - _e98);
            let _e100 = oh;
            let _e102 = v;
            v = (f32(_e100) - _e102);
        }
        case 3u: {
            let _e104 = u;
            t_2 = _e104;
            let _e105 = oh;
            let _e107 = v;
            u = (f32(_e105) - _e107);
            let _e109 = t_2;
            v = _e109;
        }
        default: {
        }
    }
    let _e111 = pair_at(0u);
    let _e112 = u;
    let _e113 = df_mul_f(_e111, _e112);
    let _e115 = pair_at(2u);
    let _e116 = df_sub(_e113, _e115);
    px = _e116;
    let _e119 = pair_at(1u);
    let _e120 = v;
    let _e121 = df_mul_f(_e119, _e120);
    let _e123 = pair_at(3u);
    let _e124 = df_sub(_e121, _e123);
    py = _e124;
    let _e127 = pair_at(6u);
    ca_1 = _e127;
    let _e130 = pair_at(7u);
    sa = _e130;
    let _e133 = pair_at(4u);
    let _e134 = px;
    let _e135 = ca_1;
    let _e136 = df_mul(_e134, _e135);
    let _e137 = py;
    let _e138 = sa;
    let _e139 = df_mul(_e137, _e138);
    let _e140 = df_sub(_e136, _e139);
    let _e141 = df_add(_e133, _e140);
    fx = _e141;
    let _e144 = pair_at(5u);
    let _e145 = px;
    let _e146 = sa;
    let _e147 = df_mul(_e145, _e146);
    let _e148 = py;
    let _e149 = ca_1;
    let _e150 = df_mul(_e148, _e149);
    let _e151 = df_add(_e147, _e150);
    let _e152 = df_add(_e144, _e151);
    fy = _e152;
    let _e154 = sw;
    w1_1 = (f32(_e154) - 1f);
    let _e159 = sh;
    h1_ = (f32(_e159) - 1f);
    let _e168 = fx;
    if (_e168.x <= 0f) {
        {
            x0f = 0f;
            tx = 0f;
        }
    } else {
        let _e174 = fx;
        let _e176 = w1_1;
        if (_e174.x >= _e176) {
            {
                let _e178 = w1_1;
                x0f = _e178;
                tx = 0f;
            }
        } else {
            {
                let _e180 = fx;
                x0f = floor(_e180.x);
                let _e183 = fx;
                let _e185 = x0f;
                let _e187 = fx;
                tx = clamp(((_e183.x - _e185) + _e187.y), 0f, 1f);
            }
        }
    }
    let _e193 = fy;
    if (_e193.x <= 0f) {
        {
            y0f = 0f;
            ty = 0f;
        }
    } else {
        let _e199 = fy;
        let _e201 = h1_;
        if (_e199.x >= _e201) {
            {
                let _e203 = h1_;
                y0f = _e203;
                ty = 0f;
            }
        } else {
            {
                let _e205 = fy;
                y0f = floor(_e205.x);
                let _e208 = fy;
                let _e210 = y0f;
                let _e212 = fy;
                ty = clamp(((_e208.x - _e210) + _e212.y), 0f, 1f);
            }
        }
    }
    let _e218 = x0f;
    x0_ = u32(_e218);
    let _e221 = y0f;
    y0_ = u32(_e221);
    let _e224 = x0_;
    let _e227 = sw;
    x1_ = min((_e224 + 1u), (_e227 - 1u));
    let _e232 = y0_;
    let _e235 = sh;
    y1_ = min((_e232 + 1u), (_e235 - 1u));
    loop {
        let _e242 = c;
        if !((_e242 < 3u)) {
            break;
        }
        {
            let _e250 = y0_;
            let _e251 = sw;
            let _e253 = x0_;
            let _e256 = c;
            let _e260 = image_data.value[((3u * ((_e250 * _e251) + _e253)) + _e256)];
            a_16 = _e260;
            let _e263 = y0_;
            let _e264 = sw;
            let _e266 = x1_;
            let _e269 = c;
            let _e273 = image_data.value[((3u * ((_e263 * _e264) + _e266)) + _e269)];
            b_16 = _e273;
            let _e276 = y1_;
            let _e277 = sw;
            let _e279 = x0_;
            let _e282 = c;
            let _e286 = image_data.value[((3u * ((_e276 * _e277) + _e279)) + _e282)];
            d = _e286;
            let _e289 = y1_;
            let _e290 = sw;
            let _e292 = x1_;
            let _e295 = c;
            let _e299 = image_data.value[((3u * ((_e289 * _e290) + _e292)) + _e295)];
            e_4 = _e299;
            let _e301 = a_16;
            let _e303 = tx;
            let _e306 = b_16;
            let _e307 = tx;
            top = ((_e301 * (1f - _e303)) + (_e306 * _e307));
            let _e311 = d;
            let _e313 = tx;
            let _e316 = e_4;
            let _e317 = tx;
            bot = ((_e311 * (1f - _e313)) + (_e316 * _e317));
            let _e321 = top;
            let _e323 = ty;
            let _e326 = bot;
            let _e327 = ty;
            result = ((_e321 * (1f - _e323)) + (_e326 * _e327));
            let _e332 = i;
            let _e334 = c;
            let _e338 = result;
            output_data.value[((3u * _e332) + _e334)] = _e338;
        }
        continuing {
            let _e246 = c;
            c = (_e246 + 1u);
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
