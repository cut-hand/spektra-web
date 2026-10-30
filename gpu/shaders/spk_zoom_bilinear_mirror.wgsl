struct Img {
    img: array<f32>,
}

struct Meta {
    meta_: array<u32>,
}

struct Out {
    dst: array<f32>,
}

@group(0) @binding(0) 
var<storage> global: Img;
@group(0) @binding(1) 
var<storage> global_1: Meta;
@group(0) @binding(2) 
var<storage, read_write> global_2: Out;
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
    let _e8 = gl_GlobalInvocationID_1;
    let _e10 = gl_NumWorkGroups_1;
    let _e15 = gl_GlobalInvocationID_1;
    return ((_e8.y * (_e10.x * 256u)) + _e15.x);
}

fn product(a_2: u32, b_2: u32) -> vec2<u32> {
    var a_3: u32;
    var b_3: u32;
    var hi_1: u32;
    var lo_1: u32;

    a_3 = a_2;
    b_3 = b_2;
    let _e14 = a_3;
    let _e15 = b_3;
    spk_umul_extended(_e14, _e15, (&hi_1), (&lo_1));
    let _e20 = lo_1;
    let _e21 = hi_1;
    return vec2<u32>(_e20, _e21);
}

fn less64_(a_4: vec2<u32>, b_4: vec2<u32>) -> bool {
    var a_5: vec2<u32>;
    var b_5: vec2<u32>;

    a_5 = a_4;
    b_5 = b_4;
    let _e12 = a_5;
    let _e14 = b_5;
    let _e17 = a_5;
    let _e19 = b_5;
    let _e22 = a_5;
    let _e24 = b_5;
    return ((_e12.y < _e14.y) || ((_e17.y == _e19.y) && (_e22.x < _e24.x)));
}

fn subtract64_(a_6: vec2<u32>, b_6: vec2<u32>) -> vec2<u32> {
    var a_7: vec2<u32>;
    var b_7: vec2<u32>;

    a_7 = a_6;
    b_7 = b_6;
    let _e12 = a_7;
    let _e14 = b_7;
    let _e17 = a_7;
    let _e19 = b_7;
    let _e22 = a_7;
    let _e24 = b_7;
    return vec2<u32>((_e12.x - _e14.x), ((_e17.y - _e19.y) - select(0u, 1u, (_e22.x < _e24.x))));
}

fn shift64_(a_8: vec2<u32>) -> vec2<u32> {
    var a_9: vec2<u32>;

    a_9 = a_8;
    let _e10 = a_9;
    let _e14 = a_9;
    let _e18 = a_9;
    return vec2<u32>((_e10.x << 1u), ((_e14.y << 1u) | (_e18.x >> 31u)));
}

