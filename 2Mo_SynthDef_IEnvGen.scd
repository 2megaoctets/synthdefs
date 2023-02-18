// https://github.com/v7b1/mi-UGens

(

/*SynthDef(\Sd_template, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;*/

SynthDef(\braids, {|out = 0, amp = 0.3, pan = 0, sustain = 1, begin = 0, end = 1, freq = 440, speed = 1, accelerate = 0, timbre = 0.5, color = 0.5, model = 0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiBraids.ar(pitch: freq.cpsmidi, timbre: timbre, color: color, model: model);

	OffsetOut.ar(out, DirtPan.ar(sig * amp * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\omi, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiOmi.ar(pit: freq.cpsmidi);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\plaits, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
	timbre=0.5,engine=0,harm=0.5,morph=0.5,level=1,lpgdecay=0,lpgcolour=0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiPlaits.ar(
		pitch: freq.cpsmidi,
		timbre: timbre,
		harm: harm,
		engine: engine,
		morph: morph,
		level: level,
		decay: lpgdecay,
		lpg_colour: lpgcolour,
	);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\tides, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,tidesshape=0.5,slope=0.5,tidessmooth=0.5,shift=0.5,mode=2|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiTides.ar(
		freq: freq,
		shape: tidesshape,
		slope: slope,
		smooth: tidessmooth,
		shift: shift,
		output_mode: mode,
		ramp_mode: 1,
		rate: 1
	);

	OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
}).add;

SynthDef(\Sd_hoover, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, envfL1 = (-5), envfL2 = 6, envfL3 = 0, envfT1 = 0.1, envfT2 = 1.7, crvf1 = 0, crvf2 = (-4), bw = 1.035, doneAction = 2;
    var snd;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
    freq = freq * Env([envfL1, envfL2, envfL3], [envfT1, envfT2], [crvf1, crvf2]).kr.midiratio;
    snd = { DelayN.ar(Saw.ar(freq * ExpRand(bw, 1 / bw)) + Saw.ar(freq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0);
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * globalEnv;
    /*snd = Balance2.ar(snd[0], snd[1], pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet1, {|out = 0, amp = 1, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, sdm = 1, mod = 0.005, from = 9, to = 12, min = 0.1, max = 0.3, doneAction = 2|
    var sig, sd = SampleDur.ir * sdm, hpf=40, mf=1.0;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

    sig = HPF.ar(
        DemandEnvGen.ar(
            Dseq([min, min.neg, [max.neg, max]], inf),
            sd * Dseq([Lag.kr(from), Lag.kr(to), Dbrown(from, to, to, from.neg, from)], inf)
        ).fold2(SinOsc.ar(mod)) * mf,
        hpf
    );
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet2, {|out = 0, amp = 0.5, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, sdm = 1, repeats = 32, from = 8, to = 30, min = 0.1, max = 0.9, doneAction = 2|
    var sig, sd = SampleDur.ir * sdm, mf=0.2;
    var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

    sig = DemandEnvGen.ar(
        Dseq([
            Dseq([0, 0.5], repeats),
            Dseq([-0.2, 0.8], repeats / 2),
            Dseq([-1.0, 1.0], Dwhite(repeats / 32, repeats)),
            Dseq([-0.8, 0.1], repeats / 16)
        ], inf),
        Dseq([
            Dwhite(from, to, [repeats, repeats * 0.5]),
            Dwhite(from / 1.5, to / 1.5, [repeats, repeats * 2]),
            Dbrown(from / 10, to / 10, from / 20, [repeats, repeats * 0.25])
        ], inf) * sd
    ) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet3, {|out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, step = 2, start = 1, from = 2, to = 5, sdm = 0.2, min = 0.1, max = 0.9, brownStep = 0.01, doneAction = 2|
    var sig, iter = 2, sd = SampleDur.ir * [sdm, sdm * 1.1], mf = 0.08;
    var levels = ({ Dseries(rrand(min.neg, max.neg), rrand(min, max), from * rrand(from, to)) } ! iter) ++
    ({ Dbrown(rrand(min.neg, max.neg), rrand(min, max), brownStep, to * 2) } ! iter);
    var times = { Dseries(rrand(start, start * 2), rrand(step, step * 2), rrand(from * 5, to * 4)) } ! (iter * 2);
    var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

    sig = DemandEnvGen.ar(
        Dseq(levels, inf),
        Dseq(times, inf) * sd
    ) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet4, {|out = 0, amp = 1, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, sdm = 1, repeats = 4, from = 5, to = 18, mod = 60, doneAction = 2|
    var sig, length = 30, sd = SampleDur.ir * sdm, mf = 0.3;
    var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

    sig = DemandEnvGen.ar(
        Dseq([Dseries(-1.0, [0.04, 0.09], 30)], inf),
        Dseq([
            Dwhite(from, to, repeats),
            Dwhite(from / 1.5, to * 3, repeats)
        ], inf) * sd
    ).clip(SinOsc.ar(mod)) * mf;
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_stochadiet5, {|out = 0, amp = 0.4, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, filtSpeed = 10, filtCenter = 200, sdm = 1, modFreq = 0.01, filtBw = 3, lpf = 2500, doneAction = 2|
    var sig, size = 3, from = 1, to = 25, a = 9, b = 5, min = 0.1, max = 0.3;
    var sd = SampleDur.ir * sdm;
    var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

    sig = DemandEnvGen.ar(
        Dseq([min, min.neg, [max.neg, max]], inf),
        Dwhite(sd * a, sd * b),
    ).wrap2(SinOsc.ar([modFreq, modFreq * 1.1])) * 0.2;
    sig = SoftClipAmp8.ar(sig, 10);
    sig = HPF.ar(BBandStop.ar(sig, Lag.ar(LFNoise1.ar([filtSpeed, filtSpeed * 2] ).range(filtCenter * 0.2, filtCenter * 2), 0.05), filtBw));
    sig = sig * globalEnv;
    /*sig = Balance2.ar(sig[0], sig[1], pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_metro, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envT4 = 0, envDivDur = 1, theta = 0.5, rho = 0.8, filterfreq = 1000, rq = 1.0, doneAction = 2;
    var snd, envf, b1, b2;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	// freq = max(0, freq * speed * (1 + (accelerate * line)));
	envf = EnvGen.ar(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2, envT3, envT4]), timeScale: sustain / envDivDur);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	snd = SOS.ar(envf, 1.0, 0.0, 0.0, b1, b2) * envf;
	snd = RHPF.ar(snd, filterfreq, rq);
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickBoomy, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), lvlScale = 1, hpfFreq = 500, softGain=1.1, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	// freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1));
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale), hpfFreq);
	sig = sig * softGain;
	sig = sig.softclip * 1;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_batuhan, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
    var sig, trig, envSaw, envSin;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	// freq = max(0, freq * speed * (1 + (accelerate * line)));
	trig = Impulse.kr(0);
	envSaw = Decay2.kr(
		trig,
		0.01,
		eSawDec
	);
	envSin = EnvGen.kr(Env.new([eSinL1, eSinL2, eSinL3, eSinL4], [eSinT1, eSinT2, eSinT3], [eSinC1, eSinC2, eSinC3]), trig);
	sig = ((Saw.ar(sawFreq, envSaw) ** 1.5) * sawMix) + (SinOsc.ar(sinFreq, 0, envSin) * (1 - sawMix));
	sig = (sig * (1 - bpfMix)) + (BPF.ar(sig, bpfFreq, bpfRq.max(0.01)) * bpfMix);
	sig = BRF.ar(sig, trig * 20 + [brfFreq1, brfFreq2], brfRq.max(0.01));
	sig = Splay.ar(sig, levelComp: false);
	sig = LeakDC.ar(sig).tanh;
	sig = HPF.ar(sig, 28);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_rim, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = SinOsc.ar(freq * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100) * freq, \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100) * freq, \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig) * globalEnv;
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_rim1, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	sig = SinOsc.ar(freq * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100), \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100), \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig);
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kick3new, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 60, tu = 1, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = SinOsc.ar(freq*tu, 0);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_kickBlocks, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1,
	//tone1 arguments
	t1freq = 400, t1harmonic = 2, t1glide = 0.01,
	t1att = 0.0005, t1rel = 0.01, t1curve = (-4), t1del = 0, t1amp = 1,
	//tone2 arguments
	t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
	t2att = 0.0001, t2rel = 0.3, t2curve = (-4), t2del = 0.005, t2amp = 1,
	//hit1 arguments
	h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
	h1att = 0.001, h1rel = 0.02, h1curve = (-4), h1del = 0.001, h1amp = 1,
	//hit2 arguments
	h2freq = 1320, h2harmonic = 1, h2glide = 0,
	h2att = 0.003, h2rel = 0.03, h2curve = (-4), h2del = 0, h2amp = 0.5,
	//click arguments
	cfreq = 6100, crq = 1, camp = 1.41, cdur = 0.001,
	doneAction = 2;

    var sig, noise, tone1, tone2, hit1, hit2, click;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide) * freq,
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide) * freq,
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide) * freq,
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide) * freq,
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: noise * EnvGen.kr(Env.step([1, 0], [cdur, cdur * 0.01]), levelScale: camp),
		freq:  cfreq * freq,
		rq: crq
	);

	sig = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh;

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_hat808, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 1, rls = 0.1, doneAction = 2;
    var sig;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = Saw.ar((1..9)*1000.23/**env*/*freq);
	sig = RHPF.ar(sig, \rhpfFreq.kr(5700), \rhpfRq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1), rls, -4), timeScale: sustain))*freq;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \rhpf1Freq.kr(2000)/**env*freq*/, \rhpf1Rq.kr(0.5));
	sig = LeakDC.ar(sig);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_werkit, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, rq = 0.1, doneAction = 2;
    var sig, filter;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = WhiteNoise.ar;
	filter = BLowPass4.ar(sig, freq, rq) * 0.3;
	sig = (0.7 * filter + (0.3 * filter.distort));

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\Sd_tubularBell, { arg out = 0, amp = 0.2, pan = 0, begin = 0, end = 1, speed = 1, accelerate = 0, sustain = 1, freq = 440, harmFreq = 1, harmAmp = 1, harmTime = 1, atk = 0.005, rls = 9, exciterRel = 0.05, doneAction = 2;
    var sig, exenv, exciter;
	var envLength = sustain * (end - begin) / speed;
    var line = Line.ar(begin, end, envLength, doneAction: doneAction);
    var env = Env.asr;
    var globalEnv = IEnvGen.ar(env, line);

	freq = max(0, freq * speed * (1 + (accelerate * line)));

	exenv = Env.perc(atk, exciterRel, 0.05).kr;

	exciter = GrayNoise.ar(exenv);

	sig = DynKlank.ar(
		specificationsArrayRef:
		Ref.new([
			[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48] * harmFreq,   // harmonics
			[1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25] * harmAmp, // amplitudes
			[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1] * harmTime   // ring times
		]),
		input: exciter,
		freqscale: freq,
		decayscale: rls
	);

	sig = LPF.ar(sig, freq * 9.5);

	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

)