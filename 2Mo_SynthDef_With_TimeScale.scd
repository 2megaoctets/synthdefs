(

///////////////////////////////////////  SynthDef with timeScale

///////////////////////////////////////  Kick

~synthSd = SynthDef(\snapkickSusSd, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, sustain = 1, doneAction = 2|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve), timeScale: sustain, doneAction: doneAction);
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(popFrqSt, popFrqEnd, popFrqDur);
	popAmp = EnvGen.ar(Env.linen(popAmpAtt, popAmpSus, popAmpRel, popAmpLev));
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(clkAmpAtt, clkAmpRel, clkAmpLev, clkAmpCurve));
	click = LPF.ar(Formant.ar(clkfFundFreq, clkfFormFreq, clkfBwFreq), clkLpfFreq) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh;

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\IkedaBassSusSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, sustain = 1, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickMistSusSd, { arg out = 0, level = 1, pan = 0, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, sustain = 1, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0);
	sig = sig.clip2(1);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig * env0, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\kick2newSusSd,{arg out = 0, amp = 1, pan = 0, att = 0, sustain = 1, rel = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.perc(att, rel), gate, timeScale: sustain, doneAction: doneAction);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, env);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig * env;
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
	sig = HPF.ar(sig, hpff);
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t1kick2SusSd, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.002, envfL2 = 20, envfT3 = 0.1, envfL3 = 0, envfT4 = 1, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 1200, hpfRq = 1, verbMix = 1, verbRoom = 1, verbDamp = 0.5, sustain = 1, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), timeScale: sustain, doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	// revSig = GVerb.ar(sig, Lag3.kr(verbRoom).max(0.01), verbTime, verbDamp);
	sig = SelectX.ar(verbMix, [sig, revSig]);
	// sig = Pan2.ar(sig, pan, amp*enva);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp*enva));
}).add;

SynthDef(\kickmedSusSd, { | out = 0, level = 0.5, pan = 0, noise = 1, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0, sustain = 1, doneAction = 2|
	var env0,env1,
env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0,0.5],[curve1, curve2, curve3]);
env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);
env0 = EnvGen.ar(env0, timeScale: sustain, doneAction: doneAction);
env1 = EnvGen.ar(env1);
env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);
	son2 = SinOsc.ar(env1m, 0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);
son = SelectX.ar(ochoose,[son,son2,son3,son4]);
son = LeakDC.ar(son,dc,30);
son = son + WhiteNoise.ar(noise);
	son = LPF.ar(son, env1m*fratio.max(0.01), env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son = son*level.distort;
	// son = Pan2.ar(son, pan);
	// OffsetOut.ar(out, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
//OffsetOut.ar(snd, Mono(son)*level).tanh;
}).add;

