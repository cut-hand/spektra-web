struct Input {
    value: array<f32>,
}

struct Coefficients {
    value: array<f32>,
}

struct Active {
    value: array<u32>,
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

@id(0) override SPK_FUSED_FMA: bool = true;

@group(0) @binding(0) 
var<storage> image_data: Input;
@group(0) @binding(1) 
var<storage> coefficients: Coefficients;
@group(0) @binding(2) 
var<storage> active_channels: Active;
@group(0) @binding(3) 
var<storage> accumulator: Accumulator;
@group(0) @binding(4) 
var<storage> mix_weights: MixWeights;
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
    let _e24 = gl_GlobalInvocationID_1;
    let _e26 = gl_NumWorkGroups_1;
    let _e31 = gl_GlobalInvocationID_1;
    return ((_e24.y * (_e26.x * 256u)) + _e31.x);
}

fn two_sum(a_2: f32, b_2: f32) -> vec2<f32> {
    var a_3: f32;
    var b_3: f32;
    var s: f32;
    var bb: f32;
    var e: f32;

    a_3 = a_2;
    b_3 = b_2;
    let _e28 = a_3;
    let _e29 = b_3;
    s = (_e28 + _e29);
    let _e32 = s;
    let _e33 = a_3;
    bb = (_e32 - _e33);
    let _e36 = a_3;
    let _e37 = s;
    let _e38 = bb;
    let _e41 = b_3;
    let _e42 = bb;
    e = ((_e36 - (_e37 - _e38)) + (_e41 - _e42));
    let _e46 = s;
    let _e47 = e;
    return vec2<f32>(_e46, _e47);
}

fn quick_two_sum(a_4: f32, b_4: f32) -> vec2<f32> {
    var a_5: f32;
    var b_5: f32;
    var s_1: f32;
    var e_1: f32;

    a_5 = a_4;
    b_5 = b_4;
    let _e28 = a_5;
    let _e29 = b_5;
    s_1 = (_e28 + _e29);
    let _e32 = b_5;
    let _e33 = s_1;
    let _e34 = a_5;
    e_1 = (_e32 - (_e33 - _e34));
    let _e38 = s_1;
    let _e39 = e_1;
    return vec2<f32>(_e38, _e39);
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
    let _e28 = a_7;
    let _e29 = b_7;
    p = (_e28 * _e29);
    if SPK_FUSED_FMA {
        {
            let _e32 = a_7;
            let _e33 = b_7;
            let _e34 = p;
            e_2 = fma(_e32, _e33, -(_e34));
            let _e38 = p;
            let _e39 = e_2;
            return vec2<f32>(_e38, _e39);
        }
    }
    let _e42 = a_7;
    ca = (4097f * _e42);
    let _e45 = ca;
    let _e46 = ca;
    let _e47 = a_7;
    ahi = (_e45 - (_e46 - _e47));
    let _e51 = a_7;
    let _e52 = ahi;
    alo = (_e51 - _e52);
    let _e56 = b_7;
    cb = (4097f * _e56);
    let _e59 = cb;
    let _e60 = cb;
    let _e61 = b_7;
    bhi = (_e59 - (_e60 - _e61));
    let _e65 = b_7;
    let _e66 = bhi;
    blo = (_e65 - _e66);
    let _e69 = ahi;
    let _e70 = bhi;
    let _e72 = p;
    let _e74 = ahi;
    let _e75 = blo;
    let _e78 = alo;
    let _e79 = bhi;
    let _e82 = alo;
    let _e83 = blo;
    e_3 = (((((_e69 * _e70) - _e72) + (_e74 * _e75)) + (_e78 * _e79)) + (_e82 * _e83));
    let _e87 = p;
    let _e88 = e_3;
    return vec2<f32>(_e87, _e88);
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
    let _e28 = a_9;
    let _e30 = b_9;
    let _e32 = two_sum(_e28.x, _e30.x);
    s_2 = _e32;
    let _e34 = a_9;
    let _e36 = b_9;
    let _e38 = two_sum(_e34.y, _e36.y);
    t_1 = _e38;
    let _e40 = s_2;
    let _e42 = t_1;
    lo_1 = (_e40.y + _e42.x);
    let _e46 = s_2;
    let _e48 = lo_1;
    let _e49 = quick_two_sum(_e46.x, _e48);
    s_2 = _e49;
    let _e50 = s_2;
    let _e52 = t_1;
    final_lo = (_e50.y + _e52.y);
    let _e56 = s_2;
    let _e58 = final_lo;
    let _e59 = quick_two_sum(_e56.x, _e58);
    return _e59;
}

