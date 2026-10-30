struct B0_ {
    y: array<f32>,
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

fn main_1() {
    var i: u32;
    var pos: vec3<f32>;
    var lin: vec3<f32>;
    var lms: vec3<f32>;
    var L: f32;
    var a_2: f32;
    var b_2: f32;
    var C: f32;
    var h: f32;
    var d: f32;
    var local: f32;
    var w: f32;
    var g: f32;
    var h2_: f32;
    var C2_: f32;
    var l: vec3<f32>;
    var code: vec3<f32>;

    let _e10 = gl_GlobalInvocationID_1;
    let _e12 = gl_NumWorkGroups_1;
    let _e17 = gl_GlobalInvocationID_1;
    i = ((_e10.y * (_e12.x * 256u)) + _e17.x);
    let _e21 = i;
    let _e24 = global_2.n[0];
    if (_e21 >= _e24) {
        return;
    }
    let _e28 = i;
    let _e31 = global.y[(3u * _e28)];
    let _e34 = global_1.p[9];
    let _e36 = spk_pow(10f, (_e31 + _e34));
    let _e39 = i;
    let _e44 = global.y[((3u * _e39) + 1u)];
    let _e47 = global_1.p[10];
    let _e49 = spk_pow(10f, (_e44 + _e47));
    let _e52 = i;
    let _e57 = global.y[((3u * _e52) + 2u)];
    let _e60 = global_1.p[11];
    let _e62 = spk_pow(10f, (_e57 + _e60));
    pos = vec3<f32>(_e36, _e49, _e62);
    let _e65 = pos;
    let _e68 = global_1.p[40];
    let _e73 = global_1.p[9];
    let _e74 = spk_pow(10f, _e73);
    let _e78 = global_1.p[10];
    let _e79 = spk_pow(10f, _e78);
    let _e83 = global_1.p[11];
    let _e84 = spk_pow(10f, _e83);
    pos = (_e65 - (vec3(_e68) * vec3<f32>(_e74, _e79, _e84)));
    let _e88 = pos;
    let _e92 = global_1.p[0];
    let _e94 = pos;
    let _e98 = global_1.p[3];
    let _e101 = pos;
    let _e105 = global_1.p[6];
    let _e108 = pos;
    let _e112 = global_1.p[1];
    let _e114 = pos;
    let _e118 = global_1.p[4];
    let _e121 = pos;
    let _e125 = global_1.p[7];
    let _e128 = pos;
    let _e132 = global_1.p[2];
    let _e134 = pos;
    let _e138 = global_1.p[5];
    let _e141 = pos;
    let _e145 = global_1.p[8];
    lin = vec3<f32>((((_e88.x * _e92) + (_e94.y * _e98)) + (_e101.z * _e105)), (((_e108.x * _e112) + (_e114.y * _e118)) + (_e121.z * _e125)), (((_e128.x * _e132) + (_e134.y * _e138)) + (_e141.z * _e145)));
    let _e152 = global_1.p[30];
    if (_e152 != 0f) {
        {
            let _e157 = global_1.p[12];
            let _e158 = lin;
            let _e163 = global_1.p[13];
            let _e164 = lin;
            let _e170 = global_1.p[14];
            let _e171 = lin;
            let _e177 = global_1.p[15];
            let _e178 = lin;
            let _e183 = global_1.p[16];
            let _e184 = lin;
            let _e190 = global_1.p[17];
            let _e191 = lin;
            let _e197 = global_1.p[18];
            let _e198 = lin;
            let _e203 = global_1.p[19];
            let _e204 = lin;
            let _e210 = global_1.p[20];
            let _e211 = lin;
            lms = vec3<f32>((((_e157 * _e158.x) + (_e163 * _e164.y)) + (_e170 * _e171.z)), (((_e177 * _e178.x) + (_e183 * _e184.y)) + (_e190 * _e191.z)), (((_e197 * _e198.x) + (_e203 * _e204.y)) + (_e210 * _e211.z)));
            let _e217 = lms;
            let _e224 = spk_pow_1(max(_e217, vec3(0f)), 0.33333334f);
            lms = _e224;
            let _e226 = lms;
            let _e230 = lms;
            let _e235 = lms;
            L = (((0.21045426f * _e226.x) + (0.7936178f * _e230.y)) - (0.004072047f * _e235.z));
            let _e241 = lms;
            let _e245 = lms;
            let _e250 = lms;
            a_2 = (((1.9779985f * _e241.x) - (2.4285922f * _e245.y)) + (0.4505937f * _e250.z));
            let _e256 = lms;
            let _e260 = lms;
            let _e265 = lms;
            b_2 = (((0.025904037f * _e256.x) + (0.78277177f * _e260.y)) - (0.80867577f * _e265.z));
            let _e270 = a_2;
            let _e271 = a_2;
            let _e273 = b_2;
            let _e274 = b_2;
            C = sqrt(((_e270 * _e271) + (_e273 * _e274)));
            let _e279 = b_2;
            let _e280 = a_2;
            h = (atan2(_e279, _e280) * 57.29578f);
            let _e285 = h;
            let _e288 = global_1.p[33];
            let _e293 = spk_fmod(((_e285 - _e288) + 540f), 360f);
            d = (_e293 - 180f);
            let _e297 = d;
            let _e301 = global_1.p[34];
            if (abs(_e297) < _e301) {
                let _e306 = d;
                let _e310 = global_1.p[34];
                local = (0.5f * (1f + cos(((3.1415927f * _e306) / _e310))));
            } else {
                local = 0f;
            }
            let _e317 = local;
            w = _e317;
            let _e319 = C;
            let _e322 = global_1.p[35];
            let _e326 = global_1.p[36];
            let _e329 = global_1.p[35];
            g = clamp(((_e319 - _e322) / (_e326 - _e329)), 0f, 1f);
            let _e336 = w;
            let _e337 = g;
            let _e338 = g;
            let _e342 = g;
            w = (_e336 * ((_e337 * _e338) * (3f - (2f * _e342))));
            let _e347 = w;
            if (_e347 > 0f) {
                {
                    let _e350 = h;
                    let _e351 = w;
                    let _e354 = global_1.p[31];
                    h2_ = ((_e350 + (_e351 * _e354)) * 0.017453292f);
                    let _e360 = C;
                    let _e362 = w;
                    let _e365 = global_1.p[32];
                    C2_ = (_e360 * (1f + (_e362 * (_e365 - 1f))));
                    let _e372 = C2_;
                    let _e373 = h2_;
                    a_2 = (_e372 * cos(_e373));
                    let _e376 = C2_;
                    let _e377 = h2_;
                    b_2 = (_e376 * sin(_e377));
                    let _e380 = L;
                    let _e382 = a_2;
                    let _e386 = b_2;
                    let _e389 = L;
                    let _e391 = a_2;
                    let _e395 = b_2;
                    let _e398 = L;
                    let _e400 = a_2;
                    let _e404 = b_2;
                    l = vec3<f32>(((_e380 + (0.39633778f * _e382)) + (0.21580376f * _e386)), ((_e389 - (0.105561346f * _e391)) - (0.06385417f * _e395)), ((_e398 - (0.08948418f * _e400)) - (1.2914855f * _e404)));
                    let _e409 = l;
                    let _e410 = l;
                    let _e412 = l;
                    lms = ((_e409 * _e410) * _e412);
                    let _e416 = global_1.p[21];
                    let _e417 = lms;
                    let _e422 = global_1.p[22];
                    let _e423 = lms;
                    let _e429 = global_1.p[23];
                    let _e430 = lms;
                    let _e436 = global_1.p[24];
                    let _e437 = lms;
                    let _e442 = global_1.p[25];
                    let _e443 = lms;
                    let _e449 = global_1.p[26];
                    let _e450 = lms;
                    let _e456 = global_1.p[27];
                    let _e457 = lms;
                    let _e462 = global_1.p[28];
                    let _e463 = lms;
                    let _e469 = global_1.p[29];
                    let _e470 = lms;
                    lin = vec3<f32>((((_e416 * _e417.x) + (_e422 * _e423.y)) + (_e429 * _e430.z)), (((_e436 * _e437.x) + (_e442 * _e443.y)) + (_e449 * _e450.z)), (((_e456 * _e457.x) + (_e462 * _e463.y)) + (_e469 * _e470.z)));
                }
            }
        }
    }
    let _e477 = global_1.p[37];
    let _e480 = global_1.p[38];
    let _e481 = lin;
    let _e488 = global_1.p[41];
    let _e493 = global_1.p[41];
    let _e496 = spk_log10_1(((max(_e481, vec3(0f)) * (1f - _e488)) + vec3(_e493)));
    let _e502 = global_1.p[39];
    code = ((vec3(_e477) + (_e480 * _e496)) / vec3(_e502));
    let _e506 = code;
    code = clamp(_e506, vec3(0f), vec3(1f));
    let _e513 = i;
    let _e516 = code;
    global_3.dst[(3u * _e513)] = _e516.x;
    let _e519 = i;
    let _e524 = code;
    global_3.dst[((3u * _e519) + 1u)] = _e524.y;
    let _e527 = i;
    let _e532 = code;
    global_3.dst[((3u * _e527) + 2u)] = _e532.z;
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
