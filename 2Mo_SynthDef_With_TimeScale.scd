(

///////////////////////////////////////  SynthDef with timeScale

///////////////////////////////////////  Kick

SynthDef(\snapkickSusSd, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, sustain = 1, doneAction = 2|
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

SynthDef(\snapkick_Sd, { |out = 0, amp = 0.3, pan = 0, attack = 0.0001, release = 0.4, sustain = 1, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2|
	var globalEnv, body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve));
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
	snd = snd.tanh * globalEnv;

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickbass_Sd, { | out = 0, level = 0.5, pan = 0, attack = 0.0001, sustain = 1, release = 0.26, atk = 0.01, dcy = 0.2, rls = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, doneAction = 2 |
	var env0,env1,
	env1m, son, son2,son3,son4,p2, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	p2 = p1 * (-pi);
	env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[atk,dcy,rls],[curve1, curve2, curve3]);
	env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0,SinOsc.kr(0.025));
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
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, level * globalEnv)).tanh;
}).add;

SynthDef(\kicklaserbeam_Sd, { arg out = 0, amp = 0.3, pan = 0.0, attack = 0.0001, sustain = 1, release = 0.26, freq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, clickAtk = 0, clickRls = 0.1, clickSus = 1, clickLevScale = 10, clickEnvPow = 1, clickEnvNoiseAmp = 0.4, clickEnvInv = 0, clickFreq = 820, clickAmp = 0.3, doneAction = 2;
	var snd, freqenv, ampenv, globalEnv, clickEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3].normalizeSum));
	snd = LFTri.ar(freq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);

	clickEnv = EnvGen.ar(Env.perc(clickAtk, clickRls), levelScale: clickLevScale, timeScale: clickSus).pow(clickEnvPow) * PinkNoise.ar(clickEnvNoiseAmp).range(0.1, 1).lag(0.02);

	clickEnv = Select.ar(clickEnvInv, [clickEnv, clickEnv.neg]);

	snd = snd + HPF.ar(clickEnv, clickFreq, clickAmp);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetBassLeak_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = 1, globalEnvPow = 1, globalEnvNoise = 0.1, globalEnvInv = 0, atk = 0.01, dcy = 0.4, frqStart = 2, frqEnd = 2, frqTime = 0, sawPow = 1.5, brfFreq1 = 45.1, brfFreq2 = 45, rq = 0.1, t_gate = 1, doneAction = 2;
	var sig, env, globalEnv, trig;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve), t_gate, timeScale: sustain, doneAction: doneAction).pow(globalEnvPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range(0.1, 1).lag(0.02);

	globalEnv = Select.ar(globalEnvInv, [globalEnv, globalEnv.neg]);

	env = Decay2.ar(
		Trig.ar(t_gate, sustain),
		atk,
		dcy
	);

	sig = Saw.ar(XLine.ar(frqStart, frqEnd, frqTime), env) ** sawPow;
	sig = BRF.ar(sig, 20 + [brfFreq1, brfFreq2], rq);
	sig = sig * globalEnv;
	sig = LeakDC.ar(sig).tanh;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick_oto309_Sd, { arg out=0, amp=0.5, pan=0, attack = 0, release = 1.2, sustain = 1, curve = 1, globalEnvPow = 1, globalEnvNoise = 0.1, globalEnvInv = 0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), t_gate = 1, doneAction = 2;
	var env0, env1, env1m, son, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve), t_gate, timeScale: sustain, doneAction: doneAction).pow(globalEnvPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range(0.1, 1).lag(0.02);

	globalEnv = Select.ar(globalEnvInv, [globalEnv, globalEnv.neg]);

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]));
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2 * globalEnv;
	son = son.clip2(1);

	// OffsetOut.ar(out, Pan2.ar(son * amp, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\IkedaBassSusSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, sustain = 1, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickRingzSd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.2, sustain = 1, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, dcy = 0.25, ffreq = 1000, doneAction = 2;
	var globalEnv, snd, env, envp;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve, curve/2, curve]));
	envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3], [curvep, curvep*1.25, curvep].midicps));
	snd = Ringz.ar(
		    in: LPF.ar(in: Impulse.ar(0), freq: ffreq),
		    freq: freq * envp,
		    decaytime: dcy,
		    mul: amp
	);

	snd = snd.tanh.sin * 2 * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
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

