struct Input {
    value: array<f32>,
}

struct ToXyz {
    value: array<f32>,
}

struct ToRgb {
    value: array<f32>,
}

struct CMax {
    value: array<f32>,
}

struct Constants {
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
var<storage> m2x: ToXyz;
@group(0) @binding(2) 
var<storage> m2r: ToRgb;
@group(0) @binding(3) 
var<storage> cmax: CMax;
@group(0) @binding(4) 
var<storage> constants: Constants;
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
    var i: u32;
    var nL: u32;
    var nh: u32;
    var lc_active: u32;
    var F_L: f32;
    var N_bb: f32;
    var N_cb: f32;
    var n_value: f32;
    var z: f32;
    var A_w: f32;
    var c_value: f32;
    var N_c: f32;
    var L_grid0_: f32;
    var L_grid1_: f32;
    var h_grid0_: f32;
    var h_step: f32;
    var threshold: f32;
    var limit: f32;
    var power_value: f32;
    var lc_threshold: f32;
    var lc_limit: f32;
    var lc_power: f32;
    var L_white: f32;
    var D0_: f32;
    var D1_: f32;
    var D2_: f32;
    var e_c: f32;
    var FL4_: f32;
    var r: f32;
    var g: f32;
    var b_input: f32;
    var X: f32;
    var Y: f32;
    var Z: f32;
    var R: f32;
    var G: f32;
    var B: f32;
    var Rc: f32;
    var Gc: f32;
    var Bc: f32;
    var local: f32;
    var sR: f32;
    var local_1: f32;
    var sG: f32;
    var local_2: f32;
    var sB: f32;
    var fR: f32;
    var fG: f32;
    var fB: f32;
    var Ra: f32;
    var Ga: f32;
    var Ba: f32;
    var a_2: f32;
    var bb: f32;
    var hrad: f32;
    var e_t: f32;
    var A: f32;
    var Aratio: f32;
    var local_3: f32;
    var sJ: f32;
    var J: f32;
    var den: f32;
    var t_1: f32 = 0f;
    var sq: f32;
    var local_4: f32;
    var C: f32;
    var Mp: f32;
    var Jp: f32;
    var Ln: f32;
    var lsc: f32;
    var lx: f32;
    var ly: f32;
    var Lc: f32;
    var Li: f32;
    var l0_: i32;
    var lf: f32;
    var hue_index: f32;
    var hue_floor: f32;
    var nhi: i32;
    var h0_: i32;
    var h1_: i32;
    var hf: f32;
    var c00_: f32;
    var c01_: f32;
    var c10_: f32;
    var c11_: f32;
    var Cmax: f32;
    var local_5: f32;
    var safe_value: f32;
    var d: f32;
    var scale: f32;
    var xk: f32;
    var yk: f32;
    var Mp_new: f32;
    var M_new: f32;
    var J_new: f32;
    var C_new: f32;
    var local_6: f32;
    var sJ2_: f32;
    var A2_: f32;
    var sq2_: f32;
    var local_7: f32;
    var t2_: f32;
    var ca: f32;
    var sa: f32;
    var p2_: f32;
    var p3_: f32 = 1.05f;
    var a2_: f32;
    var b2_: f32;
    var p1_: f32;
    var p4_: f32;
    var p5_: f32;
    var Ra2_: f32;
    var Ga2_: f32;
    var Ba2_: f32;
    var vm: f32;
    var local_8: f32;
    var sign_value: f32;
    var local_9: f32;
    var base_value: f32;
    var Rf: f32;
    var local_10: f32;
    var local_11: f32;
    var Gf: f32;
    var local_12: f32;
    var local_13: f32;
    var Bf: f32;
    var Xn: f32;
    var Yn: f32;
    var Zn: f32;

