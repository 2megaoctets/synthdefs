// https://github.com/v7b1/mi-UGens

(

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

)