SynthDef(\t1kick2SusSd, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.2, envfL2 = 20, envfT3 = 1, envfL3 = 0, envfT4 = 1.4, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 1200, hpfRq = 1, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), envPow = 1, envInv = 0, lvlScale = 1, attFreq = 440, verbMix = 1, verbRoom = 1, verbDamp = 0.5, sustain = 1, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), timeScale: sustain, doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve), doneAction: doneAction);
	var sig = SinOsc.ar(envf+50*pitch, 0, enva);
	//sig = PitchShift.ar(sig,0.001,pitch,0.1);
	sig = BHiPass4.ar(sig.distort, hpfFreq, hpfRq);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale).pow(envPow) * envInv.linlin(0, 1, 1, -1) * PinkNoise.ar(0.3!2).range( 0.1, 1 ).lag(0.01), attFreq);
	revSig = FreeVerb.ar(sig, verbMix, verbRoom.max(0.01), verbDamp);
	// revSig = GVerb.ar(sig, Lag3.kr(verbRoom).max(0.01), verbTime, verbDamp);
	sig = SelectX.ar(verbMix, [sig, revSig]);
	// sig = Pan2.ar(sig, pan, amp*enva);
	// OffsetOut.ar(out, sig);
	sig = LeakDC.ar(sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp*enva));
}).add;

// .pow(1) // * 0.linlin(0, 1, 1, -1) // * PinkNoise.ar(0.2!2).range( 0.1, 1 ).lag(0.01)

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