    let _e23 = spk_global_index();
    i = _e23;
    let _e25 = i;
    let _e29 = meta_.value[0];
    if (_e25 >= _e29) {
        return;
    }
    let _e34 = meta_.value[1];
    nL = _e34;
    let _e39 = meta_.value[2];
    nh = _e39;
    let _e44 = meta_.value[3];
    lc_active = _e44;
    let _e49 = constants.value[0];
    F_L = _e49;
    let _e54 = constants.value[1];
    N_bb = _e54;
    let _e59 = constants.value[2];
    N_cb = _e59;
    let _e64 = constants.value[3];
    n_value = _e64;
    let _e69 = constants.value[4];
    z = _e69;
    let _e74 = constants.value[5];
    A_w = _e74;
    let _e79 = constants.value[6];
    c_value = _e79;
    let _e84 = constants.value[7];
    N_c = _e84;
    let _e89 = constants.value[8];
    L_grid0_ = _e89;
    let _e94 = constants.value[9];
    L_grid1_ = _e94;
    let _e99 = constants.value[10];
    h_grid0_ = _e99;
    let _e104 = constants.value[11];
    h_step = _e104;
    let _e109 = constants.value[12];
    threshold = _e109;
    let _e114 = constants.value[13];
    limit = _e114;
    let _e119 = constants.value[14];
    power_value = _e119;
    let _e124 = constants.value[15];
    lc_threshold = _e124;
    let _e129 = constants.value[16];
    lc_limit = _e129;
    let _e134 = constants.value[17];
    lc_power = _e134;
    let _e139 = constants.value[18];
    L_white = _e139;
    let _e144 = constants.value[19];
    D0_ = _e144;
    let _e149 = constants.value[20];
    D1_ = _e149;
    let _e154 = constants.value[21];
    D2_ = _e154;
    let _e158 = n_value;
    e_c = pow((1.64f - pow(0.29f, _e158)), 0.73f);
    let _e164 = F_L;
    FL4_ = pow(_e164, 0.25f);
    let _e169 = i;
    let _e173 = input_data.value[(3u * _e169)];
    r = _e173;
    let _e176 = i;
    let _e182 = input_data.value[((3u * _e176) + 1u)];
    g = _e182;
    let _e185 = i;
    let _e191 = input_data.value[((3u * _e185) + 2u)];
    b_input = _e191;
    let _e196 = m2x.value[0];
    let _e197 = r;
    let _e202 = m2x.value[1];
    let _e203 = g;
    let _e209 = m2x.value[2];
    let _e210 = b_input;
    X = (((_e196 * _e197) + (_e202 * _e203)) + (_e209 * _e210));
    let _e217 = m2x.value[3];
    let _e218 = r;
    let _e223 = m2x.value[4];
    let _e224 = g;
    let _e230 = m2x.value[5];
    let _e231 = b_input;
    Y = (((_e217 * _e218) + (_e223 * _e224)) + (_e230 * _e231));
    let _e238 = m2x.value[6];
    let _e239 = r;
    let _e244 = m2x.value[7];
    let _e245 = g;
    let _e251 = m2x.value[8];
    let _e252 = b_input;
    Z = (((_e238 * _e239) + (_e244 * _e245)) + (_e251 * _e252));
    let _e256 = X;
    X = (_e256 * 100f);
    let _e259 = Y;
    Y = (_e259 * 100f);
    let _e262 = Z;
    Z = (_e262 * 100f);
    let _e266 = X;
    let _e269 = Y;
    let _e273 = Z;
    R = (((0.401288f * _e266) + (0.650173f * _e269)) - (0.051461f * _e273));
    let _e279 = X;
    let _e282 = Y;
    let _e286 = Z;
    G = (((-0.250268f * _e279) + (1.204414f * _e282)) + (0.045854f * _e286));
    let _e292 = X;
    let _e295 = Y;
    let _e299 = Z;
    B = (((-0.002079f * _e292) + (0.048952f * _e295)) + (0.953127f * _e299));
    let _e303 = D0_;
    let _e304 = R;
    Rc = (_e303 * _e304);
    let _e307 = D1_;
    let _e308 = G;
    Gc = (_e307 * _e308);
    let _e311 = D2_;
    let _e312 = B;
    Bc = (_e311 * _e312);
    let _e315 = Rc;
    if (_e315 >= 0f) {
        local = 1f;
    } else {
        local = -1f;
    }
    let _e322 = local;
    sR = _e322;
    let _e324 = Gc;
    if (_e324 >= 0f) {
        local_1 = 1f;
    } else {
        local_1 = -1f;
    }
    let _e331 = local_1;
    sG = _e331;
    let _e333 = Bc;
    if (_e333 >= 0f) {
        local_2 = 1f;
    } else {
        local_2 = -1f;
    }
    let _e340 = local_2;
    sB = _e340;
    let _e342 = F_L;
    let _e343 = Rc;
    fR = pow(((_e342 * abs(_e343)) / 100f), 0.42f);
    let _e351 = F_L;
    let _e352 = Gc;
    fG = pow(((_e351 * abs(_e352)) / 100f), 0.42f);
    let _e360 = F_L;
    let _e361 = Bc;
    fB = pow(((_e360 * abs(_e361)) / 100f), 0.42f);
    let _e370 = sR;
    let _e372 = fR;
    let _e375 = fR;
    Ra = ((((400f * _e370) * _e372) / (27.13f + _e375)) + 0.1f);
    let _e382 = sG;
    let _e384 = fG;
    let _e387 = fG;
    Ga = ((((400f * _e382) * _e384) / (27.13f + _e387)) + 0.1f);
    let _e394 = sB;
    let _e396 = fB;
    let _e399 = fB;
    Ba = ((((400f * _e394) * _e396) / (27.13f + _e399)) + 0.1f);
    let _e405 = Ra;
    let _e407 = Ga;
    let _e412 = Ba;
    a_2 = ((_e405 - ((12f * _e407) / 11f)) + (_e412 / 11f));
    let _e417 = Ra;
    let _e418 = Ga;
    let _e421 = Ba;
    bb = (((_e417 + _e418) - (2f * _e421)) / 9f);
    let _e427 = bb;
    let _e428 = a_2;
    hrad = atan2(_e427, _e428);
    let _e432 = hrad;
    e_t = (0.25f * (cos((_e432 + 2f)) + 3.8f));
    let _e441 = Ra;
    let _e443 = Ga;
    let _e445 = Ba;
    let _e451 = N_bb;
    A = (((((2f * _e441) + _e443) + (_e445 / 20f)) - 0.305f) * _e451);
    let _e454 = A;
    let _e455 = A_w;
    Aratio = (_e454 / _e455);
    let _e458 = Aratio;
    if (_e458 >= 0f) {
        local_3 = 1f;
    } else {
        local_3 = -1f;
    }
    let _e465 = local_3;
    sJ = _e465;
    let _e468 = sJ;
    let _e470 = Aratio;
    let _e472 = c_value;
    let _e473 = z;
    J = ((100f * _e468) * pow(abs(_e470), (_e472 * _e473)));
    let _e478 = Ra;
    let _e479 = Ga;
    let _e482 = Ba;
    den = ((_e478 + _e479) + ((21f * _e482) / 20f));
    let _e490 = den;
    if (_e490 != 0f) {
        let _e496 = N_c;
        let _e498 = N_cb;
        let _e500 = e_t;
        let _e502 = a_2;
        let _e503 = a_2;
        let _e505 = bb;
        let _e506 = bb;
        let _e511 = den;
        t_1 = (((((3846.1538f * _e496) * _e498) * _e500) * sqrt(((_e502 * _e503) + (_e505 * _e506)))) / _e511);
    }
    let _e513 = J;
    sq = sqrt((abs(_e513) / 100f));
    let _e519 = t_1;
    if (_e519 > 0f) {
        let _e522 = t_1;
        let _e525 = sq;
        let _e527 = e_c;
        local_4 = ((pow(_e522, 0.9f) * _e525) * _e527);
    } else {
        local_4 = 0f;
    }
    let _e531 = local_4;
    C = _e531;
    let _e535 = C;
    let _e537 = FL4_;
    Mp = (log((1f + ((0.0228f * _e535) * _e537))) / 0.0228f);
    let _e545 = J;
    let _e549 = J;
    Jp = ((1.7f * _e545) / (1f + (0.007f * _e549)));
    let _e554 = lc_active;
    if (_e554 != 0u) {
        {
            let _e557 = Jp;
            let _e558 = L_white;
            Ln = (_e557 / _e558);
            let _e561 = Ln;
            let _e562 = lc_threshold;
            if (_e561 > _e562) {
                {
                    let _e564 = lc_limit;
                    let _e565 = lc_threshold;
                    lsc = (_e564 - _e565);
                    let _e568 = Ln;
                    let _e569 = lc_threshold;
                    let _e571 = lsc;
                    lx = ((_e568 - _e569) / _e571);
                    let _e574 = lx;
                    let _e576 = lx;
                    let _e577 = lc_power;
                    let _e581 = lc_power;
                    ly = (_e574 / pow((1f + pow(_e576, _e577)), (1f / _e581)));
                    let _e586 = lc_threshold;
                    let _e587 = lsc;
                    let _e588 = ly;
                    Ln = (_e586 + (_e587 * _e588));
                }
            }
            let _e591 = Ln;
            let _e592 = L_white;
            Jp = (_e591 * _e592);
        }
    }
    let _e594 = Jp;
    let _e595 = L_grid0_;
    let _e596 = L_grid1_;
    Lc = clamp(_e594, _e595, _e596);
    let _e599 = Lc;
    let _e600 = L_grid0_;
    let _e602 = L_grid1_;
    let _e603 = L_grid0_;
    let _e606 = nL;
    Li = (((_e599 - _e600) / (_e602 - _e603)) * f32((_e606 - 1u)));
    let _e612 = Li;
    let _e616 = nL;
    l0_ = clamp(i32(floor(_e612)), 0i, (i32(_e616) - 2i));
    let _e622 = Li;
    let _e623 = l0_;
    lf = (_e622 - f32(_e623));
    let _e627 = hrad;
    let _e628 = h_grid0_;
    let _e630 = h_step;
    hue_index = ((_e627 - _e628) / _e630);
    let _e633 = hue_index;
    hue_floor = floor(_e633);
    let _e636 = nh;
    nhi = i32(_e636);
    let _e639 = hue_floor;
    let _e641 = nhi;
    let _e643 = nhi;
    let _e645 = nhi;
    h0_ = (((i32(_e639) % _e641) + _e643) % _e645);
    let _e648 = h0_;
    let _e651 = nhi;
    h1_ = ((_e648 + 1i) % _e651);
    let _e654 = hue_index;
    let _e655 = hue_floor;
    hf = (_e654 - _e655);
    let _e658 = l0_;
    let _e659 = nhi;
    let _e661 = h0_;
    let _e665 = cmax.value[((_e658 * _e659) + _e661)];
    c00_ = _e665;
    let _e667 = l0_;
    let _e668 = nhi;
    let _e670 = h1_;
    let _e674 = cmax.value[((_e667 * _e668) + _e670)];
    c01_ = _e674;
    let _e676 = l0_;
    let _e679 = nhi;
    let _e681 = h0_;
    let _e685 = cmax.value[(((_e676 + 1i) * _e679) + _e681)];
    c10_ = _e685;
    let _e687 = l0_;
    let _e690 = nhi;
    let _e692 = h1_;
    let _e696 = cmax.value[(((_e687 + 1i) * _e690) + _e692)];
    c11_ = _e696;
    let _e699 = lf;
    let _e702 = hf;
    let _e704 = c00_;
    let _e706 = hf;
    let _e707 = c01_;
    let _e711 = lf;
    let _e713 = hf;
    let _e715 = c10_;
    let _e717 = hf;
    let _e718 = c11_;
    Cmax = (((1f - _e699) * (((1f - _e702) * _e704) + (_e706 * _e707))) + (_e711 * (((1f - _e713) * _e715) + (_e717 * _e718))));
    let _e724 = Cmax;
    if (_e724 > 0.000000001f) {
        let _e727 = Cmax;
        local_5 = _e727;
    } else {
        local_5 = 0.000000001f;
    }
    let _e730 = local_5;
    safe_value = _e730;
    let _e732 = Mp;
    let _e733 = safe_value;
    d = (_e732 / _e733);
    let _e736 = d;
    let _e737 = threshold;
    if (_e736 > _e737) {
        {
            let _e739 = limit;
            let _e740 = threshold;
            scale = (_e739 - _e740);
            let _e743 = d;
            let _e744 = threshold;
            let _e746 = scale;
            xk = ((_e743 - _e744) / _e746);
            let _e749 = xk;
            let _e751 = xk;
            let _e752 = power_value;
            let _e756 = power_value;
            yk = (_e749 / pow((1f + pow(_e751, _e752)), (1f / _e756)));
            let _e761 = threshold;
            let _e762 = scale;
            let _e763 = yk;
            d = (_e761 + (_e762 * _e763));
        }
    }
    let _e766 = d;
    let _e767 = safe_value;
    Mp_new = (_e766 * _e767);
    let _e770 = Mp_new;
    M_new = ((exp((_e770 * 0.0228f)) - 1f) / 0.0228f);
    let _e779 = Jp;
    let _e782 = Jp;
    J_new = (_e779 / (1.7f - (0.007f * _e782)));
    let _e787 = M_new;
    let _e788 = FL4_;
    C_new = (_e787 / _e788);
    let _e791 = J_new;
    if (_e791 >= 0f) {
        local_6 = 1f;
    } else {
        local_6 = -1f;
    }
    let _e798 = local_6;
    sJ2_ = _e798;
    let _e800 = A_w;
    let _e801 = sJ2_;
    let _e803 = J_new;
    let _e808 = c_value;
    let _e809 = z;
    A2_ = ((_e800 * _e801) * pow((abs(_e803) / 100f), (1f / (_e808 * _e809))));
    let _e815 = J_new;
    sq2_ = sqrt((abs(_e815) / 100f));
    let _e821 = sq2_;
    let _e824 = C_new;
    if ((_e821 > 0f) && (_e824 > 0f)) {
        let _e828 = C_new;
        let _e829 = sq2_;
        let _e830 = e_c;
        local_7 = pow((_e828 / (_e829 * _e830)), 1.1111112f);
    } else {
        local_7 = 0f;
    }
    let _e839 = local_7;
    t2_ = _e839;
    let _e841 = hrad;
    ca = cos(_e841);
    let _e844 = hrad;
    sa = sin(_e844);
    let _e847 = A2_;
    let _e848 = N_bb;
    p2_ = ((_e847 / _e848) + 0.305f);
    let _e859 = t2_;
    if (_e859 == 0f) {
        {
            a2_ = 0f;
            b2_ = 0f;
        }
    } else {
        {
            let _e867 = N_c;
            let _e869 = N_cb;
            let _e871 = e_t;
            let _e873 = t2_;
            p1_ = ((((3846.1538f * _e867) * _e869) * _e871) / _e873);
            let _e876 = sa;
            let _e878 = ca;
            if (abs(_e876) >= abs(_e878)) {
                {
                    let _e881 = p1_;
                    let _e882 = sa;
                    p4_ = (_e881 / _e882);
                    let _e885 = p2_;
                    let _e887 = p3_;
                    let _e894 = p4_;
                    let _e896 = p3_;
                    let _e902 = ca;
                    let _e903 = sa;
                    let _e911 = p3_;
                    b2_ = (((_e885 * (2f + _e887)) * 0.32786885f) / (((_e894 + (((2f + _e896) * 0.15680684f) * (_e902 / _e903))) - 0.019244475f) + (_e911 * 4.490378f)));
                    let _e918 = b2_;
                    let _e919 = ca;
                    let _e920 = sa;
                    a2_ = (_e918 * (_e919 / _e920));
                }
            } else {
                {
                    let _e923 = p1_;
                    let _e924 = ca;
                    p5_ = (_e923 / _e924);
                    let _e927 = p2_;
                    let _e929 = p3_;
                    let _e936 = p5_;
                    let _e938 = p3_;
                    let _e948 = p3_;
                    let _e954 = sa;
                    let _e955 = ca;
                    a2_ = (((_e927 * (2f + _e929)) * 0.32786885f) / ((_e936 + ((2f + _e938) * 0.15680684f)) - ((0.019244475f - (_e948 * 4.490378f)) * (_e954 / _e955))));
                    let _e960 = a2_;
                    let _e961 = sa;
                    let _e962 = ca;
                    b2_ = (_e960 * (_e961 / _e962));
                }
            }
        }
    }
    let _e966 = p2_;
    let _e969 = a2_;
    let _e973 = b2_;
    Ra2_ = ((((460f * _e966) + (451f * _e969)) + (288f * _e973)) / 1403f);
    let _e980 = p2_;
    let _e983 = a2_;
    let _e987 = b2_;
    Ga2_ = ((((460f * _e980) - (891f * _e983)) - (261f * _e987)) / 1403f);
    let _e994 = p2_;
    let _e997 = a2_;
    let _e1001 = b2_;
    Ba2_ = ((((460f * _e994) - (220f * _e997)) - (6300f * _e1001)) / 1403f);
    let _e1007 = Ra2_;
    vm = (_e1007 - 0.1f);
    let _e1011 = vm;
    if (_e1011 >= 0f) {
        local_8 = 1f;
    } else {
        local_8 = -1f;
    }
    let _e1018 = local_8;
    sign_value = _e1018;
    let _e1020 = vm;
    if (abs(_e1020) < 400f) {
        let _e1025 = vm;
        let _e1029 = vm;
        local_9 = ((27.13f * abs(_e1025)) / (400f - abs(_e1029)));
    } else {
        local_9 = 0f;
    }
    let _e1035 = local_9;
    base_value = _e1035;
    let _e1038 = F_L;
    let _e1040 = sign_value;
    let _e1042 = base_value;
    let _e1048 = D0_;
    Rf = ((((100f / _e1038) * _e1040) * pow(_e1042, 2.3809524f)) / _e1048);
    let _e1051 = Ga2_;
    vm = (_e1051 - 0.1f);
    let _e1054 = vm;
    if (_e1054 >= 0f) {
        local_10 = 1f;
    } else {
        local_10 = -1f;
    }
    let _e1061 = local_10;
    sign_value = _e1061;
    let _e1062 = vm;
    if (abs(_e1062) < 400f) {
        let _e1067 = vm;
        let _e1071 = vm;
        local_11 = ((27.13f * abs(_e1067)) / (400f - abs(_e1071)));
    } else {
        local_11 = 0f;
    }
    let _e1077 = local_11;
    base_value = _e1077;
    let _e1079 = F_L;
    let _e1081 = sign_value;
    let _e1083 = base_value;
    let _e1089 = D1_;
    Gf = ((((100f / _e1079) * _e1081) * pow(_e1083, 2.3809524f)) / _e1089);
    let _e1092 = Ba2_;
    vm = (_e1092 - 0.1f);
    let _e1095 = vm;
    if (_e1095 >= 0f) {
        local_12 = 1f;
    } else {
        local_12 = -1f;
    }
    let _e1102 = local_12;
    sign_value = _e1102;
    let _e1103 = vm;
    if (abs(_e1103) < 400f) {
        let _e1108 = vm;
        let _e1112 = vm;
        local_13 = ((27.13f * abs(_e1108)) / (400f - abs(_e1112)));
    } else {
        local_13 = 0f;
    }
    let _e1118 = local_13;
    base_value = _e1118;
    let _e1120 = F_L;
    let _e1122 = sign_value;
    let _e1124 = base_value;
    let _e1130 = D2_;
    Bf = ((((100f / _e1120) * _e1122) * pow(_e1124, 2.3809524f)) / _e1130);
    let _e1134 = Rf;
    let _e1137 = Gf;
    let _e1141 = Bf;
    Xn = (((1.8620678f * _e1134) - (1.0112547f * _e1137)) + (0.14918678f * _e1141));
    let _e1146 = Rf;
    let _e1149 = Gf;
    let _e1153 = Bf;
    Yn = (((0.38752654f * _e1146) + (0.62144744f * _e1149)) - (0.00897398f * _e1153));
    let _e1159 = Rf;
    let _e1162 = Gf;
    let _e1166 = Bf;
    Zn = (((-0.0158415f * _e1159) - (0.03412294f * _e1162)) + (1.0499644f * _e1166));
    let _e1170 = Xn;
    Xn = (_e1170 / 100f);
    let _e1173 = Yn;
    Yn = (_e1173 / 100f);
    let _e1176 = Zn;
    Zn = (_e1176 / 100f);
    let _e1180 = i;
    let _e1187 = m2r.value[0];
    let _e1188 = Xn;
    let _e1193 = m2r.value[1];
    let _e1194 = Yn;
    let _e1200 = m2r.value[2];
    let _e1201 = Zn;
    output_data.value[(3u * _e1180)] = (((_e1187 * _e1188) + (_e1193 * _e1194)) + (_e1200 * _e1201));
    let _e1205 = i;
    let _e1214 = m2r.value[3];
    let _e1215 = Xn;
    let _e1220 = m2r.value[4];
    let _e1221 = Yn;
    let _e1227 = m2r.value[5];
    let _e1228 = Zn;
    output_data.value[((3u * _e1205) + 1u)] = (((_e1214 * _e1215) + (_e1220 * _e1221)) + (_e1227 * _e1228));
    let _e1232 = i;
    let _e1241 = m2r.value[6];
    let _e1242 = Xn;
    let _e1247 = m2r.value[7];
    let _e1248 = Yn;
    let _e1254 = m2r.value[8];
    let _e1255 = Zn;
    output_data.value[((3u * _e1232) + 2u)] = (((_e1241 * _e1242) + (_e1247 * _e1248)) + (_e1254 * _e1255));
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(num_workgroups) gl_NumWorkGroups: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_NumWorkGroups_1 = gl_NumWorkGroups;
    main_1();
    return;
}