SynthDef(\kick808newSusSd, { arg out = 0, amp = 0.5, pan = 0, envL1 = 1, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, envCurve = (-8), enfL1 = 5000, enfL2 = 100, enfL3 = 50, enfT1 = 0.0001, enfT2 = 0.01, enfCurve = (-4), tu = 2, sin2Frq = 10, sin2Amp = 50, sustain = 1, doneAction = 2;
    var env = EnvGen.ar(Env([envL1, envL2, envL3],[envT1, envT2], -8), timeScale: sustain, doneAction: doneAction);
    var enf  = EnvGen.ar(Env([enfL1, enfL2, enfL3],[enfT1, enfT2, 0.1], enfCurve));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(sin2Frq, 0, sin2Amp, 40*tu), 0, 0.01) * env, 100);
    sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicklaserbeamSusSd, { arg out = 0, amp = 0.3, pan = 0.0, frq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, sustain = 1, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3]),
		levelScale: amp,
		timeScale: sustain,
		doneAction: doneAction);
	snd = LFTri.ar(frq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

~synthSd = SynthDef(\kickParallaxSusSd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, sustain = 1, doneAction = 2;
	var sig, env_amp, env_freq, kharm, kamp, kring, reso;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, timeScale: sustain, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq + (44100 ** env_freq), 0, env_amp);

	// harmonics
	kharm = [kharm1, kharm2, kharm3, kharm4];
    // amplitudes
	kamp = [kamp1, kamp2, kamp3, kamp4];
    // ring times
	kring = [kring1, kring2, kring3, kring4];

    //reso = Klank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	reso = DynKlank.ar(`[kharm, kamp, kring], sig, frqScale, decScale);
	sig = SelectX.ar(resoMix, [sig, reso]);
	// sig = Pan2.ar (sig, pan);
	// OffsetOut.ar (out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\rc808KickSusSd, {
    arg out = 0, pan = 0, dcy = 30, amp = 2, gate = 0, tone = 56, sustain = 1, doneAction = 2;
    var fenv, env, trienv, sig, sub, punch, pfenv;
    env = EnvGen.kr(Env.new([0.11, 1, 0], [0, dcy], -225), timeScale: sustain, doneAction:2);
    trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [0, dcy], -230), doneAction:0);
    fenv = Env([tone*7, tone*1.35, tone], [0.05, 0.6], -14).kr;
    pfenv = Env([tone*7, tone*1.35, tone], [0.03, 0.6], -10).kr;
    sig = SinOsc.ar(fenv, pi/2) * env;
    sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
    punch = SinOsc.ar(pfenv, pi/2) * env * 2;
    punch = HPF.ar(punch, 350);
    sig = (sig + sub + punch) * 2.5;
    sig = Limiter.ar(sig, 0.5) * amp;
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosKickSusSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, curve = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	gate = 1, sustain = 1, doneAction = 2;

	var subfreq, sub, drumEnv, drumContour, drum, beaterContour, beaterEnv, beater, snd, click, envClick;

	subfreq = XLine.kr(startsubfreq, endsubfreq, linesubdur, 1, 0);

	sub = LPF.ar(Ringz.ar(Impulse.ar(0), subfreq, subdecay), sublowpass) * subamp;

	drumEnv = Env.perc(attackTime: drumAtt, releaseTime: drumRel, curve: curve).kr;

	sub = sub * drumEnv;

	drumContour = Line.kr(start: drumFreq * drumHarmonic, end: drumFreq, dur: drumSweep);

	drum = PMOsc.ar(
		carfreq: drumContour,
		modfreq: modFreq,
		pmindex: modIndex,
		mul: drumAmp
	);

	drum = LPF.ar(in: drum, freq: Lag2.kr(drumFilter), mul: drumEnv);

	beaterEnv = Env([beaterL1, beaterL2, beaterL3, beaterL4], [beaterT1, beaterT2, beaterT3]).kr;

	beaterContour = Line.kr(start: (beaterFreq * beaterHarmonic).min(20000), end: beaterFreq, dur: beaterSweep);

	beater = HPF.ar(in: WhiteNoise.ar(LFNoise0.kr(noiseMod)), freq: beaterFreq);

	beater = LPF.ar(in: beater, freq: beaterContour, mul: beaterEnv) * beaterAmp;

	envClick = EnvGen.kr(Env.step([700, 0], [0.0007, 0.1]), gate, 0.002);
	click = Hasher.ar(Sweep.ar(gate, 0.000001)) * envClick;
	click = MoogLadder.ar(click, clkffreq, clkres) * EnvGen.kr(Env.perc(0.0001, 0.00001), gate, clickAmp);

	snd = Mix.ar(sub + drum + beater + click) * amp;

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), gate, timeScale: sustain, doneAction: doneAction);
    //DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\drumkickSusSd, { arg out = 0, amp = 0.5, pan = 0.0, atk = 0.0001, rls = 0.09, curve = 8, attSinFreq = 0.0001, relSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, relBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, sustain = 1, doneAction = 2;
	var source;

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, relSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, relBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(atk, rls, curve: curve), gate, timeScale: sustain, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tabassSusSd, { arg out = 0, amp = 0.8, pan = 0, gate = 1, atk = 0.01, rls = 2, frq = 1, lfnFrq = (1/2), sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, timeScale: sustain, doneAction: doneAction);
	sig = LFTri.ar(frq) * Impulse.kr(0);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(lfnFrq).range(0.1, 0.98)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickBlocksSusSd, { arg out = 0, amp = 0.4, pan = 0, curve = (-4),
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
	cfreq = 6100, crq = 1, camp = 1.41, sustain = 1,
	doneAction = 2;

    var env, snd, noise, tone1, tone2, hit1, hit2, click;

	env = EnvGen.kr(Env.linen(0.01, 1, 6), timeScale: sustain, doneAction: doneAction);
	noise = Hasher.ar(Sweep.ar); //deterministic white noise

    tone1 = SinOsc.ar(
		freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
		mul: Env.perc(attackTime: t1att, releaseTime: t1rel, level: t1amp, curve: t1curve).delay(t1del).ar);

	tone2 = SinOsc.ar(
		freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
		mul: Env.perc(attackTime: t2att, releaseTime: t2rel, level: t2amp, curve: t2curve).delay(t2del).ar);

    hit1 = BPF.ar(
		in: noise,
		freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
		rq: h1rq,
		mul: Env.perc(attackTime: h1att, releaseTime: h1rel, level: h1amp, curve: h1curve).delay(h1del).ar);

	hit2 = HPF.ar(
		in: noise,
		freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
		mul: Env.perc(attackTime: h2att, releaseTime: h2rel, level: h2amp, curve: h2curve).delay(h2del).ar);

	click = BPF.ar(
		in: Impulse.ar(0) * SampleRate.ir / 44100,
		freq:  cfreq,
		rq: crq,
		mul: camp);

	snd = Mix.ar(tone1 + tone2 + hit1 + hit2 + click).tanh * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd * env, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\tweetKickIntSusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, sustain = 1, doneAction = 2;
	var sig, freq, phase, env, i;
	i = Impulse.ar(_);
	freq = i.(impfreq).lagud(0,0.4)*360;
	phase = Integrator.ar(
		Integrator.ar(
			i.(phRate).lag(LFNoise1.ar(lagFreq!2,2,2)) * inAmt,
			coef1
		),
		coef2
	).fold2(pi);
	env = EnvGen.kr(Env.linen(attack, 1, release), timeScale: sustain, doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickbassSusSd, { | out = 0, level = 0.5, pan = 0, attack = 0.01, decay = 0.2, release = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, sustain = 1, done = 2 |
	var env0,env1,
env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[attack,decay,release],[curve1, curve2, curve3]);
env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

env0 = EnvGen.ar(env0,SinOsc.kr(0.025), timeScale: sustain, doneAction: done);
	env1 = EnvGen.ar(env1);
env1m = env1.midicps;

son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = Pan2.ar(son,pan);
son = LeakDC.ar(son,dc,30);

	son = LPF.ar(son+ WhiteNoise.ar(1*noise), env1m*fratio.max(0.01), env0);

	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, [p1,p2], env0), LFSaw.ar(env1m, [p1,p2], env0), LFPulse.ar(env1m, [p1,p2], env0), LFTri.ar(env1m, [p1,p2], env0)]);
	son = LPF.ar(son,filter.max(150)+SinOsc.kr(2,0.5,200));