SynthDef(\kickParallaxSusSd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, sustain = 1, doneAction = 2;
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
    arg out = 0, pan = 0, dcy = 30, amp = 0.3, gate = 0, tone = 56, sustain = 1, doneAction = 2;
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

SynthDef(\kickBoomySusSd, { arg out = 0, amp=1, pan = 0, atk = 0.0014, rls=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, envT1 = 0.012, envL1 = 0, envT2 = 0.0012, envL2 = 1, envT3 = 0.12, envL3 = 0.1, envCrv = (-4), lvlScale = 1, hpfFreq = 500, gain=1.1, sustain = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, timeScale: sustain, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.pairs([[envT1, envL1], [envT2, envL2], [envT3, envL3]], envCrv), levelScale: lvlScale), hpfFreq);
	sig = sig * gain;
	sig = sig.softclip * 1;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\ringkickSusSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, dcy = 2.63, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, curve = (-4.92), envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, sustain = 1, doneAction = 2;
	var snd, env, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	env = EnvGen.kr(Env.linen(atk, 1, dcy), doneAction: doneAction);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod, timeScale: sustain);
	trig = Impulse.ar(0);
	snd = Ringz.ar(
		in: LPF.ar(
			in: trig,
			freq: lpfFreq
		),
		freq: frq * envf.range(1, envfAmt), /*+ (frq * envf)*/
		decaytime: dcy,
		mul: 7 * ringAmp
	).tanh.sin*2;

	snd = snd + SawDPW.ar(sawFreq, sawPh, Decay.ar(trig, dcy / sawDecDiv) * sawAmp);

	snd = snd + SinOscFB.ar(sinFreq * envf.range(1, envfAmt), sinFb, Decay.ar(trig, dcy / sinDecDiv) * sinAmp);

	snd = snd * env;
	// OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ringkick_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1.6, sustain = 1, curve = (-4), dcy = 0.2, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, doneAction = 2;
	var snd, globalEnv, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod);
	trig = Impulse.ar(0);
	snd = Ringz.ar(
		in: LPF.ar(
			in: trig,
			freq: lpfFreq
		),
		freq: frq * envf.range(1, envfAmt), /*+ (frq * envf)*/
		decaytime: dcy,
		mul: 7 * ringAmp
	).tanh.sin*2;

	snd = snd + SawDPW.ar(sawFreq, sawPh, Decay.ar(trig, dcy / sawDecDiv) * sawAmp);

	snd = snd + SinOscFB.ar(sinFreq * envf.range(1, envfAmt), sinFb, Decay.ar(trig, dcy / sinDecDiv) * sinAmp);

	snd = snd * globalEnv;
	// OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickeySusSd,{ arg out = 0, amp = 0.3, pan = 0, att = 0.0014, rel = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, sustain = 1, doneAction = 2;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, timeScale: sustain, doneAction: doneAction);
	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * gain;
	// sig = sig.softclip * amp * env;
	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickySusSd,{ arg out = 0, amp=1, pan = 0, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, softclip=1, sustain = 1, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, timeScale: sustain, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * softclip;
	sig = sig.softclip * amp * env;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick808AwSusSd, {arg out = 0, amp = 0.2, pan = 0, freqSrt = 240, freqEnd = 60, freqTime = 0.1, ringTime = 100, envpT1 = 0, envpL1 = 0, envpT2 = 0.2, envpL2 = 1, envpT3 = 0.4, envpL3 = 0.2, envpT4 = 0.4, envpL4 = 0, envpCurve = (-4), dist = 1.5, hpfFreq = 30, tott = 1, durr = 0.01, gate = 1, sustain = 1, doneAction = 2;
    var snd, env;
	tott = tott.max(0.01);
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freqSrt, freqEnd, freqTime),
		decaytime: ringTime
	);
	env = EnvGen.ar(Env.pairs([[envpT1, envpL1], [envpT2, envpL2], [envpT3, envpL3], [envpT4, envpL4]], envpCurve), gate, timeScale: sustain, doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	snd = HPF.ar(snd, hpfFreq);
	snd = Limiter.ar(snd, tott, durr.max(0.01)) * 0.5 *(1/tott);
	//snd = Clip.ar(snd, -1 * tott, tott);
	//snd = Fold.ar(snd, -1 * tott, tott);
	//snd = Wrap.ar(snd, -1 * tott, tott);
	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
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

SynthDef(\haten1_Sd, { arg out = 0, amp = 0.06, pan = 0, attack = 0, release = 1.4, sustain = 1, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve));
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
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

SynthDef(\fabHi1_Sd, {arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.2, sustain = 1, curve = (-4), envPow = 1, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, envNcurve = (-4), envNpow = 1, wbpfFreq = 2800, wbpfRq = 1, sawFrq = 2120, sinFrq = 12423, sawPh = 0, sinPh = 0.02, sawLev = 1, sinLev = 1, mix = 0.5, clickInScale = 40, envSatt = 0.001, envSrel = 0.2, envScurve = (-4), envSpow = 1, clickHpf = 322, clickRq = 1, clickPow = 1, clickAmp = 1, ffreq = 6000, gate = 1, doneAction = 2;
	var globalEnv, noise, saw, sin, click, sig, envNoise, envOsc, delay;
	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	globalEnv = globalEnv * WhiteNoise.ar(0.3 + [0, 0.1]).range(0.1, 1).lag(0.02);

	envNoise = EnvGen.ar(Env.perc(envNatt, envNrel, curve: envNcurve), gate).pow(envNpow);
	envOsc = EnvGen.kr(Env.perc(envSatt, envSrel, curve: envScurve), gate).pow(envSpow);

	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));

	click = RHPF.ar((envNoise * clickInScale).pow(clickPow), clickHpf, clickRq, clickAmp);

	saw = VarSaw.ar(sawFrq, sawPh, mul: sawLev);
	sin = SinOsc.ar(sinFrq, sinPh, sinLev);

	sig = XFade2.ar(noise * envNoise, Mix.ar([saw, sin]) * envOsc, mix);
	sig = HPF.ar(sig, ffreq);
	sig = Mix.ar([sig, click]) * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\metro_Sd, {arg out = 0, amp = 1, pan = 0, attack = 0, release = 2, sustain = 1, curve = (-4), envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envT4 = 0, envDivDur = 1, theta = 0.5, rho = 0.8, filterfreq = 1000, rq = 1.0, doneAction = 2;
	var globalEnv, env, signal, b1, b2;
	globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.ar(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2, envT3, envT4]), timeScale: sustain / envDivDur);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(env, 1.0, 0.0, 0.0, b1, b2) * env;
	signal = RHPF.ar(signal, filterfreq, rq);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat808SusSd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, atk = 0.01, rls = 0.1, sustain = 1, envPow = 1, envNoiseFrq1 = 0.3, envNoiseFrq2 = 0.33, envNoiseVol = 0.3, envInv = 0, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(atk, rls), timeScale: sustain, doneAction: doneAction);
	env = env.pow(envPow) * LFNoise0.kr([envNoiseFrq1, envNoiseFrq1] , envNoiseVol).range(0.1, 1);

	env = Select.kr(envInv, [env, env.neg]);

	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \rhpfFreq.kr(5700), \rhpfRq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1), rls, -4), timeScale: sustain))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \rhpf1Freq.kr(2000)*env*tu, \rhpf1Rq.kr(0.5));
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sosHatsSusSd, { arg out = 0, amp = 0.8, pan = 0, frq = 6000, curve = -4, rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	// General envelope
	envAtt = 0.01, envRel = 1, envCurve = (-4), sustain = 1,
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd;

	root = Pulse.ar(freq: frq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: frq * [1.34, 2.405, 3.09, 1.309],
		pmindex: rootIndex * [1, 0.22, 0.014, 0.0038]
	);

	root = Mix.new(root);

	initialEnv = Env.perc(attackTime: initAtt, releaseTime: initRel, curve: curve).kr;

	initialSweep = Line.kr(start: initStart, end: initEnd, dur: initRel);

	initial = BPF.ar(in: root, freq: initialSweep, rq: rq, mul: initialEnv * initAmp);

	bodyEnv = Env.perc(attackTime: bodyAtt, releaseTime: bodyRel, curve: curve / 2).kr;

	bodySweep = Line.kr(start: bodyStart, end: bodyEnd, dur: bodyRel);

	body = HPF.ar(in: root, freq: bodySweep, mul: bodyEnv * bodyAmp);

	snd = Mix.ar([initial, body]) * amp;

	snd = snd * EnvGen.kr(Env.perc(envAtt, envRel, curve: envCurve), timeScale: sustain, doneAction: doneAction);
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
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

SynthDef(\noise_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 1.25, sustain = 1, curve = (-4), envPow = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
	var globalEnv =  EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\newNoise48SusSd,{arg out = 0, amp = 1, pan = 0, env0L1 = 0.1, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.2, env0T3 = 0.25, env0T4 = 0.25, offset = 0, sustain = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, gate = 1, doneAction = 2;
var env0 =  EnvGen.ar(Env.step([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3, env0T4], offset), gate, timeScale: sustain, doneAction: doneAction);
var sig = LatoocarfianL.ar(
		SampleRate.ir/coeff,
		avar.max(-3).min(3),
		bvar.max(-3).min(3),
		cvar.max(0.5).min(1.5),
		dvar.max(0.5).min(1.5),
		xi,
		yi
	);
	sig = HPF.ar(sig,hpf);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig, DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*coeff);
	//sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	sig=  sig.tanh*env0;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\benjolisSusSd,{ |out = 0, amp = 0.1, pan = 0, atk = 0.00001, rls = 0.2, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, sustain = 1, doneAction = 2|
	var osc1, osc2, tri1, tri2, sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8=1, rungler, pwm, filt, output;
	var sr;
	var osc2freq, buf, bufR;

	bufR = LocalIn.ar(2,0);
	rungler = bufR.at(0);
	buf = bufR.at(1);

	sr = SampleDur.ir;
	//sr = ControlDur.ir;
	tri1 = LFTri.ar((rungler*rungler1)+freq1);
	tri2 = LFTri.ar((rungler*rungler2)+freq2);
	osc1 = PulseDPW.ar((rungler*rungler1)+freq1);
	osc2 = PulseDPW.ar((rungler*rungler2)+freq2);

	//pwm = tri1 > tri2;
	pwm = BinaryOpUGen('>', (tri1 + tri2),(0));

	osc1 = ((buf*loop)+(osc1* (loop* -1 +1)));
	sh0 = BinaryOpUGen('>', osc1, 0.5);
	sh0 = BinaryOpUGen('==', (sh8 > sh0), (sh8 < sh0));
	sh0 = (sh0 * -1) + 1;

	sh1 = DelayN.ar(Latch.ar(sh0,osc2),0.01,sr);
	sh2 = DelayN.ar(Latch.ar(sh1,osc2),0.01,sr*2);
	sh3 = DelayN.ar(Latch.ar(sh2,osc2),0.01,sr*3);
	sh4 = DelayN.ar(Latch.ar(sh3,osc2),0.01,sr*4);
	sh5 = DelayN.ar(Latch.ar(sh4,osc2),0.01,sr*5);
	sh6 = DelayN.ar(Latch.ar(sh5,osc2),0.01,sr*6);
	sh7 = DelayN.ar(Latch.ar(sh6,osc2),0.01,sr*7);
	sh8 = DelayN.ar(Latch.ar(sh7,osc2),0.01,sr*8);

	//rungler = ((sh6/8)+(sh7/4)+(sh8/2)); //original circuit
	//rungler = ((sh5/16)+(sh6/8)+(sh7/4)+(sh8/2));

	rungler = ((sh1/2.pow(8))+(sh2/2.pow(7))+(sh3/2.pow(6))+(sh4/2.pow(5))+(sh5/2.pow(4))+(sh6/2.pow(3))+(sh7/2.pow(2))+(sh8/2.pow(1)));

	buf = rungler;
	rungler = (rungler * scaler.linlin(0,1,0,127));
	rungler = rungler.midicps;

	LocalOut.ar([rungler,buf]);

	filt = Select.ar(filterType, [
		RLPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		//BMoog.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,0,gain),
		RHPF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq/** -1 +1*/,gain),
		SVF.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,1,0,0,0,0,gain),
		DFM1.ar(pwm,(rungler*runglerFilt)+filtFreq,rq,gain,1)
	]);

	output = SelectX.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp ! 2);
	// OffsetOut.ar(out, output * EnvGate(fadeTime: fadeTime, doneAction: doneAction));
	output = output * EnvGen.kr(Env.asr(atk, 1, rls), 1, timeScale: sustain, doneAction: doneAction);
	OffsetOut.ar(out, DirtPan.ar(output, ~dirt.numChannels, pan));
}).add;