fn df_mul(a_10: vec2<f32>, b_10: vec2<f32>) -> vec2<f32> {
    var a_11: vec2<f32>;
    var b_11: vec2<f32>;
    var p_1: vec2<f32>;
    var cross_terms: f32;
    var lo_2: f32;

    a_11 = a_10;
    b_11 = b_10;
    let _e28 = a_11;
    let _e30 = b_11;
    let _e32 = two_prod(_e28.x, _e30.x);
    p_1 = _e32;
    let _e34 = a_11;
    let _e36 = b_11;
    let _e39 = a_11;
    let _e41 = b_11;
    cross_terms = ((_e34.x * _e36.y) + (_e39.y * _e41.x));
    let _e46 = p_1;
    let _e48 = cross_terms;
    lo_2 = (_e46.y + _e48);
    let _e51 = p_1;
    let _e53 = lo_2;
    let _e54 = quick_two_sum(_e51.x, _e53);
    return _e54;
}

fn df_mul_f(a_12: vec2<f32>, b_12: f32) -> vec2<f32> {
    var a_13: vec2<f32>;
    var b_13: f32;
    var p_2: vec2<f32>;
    var lo_3: f32;

    a_13 = a_12;
    b_13 = b_12;
    let _e28 = a_13;
    let _e30 = b_13;
    let _e31 = two_prod(_e28.x, _e30);
    p_2 = _e31;
    let _e33 = p_2;
    let _e35 = a_13;
    let _e37 = b_13;
    lo_3 = (_e33.y + (_e35.y * _e37));
    let _e41 = p_2;
    let _e43 = lo_3;
    let _e44 = quick_two_sum(_e41.x, _e43);
    return _e44;
}