fn divide64_(numerator: vec2<u32>, denominator: vec2<u32>, remainder: ptr<function, vec2<u32>>) -> u32 {
    var numerator_1: vec2<u32>;
    var denominator_1: vec2<u32>;
    var q: u32 = 0u;
    var r: u32;
    var bit: i32 = 31i;
    var carry: u32;
    var r_1: vec2<u32> = vec2(0u);
    var q_1: u32 = 0u;
    var bit_1: i32 = 63i;
    var local: u32;
    var digit: u32;

    numerator_1 = numerator;
    denominator_1 = denominator;
    let _e13 = denominator_1;
    if (_e13.y == 0u) {
        {
            let _e17 = numerator_1;
            if (_e17.y == 0u) {
                {
                    let _e21 = numerator_1;
                    let _e23 = denominator_1;
                    (*remainder) = vec2<u32>((_e21.x % _e23.x), 0u);
                    let _e28 = numerator_1;
                    let _e30 = denominator_1;
                    return (_e28.x / _e30.x);
                }
            }
            let _e35 = numerator_1;
            r = _e35.y;
            loop {
                let _e40 = bit;
                if !((_e40 >= 0i)) {
                    break;
                }
                {
                    let _e47 = r;
                    carry = (_e47 >> 31u);
                    let _e51 = r;
                    let _e54 = numerator_1;
                    let _e56 = bit;
                    r = ((_e51 << 1u) | ((_e54.x >> u32(_e56)) & 1u));
                    let _e62 = carry;
                    let _e65 = r;
                    let _e66 = denominator_1;
                    if ((_e62 != 0u) || (_e65 >= _e66.x)) {
                        {
                            let _e70 = r;
                            let _e71 = denominator_1;
                            r = (_e70 - _e71.x);
                            let _e74 = q;
                            let _e76 = bit;
                            q = (_e74 | (1u << u32(_e76)));
                        }
                    }
                }
                continuing {
                    let _e44 = bit;
                    bit = (_e44 - 1i);
                }
            }
            let _e80 = r;
            (*remainder) = vec2<u32>(_e80, 0u);
            let _e83 = q;
            return _e83;
        }
    }
    loop {
        let _e91 = bit_1;
        if !((_e91 >= 0i)) {
            break;
        }
        {
            let _e98 = bit_1;
            if (_e98 >= 32i) {
                let _e101 = numerator_1;
                let _e103 = bit_1;
                local = ((_e101.y >> u32((_e103 - 32i))) & 1u);
            } else {
                let _e110 = numerator_1;
                let _e112 = bit_1;
                local = ((_e110.x >> u32(_e112)) & 1u);
            }
            let _e118 = local;
            digit = _e118;
            let _e120 = r_1;
            let _e121 = shift64_(_e120);
            r_1 = _e121;
            let _e123 = r_1;
            let _e125 = digit;
            r_1.x = (_e123.x | _e125);
            let _e127 = r_1;
            let _e128 = denominator_1;
            let _e129 = less64_(_e127, _e128);
            if !(_e129) {
                {
                    let _e131 = r_1;
                    let _e132 = denominator_1;
                    let _e133 = subtract64_(_e131, _e132);
                    r_1 = _e133;
                    let _e134 = bit_1;
                    if (_e134 < 32i) {
                        let _e137 = q_1;
                        let _e139 = bit_1;
                        q_1 = (_e137 | (1u << u32(_e139)));
                    }
                }
            }
        }
        continuing {
            let _e95 = bit_1;
            bit_1 = (_e95 - 1i);
        }
    }
    let _e143 = r_1;
    (*remainder) = _e143;
    let _e144 = q_1;
    return _e144;
}

fn sample_axis(o: u32, in_len: u32, out_len: u32, i0_: ptr<function, u32>, i1_: ptr<function, u32>, t_1: ptr<function, f32>) {
    var o_1: u32;
    var in_len_1: u32;
    var out_len_1: u32;
    var p: vec2<u32>;
    var offset: vec2<u32>;
    var negative: bool;
    var local_1: vec2<u32>;
    var num: vec2<u32>;
    var den: vec2<u32>;
    var top: vec2<u32>;
    var twice_top: vec2<u32>;
    var local_2: vec2<u32>;
    var rem: vec2<u32>;
    var numerator_2: f32;
    var denominator_2: f32;

    o_1 = o;
    in_len_1 = in_len;
    out_len_1 = out_len;
    let _e18 = o_1;
    let _e22 = in_len_1;
    let _e23 = product(((2u * _e18) + 1u), _e22);
    p = _e23;
    let _e25 = out_len_1;
    offset = vec2<u32>(_e25, 0u);
    let _e29 = p;
    let _e30 = offset;
    let _e31 = less64_(_e29, _e30);
    negative = _e31;
    let _e33 = negative;
    if _e33 {
        let _e34 = offset;
        let _e35 = p;
        let _e36 = subtract64_(_e34, _e35);
        local_1 = _e36;
    } else {
        let _e37 = p;
        let _e38 = offset;
        let _e39 = subtract64_(_e37, _e38);
        local_1 = _e39;
    }
    let _e41 = local_1;
    num = _e41;
    let _e43 = out_len_1;
    let _e46 = out_len_1;
    den = vec2<u32>((_e43 << 1u), (_e46 >> 31u));
    let _e51 = out_len_1;
    let _e52 = in_len_1;
    let _e55 = product(_e51, (_e52 - 1u));
    let _e56 = shift64_(_e55);
    top = _e56;
    let _e58 = negative;
    let _e60 = top;
    let _e61 = num;
    let _e62 = less64_(_e60, _e61);
    if (!(_e58) && _e62) {
        {
            let _e64 = top;
            let _e65 = shift64_(_e64);
            twice_top = _e65;
            let _e67 = twice_top;
            let _e68 = num;
            let _e69 = less64_(_e67, _e68);
            if _e69 {
                let _e70 = num;
                let _e71 = twice_top;
                let _e72 = subtract64_(_e70, _e71);
                local_2 = _e72;
            } else {
                let _e73 = twice_top;
                let _e74 = num;
                let _e75 = subtract64_(_e73, _e74);
                local_2 = _e75;
            }
            let _e77 = local_2;
            num = _e77;
        }
    }
    let _e79 = num;
    let _e80 = den;
    let _e83 = divide64_(_e79, _e80, (&rem));
    (*i0_) = _e83;
    let _e84 = (*i0_);
    let _e87 = in_len_1;
    (*i1_) = min((_e84 + 1u), (_e87 - 1u));
    let _e91 = rem;
    let _e94 = rem;
    numerator_2 = (f32(_e91.x) + (f32(_e94.y) * 4294967300f));
    let _e101 = den;
    let _e104 = den;
    denominator_2 = (f32(_e101.x) + (f32(_e104.y) * 4294967300f));
    let _e111 = numerator_2;
    let _e112 = denominator_2;
    (*t_1) = (_e111 / _e112);
    return;
}