SynthDef(\lcm2SusSd, { arg out = 0, amp = 0.1, pan = 0, atk = 1, rls = 2, sustain = 1, envPow = 1, envNoiseFrq1 = 0.3, envNoiseFrq2 = 0.33, envNoiseVol = 0.3, envInv = 0, mod1 = 3.09431, mod2 = 54.0487, gate = 1, doneAction = 2;
    var sig, sig1, sig2, env;

	env = EnvGen.kr(Env.perc(atk, rls), timeScale: sustain, doneAction: doneAction);
	env = env.pow(envPow) + LFNoise0.kr([envNoiseFrq1, envNoiseFrq1] , envNoiseVol);

	env = Select.kr(envInv, [env, env.neg]);

    mod1 = mod1.min(1000).max(1);
    mod2 = mod2.min(1000).max(1);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;

	sig = LeakDC.ar(sig);
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\danScar_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.kr(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
        Fb1.ar(
            { |in, out| in[0] - (out[1] % lfo) },
            inSig, 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) /** amp*/;

    // sig = Pan2.ar(sig, pan);

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\danScar1_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = SinOsc.ar(sinFreq + [0, 0.1]);
    lfo = LFDNoise1.ar(noiseFreq).linexp(-1, 1, 0.5, 1);

    sig = LPF.ar(
         Fb1.ar(
            // in[0][0] is the current stereo sample of inSig
            // in[0][1] is the current mono sample of lfo
            { |in, out| in[0][0] - (out[1] % in[0][1]) },
            [inSig, lfo], 2, blockSize: s.options.blockSize
        ),
        lpfFreq
    ) /** amp*/;

    // sig = Pan2.ar(sig, pan);

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\danScar2_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, triFreq = 60, noiseFreq = 0.5, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    inSig = LFTri.ar(triFreq);
    lfo = { LFDNoise3.ar(0.5).linexp(-1, 1, 0.1, 150) } ! 2;

    sig = Fb1.ar(
        // in[0][0] is the current stereo sample of inSig
        // in[0][1] is the current mono sample of lfo
        { |in, out| in[0][0] - (out[1] % in[0][1]) },
        [inSig, lfo], 2, blockSize: s.options.blockSize
    ) /** amp*/;

    // OffsetOut.ar(out, sig * globalEnv);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;*/

SynthDef(\natwich_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.2, sustain = 1.5, curve = 4, modFreq = 0.4, modAmount = 0.8, sawFreq = 2100, rlpfFreq = 4000, rlpfRq = 0.1, doneAction = 2;
    var snd, fb, sig, globalEnv, mod1, mod2;

    globalEnv = EnvGen.kr(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction);

    mod1 = LFDNoise3.kr(modFreq, modAmount).range(0.1, 1.5);
    mod2 = LFDNoise0.kr(modFreq, modAmount).range(0.1, 1.5);

    fb = LocalIn.ar(1);
    snd = Saw.ar(sawFreq * mod1 * (fb * 48).midiratio);
    snd = RLPF.ar(snd, rlpfFreq * mod2 * (48 * (1 - fb)).midiratio, rlpfRq);
    snd = (snd * 3).fold2;
    sig = snd;
    snd = Amplitude.ar(ToggleFF.ar(PulseDivider.ar(snd, 3 * (1 + (100 * fb)))), 0.03, 0.3);
    LocalOut.ar(snd);
    snd = Pan2.ar(sig, pan) * amp * globalEnv;
    snd = Sanitize.ar(snd);
    snd = snd + (NHHall.ar(snd, 3) * -10.dbamp);

    // OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
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

SynthDef(\ambitek_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.9, curve = (-4), envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, gate = 1, doneAction = 2;
	var sig, globalEnv, envS;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), gate, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);
	envS = EnvGen.kr(Env([envSL1, envSL2, envSL3, envSL4], [envST1, envST2, envST3], envSCurve));
	sig = Saw.ar(sawFreq * envS);
	2.do{|i|
		var f = 2 ** (8 - i);
		sig = BRF.ar(
			AllpassN.ar(sig, 1, Lag2.kr(delTime, 0.2) / (12 - i), delDecay),
			Lag2.ar(80 ** TRand.ar(0, 1, Impulse.ar(f / 32, 1/2)).lag(1 / f) * 80, 0.5),
			brfRq
		);
	};
	sig = sig * globalEnv;
	// OffsetOut.ar(out, sig!2 * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\main_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0.0, release = 2, sustain = 1, envPow = 1, curve = 1, levelScale = 1, levelBias = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sin1Freq = 30, envL1 = 0, envL2 = 1, envL3 = 0.01, envL4 = 1.3, envL5 = 0, envT1 = 0.01, envT2 = 0, envT3 = 0.2, envT4 = 0.01, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, sel = 0, sin2Freq = 40, sin2Amp = 0.3, noiseAmp = 1, hpffreq = 8000, revtime = 3, room = 10, distAmt = 2, distMix = 0, doneAction = 2;
	var distSig, envClick, click;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 0.6] + fmod, 0, [lev, lev - 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpffreq),
		SinOsc.ar(sin1Freq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];

	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), 1, levelScale, levelBias, sustain, doneAction).pow(envPow);

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum * sustain, clickCurve), levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq);
	click = click * clickAmp;

	sig = (click + SelectX.ar(sel.wrap(0, 3), sig).fold(-1, 1) * 0.7 + SinOsc.ar(sin2Freq, 0, sin2Amp) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpffreq)));

	distSig = Clip.ar(sig * distAmt);
	sig = SelectX.ar(distMix, [sig, distSig]);
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
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