fn main_1() {
    var t_2: u32;
    var height: u32;
    var width: u32;
    var accumulate: u32;
    var axis: u32;
    var local: u32;
    var threads: u32;
    var channel: u32;
    var line: u32;
    var local_1: u32;
    var length_: u32;
    var local_2: u32;
    var stride: u32;
    var local_3: u32;
    var base: u32;
    var B: vec2<f32>;
    var B1_: vec2<f32>;
    var B2_: vec2<f32>;
    var B3_: vec2<f32>;
    var i: u32 = 0u;
    var index: u32;
    var mixed: f32;
    var local_4: f32;
    var x0_: f32;
    var w1_1: vec2<f32>;
    var w2_1: vec2<f32>;
    var w3_: vec2<f32>;
    var i_1: u32 = 0u;
    var v: vec2<f32>;
    var xn: f32;
    var y1_: vec2<f32>;
    var y2_: vec2<f32>;
    var y3_: vec2<f32>;
    var i_2: i32;
    var index_1: u32;
    var v_1: vec2<f32>;
    var mixed_1: f32;
    var local_5: f32;

    let _e24 = spk_global_index();
    t_2 = _e24;
    let _e29 = meta_.value[0];
    height = _e29;
    let _e34 = meta_.value[1];
    width = _e34;
    let _e39 = meta_.value[2];
    accumulate = _e39;
    let _e44 = meta_.value[3];
    axis = _e44;
    let _e46 = axis;
    if (_e46 == 0u) {
        let _e49 = width;
        local = (_e49 * 3u);
    } else {
        let _e52 = height;
        local = (_e52 * 3u);
    }
    let _e56 = local;
    threads = _e56;
    let _e58 = t_2;
    let _e59 = threads;
    if (_e58 >= _e59) {
        return;
    }
    let _e61 = t_2;
    channel = (_e61 % 3u);
    let _e65 = t_2;
    line = (_e65 / 3u);
    let _e69 = axis;
    if (_e69 == 0u) {
        let _e72 = height;
        local_1 = _e72;
    } else {
        let _e73 = width;
        local_1 = _e73;
    }
    let _e75 = local_1;
    length_ = _e75;
    let _e77 = axis;
    if (_e77 == 0u) {
        let _e80 = width;
        local_2 = (_e80 * 3u);
    } else {
        local_2 = 3u;
    }
    let _e85 = local_2;
    stride = _e85;
    let _e87 = axis;
    if (_e87 == 0u) {
        let _e90 = line;
        let _e93 = channel;
        local_3 = ((_e90 * 3u) + _e93);
    } else {
        let _e95 = line;
        let _e96 = width;
        let _e100 = channel;
        local_3 = (((_e95 * _e96) * 3u) + _e100);
    }
    let _e103 = local_3;
    base = _e103;
    let _e106 = channel;
    let _e110 = coefficients.value[(8u * _e106)];
    let _e112 = channel;
    let _e118 = coefficients.value[((8u * _e112) + 1u)];
    B = vec2<f32>(_e110, _e118);
    let _e122 = channel;
    let _e128 = coefficients.value[((8u * _e122) + 2u)];
    let _e130 = channel;
    let _e136 = coefficients.value[((8u * _e130) + 3u)];
    B1_ = vec2<f32>(_e128, _e136);
    let _e140 = channel;
    let _e146 = coefficients.value[((8u * _e140) + 4u)];
    let _e148 = channel;
    let _e154 = coefficients.value[((8u * _e148) + 5u)];
    B2_ = vec2<f32>(_e146, _e154);
    let _e158 = channel;
    let _e164 = coefficients.value[((8u * _e158) + 6u)];
    let _e166 = channel;
    let _e172 = coefficients.value[((8u * _e166) + 7u)];
    B3_ = vec2<f32>(_e164, _e172);
    let _e175 = channel;
    let _e178 = active_channels.value[_e175];
    if (_e178 == 0u) {
        {
            loop {
                let _e183 = i;
                let _e184 = length_;
                if !((_e183 < _e184)) {
                    break;
                }
                {
                    let _e190 = base;
                    let _e191 = i;
                    let _e192 = stride;
                    index = (_e190 + (_e191 * _e192));
                    let _e196 = index;
                    let _e199 = accumulator.value[_e196];
                    let _e200 = channel;
                    let _e203 = mix_weights.value[_e200];
                    let _e204 = index;
                    let _e207 = image_data.value[_e204];
                    mixed = (_e199 + (_e203 * _e207));
                    let _e211 = index;
                    let _e214 = accumulate;
                    if (_e214 != 0u) {
                        let _e217 = mixed;
                        local_4 = _e217;
                    } else {
                        let _e218 = index;
                        let _e221 = image_data.value[_e218];
                        local_4 = _e221;
                    }
                    let _e223 = local_4;
                    output_data.value[_e211] = _e223;
                }
                continuing {
                    let _e187 = i;
                    i = (_e187 + 1u);
                }
            }
            return;
        }
    }
    let _e224 = base;
    let _e227 = image_data.value[_e224];
    x0_ = _e227;
    let _e229 = x0_;
    w1_1 = vec2<f32>(_e229, 0f);
    let _e233 = w1_1;
    w2_1 = _e233;
    let _e235 = w1_1;
    w3_ = _e235;
    loop {
        let _e239 = i_1;
        let _e240 = length_;
        if !((_e239 < _e240)) {
            break;
        }
        {
            let _e246 = B;
            let _e247 = base;
            let _e248 = i_1;
            let _e249 = stride;
            let _e254 = image_data.value[(_e247 + (_e248 * _e249))];
            let _e255 = df_mul_f(_e246, _e254);
            v = _e255;
            let _e257 = v;
            let _e258 = B1_;
            let _e259 = w1_1;
            let _e260 = df_mul(_e258, _e259);
            let _e261 = df_add(_e257, _e260);
            v = _e261;
            let _e262 = v;
            let _e263 = B2_;
            let _e264 = w2_1;
            let _e265 = df_mul(_e263, _e264);
            let _e266 = df_add(_e262, _e265);
            v = _e266;
            let _e267 = v;
            let _e268 = B3_;
            let _e269 = w3_;
            let _e270 = df_mul(_e268, _e269);
            let _e271 = df_add(_e267, _e270);
            v = _e271;
            let _e272 = base;
            let _e273 = i_1;
            let _e274 = stride;
            let _e279 = v;
            output_data.value[(_e272 + (_e273 * _e274))] = _e279.x;
            let _e281 = w2_1;
            w3_ = _e281;
            let _e282 = w1_1;
            w2_1 = _e282;
            let _e283 = v;
            w1_1 = _e283;
        }
        continuing {
            let _e243 = i_1;
            i_1 = (_e243 + 1u);
        }
    }
    let _e284 = base;
    let _e285 = length_;
    let _e288 = stride;
    let _e293 = output_data.value[(_e284 + ((_e285 - 1u) * _e288))];
    xn = _e293;
    let _e295 = xn;
    y1_ = vec2<f32>(_e295, 0f);
    let _e299 = y1_;
    y2_ = _e299;
    let _e301 = y1_;
    y3_ = _e301;
    let _e303 = length_;
    i_2 = (i32(_e303) - 1i);
    loop {
        let _e308 = i_2;
        if !((_e308 >= 0i)) {
            break;
        }
        {
            let _e315 = base;
            let _e316 = i_2;
            let _e318 = stride;
            index_1 = (_e315 + (u32(_e316) * _e318));
            let _e322 = B;
            let _e323 = index_1;
            let _e326 = output_data.value[_e323];
            let _e327 = df_mul_f(_e322, _e326);
            v_1 = _e327;
            let _e329 = v_1;
            let _e330 = B1_;
            let _e331 = y1_;
            let _e332 = df_mul(_e330, _e331);
            let _e333 = df_add(_e329, _e332);
            v_1 = _e333;
            let _e334 = v_1;
            let _e335 = B2_;
            let _e336 = y2_;
            let _e337 = df_mul(_e335, _e336);
            let _e338 = df_add(_e334, _e337);
            v_1 = _e338;
            let _e339 = v_1;
            let _e340 = B3_;
            let _e341 = y3_;
            let _e342 = df_mul(_e340, _e341);
            let _e343 = df_add(_e339, _e342);
            v_1 = _e343;
            let _e344 = index_1;
            let _e347 = accumulator.value[_e344];
            let _e348 = channel;
            let _e351 = mix_weights.value[_e348];
            let _e352 = v_1;
            mixed_1 = (_e347 + (_e351 * _e352.x));
            let _e357 = index_1;
            let _e360 = accumulate;
            if (_e360 != 0u) {
                let _e363 = mixed_1;
                local_5 = _e363;
            } else {
                let _e364 = v_1;
                local_5 = _e364.x;
            }
            let _e367 = local_5;
            output_data.value[_e357] = _e367;
            let _e368 = y2_;
            y3_ = _e368;
            let _e369 = y1_;
            y2_ = _e369;
            let _e370 = v_1;
            y1_ = _e370;
        }
        continuing {
            let _e312 = i_2;
            i_2 = (_e312 - 1i);
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
