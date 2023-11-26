(

///////////////////////////////////////  SynthDef

///////////////////////////////////////  Archetype SynthDef for SuperDirt

/*SynthDef(\archetypeSd, {
	|out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,clamp=1|
	var line, env, volume, tone, outAudio;
	freq=freq*speed;
	line = Line.ar(begin,end,sustain/speed,doneAction: Done.freeSelf);
	env = Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.5, 1], curve: [-5, 0, -5]);
	volume = IEnvGen.ar(env, line);
	tone = (Pulse.ar(freq,line)+Pulse.ar(freq*1.01,line)+Pulse.ar(freq*0.99,line))/3;
	outAudio = RLPF.ar(tone*volume, 20000*clamp*volume,0.3);
	OffsetOut.ar(out,DirtPan.ar(outAudio, ~dirt.numChannels, pan, volume));
}).add;*/

///////////////////////////////////////  Kick

SynthDef(\snapkickSd, { |out = 0, amp = 0.3, pan = 0, bdFrqL1 = 261, bdFrqL2 = 120, bdFrqL3 = 51, bdFrqT1 = 0.035, bdFrqT2 = 0.08, bdFrqC = (-4), bdAmpAtt = 0.005, bdAmpSus = 0.1, bdAmpRel = 0.3, bdAmpLev = 1, bdAmpCurve = 1, popFrqSt = 750, popFrqEnd = 261, popFrqDur = 0.02, popAmpAtt = 0.001, popAmpSus = 0.02, popAmpRel = 0.001, popAmpLev = 0.15, clkAmpAtt = 0.001, clkAmpRel = 0.01, clkAmpLev = 0.15, clkAmpCurve = (-4), clkfFundFreq = 910, clkfFormFreq = 4760, clkfBwFreq = 2110, clkLpfFreq = 3140, doneAction = 2|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([bdFrqL1, bdFrqL2, bdFrqL3], [bdFrqT1, bdFrqT2], bdFrqC));
	bodyAmp = EnvGen.ar(Env.linen(bdAmpAtt, bdAmpSus, bdAmpRel, bdAmpLev, bdAmpCurve), doneAction: doneAction);
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

SynthDef(\IkedaBassSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, doneAction = 2;
	var env, sin, sig;
	env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
	sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
	sig = sin * env;
	OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ikedaBassBrSd, { arg out = 0, amp = 1, pan = 0, att = 0, dec = 0.1, sus = 0.8, rel = 0.01, curve = -5, freq = 0, harmonic = 14.015, iphase = pi/3, gate = 1, doneAction = 2;
	var env, snd;

	env = Env.adsr(
	    	attackTime: att,
	    	decayTime: dec,
	    	sustainLevel: sus,
	    	releaseTime: rel,
	    	curve: curve,
	    ).kr(gate: gate, doneAction: doneAction);

	env = env * amp.curvelin(inMin: 0, inMax: 1, outMin: 0, outMax: 1, curve: log(10));

	snd = SinOsc.ar(
		    //Any value for freq here gets added to the freq of the note (n + 0 = n)
		    freq: 0,
		    //Phase sweeps around a circle at (rate / 2pi) to make a sine wave.
		    phase: (Sweep.ar(trig: gate, rate: 2pi * [freq, freq * harmonic]) + iphase).wrap(-pi, pi),
	        mul: [1, 0.01]
	    );

	snd = Mix.ar(snd).tanh;

	snd = LeakDC.ar(snd);

	snd = snd * env;

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\gabberkickSd, { arg out = 0, pan = 0, amp = 0.1, attack = 0.001, release = 0.05;
    var snd, freq, high, lfo;
	freq = \freq.kr(440).min(1400) * (Env.perc(0.001, 0.08, curve: \curve.kr(-1)).ar * 48 * \bend.kr(1)).midiratio;
    snd = Saw.ar(freq);
    snd = (snd * 100).tanh + ((snd.sign - snd) * -8.dbamp);
    high = HPF.ar(snd, 300);
    lfo = SinOsc.ar(8, [0, 0.5pi]).range(0, 0.01);
    high = high.dup(2) + (DelayC.ar(high, 0.01, lfo) * -2.dbamp);
    snd = LPF.ar(snd, 100).dup(2) + high;
    snd = RLPF.ar(snd, 7000, 2);
    snd = BPeakEQ.ar(snd, \ffreq.kr(3000) * XLine.kr(1, 0.8, 0.3), 0.5, 15);
    snd = snd * Env.asr(attack, 1, release).ar(2, \gate.kr(1));
    // OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickMistSd, { arg out = 0, level = 1, pan = 0, tu = 1, noise = 1, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.5, env0T3 = 0.26, curve0_1 = (-4), curve0_2 = (-2), curve0_3 = (-4), env1L1 = 120, env1L2 = 43, env1L3 = 29, env1T1 = 0.03, env1T2 = 0.29, curve1_1 = (-4), curve1_2 = (-5), doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [curve0_1, curve0_2, curve0_3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [curve1_1, curve1_2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(noise);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig.clip2(1);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\kickhiSd, { arg out = 0, amp = 0.3, pan = 0, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), tu = 1, doneAction = 2;
	var env0, env1, env1m, sig;
	env0 =  EnvGen.ar(Env.new([vcaLev1, vcaLev2, vcaLev3, vcaLev4, vcaLev5], [vcaTime1, vcaTime2, vcaTime3, vcaTime4], [vcaCurve1, vcaCurve2, vcaCurve3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([vcfLev1, vcfLev2, vcfLev3, vcfLev4], [vcfTime1, vcfTime2, vcfTime3], [vcfCurve1, vcfCurve2]));
	env1m = env1.midicps;
	sig = LFPulse.ar(env1m*tu, 0, 0.5, 1, -0.5);
	sig = out + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m*tu, 0.5, env0*4);
	sig = sig * 1.2;
	sig = sig.clip2(1);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2Sd,{arg out = 0, gate = 1, freq = 60, tu = 1, amp = 1, atf = 80, rel =1, pan = 1;
	var env = EnvGen.ar(Env.perc(0,rel),gate,doneAction:2);
	var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
	var sig = SinOsc.ar(frequ*tu,0,env);
	// sig = Pan2.ar(LPF.ar(sig,100), pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(LPF.ar(sig,100), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick2newSd,{arg out = 0, amp = 1, pan = 0, att = 0, rel = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.perc(att, rel), gate, doneAction: doneAction);
    var frequ = EnvGen.ar(Env([freq+1100, freq, 31.4],[envfT1, envfT2]));
    var sig = SinOsc.ar(frequ*tu, 0, env);
    sig = BPeakEQ.ar(sig, bpeqf1, bpeqrq1, bpeqamp1);
    sig = sig *0.4*(env+0.2);
    sig = BPeakEQ.ar(sig, bpeqf2, bpeqrq2, bpeqamp2);
    //sig = Limiter.ar(sig,0.5);
    //Out.ar(6,[DelayL.ar(sig*(-1),0.1,SinOsc.kr(-0.1,0,0.05,0.1)),sig]);
	sig = HPF.ar(sig, hpff);
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick3Sd,{arg out = 0, amp = 0.5, pan = 0, tu = 1, atk = 0, rls = 3, freq = 60, gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	var frequ = EnvGen.ar(Env([130,freq,30],[0.05,rls]));
	var sig = SinOsc.ar(freq*tu,0,env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick3newSd,{arg out = 0, amp = 0.5, gate = 1, tu = 1, rel = 3, freq = 60, pan = 0;
    var env = EnvGen.ar(Env.perc(0,rel), gate, doneAction:2);
    var frequ = EnvGen.ar(Env([100,50,50],[0.005,0.1]));
    var sig = SinOsc.ar(freq*tu,0,env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicknoiseSd,{arg out = 0, amp = 0.5, pan = 0;
	var env = EnvGen.ar(Env([0,1,0],[0.01, 0.1]), doneAction: 2);
	var freq =EnvGen.ar(Env([20000,100,30],[0.005,1]));
	var sig =  SinOsc.ar(freq,0,env)+(WhiteNoise.ar(1)*env);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t1kickSd, {arg out = 0, amp = 0.5, pan = 0, rel = 0, doneAction = 2;
	var enva, envf, sig;
	enva = EnvGen.ar(Env([0.01,1,0],[0.001, rel]), doneAction: doneAction);
	envf = EnvGen.ar(Env([800,50],[0.005,1]));
	sig = SinOsc.ar(envf,0,enva);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t1kick2Sd, {arg out = 0, amp = 0.5, pan = 0, envaT1 = 0, envaL1 = 1, envaT2 = 0.6, envaL2 = 1, envaT3 = 0.2, envaL3 = 0.5, envaT4 = 0.2, envaL4 = 0, envaCurve = (-4), envfT1 = 0, envfL1 = 10000, envfT2 = 0.002, envfL2 = 20, envfT3 = 0.1, envfL3 = 0, envfT4 = 1, envfL4 = 4, envfCurve = (-4), pitch = 0.1, hpfFreq = 1200, hpfRq = 1, verbMix = 1, verbRoom = 1, verbDamp = 0.5, doneAction = 2;
	var revSig;
	var enva = EnvGen.kr(Env.pairs([[envaT1, envaL1], [envaT2, envaL2], [envaT3, envaL3], [envaT4, envaL4]], envaCurve), doneAction: doneAction);
	//var envf = EnvGen.kr(Env([10000,20,00,4],[0.002,0.1,1,1]));
	var envf = EnvGen.kr(Env.pairs([[envfT1, envfL1], [envfT2, envfL2], [envfT3, envfL3], [envfT4, envfL4]], envfCurve));
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

SynthDef(\kickmedSd, { | out = 0, level = 0.5, pan = 0, noise = 1, done = 2, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0,0.5],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2,env1T3,env1T4],[curve1, curve2, curve3]);
	env0 = EnvGen.ar(env0, doneAction:done);
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

SynthDef(\kick808Sd,{arg out = 0, amp = 0.5,  pan = 0, tu = 1, gate = 1, envL1 = 0, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, enfL1 = 1000, enfL2 = 20, enfL3 = 20, enfT1 = 0.001, enfT2 = 0.001, enfT3 = 0.001;
	var env = EnvGen.ar(Env([envL1,envL2,envL3],[envT1,envT2],-8), gate, doneAction:2);
	var enf  = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2,enfT3],-4));
	var sig = SinOsc.ar(tu*(enf+40))*env;
	sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(100,0,50,100*tu),0,0.2)*env,1000);
	// OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick808newSd, { arg out = 0, amp = 0.5, pan = 0, envL1 = 1, envL2 = 1, envL3 = 0, envT1 = 0, envT2 = 1, envCurve = (-8), enfL1 = 5000, enfL2 = 100, enfL3 = 50, enfT1 = 0.0001, enfT2 = 0.01, enfCurve = (-4), tu = 2, sin2Frq = 10, sin2Amp = 50, doneAction = 2;
    var env = EnvGen.ar(Env([envL1, envL2, envL3],[envT1, envT2], -8), doneAction: doneAction);
    var enf  = EnvGen.ar(Env([enfL1, enfL2, enfL3],[enfT1, enfT2, 0.1], enfCurve));
    var sig = SinOsc.ar(tu*(enf))*env;
    sig = sig + LPF.ar(SinOsc.ar(SinOsc.ar(sin2Frq, 0, sin2Amp, 40*tu), 0, 0.01) * env, 100);
    sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick808AwSd, {arg out = 0, amp = 0.2, pan = 0, freqSrt = 240, freqEnd = 60, freqTime = 0.1, ringTime = 100, envpT1 = 0, envpL1 = 0, envpT2 = 0.2, envpL2 = 1, envpT3 = 0.4, envpL3 = 0.2, envpT4 = 0.4, envpL4 = 0, envpCurve = (-4), dist = 1.5, hpfFreq = 30, tott = 1, durr = 0.01, gate = 1, doneAction = 2;
    var snd, env;
	tott = tott.max(0.01);
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freqSrt, freqEnd, freqTime),
		decaytime: ringTime
	);
	env = EnvGen.ar(Env.pairs([[envpT1, envpL1], [envpT2, envpL2], [envpT3, envpL3], [envpT4, envpL4]], envpCurve), gate, doneAction: doneAction);
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

SynthDef(\kick808BrSd, {arg out = 0, amp = 1, pan = 0, att = 0.001, rel = 1, freq1 = 240, freq2 = 60, ringTime = 10, dist = 0.5, doneAction = 2;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(att, rel, amp).kr(doneAction: doneAction);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kikAwSd, { |out = 0, amp = 0.5, pan = 0, basefreq = 50, ratio = 7, sweeptime = 0.05, envL1 = 1, envL2 = 0.8, envL3 = 0, envT1 = 0.3, envT2 = 0.15|
    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([envL1, envL2, envL3], [envT1, envT2], -4), doneAction: 2),
	sig = SinOsc.ar(fcurve, 0.5pi, env).distort * amp;
    // OffsetOut.ar(out, sig ! 2);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickbassSd, { | out = 0, level = 0.5, pan = 0, attack = 0.01, decay = 0.2, release = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, done = 2 |
	var env0,env1,
	env1m, son, son2,son3,son4,p2;

	p2 = p1 * (-pi);
	env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[attack,decay,release],[curve1, curve2, curve3]);
	env1 = Env([freq1,freq2,freq3],[famp1,famp2,famp3,famp4],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0,SinOsc.kr(0.025) ,doneAction: done);
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

SynthDef(\drumkickSd, { arg out = 0, amp = 0.5, pan = 0.0, attack = 0.0001, release = 0.09, curve = 8, attSinFreq = 0.0001, relSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, relBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, doneAction = 2;
	var source;

	source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, relSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
	((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, relBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(attack, release, curve: curve), gate, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickAwSd, {arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.45, sinfreq = 70, glissf = 0.9, doneAction = 2;
	var gliss = XLine.kr(sinfreq, sinfreq*glissf, rel);
	var snd = SinOsc.ar(gliss);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: doneAction);
	snd = snd * env * amp;
	snd = Limiter.ar(snd,1,0.001);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick3AwSd, {arg out = 0, amp = 0.5, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.8, envL4 = 0, attack = 0.01, decay = 0.1, release = 0.2, punch = 1, envfLev1 = 400, envfLev2 = 66, envfTime = 0.08, envfCurve = -3, doneAction = 2;
	var freq, env, sig;
    freq = EnvGen.kr(Env([envfLev1, envfLev2], [envfTime], envfCurve));
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [attack, decay, release]), doneAction: doneAction);
	sig = Normalizer.ar(SinOsc.ar(freq, 0.5pi, punch).distort, 1) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kicklaserbeamSd, { arg out = 0, amp = 0.3, pan = 0.0, freq = 13007, freqenvL1 = 3.97, freqenvL2 = 5, freqenvL3 = 0, freqenvL4 = 2.97, freqenvT1 = 0.16, freqenvT2= 0.07, freqenvT3= 0.26, ampenvL1 = 1, ampenvL2 = 1, ampenvL3 = 0, ampenvL4 = 0, ampenvT1 = 0.02, ampenvT2 = 0.2, ampenvT3 = 0.1, hpfFreq = 50, hpfRq = 1, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([freqenvL1, freqenvL2, freqenvL3, freqenvL4], [freqenvT1, freqenvT2, freqenvT3]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([ampenvL1, ampenvL2, ampenvL3, ampenvL4], [ampenvT1, ampenvT2, ampenvT3]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq * freqenv, 0, ampenv);
	snd = BHiPass4.ar(snd, hpfFreq, hpfRq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tweetBassLeakSd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1, att = 0.01, dec = 0.4, freq = 2, rq = 0.1, gate = 1, doneAction = 2;
	var sig, demand, env, globenv;
	demand = Demand.kr(
		gate,
		0,
		Drand([0.8, 1], inf)
	);
	env = Decay2.kr(
		demand,
		att,
		dec
	);
	sig = Saw.ar(freq, env) ** 1.5;
	sig = BRF.ar(sig, demand * 20 + [45.1, 45], rq);
	//globenv = EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	globenv = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = sig * globenv;
	sig = LeakDC.ar(sig).tanh;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetKickIntSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, doneAction = 2;
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
	env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	sig = SinOsc.ar(freq, phase, env);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickParallaxSd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, kharm1 = 1, kharm2 = 2, kharm3 = 3, kharm4 = 4, kamp1 = 0.05, kamp2 = 0.05, kamp3 = 0.05, kamp4 = 0.05, kring1 = 1, kring2 = 1, kring3 = 1, kring4 = 1, frqScale = 1, decScale = 1, resoMix = 0.5, doneAction = 2;
	var sig, env_amp, env_freq, kharm, kamp, kring, reso;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

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

SynthDef(\kickParallax1Sd, { arg out = 0, amp = 1, pan = 0, envAmpAtt = 0.01, envAmpRel = 0.3, envFrqAtt = 0, envFrqRel = 0.02, freq = 55, doneAction = 2;
	var sig, env_amp, env_freq;

	env_amp  = Env.perc (envAmpAtt, envAmpRel - 0.01, amp);
	env_amp  = EnvGen.kr (env_amp, doneAction: doneAction);

	env_freq = Env.perc (envFrqAtt, envFrqRel, 1);
	env_freq = EnvGen.ar (env_freq);

	sig = SinOsc.ar (freq * env_freq, 0, env_amp);
	// sig = Pan2.ar (sig, pan);
	// OffsetOut.ar (out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\tabassSd, { arg out = 0, amp = 0.8, pan = 0, gate = 1, attack = 0.01, release = 2, freq = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = LFTri.ar(freq);
	20.do{
		sig = BAllPass.ar(sig,80,1);
		sig = ((sig+0.02)*LFNoise0.kr(1/2)*6).tanh;
		sig = LeakDC.ar(sig,0.995);
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\mcldSd, { arg out = 0, amp = 0.7, pan = 0, att = 0.01, rel = 2, impFreq = 10, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, env, input;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;*/

SynthDef(\batuhanSd, { arg out = 0, amp = 0.2, pan = 0, att = 0.01, rel = 5, eSawDec = 0.6, eSinL1 = 0, eSinL2 = 1, eSinL3 = 0, eSinL4 = 0.32, eSinT1 = 0.24, eSinT2 = 0.02, eSinT3 = 0.12, eSinC1 = (-4), eSinC2 = (-4), eSinC3 = (-4), sinFreq = 33, sawMix = 1, sawFreq = 8, bpfFreq = 162, bpfRq = 1, bpfMix = 0, brfFreq1 = 45.1, brfFreq2 = 45, brfRq = 1, doneAction = 2;
	var sig, env, trig, envSaw, envSin;
	trig = Impulse.kr(0);
	env = Linen.kr(trig, att, 1, rel, doneAction);
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
	//sig = (sig[0] + sig[1])!2; // mono
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\kickySd,{ arg out = 0, amp=1, pan = 0, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, noiseAmp=0.0, gain=1, doneAction = 2;
	var sig, env, freq;
	freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
	env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, doneAction: doneAction);
	sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
	sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickeySd,{ arg out = 0, amp = 0.3, pan = 0, att = 0.0014, rel = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, decay = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
	var sig, env, freq;
	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	sig = sig * gain;
	//sig = sig.softclip * amp * env;
	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickBoomySd, { arg out = 0, amp=1, pan = 0, atk = 0.0014, rel=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, gain=1.1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(atk, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(frq1/4) + SinOsc.ar(frq2/4) + LFTri.ar(frq3/4) + LFTri.ar(frq4/4) + BrownNoise.ar(0.1)) * env * amp;
	sig = LPF.ar(sig, 500);
	sig = sig + HPF.ar(EnvGen.ar(Env.perc(0.001,0.001,0.5)),500);
	sig = sig * gain;
	sig = sig.softclip * 1;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_oto309Sd, { arg out=0, amp=0.5, pan=0, env0L1 = 0.5, env0L2 = 1, env0L3 = 0.5, env0L4 = 0, env0T1 = 0.005, env0T2 = 0.06, env0T3 = 0.26, env0Crv1 = (-4), env0Crv2 = (-2), env0Crv3 = (-4), env1L1 = 110, env1L2 = 59, env1L3 = 29, env1T1 = 0.005, env1T2 = 0.29, env1Crv1 = (-4), env1Crv2 = (-5), doneAction = 2;
	var env0, env1, env1m, son;

	env0 =  EnvGen.ar(Env.new([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3], [env0Crv1, env0Crv2, env0Crv3]), doneAction: doneAction);
	env1 = EnvGen.ar(Env.new([env1L1, env1L2, env1L3], [env1T1, env1T2], [env1Crv1, env1Crv2]));
	env1m = env1.midicps;

	son = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	son = son + WhiteNoise.ar(1);
	son = LPF.ar(son, env1m*1.5, env0);
	son = son + SinOsc.ar(env1m, 0.5, env0);

	son = son * 1.2;
	son = son.clip2(1);

	// OffsetOut.ar(out, Pan2.ar(son * amp, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kick_oto309BrSd, { arg out = 0, amp = 0.5, pan = 0, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = -4,
	//Other Controls:
	filterHarmonic = 1.5, preamp = 1.25, pulseAmp = 0.5, noiseAmp = 1, sineAmp = 1,
	doneAction = 2;
	var env, envp, snd;

	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curve, curve * 1.25]).kr.midicps;

	snd = LFPulse.ar(freq: envp).range(-1 * pulseAmp, pulseAmp);
	snd = snd + WhiteNoise.ar(mul: noiseAmp);
	snd = LPF.ar(in: snd, freq: envp * filterHarmonic, mul: env);
	snd = snd + SinOsc.ar(freq: envp, phase: 0.5, mul: env * sineAmp);

	snd = Mix.ar(snd) * preamp;
	snd = snd.clip2(1) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kickBlocksSd, { arg out = 0, amp = 0.4, pan = 0, curve = (-4),
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
	cfreq = 6100, crq = 1, camp = 1.41,
	doneAction = 2;

    var env, snd, noise, tone1, tone2, hit1, hit2, click;

	env = EnvGen.kr(Env.linen(0.01, 1, 6), doneAction: doneAction);
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

SynthDef(\ringkickSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, dcy = 2.63, lpfFreq = 13760, frq = 26, envfL1 = 6416.9, envfL2 = 0, envfL3 = 66.2, envfL4 = 20, envfL5 = 0, envfT1 = 0, envfT2 = 0.04, envfT3 = 0.53, envfT4 = 2.37, curve = (-4.92), envfAmt = 0.32, lfnFrq = 59.2, lfnAmt = 0, ringAmp = 0.04, sawFreq = 20.7, sawPh = 6.18, sawDecDiv = 7, sawAmp = 0.18, sinFreq = 10010, sinFb = 0, sinDecDiv = 188, sinAmp = 0.29, doneAction = 2;
	var snd, env, trig, envf, mod;
	mod = LFNoise2.kr(lfnFrq, lfnAmt).range(1, lfnAmt);
	env = EnvGen.kr(Env.linen(atk, 1, dcy), doneAction: doneAction);
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

	snd = snd * env;
	// OffsetOut.ar(out, snd * amp);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kickRingzSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, decay = 0.25, ffreq = 1000, doneAction = 2;
	var snd, env, envp;

	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve, curve/2, curve]), doneAction: doneAction);
	envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3], [curvep, curvep*1.25, curvep].midicps));
	snd = Ringz.ar(
		    in: LPF.ar(in: Impulse.ar(0), freq: ffreq),
		    freq: freq * envp,
		    decaytime: decay,
		    mul: amp
	);

	snd = snd.tanh.sin * 2 * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_chirpSd, { arg out = 0, amp = 0.1, pan = 0, curve = -20, att = 0.001, rel = 0.5, maxFreq = 500, doneAction = 2;
    var env, snd;

	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).exprange(0, maxFreq).kr(doneAction: doneAction);

    snd = SinOsc.ar(freq: env, mul: amp);
    snd = LeakDC.ar(snd);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\kick_electroSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 0.3, envbfL1 = 261, envbfL2 = 120, envbfL3 = 51, envbfRel = 0.003, envbfC = (-4), envbaL1 = 0, envbaL2 = 1, envbaL3 = 0.1, envbaL4 = 0.8, envbaL5 = 0, envbaT1 = 0.2, envbaT2 = 0.1, envbaT3 = 0.03, envbaT4 = 0.2, envbaC1 = (-4), envbaC2 = (-4), envbaC3 = (-4), envbAmp = 1, pfSt = 750, pfEnd = 261, pfDur = 0.02, envpaL1 = 0, envpaL2 = 0.4, envpaL3 = 1, envpaL4 = 0.02, envpaL5 = 0, envpaT1 = 0.1, envpaT2 = 0.4, envpaT3 = 0.03, envpaT4 = 0.2, envpaC1 = (-4), envpaC2 = (-4), envpaC3 = (-4), envpAmp = 1, envcaAtt = 0, envcaRel = 0.2, envcAmp = 1, cFundFreq = 910, cFormFreq = 4760, cBwFreq = 2110, lpfFreq = 3140, doneAction = 2;
    var env, body, bodyFreq, bodyAmp, pop, popFreq, popAmp, click, clickAmp, snd;

	env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);

    // body starts midrange, quickly drops down to low freqs, and trails off
    bodyFreq = Env.new(
		    levels: [envbfL1, envbfL2, envbfL3],
		    times: [envbfRel / 8.57, envbfRel / 3.75],
		    curve: envbfC
	).kr;

	bodyAmp = Env.new(
		[envbaL1, envbaL2, envbaL3, envbaL4, envbaL5],
		[envbaT1, envbaT2, envbaT3, envbaT4],
		[envbaC1, envbaC2, envbaC3]
	).kr(levelScale: envbAmp);

    body = SinOsc.ar(freq: bodyFreq, mul: bodyAmp);

    // pop sweeps over the midrange
    popFreq = XLine.kr(start: pfSt, end: pfEnd, dur: pfDur);

	popAmp = Env.new(
		[envpaL1, envpaL2, envpaL3, envpaL4, envpaL5],
		[envpaT1, envpaT2, envpaT3, envpaT4],
		[envpaC1, envpaC2, envpaC3]
	).kr(levelScale: envpAmp);

    pop = SinOsc.ar(freq: popFreq, mul: popAmp);

    // click is spectrally rich, covering the high-freq range
    // you can use Formant, FM, noise, whatever
	clickAmp = Env.perc(
		attackTime: envcaAtt,
		releaseTime: envcaRel,
		level: envcAmp
	).kr;

	click = LPF.ar(
		in: Formant.ar(fundfreq: cFundFreq, formfreq: cFormFreq, bwfreq: cBwFreq, mul: clickAmp),
		freq: lpfFreq
	);

	//Putting it all together:
	snd = Mix.ar([body, pop, click]);
    snd = snd.tanh * env;

    // OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kik3BrSd, { arg out = 0, amp = 0.3, pan = 0, freq = 66, att = 0.01, dec = 0.1, decaylevel = 0.8, rel = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = 2, harmonic = 6, preamp = 3;
	var snd, env, fenv;

	env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [att, dec, rel], curve: envCurve).kr(doneAction: 2);

	fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

	snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

    snd = Normalizer.ar(in: snd, level: env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosKickSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
	// sub controls
	startsubfreq = 60, endsubfreq = 32, linesubdur = 0.08, subdecay = 0.2, sublowpass = 500,
	// drum controls
	drumFreq = 50, drumHarmonic = 2, drumSweep = 0.02, drumAtt = 0.005, drumRel = 0.4, curve = (-4),
	drumFilter = 1000, modIndex = 6.5, modFreq = 5,
	// beater controls
	beaterFreq = 500, beaterHarmonic = 12, beaterSweep = 0.03, noiseMod = 500, beaterL1 = 0, beaterL2 = 1, beaterL3 = 2.4, beaterL4 = 0, beaterT1 = 0.01, beaterT2 = 0.3, beaterT3 = 0.08,
	// click controls
	clkffreq = 500, clkres = 0,
	gate = 1, doneAction = 2;

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

	snd = snd * EnvGen.kr(Env.asr(att, 1, rel), gate, doneAction: doneAction);
    //DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\technokickSd, {
	| out=0, amp=0.5, pan = 0, atk = 0.01, rls = 6, freq=51.913087197493, dcy=0.28571428571429, click=0.008, spread=0.1, damp=0.6, gate=1, doneAction = 2 |
	var sig, env, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
	// env.ar is really good for this since thie envelopes are so short
	env = EnvGen.kr(Env.linen(atk, rls*2, rls), doneAction: doneAction);
	env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -8, bias: 1)); // initial attack
	env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
	aEnv = EnvGen.kr(Env.perc(0.005, rls/1.75, curve: 2)); // amplitude
	wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4));

	vEnv = EnvGen.kr(Env.adsr(dcy, dcy/2, 1, 0.01, curve: 3), gate); // for reverb
	// separate signals for extra processing
	low  = SinOsc.ar(freq * env1 * env2);
	high = WhiteNoise.ar() * wEnv * 0.6;
	high = BBandPass.ar(high, 1000, 2);
	dry = Mix.new([low, high]) * aEnv;
	dry = CrossoverDistortion.ar(dry * 0.3, 0.9, 1);
	// dry = dry * 0.25;
	// equalizer
	dry = BPeakEQ.ar(dry, 5500, db: 10);
	dry = BPeakEQ.ar(dry, 360, db: -12, rq: 2);
	dry = BLowShelf.ar(dry, 300, db: 6).distort;
	// compression
	dry = Compander.ar(dry, dry, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 5);
	// finalize dry signal
	dry = Pan2.ar(dry * aEnv);
	// create reverb signal
	// verb = FreeVerb2.ar(dry[0],dry[1],mix: 1,room: 1, damp: 1).distort * vEnv;
	verb = GVerb.ar(dry, roomsize: 10, revtime: rls,
		damping: damp, drylevel: 0, earlyreflevel: 0.5, taillevel: 1,
		maxroomsize: 100, mul: 1) ;
	// Sum the double stereo output into a single stereo one
	verb = verb.sum;
	// eq

	verb = BLowPass.ar(verb, 400+freq,2);

	// Reduce stereo spread, and balance audio to be level no matter the spread (more or less)
	verbHi = BHiPass.ar(verb, 200);
	verbHi = Balance2.ar(verbHi[0] + (verbHi[1] * spread), // left
		verbHi[1] + (verbHi[0] * spread), level: 0.5 + (1-spread)); // right
	// Keep low frequencies in mono
	verbLo = BLowPass.ar(verb, 200);
	verbLo = Balance2.ar(verbLo[0] + verbLo[1], verbLo[1] + verbLo[0], level: 0.5);
	verb = verbHi + verbLo;
	verb = Compander.ar(verb,verb, thresh: 0.5,
		slopeBelow: 1.75, slopeAbove: 0.75,
		clampTime: 0.002, relaxTime: 0.1, mul: 0.25) * vEnv;
	// finalize signals
	sig = dry + verb;
	sig = Compander.ar(sig,sig, thresh: 0.5,
		slopeBelow: 0.59, slopeAbove: 1,
		clampTime: 0.002, relaxTime: 0.1, mul: 1)!2;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\expodecPHSd, { |out, amp = 0.3, pan = 0, lev = 1, waveSel = 1, freqLow = 50, phaseLow = 3.14, ampLow = 0.3, freq = #[70, 90], click = 0, ampSin = 1, sustain = 0.9|
	var body, snd, env;

	env = XLine.ar(amp, amp * 0.001, sustain, doneAction: 2) * (AmpComp.ir(freq) * 0.5);

	body = Select.kr(waveSel.mod(5), [SinOsc, VarSaw, LFTri, LFPar, LFPulse].collect(_.ar(freqLow, phaseLow) * ampLow));

    snd = FSinOsc.ar(freq, click * 0.5pi, ampSin);
	snd = Mix.ar(snd + body);

    // OffsetOut.ar(out, Pan2.ar(snd * env, pan));
	OffsetOut.ar(out, DirtPan.ar(snd * env, ~dirt.numChannels, pan, lev));
}).add;

SynthDef.new(\bd808HoriuchiSd, { arg out = 0, amp = 2, pan = 0, attack = 0, decay = 0.921, triEnvCrv = (-230), lev1Mul = 7, lev2Mul = 1.35, atkf = 0.05, dcyf = 0.6, crvf = (-14), atkpf = 0.03, dcypf = 0.6, crvpf = (-10), tone = 56, doneAction = 2;
    var fenv, env, trienv, sig, sub, punch, pfenv;
    env = EnvGen.kr(Env.new([0.11, 1, 0], [attack, decay], -6.843224515159), doneAction: doneAction);
    trienv = EnvGen.kr(Env.new([0.11, 0.6, 0], [attack, decay], triEnvCrv), doneAction: 0);
    fenv = Env([tone*lev1Mul, tone*lev2Mul, tone], [atkf, dcyf], crvf).kr;
    pfenv = Env([tone*lev1Mul, tone*lev2Mul, tone], [atkpf, dcypf], crvpf).kr;
    sig = SinOsc.ar(fenv, pi/2) * env;
    sub = LFTri.ar(fenv, pi/2) * trienv * 0.05;
    punch = SinOsc.ar(pfenv, pi/2) * env * 2;
    punch = HPF.ar(punch, 350);
    sig = (sig + sub + punch) * 2.5;
    sig = Limiter.ar(sig, 0.5) * amp;
    // sig = Pan2.ar(sig, pan);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\nataskickSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.001, duration = 1, freq = 60, modfreqamt1 = 8, modfreqtime1 = 0.001, modfreqamt2 = 8, modfreqtime2 = 0.03, modfreqamt3 = 0.5, modfreqtime3 = 0.3, modfreqamt4 = 0.1, bpffreq1 = 8321, bpfrq1 = 0.3, bpffreq2 = 3321, bpfrq2 = 0.3, revtime = 1, earlyRef = 0.7, doneAction = 2;
    var snd, velocity;
    velocity = duration.linlin(1, 0, 1, 0);
    snd = SinOsc.ar(
        freq
        * (1 + (modfreqamt1 * Env.perc(0, modfreqtime1).ar * velocity))
        * (1 + (modfreqamt2 * Env.perc(0, modfreqtime2).ar * velocity))
        * (1 + (modfreqamt3 * Env.perc(0, modfreqtime3).ar * velocity))
        * ([1, -1] * modfreqamt4).midiratio
    );
    snd = snd * (1 + (Env.perc(0, 0.03).ar * velocity));
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpffreq1, bpfrq1) * Env.perc(0.001, 0.003).ar * 1.dbamp * velocity);
    snd = snd.tanh;
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpffreq2, bpfrq2) * Env.perc(0.03, 0.05).ar * -10.dbamp * velocity);
    snd = snd * velocity.sqrt;
    snd = snd + GVerb.ar(snd.sum * -30.dbamp, 30, revtime, earlyreflevel: earlyRef);
    snd = snd * Env.perc(atk, duration).ar(doneAction);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Snare

SynthDef(\sdSd, { | out = 0, amp = 1, pan = 0, att = 0, rel = 0.05, freq = 200, ffreq = 12000 |
	var osc1, osc2, env, sig;
	osc1 = WhiteNoise.ar;
	osc2 = FSinOsc.ar(freq);
	env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	sig = LPF.ar(Mix([osc1, osc2]), ffreq) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snareSd, { arg out=0, amp=0.1, pan = 0, tu=1, gate=1, freq=200, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,0.1));
	var enf = EnvGen.ar(Env([600,1057,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(15100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snarenewSd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var sig, env, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu*envp,0,0.5)*env;
	sig = ((PinkNoise.ar*env) * mixNoise) + (sig * (1 - mixNoise));
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

SynthDef(\snare2Sd,{arg out=0, amp=1, pan = 0, gate = 1;
	var env = EnvGen.ar(Env.perc(0.001,0.2),gate,doneAction:2);
	var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
	var sig = WhiteNoise.ar(env);
	sig = LPF.ar(sig,freq);
	sig = sig.tanh;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp) );
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snare2newSd, { arg out = 0, amp = 0.1,  pan = 0, tu = 1, gate = 1, envAtt = 0.1, envRel = 0.1, enfL1= 1600, enfL2 = 177, enfL3 = 190, enfT1 = 0.01, enfT2 = 0.1;
    var sig;
    var env = EnvGen.ar(Env.perc(envAtt,envRel));
    var enf = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2],-4));
    var sig2 = BrownNoise.ar(1);
    sig = SinOsc.ar(tu*enf+27,0,0.1)*env;
    sig = WhiteNoise.ar(0.6)+sig+(LPF.ar(sig2,250,0.5)*env);
//    sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq.kr(1));
//    sig = sig + Mix.ar(BPF.ar(sig,[1207,4300],[0.5,0.5])*0.1);
    //sig = RLPF.ar(sig, \lpf.kr(11000)*tu, \rq.kr(1));
    //sig = CombL.ar(sig,0.2,0.1);
    sig = BRF.ar(sig,450,0.3);
    sig = HPF.ar(sig,250);
    sig = sig * EnvGen.ar(Env.perc(0.02,\rel.kr(0.4),-4),gate,doneAction:2);
    //sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\jungleSnareSd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 1, envL2 = 0, envL3 = 1, envL4 = 0, envT1 = 0, envT2 = 0.004, envT3 = 0.05, envCurve = (-4), envfL1 = 1600, envfL2 = 5600, envfL3 = 800, envfL4 = 250, envfT1 = 0.001, envfT2 = 0.001, envfT3 = 0.001, envfCurve = (-4), envnAtt = 0.01, envnRel = 1, envnCurve = -4, noiseAmp = 1, tu = 1, kracter = 10, gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
	var envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4],[envfT1, envfT2, envfT3], envfCurve));
	var envn = EnvGen.ar(Env.perc(envnAtt, envnRel), 1, envnCurve);
	sig = SinOsc.ar(tu*envf+107,0,0.5)*env;
	sig = (WhiteNoise.ar(envn) * noiseAmp) + sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1));
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+ (WhiteNoise.ar(envn)+BrownNoise.ar(envn/8) * noiseAmp);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5));
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([envf,envf*0.9,envf*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(envn) * noiseAmp,envf*4,1,1)+sig )*envn ;
	sig = CompanderD.ar(sig*kracter,0.8,0.3,0.5,0.001,0.2,env);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t5snareSd, { arg out=0, amp=0.3, pan=0, tu=1, freq=200, gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.1],-4));
	//sig = SinOsc.ar(tu*enf+1207,0,0.5)*env;
	sig = WhiteNoise.ar;
	sig = FreeVerb.ar(sig,0.5,1);
	sig = RHPF.ar(sig, \hpf.kr(180)*tu, \hpfRq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(12100)*tu, \lpfRq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),-4),gate,doneAction: doneAction);
	sig = sig*amp;
	sig = CompanderD.ar(sig,1,1,0.1,0.01,0.4);
	sig = FreeVerb.ar(sig,1,1)+sig;
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snare808Sd, { arg out = 0, amp = 0.1, pan = 0, freq = 200, tu = 1, gate = 1;
	var sig;
	var env = EnvGen.ar(Env.perc(0.01,1));
	var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
	sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
	sig = WhiteNoise.ar+sig;
	sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
	sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
	sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\snaremedSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, doneAction: doneAction);
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

SynthDef(\snareAwSd, {arg out = 0, amp = 0.1, pan = 0, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000;
	var snd1 = WhiteNoise.ar(amp);
	var snd2 = SinOsc.ar(sinfreq,0,amp);
	var env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
	var sum = HPF.ar(snd1, ffreq) + snd2;
	// OffsetOut.ar(out, Pan2.ar(sum * env, pan));
	OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\snareySd,{ arg out = 0, amp=0.75, pan = 0, attack = 0.001, release = 0.3, freq=120, gain=0.5, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(attack, release, 1, -9), 1, doneAction: doneAction);
	sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
	sig = sig * gain;
	sig = sig.softclip * amp * env;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\snarySd,{ arg out = 0, amp=0.75, pan = 0, att = 0.001, rel = 0.1, curve = (-5), freq=120, gain=1, doneAction = 2;
	var env, sig, snare;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
	sig = sig * gain * 0.4;
	sig = sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\kraftySnareSd, { arg out = 0, amp = 1, pan = 0, freq = 6000, rq = 3, att = 0.01, dec = 0.2, curve = -6, doneAction = 2;
	var snd, env;

	env = Env.perc(attackTime: att, releaseTime: dec, curve: curve).kr(doneAction: doneAction);

	snd = PinkNoise.ar(amp);

	snd = BPF.ar(snd, freq, rq, env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\neuroSnareSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500,
	doneAction = 2;

    var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

    // a percussive click to give it some attack
	cEnv = Env.linen(
		attackTime: 0.001,
		sustainTime: 0.01,
		releaseTime: 0.001,
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

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snare909Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 85, att = 0.0005, curve = -2, toneRel = 0.075, toneAmp = 0.25, noiseRel = 0.4, noiseAmp = 0.2, nyquist = 2200, lpFreq = 7040, hpFreq = 523, doneAction = 2;
	var relTimes, env, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env.perc(attackTime: att, releaseTime: relTimes, level: amp, curve: curve).kr;

	tone = LFTri.ar(freq: [1, 1.78] * freq, mul: toneAmp);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(in: noise, freq: lpFreq, mul: noiseAmp);

	snd = tone ++ [noise, HPF.ar(in: noise, freq: hpFreq)];

	snd = Mix.ar(snd * env);

	DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snareElectroSd, { arg out = 0, amp = 0.4, pan = 0, att = 0.001, rel = 0.15, curve = -4, popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41, doneAction = 2;
    var pop, popEnv, popSweep, noise, noiseEnv, snd;

    // pop makes a click coming from very high frequencies
    // slowing down a little and stopping in mid-to-low
    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

    popEnv = Env.perc(attackTime: att, releaseTime: 0.73 * rel, level: blend, curve: curve).kr;

	pop = SinOsc.ar(freq: popSweep, mul: popEnv);

    // bandpass-filtered white noise
    noiseEnv = Env.perc(attackTime: att, releaseTime: rel, level: 1 - blend, curve: curve).kr(doneAction: doneAction);

	noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

    snd = Mix.ar(pop + noise) * amp;

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snareSteinSd, { arg out = 0, amp = 1, pan = 0, att = 0.0005, curve = -4, tonerel = 0.075, noiserel = 0.2,
	//Other Controls, blend ranges from 0 to 1.
	noisetop = 7040, noisebottom = 523, noiseamp = 0.2, tonelo = 185, tonehi = 330, toneamp = 0.5, blend = 0.2,
	doneAction = 2;

    var env, tone, noise, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	//Sines for the frequency of the drum:
    tone = SinOsc.ar(freq: [tonelo, tonehi]);

	tone = tone * Env.perc(
		attackTime: att,
		releaseTime: [tonerel, 0.73 * tonerel],
		level: toneamp,
		curve: curve
	).kr;

	//Noise for the rattling of the snares: (original used WhiteNoise alone)
	noise = PinkNoise.ar(noiseamp * (1 - blend)) + WhiteNoise.ar(noiseamp * blend);

	noise = LPF.ar(in: noise, freq: noisetop);

	snd = noise * Env.perc(
		attackTime: att,
		releaseTime: noiserel,
		curve: curve
	).kr;

	snd = snd +	HPF.ar(
		in: noise,
		freq: noisebottom,
		mul: Env.perc(
			attackTime: att,
			releaseTime: 0.915 * noiserel,
			curve: curve
		).kr
	);

	//Mix it all together:
	snd = Mix.ar(snd + tone) * amp * env;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosSnareSd, { arg out = 0, amp = 0.8, pan = 0, att = 0.005, rel = 0.1, curve = -4, freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 2000, rq = 0.1, bwr = 1,
	doneAction = 2;

	var env, drumMode, drumModeEnv, snares, snareEnv, snd;

	env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
	drumModeEnv = Env.perc(attackTime: att, releaseTime: rel, level: 0.5, curve: curve).kr;

	drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

	drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

	drumMode = drumMode + PMOsc.ar(
		carfreq: Saw.ar(freq * 0.85),
		modfreq: freq * modHarmonic,
		pmindex: timbreIndex,
		mul: drumModeEnv * 10
	);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	snareEnv = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr;

	snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

	snares = BRF.ar(in: snares, freq: 4 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 2.5 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: 1.8 * ffreq, mul: 0.5, rq: rq);

	snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

	snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

	snd = Mix.new(drumMode + snares) * env * amp;

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrumSd, {
    arg
    // Standard values
    out = 0, freq = 180, amp = 0.6, pan = 0,
    // Stick Controls
    att = 0.001, dec = 0.01,
    // Head Controls
    headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rel = 0.2,
    // Snares Controls (thresh goes from 0 to 1)
    snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
    snareGate = 0.6, rq = 0.5,
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
        attackTime: att,
        decayTime: dec,
        mul: 0.005
	); // This keeps the volume at a sane level

    // Drum Head
    head = Klank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: stick,
        freqscale: freq,
        decayscale: rel
	);

    // Snares
    snares = PinkNoise.ar(
        Amplitude.ar(
            in: head,
            attackTime: followAtt,
            releaseTime: followRel
		)
	);
    snares = CompanderD.ar(
        in: snares,
        thresh: thresh,
        slopeBelow: 1 + snareGate.clip(0, inf)
	);
    snares = BRF.ar(
        in: snares,
        freq: freqarray[1..6],
        rq: rq
	);

    //Output Stuff
    snd = (head * headAmp) + (snares * snaresAmp);
    snd = Mix.ar(snd * amp);
    snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: doneAction);

    // Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\natassnareSd, { arg out = 0, amp = 0.5, pan = 0, atk = 0.001, stn = 0.23, rls = 0.01, freq = 260, modfreqamt = 3, modfreqtime = 0.04, modfreqcrv = (-6), modfreqfact1 = 4.3, modfreqfact2 = 8.4, rls1 = 0.3, rls2 = 0.1, rls3 = 0.03, bpffreq1 = 2310, bpfrq1 = 0.25, bpffreq2 = 7310, bpfrq2 = 0.3, pshiftwin1 = 0.06, pshiftratio1 = 2.4, pshiftwin2 = 0.08, pshiftratio2 = 1.3, doneAction = 2;
    var snd;
    snd = SinOsc.ar(
        freq
        * (1 + (modfreqamt * Env.perc(0.001, modfreqtime, curve: modfreqcrv).ar))
        * [1, modfreqfact1, modfreqfact2]
    );
    snd = snd * [0, -8, -12].dbamp;
    snd = snd * Env.perc(0.001, [rls1, rls2, rls3]).ar;
    snd = snd.sum;
    snd = snd + (BPF.ar(WhiteNoise.ar, bpffreq1, bpfrq1) * Env.perc(0.03, 0.3).ar * 12.dbamp);
    snd = snd + (BPF.ar(WhiteNoise.ar, bpffreq2, bpfrq2) * Env.perc(0.003, 0.04).ar * 8.dbamp);
    snd = snd.tanh;
	snd = snd + PitchShift.ar(snd, pshiftwin1, pshiftratio1.max(0).min(4));
    snd = snd + PitchShift.ar(snd * -5.dbamp, pshiftwin2, pshiftratio2.max(0).min(4));
    snd = snd * Env.linen(atk, stn, rls).ar(doneAction);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  HiHat

SynthDef(\hatSd, { | out = 0, amp = 1, pan = 0 |
	var osc1, env;
	osc1 = WhiteNoise.ar(amp);
	env = EnvGen.kr(Env.perc(0, 0.01), doneAction: 2);
	// OffsetOut.ar(out, Pan2.ar(osc1, pan, env));
	OffsetOut.ar(out, DirtPan.ar(osc1, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\hatenSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, mixNoise = 0.5, sinFreq = 200, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.step([envL1, envL2, envL3, envL4], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4]), doneAction: 2);
	sig = (WhiteNoise.ar(amp) * mixNoise) + (FSinOsc.ar(sinFreq) * (1 - mixNoise));
	sig = (LFSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\haten1Sd, { arg out = 0, amp = 0.06, pan = 0, envL1 = 0, envL2 = 3, envL3 = 0, envL4 = 5, envL5 = 0, envT1 = 0, envT2 = 0.2, randFreq = 1, randAmt = 0.5, envT3 = 0.9, envT4 = 0.03, curve = (-4), mixNoise = 0.5, sinFreq = 142, sinAmp = 0.2, fsinFreq = 200, fsinAmp = 0, mixSaw = 0.5, sawFreq = 0, hpfreq = 400, hprq = 0.2, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2 * LFNoise2.ar(randFreq, randAmt), envT3, envT4], curve), doneAction: 2);
	sig = (WhiteNoise.ar(1) * mixNoise) + ((SinOsc.ar(sinFreq, 0, sinAmp) + FSinOsc.ar(fsinFreq, 0, fsinAmp)) * (1 - mixNoise));
	sig = (VarSaw.ar(sawFreq) * mixSaw) + (sig * (1 - mixSaw));
	sig = RHPF.ar(sig, hpfreq, hprq);
	sig = sig * env * amp;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\IkedaHiNoiseSd, { arg out = 0, level = 10, pan = 0, attack = 0.02, decay = 0.1, rq = 0.9, amp = 0.05, gate = 0, doneAction = 2;
	var noise, sig;
	noise = WhiteNoise.ar(Decay2.kr(gate, attack, decay, amp));
	sig = BPF.ar(noise, TRand.kr(12000, 15000, gate), rq.max(0.001));
	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\IkedaClickSd, { arg out = 0, level = 1, pan = 0, gate = 0, centerFreq = 15000, rq = 0.9, modamp = 25, doneAction = 2;
	var noise, sig;
 	noise = PinkNoise.ar(Decay.kr(gate, 0.001 * LFNoise1.kr(4).abs));
	sig = BPF.ar(noise, centerFreq.max(1), rq.max(0.01), modamp * LFNoise1.kr(8).range(0, 1)).fold(-1, 1);
 	DetectSilence.ar(sig, 0.0001, doneAction: doneAction);
 	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\hatYSd,{arg gate = 1, pan = 0, amp = 1, out = 0, rel = 0.1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(0,rel), gate, doneAction: doneAction);
	var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
	var sig = PinkNoise.ar(env);
	sig = HPF.ar(sig,freq);
	// sig = Pan2.ar(sig.tanh, pan, amp);
	// OffsetOut.ar(out,sig*12);
	OffsetOut.ar(out, DirtPan.ar(sig.tanh*12, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hatnewSd, {|out=0, amp=0.3, pan=0, freq=230, hpf=8500, rel=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0, doneAction = 2|
	var pulse, sig, env, freqs;
	freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
	sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
	env = EnvGen.kr(Env.perc(0,rel), doneAction: doneAction);
	// sig =  Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out,sig);
	OffsetOut.ar(out, DirtPan.ar(sig*env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat909Sd, {|out=0, amp=0.3, pan=0, envL1 = 0, envL2 = 0.98, envL3 = 0.12, envL4 = 0.9, envT1 = 0.2, envT2 = 0.01, envT3 = 0.32, envCurve = (-4), freq=230, hpf=6500, doneAction = 2|
	var pulse, sig, env, freqs;
	freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
	pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6));
	sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
	// env = EnvGen.kr(Env.perc(0,release),doneAction:2);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve).kr(doneAction: doneAction);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hat808Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, gate = 1, attack = 0.01, release = 0.1;
	var sig;
	var env = EnvGen.ar(Env.perc(attack, release),doneAction:2);
	sig = Saw.ar((1..9)*1000.23*env*tu);
	sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
	sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),gate))*tu;
	sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
	sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hihatAwSd, {arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.2, ffreq = 6000, doneAction = 2;
	var snd = WhiteNoise.ar(amp);
	var env = Env.perc(att, rel).kr(doneAction: doneAction);
	snd = HPF.ar(snd * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\hihatElectroSd, { arg out = 0, pan = 0, amp = 0.3, att = 0.001, rel = 0.3, curve = -8, filterFreq = 4010, rq = 0.56, doneAction = 2;
	var env, snd;

	// noise -> resonance -> exponential dec envelope
	env = Env.perc(attackTime: att, releaseTime: rel, curve: curve).kr(doneAction: doneAction);

	snd = ClipNoise.ar(amp);
	snd = BPF.ar(
		in: snd,
		freq: [1, 1.035] * filterFreq,
		rq: [0.27, 1] * rq,
		mul: [1.0, 0.6]
	);
	snd = Mix(snd) * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ikedhatSd,{arg out = 0, amp = 1, pan = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att= 0.0, rel = 0.01, timeScale = 1, hpf = 6000, gate = 1, doneAction = 2;
	var sig = HPF.ar(WhiteNoise.ar(1), hpf);
	var env = EnvGen.ar(Env([envLevel1, envLevel2, envLevel3], [att, rel]), gate, levelScale, levelBias, timeScale, doneAction);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, env*amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
}).add;

SynthDef(\fabHiSd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.step([envL1, envL2, envL3], [envT1, envT2, envT3]).kr(doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fabHi1Sd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatt = 0.001, envNrel = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatt = 0.001, envSrel = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
	var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
	envNoise = EnvGen.kr(Env.perc(envNatt, envNrel), gate);
	envSin = EnvGen.kr(Env.perc(envSatt, envSrel), gate);
	noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
	sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
	sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
	sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
	env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(doneAction: doneAction);
	sig = HPF.ar(sig * env, ffreq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hiSinSd, {arg out = 0, amp = 1, pan = 0, attack = 0.0001, sustain = 1, release = 1.2, curve = (-4), envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, envT1 = 0.02, envT2 = 0.12, envT3 = 0.01, envLev = 15, envPow = 1, envDivDur = 1, theta = 0.5, rho = 0.8, a0 = 1, a1 = 0, a2 = 0, filterfreq = 1000, rq = 1.0, selectMod = 0, sinFreq = 12000, sinAmp = 0.3, modFreq = 0.2, doneAction = 2;
	var env, globalEnv, click, b1, b2, signal, mod;
	globalEnv = EnvGen.kr(Env.asr(attack, sustain, release, curve), timeScale: sustain, doneAction: doneAction);
	env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]), levelScale: envLev, timeScale: sustain / envDivDur).pow(envPow);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	click = SOS.ar(env, a0, a1, a2, b1, b2);
	click = RHPF.ar(click, filterfreq, rq);
	mod = SelectX.kr(selectMod.mod(3), [LFNoise0.kr(modFreq), LFNoise1.kr(modFreq), LFNoise2.kr(modFreq)]);
	signal = ((SinOsc.ar(sinFreq, mul: sinAmp) * mod * env) + click) * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\metroSd, {arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 2, impFreq=1, theta = 0.5, rho = 0.8, filterfreq=1000, rq=1.0, doneAction = 2;
	var env, signal, b1, b2;
	env = EnvGen.kr(Env.linen(att, 1, rel), doneAction: doneAction);
	b1 = 2.0 * rho * cos(theta);
	b2 = rho.squared.neg;
	signal = SOS.ar(Impulse.ar(impFreq, 0, env), 1.0, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal, filterfreq, rq);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hatySd,{ arg out = 0, pan = 0, att = 0.001, rel = 0.1, curve = (-4), amp = 0.75, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.perc(att, rel, 1, curve), 1, doneAction: doneAction);
	sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp), 4000);
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\haty48Sd,{ arg out = 0, amp = 0.75, pan = 0, att = 0, rel = 0.12, curve = (-4), envaL1 = 1.81, envaL2 = 0, envaL3 = 2.52, envaL4 = 0.85, envaL5 = 0, envaT1 = 0.01, envaT2 = 0.02, envaT3 = 0, envaT4 = 0, envaCrv = 3.54, envpL1 = 0, envpL2 = 16936, envpL3 = 1279, envpL4 = 0, envpT1 = 0, envpT2 = 0.33, envpT3 = 0, envpT4 = 0.53, envpCrv = (-0.64), modFreq = 1, modAmt = 1.4, sinfAdd = 1.7, sinPhase = 0.28, sinpAdd = 1.7, rf1Freq = 16938.8, rf1Rq = 0.26, rf2Freq = 765, rf2Rq = 0.62, hpfFreq = 3699, doneAction = 2;
	var mod, env, enva, envp, sig;
	env = EnvGen.kr(Env.linen(att, rel, rel/2, 1, curve), 1, doneAction: doneAction);
	enva = EnvGen.kr(Env([envaL1, envaL2, envaL3, envaL4, envaL5], [envaT1, envaT2, envaT3, envaT4], [envaCrv, envaCrv / 2, envaCrv.neg]));
	envp = EnvGen.kr(Env.circle([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3, envpT4], [envpCrv, envpCrv * 2 , envpCrv.neg, envpCrv / 2]));
	mod = LFNoise0.ar(modFreq * envp.range(0.1, 4), modAmt * enva).range(1, modAmt);
	sig = SinOsc.ar([envp, envp + sinfAdd], [sinPhase, (sinPhase + sinpAdd)]);
	sig = Resonz.ar(sig, [rf1Freq, rf2Freq] * mod, [rf1Rq, rf2Rq], enva);
	sig = HPF.ar(sig, hpfFreq);
	sig = (sig[0] + sig[1]) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sosHatsSd, { arg out = 0, amp = 0.8, pan = 0, freq = 6000, curve = -4, rootIndex = 238.5, rq = 1,
	// Initial envelopes
	initAtt = 0.005, initRel = 0.1, initAmp = 1, initStart = 15000, initEnd = 9000,
	// Body envelopes
	bodyAtt = 0.005, bodyRel = 0.1, bodyAmp = 1, bodyStart = 9000, bodyEnd = 12000,
	// General envelope
	envAtt = 0.01, envRel = 1, envCurve = (-4),
	doneAction = 2;

	var root, initialEnv, initialSweep, initial, bodyEnv, bodySweep, body, snd;

	root = Pulse.ar(freq: freq, width: 0.5, mul: 1);

	root = PMOsc.ar(
		carfreq: root,
		modfreq: freq * [1.34, 2.405, 3.09, 1.309],
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

	snd = snd * EnvGen.kr(Env.perc(envAtt, envRel, curve: envCurve), doneAction: doneAction);
    // DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tick2Sd, {
    var sig, env, rq = \rq.kr(0.1);
    env = Env.perc(\atk.kr(0), \rel.kr(0.05)).ar(2);
    sig = Impulse.ar(0);
    sig = sig * 0.5;
    sig = RHPF.ar(sig, \freq.kr(1000), rq) * env;
    // sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(1.0);
    // OffsetOut.ar(\out.kr(0), sig);
	OffsetOut.ar(\out.kr(0), DirtPan.ar(sig, ~dirt.numChannels, \pan.kr(0), \amp.kr(1.0)));
}).add;

///////////////////////////////////////  Cymbal

SynthDef(\cymSd, { arg out=0, amp=0.5, pan=0, att=0, rel=1, curve=(-8), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.perc(att,rel,1,curve),doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cym1Sd, { arg out=0, amp=0.2, pan=0, envL1 = 0, envL2 = 1, envL3 = 0.3, envL4 = 0, levScale = 1, envT1 = 0.1, envT2 = 0.02, envT3= 0.01, envC1 = (-8), envC2 = 4, envC3 = (-4), tu=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], [envC1, envC2, envC3]), levelScale: levScale, doneAction: doneAction);
	var freqs = geom(100, 50, 1.3434)*10.234567*Lag3.kr(tu, 10);
	sig = WhiteNoise.ar;
	sig = Ringz.ar(sig,freqs).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymnewSd, { arg out = 0, amp = 0.2, pan = 0, att = 0, rel = 4, curve = (-8), tu = 6, gate = 1, doneAction = 2;
    var sig;
    var env = EnvGen.ar(Env.perc(att,rel,1,curve), gate, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    // sig = Pan2.ar(sig*env, pan);
    // OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymnew1Sd, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0.23, curve = (-8), tu = 6, gate = 1, doneAction = 2;
    var sig;
	var env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], curve), gate, doneAction: doneAction);
	var freqs = geom(99,40,pi/3)*10.234567*tu;
	sig = WhiteNoise.ar(0.2);
    sig = Ringz.ar(sig,freqs,1).mean;

    // sig = Pan2.ar(sig*env, pan);
    // OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbalicMcldSd, { |out=0, amp=0.5, pan=0, attLowf = 0.5, relLowf = 5, lowNoiseLev = 0.1, attHif = 1, relHif = 3, hiNoiseLev = 0.1, attHi = 1, relHi = 2, hiLev = 0.25, attTh = 0.001, relTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, gate = 1, doneAction = 2|
	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

	locutoffenv = EnvGen.kr(Env.perc(attLowf, relLowf), gate, doneAction: doneAction) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, relHif), gate, doneAction: doneAction) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
	hidriver = hidriver * EnvGen.kr(Env.perc(attHi, relHi, hiLev));

	thwack = EnvGen.kr(Env.perc(attTh,relTh), gate, doneAction: doneAction);

	// This bit will regenerate new freqs every time you evaluate the SynthDef!
	//freqs  = {exprand(300, 20000)}.dup(100);

	freqs = [freq1, freq2, freq3, freq4] /** LFNoise2.kr(0.002, 0.5, 0.5)*/;

	res = Ringz.ar(
		lodriver + hidriver + thwack,
		freqs
	).mean;
	sig = (res * 1) + (lodriver * 2) + thwack;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cymbal808ryanSd, { arg out = 0, amp = 0.1, pan = 0, baseFreq = 300, penvL1 = 1.0, penvL2 = 0.6, ptime = 250, pcurve = (-0.5), pulsew = 0.55, rlpfFrq = 7000, rlpfRq = 0.6, rhpfFrq = 6800, rhpfRq = 1.5, envL1 = 0, envL2 = 1, envL3 = 0.4, envL4 = 0, envL5 = 0, envT1 = 2, envT2 = 250, envT3 = 50, envT4 = 500, envC1 = 0, envC2 = (-0.5), envC3 = 0, envC4 = (-50), doneAction = 2;
	var freqs = [baseFreq, baseFreq*1.3420, baseFreq*1.2312, baseFreq*1.6532, baseFreq*1.9523, baseFreq*2.1523];
	//var freqs = [78.6, 140.44, 123.87, 219.4, 787.5, 531.3];
	//var freqs = [205.35, 254.29, 294.03, 304.41, 369.64, 522.71];
	//var freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];
	var signal, pulseEnv;

	pulseEnv = EnvGen.kr(Env.new([penvL1, penvL2], [ptime], [pcurve]), timeScale:(1/1000));
	signal = Mix.new(LFPulse.ar(freqs * 4.09));
	signal = (BinaryOpUGen('==', signal, 6.0) * 0.6) + (BinaryOpUGen('==', signal, 2.0) * 0.2) + (BinaryOpUGen('==', signal, 1.0) * 0.9); // XOR
	signal = (signal * pulseEnv) + (Mix.new(LFPulse.ar(freqs, width: pulsew)) * 0.9);
	signal = RLPF.ar(signal, rlpfFrq, rlpfRq);
 	signal = RHPF.ar(signal, rhpfFrq, rhpfRq);
	signal = signal * EnvGen.kr(Env.new([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [envC1, envC2, envC3, envC4]), timeScale:(1/1000), doneAction: doneAction);
	signal = [signal, DelayN.ar(signal, 0.005, 0.005)];
	// OffsetOut.ar(out, signal*4*amp);
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp*4));
}).add;

SynthDef(\cymbal808Sd, { arg out = 0, amp = 0.1, pan = 0, att = 0.002, dec = 0.25, rel = 0.05, freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5, doneAction = 2;
	var snda, sndb, snd, env, pulseEnv, freqs;

	freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

	env = Env.new(
		levels: [0, 1, decLevel, 0],
		times: [att, dec, rel],
		curve: [0, -0.5, 0]
	).kr;

	pulseEnv = Env.new(
		levels: [1.0, 0.6],
		times: dec,
		curve: -0.5
	).kr;

	snd = Mix.ar(LFPulse.ar(freq: freqs * freqMultiplier));

	snd = (BinaryOpUGen('==', snd, 6.0) * 0.6) + (BinaryOpUGen('==', snd, 2.0) * 0.2) + (BinaryOpUGen('==', snd, 1.0) * 0.9);

	snd = (snd * pulseEnv) + Mix.ar(LFPulse.ar(freq: freqs, width: 0.55, mul: 0.9));

	snd = RLPF.ar(in: snd, freq: 7000, rq: 0.6);
 	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 6800, rq: 1.5);
	snd = RHPF.ar(in: snd, freq: 1200, rq: 1.5);

	snd = snd + FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp);
	snd = Mix.ar(snd);
	snd = snd * env * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Clap

SynthDef(\clapSd, {| out=0, amp = 1, pan=0, q=0.1, fq=1, rnd1=0, rnd2=0, rnd3=0, gate=1, doneAction=2 |
	var env1, env2, noise1, noise2, sig;
	env1 = EnvGen.ar(\env1.kr(Env([0, 1, 0.5, 0.5, 0, 1, 0, 0.3, 0], [0.001, 0.0013, 0, 0.01, 0, 0.001, 0, 0.03],[0, -3, 0, -3, 0, -3, 0, -4])),doneAction:2);
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 400);
	noise1 = BPF.ar(noise1, 1000*fq, 20*q);
	env2 = EnvGen.ar(\env2.kr(Env([0, 1, 0], [0.002, 0.1], [0, -4])), gate, doneAction: doneAction);
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 2300);
	noise2 = BPF.ar(noise2, 2000*fq, 7*q, 0.7);
	sig = noise1 + noise2;
	sig = sig * 2;
	// sig = Pan2.ar(sig.softclip, pan, amp);
	// OffsetOut.ar(out,sig);
	OffsetOut.ar(out, DirtPan.ar(sig.softclip, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\clappingSd, {arg out = 0, amp=0.5, pan = 0, attack = 0.01, release = 1, att = 0.003, rel = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, gate=1, doneAction=2;
	var env, signal, noise, hpf1, hpf2, fx;
	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
	env = EnvGen.kr(Env.perc(att, rel));
	signal = (hpf1+hpf2) * env;
	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	signal = (signal * (1 - delMix)) + (fx * delMix) ;
	signal = signal * EnvGen.kr(Env.linen(attack, 1, release), doneAction: doneAction);
	// DetectSilence.ar(signal, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\clap_oto309Sd, {
	arg out=0, amp = 0.1, pan=0;
	var env1, env2, son, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	son = noise1 + noise2;
	son = son * 2;
	son = son.softclip * amp;

	// OffsetOut.ar(out, Pan2.ar(son, pan));
	OffsetOut.ar(out, DirtPan.ar(son, ~dirt.numChannels, pan));
}).add;

SynthDef(\oneclap_thorSd, {arg out=0, amp=0.1,  pan=0, filterfreq=1000, rq=0.1, attackTime = 0.003, releaseTime = 0.035, doneAction = 2;
var env, signal, attack, noise, hpf1, hpf2;
	noise = WhiteNoise.ar(1)+SinOsc.ar([filterfreq/2,filterfreq/2+4 ], pi*0.5, XLine.kr(1,0.01,4));
	noise = PinkNoise.ar(1)+SinOsc.ar([(filterfreq)*XLine.kr(1,0.01,3), (filterfreq+4)*XLine.kr(1,0.01,3) ], pi*0.5, XLine.kr(1,0.01,4));
	hpf1 = RLPF.ar(noise, filterfreq, rq);
	hpf2 = RHPF.ar(noise, filterfreq/2, rq/4);
	env = EnvGen.kr(Env.perc(attackTime, releaseTime), doneAction: doneAction);
	signal = (hpf1+hpf2) * env;
	signal = CombC.ar(signal, 0.5, 0.03, 0.031)+CombC.ar(signal, 0.5, 0.03016, 0.06);
	// signal = Decay2.ar(signal, 0.5);
	signal = FreeVerb.ar(signal, 0.23, 0.15, 0.2);
	// DetectSilence.ar(signal, doneAction:2);
	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\oneclapThorBrSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, rls = 1, atkT = 0.003, relT = 0.00035, tone = 0.4, noiseAmp = 1, freq = 100, rq = 0.1,
	//Other Controls
	echohz1 = 33.333, echohz2 = 33.156, curve = -4, decay = 0.06, shelfFreq = 7000, rs = 0.5, db = -3,
	// Controls Ranging from 0 to 1
	size = 0.15, mix = 0.23, damp = 0.5,
	doneAction = 2;

	var env, snd, noise1, noise2, hpf1, hpf2, delay1, delay2;

	noise1 = (GrayNoise.ar(1 - tone) + WhiteNoise.ar(tone)) * noiseAmp;

	noise1 = noise1 + SinOsc.ar(freq: [freq / 2, freq / 2 + 4 ]);

	noise2 = PinkNoise.ar(noiseAmp);

	noise2 = noise2 + SinOsc.ar(freq: [freq, (freq * 1.04)] * XLine.kr(start: 1, end: 0.01, dur: 3));

	hpf1 = RLPF.ar(in: noise1, freq: freq, rq: rq);

	hpf2 = RHPF.ar(in: noise1, freq: freq/2, rq: rq/4);

	env = Env.perc(attackTime: atkT, releaseTime: relT, curve: curve).kr;

	snd = Mix.ar(hpf1 + hpf2) * env;

	delay1 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz1, delaytime: 1/echohz1, decaytime: decay / 2);

	delay2 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz2, delaytime: 1/echohz2, decaytime: decay);

	snd = FreeVerb.ar(in: Mix.ar(delay1 + delay2), mix: mix, room: size, damp: damp, mul: amp);

	snd = BHiShelf.ar(in: snd, freq: shelfFreq, rs: rs, db: db);

	snd = snd * EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	// DetectSilence.ar(snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapySd, { arg out = 0, amp = 0.5, pan = 0, att = 0.02, rel = 0.3, curve1 = 0, curve2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [att, rel], [curve1, curve2]), doneAction: doneAction);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapGraySd, { arg out = 0, amp = 0.1, pan = 0, att = 0.001, rel = 0.25, curve = -4, spreadRate = 75, minDelay = 0.025, maxDelay = 0.05, decay = 0.15, rq = 0.4, blend = 0.7, reverb = 0.1, size = 0.25, damp = 1, doneAction = 2;
	var env1, env2, snd, noise1, noise2, spread;

	//Multiple Shorter Claps
	spread = LFNoise1.kr(spreadRate).range(minDelay, maxDelay);

	env1 = Env.perc(attackTime: att / 10, releaseTime: rel / 8, curve: [0, curve]).kr;
	env1 = CombC.ar(in: env1, maxdelaytime: maxDelay, delaytime: spread, decaytime: decay);

	noise1 = GrayNoise.ar(env1); //Play with frequencies here:
	noise1 = RHPF.ar(in: noise1, freq: 1000, rq: rq);
	noise1 = BPF.ar(in: noise1, freq: 2000, rq: 3);

	//One Longer Clap
	env2 = Env.perc(attackTime: att, releaseTime: rel, curve: [0, curve]).kr;

	noise2 = GrayNoise.ar(env2); //Play with frequencies here:
	noise2 = RHPF.ar(in: noise2, freq: 1200, rq: rq);
	noise2 = BPF.ar(in: noise2, freq: 1400, rq: 0.7);

	//Mixing and light Reverb
	snd = Mix.ar((blend * noise1) + ((1 - blend) * noise2));
	snd = (snd * 2).softclip;
	snd = FreeVerb.ar(in: snd, mix: reverb, room: size, damp: damp, mul: amp);

	DetectSilence.ar(in: snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapthanSd, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.5, envL4 = 1, envL5 = 0.5, envL6 = 1, envL7 = 0, envT1 = 0.001, envT2 = 0.01, envT3 = 0.001, envT4 = 0.01, envT5 = 0.001, envT6 = 0.01, curve = 0, hpfFrq = 1024, hpfRq = 0.3, doneAction = 2;
    var snd, env;
	env = Env([envL1, envL2, envL3, envL4, envL5, envL6, envL7], [envT1, envT2, envT3, envT4, envT5, envT6], curve).ar(doneAction);
    snd = RHPF.ar(Hasher.ar(Sweep.ar), hpfFrq, hpfRq);
    snd = snd * env;
	/*snd = Pan2.ar(snd, pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Noise

SynthDef(\IkedaBreathSd, { arg out = 0, level = 1, pan = 0, atk = 0.0001, dcy = 0.4, rls = 0.5, note1 = 44, note2 = 90, amp1 = 0.5, amp2 = 0.6, lpfFreq = 1003.82, hpfFreq = 240, gate = 1, doneAction = 2;
	var sin, lpf, hpf, sig;
	sin = SinOsc.ar(note1.midicps, 0, amp1) + SinOsc.ar(note2.midicps, 0, amp2);
	lpf = LPF.ar(sin, lpfFreq.max(1));
	hpf = HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), hpfFreq.max(1));
	sig = (lpf + hpf) * EnvGen.kr(Env(#[0, 1, 0.6, 0], [atk, dcy, rls]), gate, doneAction: doneAction); // # makes a totally fixed (non-dynamic) Array and is slightly cheaper, especially where you're not going to change the Array once you make it
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\noise2Sd,{arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 0.01, a = 4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [-4, -2, -4]), doneAction:2);
var sig = CuspN.ar(
		SampleRate.ir/a,
		LFNoise2.kr([4,4],1.5,1.5),
		LFNoise2.kr([2,2],1.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5),
		LFNoise2.kr([2,2],0.5,1.5);
	);
	sig = HPF.ar(sig,1000);
	sig = Limiter.ar(sig,0.4);
	sig =	[sig ,DelayL.ar(sig,0.1,100/44100)];
	//sig = PitchShift.ar(sig,0.2,1*a);
	sig = Compander.ar(sig,In.ar(0,1),0.01,1,0.01,0.01,0.1);
	// sig =  Pan2.ar(sig.tanh, pan, amp);
	// OffsetOut.ar(out,sig*env0);
	OffsetOut.ar(out, DirtPan.ar(sig.tanh, ~dirt.numChannels, pan, amp * env0));
}).add;

SynthDef(\noise2newSd,{arg out = 0, amp = 1, pan = 0, levelScale = 1, att = 0.01, rel = 1, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 0.2, avar = 1, bvar = 1, xi = 0.5, hpf = 1000, del1 = 10, del2 = 20, doneAction = 2;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [curve1, curve2, curve3]), levelScale: levelScale, doneAction: doneAction);
	sig = CuspN.ar(
        SampleRate.ir/coeff,
        LFNoise2.kr([4,4],1.5,1.5) * avar,
        LFNoise2.kr([0.2,0.2],1.5,1.5) * bvar,
        LFNoise2.kr([2,2],0.5,1.5) * xi,
        LFNoise2.kr([2,2],0.5,1.5);
    );
    sig = HPF.ar(sig,hpf);
    sig = Limiter.ar(sig,0.4);
    sig = [DelayL.ar(sig,0.1,del1/44100) ,DelayL.ar(sig,0.1,del2/44100)];
    //sig = PitchShift.ar(sig,0.2,1*coeff);
    sig = Compander.ar(sig,In.ar(out,1),0.01,1,0.01,0.01,0.1);
    sig = sig.tanh;
	// sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig * env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\noiseSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel  = 0.25, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [att, rel], [curve1, curve2, curve3]), doneAction: doneAction);
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

SynthDef(\newNoise48Sd,{arg out = 0, amp = 1, pan = 0, env0L1 = 0.1, env0L2 = 1, env0L3 = 0.3, env0L4 = 0, env0T1 = 0.01, env0T2 = 0.2, env0T3 = 0.25, env0T4 = 0.25, offset = 0, timeScale = 1, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, gate = 1, doneAction = 2;
var env0 =  EnvGen.ar(Env.step([env0L1, env0L2, env0L3, env0L4], [env0T1, env0T2, env0T3, env0T4], offset), gate, timeScale: timeScale, doneAction: doneAction);
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

/*SynthDef(\cosc, { arg out = 0, gate = 1, amp = 1, pan = 0, freq = 512, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0), gate, doneAction: doneAction);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;*/

SynthDef(\jiletSd, { arg out=0, amp=0.20, pan = 0, att = 0.005, dec = 0.01, sus = 1.1, rel = 0.01, envOffset=0.5, freq=4, endReflection=1.5, jetReflection=0.5, jetRatio=10.72, noiseGain=0.35, vibFreq=5.925, vibGain=0.02, gate=1, doneAction = 2;

	var adsr = (envOffset*0.2) + EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: doneAction);
	var noise = WhiteNoise.ar(noiseGain.max(0.1));
	var vibrato = SinOsc.ar(vibFreq, 0, vibGain);

	var delay = (freq.min(340)*0.66666).reciprocal;
	var lastOut = LocalIn.ar(1);
	var breathPressure = adsr*Mix([1.0, noise, vibrato]);
	var filter = LeakDC.ar(OnePole.ar(lastOut.neg, 0.7));
	var pressureDiff = breathPressure - (jetReflection*filter);
	var jetDelay = DelayL.ar(pressureDiff, 0.025, delay*jetRatio);
	var jet = (jetDelay * (jetDelay.squared - 1.0)).clip2(1.0);
	var boreDelay = DelayL.ar(jet + (endReflection*filter), 0.05, delay);
	LocalOut.ar(boreDelay);
	// boreDelay = Pan2.ar(boreDelay, pan, amp);
	// OffsetOut.ar(out, 0.3*boreDelay);
	OffsetOut.ar(out, DirtPan.ar(boreDelay, ~dirt.numChannels, pan, amp * 0.3));
}).add;

SynthDef(\pitchednoiseSd, { arg out = 0, amp=0.1, pan=0.0, attack=0.01, release=10, freq=440, bandwidth=100, doneAction=2;
	var source, filter, env;
	// env = EnvGen.ar(Env([0,1,1,0],[attack, sustain, decay]), doneAction: doneAction);
	env = EnvGen.ar(Env.linen(attack, 1, release), doneAction: doneAction);
	source = WhiteNoise.ar;
	filter = BPF.ar(source*env*2*amp,freq,bandwidth/freq);
	// OffsetOut.ar(out, Pan2.ar(filter,pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan));
}).add;

SynthDef(\plastickystringsSd, { | out= 0 freq = 440 amp = 0.1 gate=1 lforate = 5900 lfowidth= 0.01 cutoff= 12000 rq=0.5 pan=0.0, doneAction=2 |
	var lfo, saw, filter, env;
	lfo = LFTri.ar(lforate,Rand(0,2.0));
	saw = Saw.ar(freq*(1.0+(lfowidth*lfo)),0.5);
	//filter = BBandPass.ar(saw,freq,4);
	filter = BHiPass.ar(saw,freq,rq); 	//or using cutoff
	env = EnvGen.ar(Env.adsr(0.4,0.0,1.0,1.0),gate,doneAction: doneAction);
	// OffsetOut.ar(out,Pan2.ar(filter*env, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\resSd, { | out = 0, amp = 1, pan = 0, att = 0, rel = 0.7, freqSin = 52, ampSin = 1, freqSaw = 22, ampSaw = 1, oscMix = 0.5, freqClc = 7302, harmClc = 200, ampClc = 0.5, maxL = 1, t1Clc = 0.001, t2Clc = 0.03, t3Clc = 0.01, gFreq = 12, damp = 0, fric = 0.001, doneAction = 2|
	var aEnv, osc, sig, flt, clic;
	aEnv = EnvGen.kr(Env.perc(att, rel), doneAction: doneAction);
	osc = Mix([SinOsc.ar(freqSin, 0, ampSin), Saw.ar(freqSaw, ampSaw)]) * aEnv;
	clic = Blip.ar(freqClc, harmClc, ampClc) * EnvGen.kr(Env.step([0, maxL, 0], [t1Clc, t2Clc, t3Clc]));
	sig = (osc * oscMix) + (clic * (1 - oscMix));
	sig = sig + Ball.ar(sig, LFNoise1.kr(gFreq, 0.5, 0.5), damp, fric) * aEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*~resSynthDef = SynthDef(\res, { | out = 0, amp = 1, pan = 0, att = 0, rel = 0.7, freqSaw = 40, freqPls = 62, wPls = 0.5, rlpfRq = 0.1, lfnFreq = 0.3, lfnMul = 1000, lfnAdd = 1500, gate = 1, doneAction = 2|
	var aEnv, osc, flt, fltBus;
	aEnv = EnvGen.kr(Env.perc(att, rel), gate, doneAction: doneAction);
	fltBus = Bus.control(s, 1);
	osc = Mix([Saw.ar(freqSaw), Pulse.ar(freqPls, wPls)]);
	flt = RLPF.ar(osc, In.kr(fltBus, 1), rlpfRq, aEnv);
	ReplaceOut.kr(fltBus, LFNoise1.kr(lfnFreq, lfnMul, lfnAdd));

	OffsetOut.ar(out, Pan2.ar(flt, pan, amp));
}).add;*/

SynthDef(\mutantFricSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, spec1 = 0.00001, spec2 = 0.03, noiseFreq = 3, sigFreq = 50, spring = 0.414, damp = 0.313, beltmass = 1, source = 0, hpfFreq = 50, gate = 1, doneAction = 2;
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
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	// OffsetOut.ar(out, Splay.ar(sig * amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetSynthSd, { arg out = 0, amp = 1, pan = 0, freq = 25, rate = 8, attack = 0.01, release = 10, sigatt = 0.01, sigdec = 3.16, thresh = 0.5, ratio = 1, revMix = 0, revRoom = 0.5, revDamp = 0.5, gate = 1, doneAction = 2;
	var sig, demand, env, sigenv;
	demand = Demand.kr(
		gate,
		0,
		Drand(freq, inf)
	);
	sig = (
		BHiPass.ar(
			LFNoise1.ar(rate) ** 3,
			[demand, demand + 0.2].midicps,
			demand / 2e3,
			67 - demand
		)
	).tanh;
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), gate);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = sig * sigenv * env;
	sig = Compander.ar(sig, sig, thresh.max(0.01), 1, ratio);
	sig = FreeVerb2.ar(sig[0], sig[1], Lag2.kr(revMix), revRoom, revDamp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetFogAttackSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, sigatt = 0.01, sigdec = 3.16, feedBack = 0.2, freq = 0.8, gate = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatt, 1, sigdec), gate);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = (sig.mean!2) * sigenv * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetErosionSd, { arg out = 0, amp = 0.3, pan = 0, attack = 0.01, release = 10, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, div, envIndex, xyc;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500 * (sig**(8/div)));
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\harshTextureSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, impFreq = 2, delTimeMod = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = Impulse.ar(impFreq).lag(0.3)!2;
	5.do {
		sig = LeakDC.ar(
			AllpassC.ar(
				sig,
				1,
				LFNoise0.ar(delTimeMod).range(1e-5,0.2),
				-0.15,
				LFNoise0.ar(delTimeMod).range(1,3)
			)
		).tanh;
	};
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ultraHiSummerSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, curve = (-4), blpFreq1 = 16e3, blpFreq2 = 16150, seqRate = 0.2, seqVal1 = 70, seqVal2 = 30, seqVal3 = 0, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release, curve: curve), gate, doneAction: doneAction);
	sig = Blip.ar(
		[blpFreq1, blpFreq2],
		2,
		LFSaw.ar(
			Duty.ar(
				LFNoise0.ar(seqRate,4,6),
				0,
				Dseq([seqVal1, seqVal2, seqVal3], inf)
			)
		).clip(0, 1)
	);
	sig = (sig[0] + sig[1]) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ambiantPicSd, { arg out = 0, amp = 0.3, pan = 0, attack = 0.01, release = 10, lfnFreq = 22, lfnAmp = 5, lfnOffset = 9, ampDst1 = 4, ampDst2 = 2, durDst1 = 0.5, durDst2 = 1, adPar1 = 1/9, adPar2 = 1/4, ddPar1 = 1/2, ddPar2 = 1/8, delTime1 = 0.13, delTime2 = 0.1, decTime = 0.2, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = LFNoise2.kr(lfnFreq, lfnAmp, lfnOffset);
	sig = CombC.ar(
		Splay.ar(
			Gendy3.ar(
				[ampDst1, ampDst2],
				[durDst1, durDst2] * decTime,
				[adPar1, adPar2]*sig,
				[ddPar1, ddPar2]*sig,
				(9,49..199)
			)
		),
		5,
		[delTime1, delTime2],
		[sig/2,sig/2.1] * decTime
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\attWindSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, seq1 = 1, seq2 = 1, seq3 = 4, seq4 = 2, seq5 = 2, seqDiv = 8, freq1 = 250, freq2 = 8000, bwrLo = 0.01, bwrHi = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = TDuty.kr(Dseq([seq1, seq2, seq3, seq4, seq5] / seqDiv, inf));
	sig = Resonz.ar(
		WhiteNoise.ar!2,
		Demand.kr(sig, 0, Dseq([freq1, freq2], inf)),
		Demand.kr(sig, 0, Dwhite(bwrLo, bwrHi, inf))
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\dStowellSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, freq = 6/3, width = 1/5, lpf = 20000, gate = 1, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = LPF.ar(sig, lpf);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\henonSd, { arg out = 0, amp = 0.1, pan = 0, freq = 440, a = 1.3, b = 0.3, x0 = 0.30501993062401, x1 = 0.20938865431933, atk = 0.01, sus = 1, rel = 1, ts = 1, gate = 1, doneAction = 2;
	var sig,env;
	sig = HenonN.ar(freq,a,b,x0,x1,amp);
	env = EnvGen.ar(Env.linen(atk,sus,rel),gate,1,0,ts,doneAction);
	sig = LeakDC.ar(sig);
	sig = sig*env;
	// OffsetOut.ar(out,Pan2.ar(sig,pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\harrishSd, {| out = 0, amp = 0.2, pan = 0, attack = 0, sustain = 0.2, release = 0.1, curve = 0, clipLevel = 0.006, impFreq = 0, impPhase = 0, impLevel = 1, noiseLevel = 0.3, lpf = 20000, eqfreq = 4000, eqrq = 1, eqdb = 0, hpf = 20,  doneAction = 2|
	var env = EnvGen.ar(Env.linen(attack, sustain, release, curve: curve), doneAction: doneAction);
	var snd = (ClipNoise.ar(clipLevel) + Impulse.ar(impFreq, impPhase, impLevel) + BrownNoise.ar(noiseLevel)) * env;
	snd = LPF.ar(snd, lpf);
	snd = BPeakEQ.ar(snd, Lag2.kr(eqfreq.max(20).min(20000), 0.5), eqrq, eqdb);
	snd = HPF.ar(snd, hpf);
	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kSpluck3Sd, { arg out = 0, amp = 0.2, pan = 0, att = 0, rel = 0.01, midiPitch = 24, art = -3, noiseFreq = 1, noiseLev = 13000, noiseOffset = 14010, mix = 0.5, doneAction = 2;
	var burstEnv;
	var sig, delayTime;
	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(att, rel));
	sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
	sig = CombL.ar(sig, delayTime, delayTime, art, add: sig); //Echo chamber
	sig = XFade2.ar(sig, RLPF.ar(sig, LFNoise1.kr(noiseFreq, noiseLev, noiseOffset), 0.1), mix, amp); //Filter ADSR GELSIN BURAYA
	DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lumbricostSd, {arg out = 0, amp = 0.2, pan = 0, attTim= 1, relTim=2.5, scale= 6, offset = 40, freq = 10, timescale = 10, widthmod = 0.4, width = 0.2, abc = 0, randLo = 0, randHi = 20000, bprq = 1, gate = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(30/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(7/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(2/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(5/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(9/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, relTim), Impulse.ar(40/freq),widthmod,width,timescale), mul: 0.1);
	var env = generation * EnvGen.kr(Env.perc(attackTime:attTim,releaseTime: relTim), gate, doneAction: doneAction);
	var env1 = LeakDC.ar(env);
	var sig = env1 * amp;
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bprq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	noise = PinkNoise.ar(1!2);
	rainStep = noise + Blip.ar(noise + blipFreqMod, blipHarmo);
	rainStep = BRF.ar(
		rainStep,
		brfFreq,
		brfRq,
		0.1
	);
	thunder = LPF.ar(FreeVerb2.ar(*LPF.ar(noise + 0.2 * Dust.ar(0.1), 60) ++ [1, 1, 0.2, 1e4]).tanh, 2000);
	sig = rainStep + thunder;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

/*SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\plouxSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.1, dec = 0.1, stn = 0.8, rls = 0.1, feedBack = 0, fbPost = 0, dustfreq = 2, dustdecay = 0.7, frq = 200, fmfreq = 100, folAtt = 0.01, folDec = 0.2, sinMix = 1, a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, gate = 1, doneAction = 2;
    var sig, dust, input, inMod, envFol, freqMod;
	input = LocalIn.ar(2);
	inMod = input * feedBack;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
	freqMod = SinOsc.ar(fmfreq * dust) * inMod + 1;
    sig = SinOsc.ar(frq * freqMod);
	envFol = Amplitude.kr(sig, folAtt, folDec);
	sig = (sig * sinMix) + (RHPF.ar(LatoocarfianN.ar(freqMod.range(2000, 22050), a, b, c, d, xi, yi, LFNoise0.kr(dust)), input.range(20, 20000)) * (1 - sinMix));
    sig = sig * EnvGen.kr(Env.adsr(atk, dec, stn, rls), gate, doneAction: doneAction);
	LocalOut.ar(sig * fbPost);
	sig = sig.tanh;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}, [\kr ! 22, \tr, \ir].flat).add;

SynthDef(\complexoscSd, { arg out = 0, amp = 1, pan = 0, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, gate = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(gate, attack, 1, release, doneAction);
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
    osc1 = SinOsc.ar(freq1 + (fbk[1].range(1,1000) * fm1), 0 + (fbk[1].range(-pi,pi) * pm1), amp1 + (fbk[1] * ring1), offset1);
    osc2 = SinOsc.ar(freq2 + (fbk[0].range(1,1000) * fm2), 0 + (fbk[1].range(-pi,pi) * pm2), amp2 + (fbk[0] * ring2), offset2);
    LocalOut.ar([osc1, osc2]);
    folded = Fold.ar(osc1 ! 2, fold.neg, fold);
    wrapped = Wrap.ar(osc1 ! 2, wrap.neg, wrap);
    outlet = LeakDC.ar(Select.ar(switch, [osc1!2, osc2!2, folded, wrapped]));
    // OffsetOut.ar(out, outlet * env * amp);
	OffsetOut.ar(out, DirtPan.ar(outlet, ~dirt.numChannels, pan, amp * env));
}, [\kr ! 11, \ar ! 14, \kr, \tr, \ir].flat).add;

SynthDef(\benjolisSd,{ |out = 0, amp = 0.1, pan = 0, fadeTime = 0.01, freq1= 40, freq2=4, scaler=1, rungler1=0.16, rungler2=0.0, runglerFilt=9, loop=0, filtFreq=40, rq=0.82, gain=1, filterType=0, outSignal=6, doneAction = 2|
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
	OffsetOut.ar(out, DirtPan.ar(output * EnvGate(fadeTime: fadeTime, doneAction: doneAction), ~dirt.numChannels, pan));
}).add;

SynthDef(\bytebeatsSd, { arg out = 0, amp = 0.2, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.2, envL4 = 3.2, envL5 = 0, envT1 = 0.12, envT2 = 0.02, envT3 = 0, envT4 = 0.2, curve1 = (-4), curve2 = (-4), curve3 = (-4), curve4 = (-4), counterFreq = 1, counterMul = 3.5, counterAdd = 3.5, srDiv = 6, frq = 232, doneAction = 2;
	//var sr = SampleRate.ir/6; //fix sample rate
	var counter, env;
	var sr = SampleRate.ir/srDiv; //variable sample rate
	//var frq = 10;
	var n = 16; //bit resolution
	var t= Phasor.ar(1,frq*((2**n)/sr),0,((2**n)-1)); //creating a raising value from 0 to 2**n
	//t = t & (2**(n-1)); // few tests
	env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve1, curve2, curve3, curve4]), doneAction: doneAction);
	//equations: try one at the time
	t = t * 4;
	//counter = LFSaw.ar(0.5,0,3.5,3.5); // browse the equations
	counter = LFDNoise0.ar(counterFreq, counterMul, counterAdd);
	//counter.poll;
	t = SelectX.ar(counter,[

	t*(((t>>12)|(t>>8))&(63&(t>>4))),
	t*(((t>>9)|(t>>13))&(25&(t>>6))),
	t*(((t>>5)|(t>>8)) & 63),
	t*(((t>>11)&(t>>8))&(123&(t>>3))),
	t*(t>>8*((t>>15)|(t>>8))&(20|(t>>19)*5>>t|(t>>3))),
	t*(t>>((t>>9)|(t>>8))&(63&(t>>4))),
	(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
	]);

	t = t % (2**(n));// avoiding number beyond 2**(bit resolution)
	t = t*(0.5**(n-1)) - 1;//scaling to -1, 1

	t = LeakDC.ar(t * amp);
	// OffsetOut.ar(out, t * env);
	OffsetOut.ar(out, DirtPan.ar(t, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\feedbackOscSd, {|out=0, amp = 0.2, pan = 0, atk=0.01, rls=1, mFrq= 313, mFB= 1, frq= 100, fB= 1, width= 0, mul= 500, ffreq=1000, rq=1, gate = 1, doneAction = 2|
	var w= [0, width*2pi];
	var buf= LocalBuf(1).clear;
	var buf2= LocalBuf(1, 2).clear;
	var osc= sin(LFSaw.ar(mFrq).range(0, 2pi)+(Dbufrd(buf)*mFB));
	var snd= Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));
	var osc2= sin(LFSaw.ar(frq+(snd*mul)).range(0, 2pi)+(Dbufrd(buf2)*fB)+w);
	var snd2= Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));
	//var filter= RLPF.ar(snd2, ffreq, rq);
	var filter = DFM1.ar(snd2, ffreq, rq);
	var env = EnvGen.ar(Env.perc(atk, rls),gate,doneAction: doneAction);
	// OffsetOut.ar(out,filter * amp * env/*EnvGate(gate: gate, doneAction: doneAction)*/);
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef.new(\ShaiSd, { arg out = 0, amp=0.1, pan = 0, freq=440, atk=1, rel=8, doneAction = 2;
	var sig, env;
	sig = Mix.new(
		Array.fill(32, { SinOsc.ar(freq + Line.kr(1536.0.rand,freq*1.5,8), 0, 0.05) })
	);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	sig = sig*env*amp;
	// OffsetOut.ar(out, [sig, sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef.new(\Colleen3Sd, { arg out = 0, amp=1, pan = 0, freq=110, atk=0.01, rel=2, lpf = 4000, lpfmin = 500, lpfmax = 16000, hpfmin = 1, hpfmax = 2000, doneAction = 2;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.00,1)*0.36;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),lpf);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	env = env**2;
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(lpfmin,lpfmax,rel/6));
	sig = HPF.ar(sig, XLine.kr(hpfmin,hpfmax,rel/6));
	sig = (sig*env*amp)*0.7;
	// sig = Pan2.ar(sig,pan);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\combsSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 0.1, sus = 0.7, rel = 0.5, freq = 440, rate = 6, depth = 0.2, regen = -3, sweep = 16, rq = 0.5, harmonic = 1.5, gate = 1, doneAction = 2;

	var max, min, vibrato, snd, env, filterenv;

	//Setting some values for the filters:
	max = ((1 + depth) / freq);
	min = (1 / (freq * (1 + depth)));
	vibrato = LFNoise1.ar(rate).range(min, max);

	//Amplitude and filter cutoff envelopes
	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: doneAction);
	filterenv = Env.perc(att, rel).kr;
	filterenv = ((filterenv * sweep) + 1) * freq;

	//The core noise:
	snd = BrownNoise.ar(1);
	snd = CombL.ar(snd, max, vibrato, regen);
	snd = CombN.ar(snd, harmonic / freq, harmonic / freq, regen, env);

	//More filters and output stuff:
	snd = RHPF.ar(snd, freq * 4, rq);
	snd = RLPF.ar(snd, filterenv, rq, amp);
	snd = Limiter.ar(snd, amp);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\werkitSd, { arg out = 0, amp = 0.1, pan = 0.0, att = 0.01, dec = 0, sus = 1, rel = 1, freq = 440, rq = 0.1, gate = 1,doneAction = 2;

	var source, filter, env, snd, delayEnv;
	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, freq, rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\werkit2Sd, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 0, sus = 1, rel = 0.1, freq = 440, rq = 0.1, gate = 1, doneAction = 2;

	var source, filter, env, snd;
	source = LFSaw.ar(Array.fill(16, { Rand(100, 200) }));
	filter = BLowPass4.ar(source, freq, rq) * 0.1;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: doneAction);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	snd = HPF.ar(snd, 100);
	snd = Splay.ar(snd);
	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\impnSd,{ arg out = 0, amp=0.75, pan = 0, att = 0.001, rel = 0.1, curve = (-5), impRate = 10, kfreq = 1, kdec = 1, tu = 1, freq = 10327, bwr = 1, delTime = 0.25, decTime = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.linen(att, 1, rel, 1, curve), doneAction: doneAction);
	sig = Impulse.ar(impRate);
	sig = DynKlank.ar(
		Ref.new([
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421] * tu,   // harmonics
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		]),
		sig,
		kfreq,
		decayscale: kdec
	);
	sig = Resonz.ar(sig, freq, bwr);
	sig = CombL.ar(sig, 6, delTime, decTime);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\batuhanSddMystSd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.01, release = 4, sustain = 1, curve = (-4), pNoiseFreq = 5e-3, hpfFreq = 10, modDur = 9, lfnFreq = 0.05, ringFreq = 55, ringDec = 0.2, revSize = 70, revTime = 99, gate = 1, doneAction = 2;
	var sig, globalEnv;
	globalEnv = EnvGen.kr(Env.asr(attack, 1, release, curve), timeScale: sustain, doneAction: doneAction);
	sig = HPF.ar(PinkNoise.ar(pNoiseFreq), hpfFreq) * Line.kr(0, 1, modDur);
	sig = GVerb.ar(
		({ |i|
			Ringz.ar(
				sig * LFNoise1.kr(lfnFreq + 0.1.rand),
				ringFreq * i + 60,
				ringDec
			)
		}!44).sum,
		2,
		revTime
	).tanh;
	sig = sig * globalEnv * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedRainSd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.01, release = 2, sustain = 1, curve = (-4), nFrqR = 0.08, lfnFrqR1 = 0.3, lfnFrqR2 = 0.2, lpfR = 7000, hpfR = 400, revTimeR = 100, revDampR = 0.25, dryLevR = 0.3, modDurR = 10, lfnFrqT1 = 3, lfnFrqT2 = 2, hpfT = 20, revTimeT = 30, revDampT = 0.7, dryLevT = 0.5, modDurT = 30, gate = 1, doneAction = 2;
	var sig, globalEnv, rain, thunder;
	globalEnv = EnvGen.kr(Env.asr(attack, 1, release, curve), timeScale: sustain, doneAction: doneAction);

	rain = PinkNoise.ar(nFrqR + LFNoise1.kr(lfnFrqR1, 0.02));
	rain = rain + LPF.ar(Dust2.ar(LFNoise1.kr(lfnFrqR2).range(40, 50)), lpfR);
	rain = tanh(
		3 * GVerb.ar(
			HPF.ar(
				rain,
				hpfR
			),
			5,
			revTimeR,
			revDampR,
			drylevel: dryLevR
		) * Line.kr(0, 1, modDurR)
	);

	thunder = 10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(lfnFrqT1).clip(0, 1) * LFNoise1.kr(lfnFrqT2).clip(0, 1) ** 1.8), hpfT);
	thunder = GVerb.ar(
		LPF.ar(
			thunder,
			LFNoise1.kr(1).exprange(100, 2500)
		).tanh,
		5,
		revTimeT,
		revDampT,
		drylevel: dryLevT
	) * Line.kr(0, 0.7, modDurT);

	sig = (rain + thunder) * globalEnv * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\danScarSd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 0, envL2 = 0.3, envL3 = 1, envL4 = 0, envT1 = 0.01, envT2 = 1, envT3 = 4, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

	globalEnv = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3].normalizeSum * sustain, curve), doneAction: doneAction);

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

SynthDef(\danScar1Sd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 0, envL2 = 0.3, envL3 = 1, envL4 = 0, envT1 = 0.01, envT2 = 1, envT3 = 4, sustain = 1.5, curve = 4, sinFreq = 30, noiseFreq = 1, lpfFreq = 15000, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3].normalizeSum * sustain, curve), doneAction: doneAction);

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

SynthDef(\danScar2Sd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 0, envL2 = 0.3, envL3 = 1, envL4 = 0, envT1 = 0.1, envT2 = 1, envT3 = 4, sustain = 1.5, curve = 4, triFreq = 60, noiseFreq = 0.5, doneAction = 2;
    var sig, globalEnv, inSig, lfo;

    globalEnv = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3].normalizeSum * sustain, curve), doneAction: doneAction);

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

SynthDef(\natwichSd, { arg out = 0, amp = 0.3, pan = 0, envL1 = 0, envL2 = 0.3, envL3 = 1, envL4 = 0.5, envL5 = 0, envT1 = 0.01, envT2 = 1, envT3 = 4, envT4 = 0.1, sustain = 1.5, curve = 4, modFreq = 0.4, modAmount = 0.8, sawFreq = 2100, rlpfFreq = 4000, rlpfRq = 0.1, doneAction = 2;
    var snd, fb, sig, globalEnv, mod1, mod2;

    globalEnv = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum * sustain, curve), doneAction: doneAction);

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

SynthDef(\pnoiseSd, {
    /*:the Perlin noise is sampled on a supertoroid 3d path with
    given major and minor radius. The shape is controled wit tMajor and sMinor.
    */
	/*
	1 < rMajor < 25
	1 < rMinor < 10
	0.25 < tMajor < 2.5
	0.25 < sMinor < 2.5
	1 < freq_u < 250
	1 < freq_v < 250
	0 < scaleX < 5
	0 < scaleY < 5
	0 < scaleZ < 5])
	*/
	arg out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, rMajor = 1, rMinor = 0.25, tMajor = 1, sMinor = 0.5, freq_u = 100, freq_v = 100, scaleX = 1, scaleY = 1, scaleZ = 1, doneAction = 2;
    var u, v, x, y, z, grey, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    //parametric supertoroid
    //u -> [  0   , 2*pi];
    //v -> [  0   , 2*pi];
    u = Phasor.ar(0, freq_u/SampleRate.ir, start: 0, end: 2*pi);
    v = Phasor.ar(0, freq_v/SampleRate.ir, start: 0, end: 2*pi);
    x = cos(u).sign*pow(abs(cos(u)),tMajor)*(rMajor+rMinor*cos(v).sign*pow(abs(cos(v)),sMinor));
    y = sin(u).sign*pow(abs(sin(u)),tMajor)*(rMajor+rMinor*cos(v).sign*pow(abs(cos(v)),sMinor));
    z = rMinor*sin(v).sign*pow(abs(sin(v)),sMinor);
    grey = Perlin3.ar(x/scaleX, y/scaleY, z/scaleZ);
	grey = grey * globalEnv;
    OffsetOut.ar(out, DirtPan.ar(grey, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ulysse42Sd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 0.2, mod2 = 0.71, doneAction = 2;
    var sig, sig1, sig2, sig3, z1, z2, sinFrq, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    mod1 = mod1.linlin(0, 1, -10, 10);
    sig1 = LFSaw.kr(0.062).range(-10, 10);
    sig1 = sig1 + (mod2.linlin(0, 1, 0, 5) * (0..8));
    sig2 = sig1.frac;
    sig3 = 0.8 - sig2.moddif(0.5, 1);

    z1 = gcd(sig1, mod1) + sig2;
    z2 = lcm(sig1, mod1) + sig2;
    sinFrq = 120 * ([z1, z2].flop.abs + 1);

    sig = (SinOsc.ar(sinFrq) * AmpComp.kr(sinFrq) * sig3).mean;
    // sig = Pan2.ar(sig * env, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDmFbGeneSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, ser1_1 = 0, ser1_2 = 1, ser1_3 = 2, ser1_4 = 3, ser1Size = 4, ser2_1 = 4, ser2_2 = 3, ser2_3 = 2, ser2_4 = 1, ser2_5 = 0, ser2Size = 5, add1 = 50, add2 = 50.1, modul = 50, sinFmin = 70, divisor = 10, sigSel = 0, fbSel = 0, doneAction = 2;
    var seq1, seq2, src1, src2, count1, count2, in, sinFrq, sig, sig1, sig2, sig3, sig4, sig5, fb, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    seq1 = Dseq([Dser([ser1_1, ser1_2, ser1_3, ser1_4], ser1Size.max(1))], inf);
    seq2 = Dseq([Dser([ser2_1, ser2_2, ser2_3, ser2_4, ser2_5], ser2Size.max(1))], inf);

    src1 = TDuty.ar(seq1 + add1 * SampleDur.ir);
    src2 = TDuty.ar(seq2 + add2 * SampleDur.ir);

    count1 = PulseCount.ar(src1) % modul;
    count2 = PulseCount.ar(src2) % modul;

    in = LocalIn.ar(2);
    sig1 = gcd(count1, count2 + [0, 1]);
    sinFrq = sig1.linexp(0, modul, sinFmin, 10000);
    sig2 = SinOsc.ar(sinFrq, 0, in / 2);
    sig3 = SinOsc.ar(sinFrq * (in / divisor + 1));
    sig4 = SinOsc.ar(sinFrq);
    sig5 = SinOsc.ar(sinFrq) + BPF.ar(in * 0.95, LFDNoise3.ar(0.2).range(100, 10000));

    sigSel = sigSel.min(3).max(0);
	sig = Select.ar(sigSel.mod(4), [sig2, sig3, sig4, sig5]);

    fbSel = fbSel.min(3).max(0);
	fb = Select.ar(fbSel.mod(4), [sinFrq.reverse, in.reverse, sig * in, sig]);
    LocalOut.ar(fb);

    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\addiditiveSinSd, { arg out = 0, amp = 0.9, pan = 0, atk = 0.0001, stn = 1, rls = 0.4, crv = (-4), envPow = 1, sampleRate = 44100, doneAction = 2;
	var sig, env, buffAmp, numPartials = 50;

	env = EnvGen.ar(Env.asr(atk, stn, rls, crv), doneAction: doneAction).pow(envPow);

	buffAmp = LocalBuf(numPartials);

	BufWr.ar(
		LFGauss.ar(
			duration: sampleRate.reciprocal * numPartials / \factor.kr(1, 0.5),
			width: \width.kr(0.2, 0.5),
			iphase: \phase.kr(0, 0.5).mod(4)
		),
		bufnum: buffAmp,
		phase: Phasor.ar(
			end: numPartials
		)
	);

	sig = Mix.fill(numPartials, {
		arg i;
		SinOsc.ar(
			//Odd harmonics
			freq: ((i * 2) + 1) * \fund.kr(120, 0.5),
			//The i-th value of ~buffer_amplitudes is read with an Index Ugen
			mul: Index.ar(buffAmp, i)
		) / numPartials
	});

	/*sig = Pan2.ar(sig * env, pan, amp);

	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fbDelNetSd, { arg out = 0, pan = 0, amp = 0.2, atk = 0.001, rls = 1, stn = 1, crv = (-4), doneAction = 2;
    var trig = \trig.tr(1);
    var size, delTimes, delTimesSec, order;
    var sig, inSig, modEnv, gainEnv, delMod;
    var rotate, angle, matrix, householder4x4, givens2x2, kronecker, s, c;

    rotate = SinOsc.ar(\rotateFreq.kr(0.1)).linlin(-1, 1, 0, \rotateAmount.kr(55));
    angle = Phasor.ar(trig, rotate * SampleDur.ir, 0, 1) * 2pi;

    s = angle.sin;
    c = angle.cos;

    givens2x2 = [
        [ c, s.neg ],
        [ s,  c ]
    ];

    householder4x4 = [
        [ -0.5,  0.5,  0.5,  0.5 ],
        [  0.5, -0.5,  0.5,  0.5 ],
        [  0.5,  0.5, -0.5,  0.5 ],
        [  0.5,  0.5,  0.5, -0.5 ],
    ];

    matrix = givens2x2.collect { |x|
        x.collect { |y| householder4x4 * y }.reduce('+++')
    }.reduce('++');

    delMod = SinOsc.ar(2).linlin(-1, 1, 1, 4);

    gainEnv = EnvGen.ar(Env.perc(atk, rls, 1, crv), trig, timeScale: stn, doneAction: doneAction);
    modEnv = EnvGen.ar(Env([0,1,0], [0.125, 0.5], [-8.0, -4.0]), trig);

	inSig = Saw.ar(XLine.kr(\startFreq.kr(100), \endFreq.kr(1000), \durFreq.kr(0.1))) * gainEnv;
    sig = Mix(inSig);

    order = 8;
    size = \size.kr(0.15) + modEnv.linlin(0, 1, 0, \sizeEnvAmount.kr(0.65));

	delTimes = order.collect({|i| ((i + 1) * 511).max(1000).nextPrime });
    delTimesSec = (delTimes * delMod) / 44100;

    sig = sig + LocalIn.ar(order);
    sig = DelayC.ar(sig, 0.5, delTimesSec * size - ControlDur.ir);
    sig = sig * \feedback.kr(0.9);
    sig = OnePole.ar(sig, \coef.kr(0.3));

    sig = sig * matrix.flop;
    sig = sig.sum;
    LocalOut.ar(sig);
    // OffsetOut.ar(out, Pan2.ar((inSig + Splay.ar(sig)), pan, amp) * 0.5);
	OffsetOut.ar(out, DirtPan.ar((inSig + Splay.ar(sig)), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\fbIntegratNetSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.001, dcy = 0.2, rls = 1, crv = (-4), doneAction = 2;
    var snd, n, env, mod;
    n = 8;
    env = EnvGen.kr(Env.adsr(atk, dcy, 1, rls, 1, crv), doneAction: doneAction);
    mod = SinOsc.ar(0.02, SinOsc.kr(0.12, 0.001, 0.02), 0.2);
    snd = Impulse.ar(0);
    snd = snd + LocalIn.ar(n);
    snd = Integrator.ar(snd, 0.99);
    snd = snd * ({ { (Rand(-1, 1) + mod) * 1000 } ! n } ! n);
    snd = snd.sum;
    snd = LeakDC.ar(snd);
    snd = snd.clip2;
    LocalOut.ar(snd);
    snd = Splay.ar(snd) * env;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\chaosEngineSd, { arg out = 0, pan = 0, amp = 0.2, atk = 0.0001, dcy = 0.1, stn = 1, rls = 1.2, modPhaseFreq = 0.12345, modPhaseMul = 678, modPhaseAdd = 9, modAmpFreq = 101, modAmpMul = 0.2, modAmpAdd = 0.8, modOffsetFreq = 25, modOffsetWidth = 0.25, modOffsetMul = 0.125, modOffsetAdd = (-0.25), modFreqFreq = 50, sinFreq = 10, gate = 1, doneAction = 2;
    var sig, env, modPhase, modAmp, modOffset, modFreq;
    env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls), gate, doneAction);
    modPhase = Saw.kr(modPhaseFreq, modPhaseMul, modPhaseAdd);
    modAmp = SinOsc.kr(modAmpFreq, modPhase, modAmpMul, modAmpAdd);
    modOffset = Pulse.kr([modOffsetFreq, modOffsetFreq + 0.5], modOffsetWidth, modOffsetMul, modOffsetAdd);
    modFreq = (modFreqFreq * SinOsc.kr([modFreqFreq, modFreqFreq + 1], 0, modAmp, modOffset));
    sig = SinOsc.ar(sinFreq + modFreq, 0, 0.5);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\claudesSd, { arg out = 0, amp = 0.5, pan = 0, atk = 0.02, rls = 6, crv = (-4), freq = 210, filtCutOff = 950, lpffreq = 2000, revMix = 0, dur = (1/6), doneAction = 2;
    var num = 10;
    var sig = num.collect{
        var frq = freq * SinOsc.kr(LFNoise1.kr(dur).range(30, 1000), 0, LFNoise1.kr(dur).range(0.01, 8)).midiratio;
        var sig = Select.ar(LFNoise0.kr(dur).range(0, 2).round,
            [SinOsc.ar(frq, 0, 0.3), Saw.ar(frq, 0.3), Pulse.ar(frq, 0, 0.3)]);
        var filtFreq = filtCutOff * LFNoise1.kr(dur).range(1.0, 5.0);
        var filt = Select.ar(LFNoise0.kr(dur).range(0, 2).round,
            [LPF.ar(sig, filtFreq), HPF.ar(sig, filtFreq), BPF.ar(sig, filtFreq)]
        );
        sig = CombL.ar(filt, 0.5, LFNoise1.kr(dur).range(0.02, 0.5), rrand(0.3, 2));
        sig
    };
    var env = Env.perc(atk, rls, 1, crv).ar(doneAction);
    sig = Splay.ar(sig); // nb! levelComp: true, so if removed signal will be extremely loud!
    sig = LPF.ar(sig, lpffreq);
    sig = FreeVerb2.ar(sig[0], sig[1], revMix.range(0, 1.0), LFNoise1.kr(dur).range(0.2, 2));
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

)