SynthDef(\danUk_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.3, sustain = 1, curve = (-4), envPow = 1, globalEnvNoise = 0.3, globalEnvInv = 0, sawFreq = 50, r = 12, doneAction = 2;
	var phi, x, y, sig, globalEnv, envShape;

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1], 1, curve), doneAction: doneAction).pow(envPow);
	globalEnv = globalEnv * PinkNoise.ar(globalEnvNoise).range([0.1, 0.12], [1, 1.02]).lag(0.02);

	globalEnv = Select.ar(globalEnvInv.wrap(0, 1).round, [globalEnv, globalEnv.neg]);

    phi = LFSaw.ar([sawFreq, sawFreq + 0.1], -1).range(0, 2pi);
    x = r * cos(phi);
    y = r * sin(phi);
    sig = sin(x) - (sin(y) * log(x * x + 1)) / 10;
    sig = Limiter.ar(sig * globalEnv, 0.2);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan));
}).add;

~synthSd = SynthDef(\prayerBell_Sd, { |out = 0, gate = 1, amp = 0.5, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing, globalEnv, envShape;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1]), doneAction: i_doneAction).pow(envPow);

	mallet = LPF.ar(Trig.ar(gate, SampleDur.ir)!2, 10000 * freqscale);
	sing = LPF.ar(
		LPF.ar(
			{
				PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
			} ! 2,
			2434 * freqscale
		) + Dust.ar(0.1), 10000 * freqscale
	) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing);


	sig = DynKlank.ar(`[
		[
			(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
			first + LFNoise1.kr(0.5).range(1,3),
			LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
			LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
			LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
			LFNoise1.kr(2).range(8665, 8670),
			LFNoise1.kr(2).range(8704, 8709),
			LFNoise1.kr(2).range(8807, 8817),
			LFNoise1.kr(2).range(9570, 9607),
			LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
			LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
			LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
		],
		[
			LFNoise1.kr(1).range(-10, -5).dbamp,
			LFNoise1.kr(1).range(-20, -10).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			LFNoise1.kr(1).range(-12, -6).dbamp,
			-20.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp,
			-10.dbamp,
			-20.dbamp,
			-20.dbamp,
			-25.dbamp
		],
		[
			20 * freqscale.pow(0.2),
			20 * freqscale.pow(0.2),
			5,
			5,
			0.6,
			0.5,
			0.3,
			0.25,
			0.4,
			0.5,
			0.4,
			0.6
		] * freqscale.reciprocal.pow(0.5)
	], input, freqscale, 0, decayscale);
	// DetectSilence.ar(sig, doneAction: i_doneAction);
	sig = sig * globalEnv;
	// sig = Pan2.ar(sig, pan, level);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
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

SynthDef(\squareDrumSusSd, {
	arg
	// Standard values
	out = 0, freq = 180, amp = 0.6, pan = 0,
	// Stick Controls
	atk = 0.001, dcy = 0.01, rls = 0.2,
	// Head Controls
	headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rel = 0.2,
	// Snares Controls (thresh goes from 0 to 1)
	snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
	snareGate = 0.6, rq = 0.5, sustain = 1,
	doneAction = 2;

	var freqarray, amparray, decarray, stick, head, snares, snd;

	// Setting up arrays for Klank
	freqarray = Array.fill(8, {
		arg i = 1;
		(
			Array.fill((i + 1), {
				arg j;
				(j + 1).pow(2)
			}) +
			(i + 1).pow(2)
		).sqrt

	});
	freqarray = freqarray.flatten/(2.sqrt);

	amparray = Array.fill(36, {
		arg i;
		if (freqarray[i] > 20000)
		{ 0 }
		{
			(ampSlope * (freqarray[i]).log2).dbamp
		}
	});
	amparray = amparray/amparray.max;

	decarray = Array.fill(36, {
		arg i;
		exp(-1 * i * decCoef)
	});
	decarray = decarray/decarray[0];

	// Drumstick
	stick = Decay2.ar(
		in: Impulse.ar(0),
		attackTime: atk,
		decayTime: dcy,
		mul: 0.005); // This keeps the volume at a sane level

	// Drum Head
	head = Klank.ar(
		specificationsArrayRef:
		Ref.new([freqarray, amparray, decarray]),
		input: stick,
		freqscale: freq,
		decayscale: rel);

	// Snares
	snares = PinkNoise.ar(
		Amplitude.ar(
			in: head,
			attackTime: followAtt,
			releaseTime: followRel));
	snares = CompanderD.ar(
		in: snares,
		thresh: thresh,
		slopeBelow: 1 + snareGate.clip(0, inf));
	snares = BRF.ar(
		in: snares,
		freq: freqarray[1..6],
		rq: rq);

	//Output Stuff
	snd = (head * headAmp) + (snares * snaresAmp);
	snd = Mix.ar(snd * amp);
	snd = Limiter.ar(snd);

	// DetectSilence.ar(in: snd, doneAction: doneAction);

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), 1, timeScale: sustain, doneAction: doneAction);

	// Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrum_Sd, {
    arg
    // Standard values
    out = 0, freq = 180, amp = 0.6, pan = 0,
	// global env
	attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1,
    // Stick Controls
    atk = 0.001, dcy = 0.01,
    // Head Controls
    headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rls = 0.2,
    // Snares Controls (thresh goes from 0 to 1)
    snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
    snareGate = 0.6, rq = 0.5,
	doneAction = 2;

    var globalEnv, freqarray, amparray, decarray, stick, head, snares, snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // Setting up arrays for Klank
    freqarray = Array.fill(8, {
        arg i = 1;
        (
            Array.fill((i + 1), {
                arg j;
                (j + 1).pow(2)
            }) +
            (i + 1).pow(2)
        ).sqrt

    });
    freqarray = freqarray.flatten/(2.sqrt);

    amparray = Array.fill(36, {
        arg i;
        if (freqarray[i] > 20000)
            { 0 }
            {
                (ampSlope * (freqarray[i]).log2).dbamp
            }
    });
    amparray = amparray/amparray.max;

    decarray = Array.fill(36, {
        arg i;
        exp(-1 * i * decCoef)
    });
    decarray = decarray/decarray[0];

    // Drumstick
    stick = Decay2.ar(
        in: Impulse.ar(0),
        attackTime: atk,
        decayTime: dcy,
        mul: 0.005); // This keeps the volume at a sane level

    // Drum Head
    head = Klank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: stick,
        freqscale: freq,
        decayscale: rls);

    // Snares
    snares = PinkNoise.ar(
        Amplitude.ar(
            in: head,
            attackTime: followAtt,
            releaseTime: followRel));
    snares = CompanderD.ar(
        in: snares,
        thresh: thresh,
        slopeBelow: 1 + snareGate.clip(0, inf));
    snares = BRF.ar(
        in: snares,
        freq: freqarray[1..6],
        rq: rq);

    //Output Stuff
    snd = (head * headAmp) + (snares * snaresAmp);
    snd = Mix.ar(snd * amp);
	snd = snd * globalEnv;
    snd = Limiter.ar(snd);

    // Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\neuroSnareSusSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500, sustain = 1,
	doneAction = 2;

	var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

	// a percussive click to give it some attack
	cEnv = Env.linen(
		attackTime: clickatt,
		sustainTime: clicksus,
		releaseTime: clickrel,
		level: clickamp
	).ar;

	click = Hasher.ar(Sweep.ar);

	click = HPF.ar(in: click, freq: hipass);

	click = LPF.ar(in: click, freq: lopass);

	click = click * cEnv;

	// sine sweep body
	bEnvFreq = Env.new(
		levels: [2.5, 1.225, 1],
		times: [bodyatt, bodyrel],
		curve: \exp
	).ar;

	bEnvAmp = Env.perc(
		attackTime: bodyatt,
		releaseTime: bodyrel,
		level: bodyamp,
		curve: curve
	).ar;

	body = SinOsc.ar(freq: freq * bEnvFreq, mul: bEnvAmp);

	body = body.tanh;

	// sound of snare coils rattling
	rEnv = Env.perc(
		attackTime: rattleatt,
		releaseTime: rattlerel,
		level: rattleamp,
		curve: curve
	).delay(rattlehold).ar;

	rattle = Hasher.ar(Sweep.ar);

	rattle = BPeakEQ.ar(in: rattle, freq: rattlefreq, rq: rq, db: rattlepeak);

	rattle = HPF.ar(in: rattle, freq: hipass);

	rattle = rattle * rEnv;

	// another sound sweep to improve the attack, optional
	sEnvFreq = XLine.kr(
		start: sweepstart,
		end: sweepend,
		dur: sweeprel / 2
	);

	sEnvAmp = Env.perc(
		attackTime: sweepatt,
		releaseTime: sweeprel,
		level: sweepamp,
		curve: curve
	).ar;

	sweep = SinOsc.ar(freq: sEnvFreq, mul: sEnvAmp);

	// distortion helps glue everything together and acts as a compressor
	snd = Mix.ar(click + body + rattle + sweep);

	snd = (snd * preamp).tanh * amp;

	// DetectSilence.ar(in: snd, doneAction: doneAction);
	snd = snd * EnvGen.kr(Env.perc(0, sustain), doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snare909_Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 124, attack = 0, release = 0.1, sustain = 1, curve = 6, atk = 0, stn = 1, rls = 0.08, crv = 24, envNoiseAmp = 0.4, envTonePow = 12, envNoisePow = 0.63, toneRel = 0.1, toneAmp = 1, noiseRel = 0.06, noiseAmp = 0.4, nyquist = 12100, lpFreq = 14040, hpFreq = 83, doneAction = 2;
	var env, envTone, envNoise, envBlur, relTimes, globalEnv, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env([atk, stn, rls], relTimes, crv);

	envBlur = PinkNoise.kr(envNoiseAmp).range(0.1, 1).lag(0.02);

	envTone = EnvGen.kr(env, timeScale: toneRel) * envBlur;

	envNoise = EnvGen.kr(env, timeScale: noiseRel) * envBlur;

	globalEnv = Env.perc(attack, release, curve: curve).kr(timeScale: sustain, doneAction: doneAction);

	tone = LFTri.ar([1, 1.78] * freq, mul: toneAmp) * envTone.pow(envTonePow);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(noise, lpFreq, noiseAmp) * envNoise.pow(envNoisePow);

	snd = tone ++ [noise, HPF.ar(noise, hpFreq)];

	snd = Mix.ar(snd * globalEnv) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snarenew_Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), sustain = 1, mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var globalEnv, sig, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	globalEnv = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3].normalizeSum * sustain, curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu * envp,0,0.5) * globalEnv;
	sig = ((PinkNoise.ar * globalEnv) * mixNoise) + (sig * (1 - mixNoise));
    sig = RHPF.ar(sig, hpFreq*tu, rqhpf);
	sig = (Mix.ar(BPF.ar(sig,[freq1bpf, freq2bpf],[rq1bpf, rq2bpf])) * mixBpf) + (sig * (1 - mixBpf));
    sig = RLPF.ar(sig, lpf, rqlpf);
    // sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),gate, doneAction: doneAction);
    // sig = DelayL.ar(sig,0.05,0.001)+sig;
    // sig = DelayL.ar(sig,0.05,0.01)+sig;
    // sig = DelayL.ar(sig,0.1,0.1)+sig;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

)