son = son * 1;
//son = son.clip2(1);
son = son * level.distort;
// son = Pan2.ar(son, pan, level);
// OffsetOut.ar(out, son).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
}).add;

///////////////////////////////////////  HiHat

SynthDef(\haten1SusSd, { arg out = 0, amp = 0.06, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve), timeScale: sustain, doneAction: 2);
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\fabHi1SusSd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, sustain = 1, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(timeScale: sustain, doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Cymbal

SynthDef(\cymbalicMcldSusSd, { |out=0, amp=0.5, pan=0, atk = 0.0001, sustain = 1, rls = 0.2, attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, gate = 1, doneAction = 2|
	var env, lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	env = EnvGen.kr(Env.perc(atk, rls), gate, timeScale: sustain, doneAction: doneAction);
	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf), gate) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif), gate) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh), gate);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Noise

SynthDef(\tweetFogAttackSusSd, { arg out = 0, amp = 1, pan = 0, sustain = 1, sigatt = 0.01, sigdec = 3.16, feedBack = 0.2, freq = 0.8, gate = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), gate, timeScale: sustain);
	sig = (sig.mean!2) * sigenv;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\attBreathSusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, seqv1 = 1, seqv2 = 1, seqv3 = 4, seqv4 = 2, seqv5 = 2, seqFreq = 0.2, freqMin = 250, freqMax = 800, bwrMod = 0.5, gate = 1, sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, timeScale: sustain, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = TDuty.kr(Dseq([seqv1, seqv2, seqv3, seqv4, seqv5] * seqFreq, inf));
	sig = Resonz.ar(
		Crackle.ar(sig.range(0.6, 1.6))!2,
		Demand.kr(sig, 0, Dseq([freqMin, freqMax], inf)),
		Demand.kr(sig, 0, Dwhite(0.01,0.5, inf)) * bwrMod
	);
	sig = sig * env;
	// sig = Compander.ar(sig, sig, 0.4, 1, 1/3);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\complexoscSusSd, { arg out = 0, amp = 1, pan = 0, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, sustain = 1, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, gate = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(gate, attack, 1, release, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    // OffsetOut.ar(out, outlet * env * amp);
	OffsetOut.ar(out, DirtPan.ar(outlet, ~dirt.numChannels, pan, amp * env));
}, [\kr ! 12, \ar ! 15, \kr, \tr, \ir].flat).add;

SynthDef(\mutantFricSusSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, sigFreq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 50, gate = 1, sustain = 1, doneAction = 2;
	var friction, sig;
	friction = Array.fill(5, {
		[spec1.max(0.00001), spec2.max(0.03)].asSpec.map(LFNoise2.kr(noiseFreq))
	});
	sig = Select.ar(source, [
		LFTri.ar(sigFreq),
		LFPar.ar(sigFreq),
		LFCub.ar(sigFreq),
		LFSaw.ar(sigFreq),
		LFDNoise3.ar(sigFreq),
		LFDNoise0.ar(sigFreq)
	]);
	sig = Friction.ar(sig, friction, Lag2.kr(spring), damp, friction*30000, beltmass);
	sig = HPF.ar(sig, hpfFreq);
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, timeScale: sustain, doneAction: doneAction);

	// OffsetOut.ar(out, Splay.ar(sig * amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Tonal