fn main_1() {
    var i: u32;
    var SH: u32;
    var SW: u32;
    var OH: u32;
    var OW: u32;
    var oy: u32;
    var ox: u32;
    var ya: u32;
    var yb: u32;
    var xa: u32;
    var xb: u32;
    var ty: f32;
    var tx: f32;
    var c: u32 = 0u;
    var a_10: f32;
    var b_8: f32;
    var d: f32;
    var e: f32;
    var top_1: f32;
    var bot: f32;
    var v: f32;

    let _e8 = spk_global_index();
    i = _e8;
    let _e12 = global_1.meta_[0];
    SH = _e12;
    let _e16 = global_1.meta_[1];
    SW = _e16;
    let _e20 = global_1.meta_[2];
    OH = _e20;
    let _e24 = global_1.meta_[3];
    OW = _e24;
    let _e26 = i;
    let _e27 = OH;
    let _e28 = OW;
    if (_e26 >= (_e27 * _e28)) {
        return;
    }
    let _e31 = i;
    let _e32 = OW;
    oy = (_e31 / _e32);
    let _e35 = i;
    let _e36 = OW;
    ox = (_e35 % _e36);
    let _e45 = oy;
    let _e46 = SH;
    let _e47 = OH;
    sample_axis(_e45, _e46, _e47, (&ya), (&yb), (&ty));
    let _e54 = ox;
    let _e55 = SW;
    let _e56 = OW;
    sample_axis(_e54, _e55, _e56, (&xa), (&xb), (&tx));
    loop {
        let _e65 = c;
        if !((_e65 < 3u)) {
            break;
        }
        {
            let _e73 = ya;
            let _e74 = SW;
            let _e76 = xa;
            let _e79 = c;
            let _e82 = global.img[((3u * ((_e73 * _e74) + _e76)) + _e79)];
            a_10 = _e82;
            let _e85 = ya;
            let _e86 = SW;
            let _e88 = xb;
            let _e91 = c;
            let _e94 = global.img[((3u * ((_e85 * _e86) + _e88)) + _e91)];
            b_8 = _e94;
            let _e97 = yb;
            let _e98 = SW;
            let _e100 = xa;
            let _e103 = c;
            let _e106 = global.img[((3u * ((_e97 * _e98) + _e100)) + _e103)];
            d = _e106;
            let _e109 = yb;
            let _e110 = SW;
            let _e112 = xb;
            let _e115 = c;
            let _e118 = global.img[((3u * ((_e109 * _e110) + _e112)) + _e115)];
            e = _e118;
            let _e120 = a_10;
            let _e121 = tx;
            let _e122 = b_8;
            let _e123 = a_10;
            top_1 = (_e120 + (_e121 * (_e122 - _e123)));
            let _e128 = d;
            let _e129 = tx;
            let _e130 = e;
            let _e131 = d;
            bot = (_e128 + (_e129 * (_e130 - _e131)));
            let _e136 = top_1;
            let _e137 = ty;
            let _e138 = bot;
            let _e139 = top_1;
            v = (_e136 + (_e137 * (_e138 - _e139)));
            let _e145 = i;
            let _e147 = c;
            let _e150 = v;
            global_2.dst[((3u * _e145) + _e147)] = _e150;
        }
        continuing {
            let _e69 = c;
            c = (_e69 + 1u);
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