SynthDef(\fakeResSusSd, {
    arg  out = 0, pan = 0, freq = 200, peamount = 900,
    pitchAtt = 0.001, pitchDec = 0.13,
    ampAtt = 0.03, ampDec = 1.0, level = 0.5, sustain = 1, doneAction = 2;

    var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;

    pitchenv = EnvGen.ar(
        // Env([0, 1, 0], [pitchAtt, pitchDec], [0, 0])  // original
        Env([0, 1, 0], [pitchAtt, pitchDec],  \squared)
        // Env([0, 1, 0], [pitchAtt, pitchDec],  \cubed)
    );

    ampenv = EnvGen.ar(
        Env([0, 1, 0], [ampAtt, ampDec], [0, 0]),
        levelScale: level,
		timeScale: sustain,
        doneAction: doneAction
    );

    sig1 = SinOsc.ar(
        freq,
        mul: -0.53,
        add: 0.5
    );

    sig2Phase = Sweep.ar(sig1, (freq + (pitchenv * peamount)));

    sig2 = SinOsc.ar(
        freq + (pitchenv * peamount),
        phase: 2pi * sig2Phase
    );

    // sig = (sig1 * sig2)**2;  // orig
    // sig = (sig1 * sig2).pow(2);  // same sound as orig
    sig = (sig1 * sig2).squared;  // sounds different

    sig = OnePole.ar(sig, -0.22); // added
    sig = sig * ampenv;
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\windowsyncSusSd, { |out = 0, pan = 0, freq = 65.40639132515, amp = 0.1,
    syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, gate = 1, sustain = 1, doneAction = 2|
    var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
    var eg = EnvGen.kr(Env.adsr(0.01, 0.3, 0.6, 0.1), gate, timeScale: sustain, doneAction: doneAction);
    var fundamental = LFTri.ar(freq);
    var syncFreq = freq * syncRatio * syncEg;
    // note, Phasor here is behaving like the Sweep above (retrigger behavior)
    // but Phasor loops around its range, eliminating the need for '% 1'
    var syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
    var sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;
    // OffsetOut.ar(out, (sig * (amp * eg)).dup);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * eg));
}).add;

///////////////////////////////////////  Sequence

SynthDef(\talters1SusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, sustain = 1, release = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = EnvGen.kr(Env.perc(attack, release), gate, timeScale: sustain, doneAction: doneAction);
	input = LocalIn.ar(2) * feedBack;
	modenv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) * modenv,
				y.ar(i*k**i/[modenv, (i*k)+modenv]) * Decay.kr(Dust.kr(decDens - input), (y.ar(decTimeFreq)+1*k+i) * modenv, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Bass

SynthDef(\bass3SusSd,{arg out=0, amp=1, pan = 0, tu = 1.54, sustain = 1, gate = 1;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate, timeScale: sustain, doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    // OffsetOut.ar(out,sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

///////////////////////////////////////  Snare

SynthDef(\snaremedSusSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, sustain = 1, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, timeScale: sustain, doneAction: doneAction);
	env1 = EnvGen.ar(env1);
	env1m = env1.midicps;
	son = LFSaw.ar(env1m,0,oamp, 1,1.4);//*LFSaw.ar(100).distort;
	son2 = SinOsc.ar(env1m,0, oamp, 1,1.4);
	son3 = LFPulse.ar(env1m,0, oamp, 1,1.4);
	son4 = LFTri.ar(env1m,0, oamp, 1,1.4);

	son = SelectX.ar(ochoose,[son,son2,son3,son4]);
	son = LeakDC.ar(son,dc,30);
	son = son ;
	son = HPF.ar(son, 100, env0);
	son = son + SelectX.ar(owhich2,[ SinOsc.ar(env1m, phase, env0), LFSaw.ar(env1m, phase, env0), LFPulse.ar(env1m, phase, env0), LFTri.ar(env1m, phase, env0)]);
	son =  HPF.ar(son +BrownNoise.ar(env0/2*noise)+WhiteNoise.ar(env0*noise),fratio);
	//son = son.clip2(1);

	son = Limiter.ar(son,1);
	son = son * level.distort;

	// OffsetOut.ar(out, Pan2.ar(son, pan, level)).tanh;
	//OffsetOut.ar(snd, son*level).tanh;
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level)).tanh;
}).add;

)