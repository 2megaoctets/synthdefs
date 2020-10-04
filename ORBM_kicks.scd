
(

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

	SynthDef(\IkedaBassSusSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.2, envL2 = 0.5, envL3 = 0.4, envL4 = 0, envT1 = 0, envT2 = 0.2, envT3 = 0.01, envCurve = (-5), freq = 0, sweep1 = 52.8, sweep2 = 740, vol1 = 2, vol2 = 0.05, gate = 1, sustain = 1, doneAction = 2;
		var env, sin, sig;
		env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, timeScale: sustain, doneAction: doneAction);
		sin = SinOsc.ar(freq, (Sweep.ar(gate, 2pi * [sweep1, sweep2]) + (pi/3)).wrap(-pi, pi), [vol1, vol2]).mean.tanh;
		sig = sin * env;
		OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\ikedaBassBrSd, { arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 0.1, sst = 0.8, rls = 0.01, curve = -5, freq = 0, harmonic = 14.015, iphase = pi/3, gate = 1, doneAction = 2;
		var env, snd;

		env = Env.adsr(
		    	attackTime: atk,
		    	decayTime: dcy,
		    	sustainLevel: sst,
		    	releaseTime: rls,
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

	SynthDef(\gabberkickSd, { arg out = 0, pan = 0, amp = 0.1, atk = 0.001, rls = 0.05;
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
	    snd = snd * Env.asr(atk, 1, rls).ar(2, \gate.kr(1));
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

	SynthDef(\kickhiSd, { arg out = 0, amp = 1, pan = 0, vcaLev1 = 0.5, vcaLev2 = 0.1, vcaLev3 = 0.01, vcaLev4 = 0.01, vcaLev5 = 0, vcaTime1 = 0.01, vcaTime2 = 0.5, vcaTime3 = 1.26, vcaTime4 = 0.1, vcaCurve1 = (-4), vcaCurve2 = (-2), vcaCurve3 = (-4), vcfLev1 = 122, vcfLev2 = 30, vcfLev3 = 33, vcfLev4 = 28, vcfTime1 = 0.05, vcfTime2 = 0.29, vcfTime3 = 1, vcfCurve1 = (-4), vcfCurve2 = (-5), tu = 1, doneAction = 2;
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

	SynthDef(\kick2Sd,{arg out = 0, gate = 1, freq = 60, tu = 1, amp = 1, atf = 80, rls =1, pan = 1;
		var env = EnvGen.ar(Env.perc(0,rls),gate,doneAction:2);
		var frequ = EnvGen.ar(Env([freq-30,freq,60],[0.001,0.01]));
		var sig = SinOsc.ar(frequ*tu,0,env);
		// sig = Pan2.ar(LPF.ar(sig,100), pan, amp);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(LPF.ar(sig,100), ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\kick2newSd,{arg out = 0, amp = 1, pan = 0, atk = 0, rls = 1, envfT1 = 0.002, envfT2 = 0.1, freq = 60, tu = 1.33, bpeqf1 = 3081, bpeqrq1 = 0.71, bpeqamp1 = (-54), bpeqf2 = 800, bpeqrq2 = 10, bpeqamp2 = (-12), hpff = 81, gate = 1, doneAction = 2;
	    var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
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

	SynthDef(\kick3newSd,{arg out = 0, amp = 0.5, gate = 1, tu = 1, rls = 3, freq = 60, pan = 0;
	    var env = EnvGen.ar(Env.perc(0,rls), gate, doneAction:2);
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

	SynthDef(\t1kickSd, {arg out = 0, amp = 0.5, pan = 0, rls = 0, doneAction = 2;
		var enva, envf, sig;
		enva = EnvGen.ar(Env([0.01,1,0],[0.001, rls]), doneAction: doneAction);
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

	SynthDef(\kickmedSd, { | out = 0, level = 0.5, pan = 0, noise = 1, done = 2, dc = 1, snd = 18, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, rlsEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1, env1T2, env1T3, env1T4, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase, oamp = 0.1, owhich2 = 0, ochoose = 0|
		var env0,env1,
	env1m, son, son2,son3,son4,p2;
		p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,rlsEnv0,0.5],[curve1, curve2, curve3]);
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

	SynthDef(\kick808BrSd, {arg out = 0, amp = 1, pan = 0, atk = 0.001, rls = 1, freq1 = 240, freq2 = 60, ringTime = 10, dist = 0.5, doneAction = 2;
		var snd, env;
		snd = Ringz.ar(
			in: Impulse.ar(0), // single impulse
			freq: XLine.ar(freq1, freq2, 0.1),
			decaytime: ringTime);
		env = Env.perc(atk, rls, amp).kr(doneAction: doneAction);
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

	SynthDef(\kikAwSusSd, { |out = 0, amp = 0.5, pan = 0, basefreq = 50, ratio = 7, sweeptime = 0.05, envL1 = 1, envL2 = 0.8, envL3 = 0, envT1 = 0.3, envT2 = 0.15, sustain = 1|
	    var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
		env = EnvGen.kr(Env([envL1, envL2, envL3], [envT1, envT2], -4), timeScale: sustain, doneAction: 2),
		sig = SinOsc.ar(fcurve, 0.5pi, env).distort * amp;
	    // OffsetOut.ar(out, sig ! 2);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\kickbassSd, { | out = 0, level = 0.5, pan = 0, atk = 0.01, dcy = 0.2, rls = 0.26, fratio = 1.5, noise = 1, freq1 = 120, freq2 = 30, freq3 = 30, dc = 1, aamp1 = 1, aamp2 = 1, aamp3 = 1, aamp4 = 1, curve1 = (-4), curve2 = (-2), curve3 = (-4), famp1, famp2, famp3, famp4, p1, oamp = 0.1, owhich2 = 0, ochoose = 0, filter = 20000, done = 2 |
		var env0,env1,
	env1m, son, son2,son3,son4,p2;

		p2 = p1 * (-pi);
	env0 = Env([aamp1,aamp2,aamp3,aamp4,0.1,0],[atk, dcy, rls],[curve1, curve2, curve3]);
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

	SynthDef(\drumkickSd, { arg out = 0, amp = 0.5, pan = 0.0, atk = 0.0001, rls = 0.09, curve = 8, attSinFreq = 0.0001, rlsSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, rlsBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, doneAction = 2;
		var source;

		source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, rlsSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
		((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, rlsBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(atk, rls, curve: curve), gate, doneAction: doneAction);

		// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\drumkickSusSd, { arg out = 0, amp = 0.5, pan = 0.0, atk = 0.0001, rls = 0.09, curve = 8, attSinFreq = 0.0001, rlsSinFreq = 1.5, curveSinFreq = (-200), levSin = 1, attBpfFreq = 0.001, rlsBpfFreq = 0.3, timeScaleBpf = 1.5, curveBpf =(-200), levBpf = 1, levScaleBpf = 6000, levBiasBpf = 70, lineStartBpf = 0.3, lineEndBpf = 0, lineLevBpf = 0.1, gate = 1, sustain = 1, doneAction = 2;
		var source;

		source = SinOsc.ar(EnvGen.kr(Env.perc(attSinFreq, rlsSinFreq, levSin, curveSinFreq), gate, 1000, 45), 1, 1) +
		((BPF.ar([GrayNoise.ar(6),GrayNoise.ar(6)], EnvGen.kr(Env.perc(attBpfFreq, rlsBpfFreq, levBpf, curveBpf), gate, levScaleBpf, levBiasBpf.max(0.1)), timeScaleBpf.max(0.01))).distort * Line.kr(lineStartBpf, lineEndBpf, lineLevBpf)) * EnvGen.kr(Env.perc(atk, rls, curve: curve), gate, timeScale: sustain, doneAction: doneAction);

		// OffsetOut.ar(out, Pan2.ar(source, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(source, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\kickAwSd, {arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 0.45, sinfreq = 70, glissf = 0.9, doneAction = 2;
		var gliss = XLine.kr(sinfreq, sinfreq*glissf, rls);
		var snd = SinOsc.ar(gliss);
		var env = EnvGen.kr(Env.perc(atk, rls), doneAction: doneAction);
		snd = snd * env * amp;
		snd = Limiter.ar(snd,1,0.001);
		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\kick3AwSd, {arg out = 0, amp = 0.5, pan = 0, envL1 = 0, envL2 = 1, envL3 = 0.8, envL4 = 0, atk = 0.01, dcy = 0.1, rls = 0.2, punch = 1, envfLev1 = 400, envfLev2 = 66, envfTime = 0.08, envfCurve = -3, doneAction = 2;
		var freq, env, sig;
	    freq = EnvGen.kr(Env([envfLev1, envfLev2], [envfTime], envfCurve));
		env = EnvGen.kr(Env([envL1, envL2, envL3, envL4], [atk, dcy, rls]), doneAction: doneAction);
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

	// edit 060892020
	SynthDef(\tweetBassLeakSd, { arg out = 0, amp = 0.2, pan = 0, atkEnv = 0.01, rlsEnv = 1, atkDec2 = 0.01, dcy = 0.4, freq = 2, rq = 0.1, gate = 1, doneAction = 2;
		var sig, demand, env, globenv;
		demand = Demand.kr(
			gate,
			0,
			Drand([0.8, 1], inf)
		);
		env = Decay2.kr(
			demand,
			atkDec2,
			dcy
		);
		sig = Saw.ar(freq, env) ** 1.5;
		sig = BRF.ar(sig, demand * 20 + [45.1, 45], rq);
		//globenv = EnvGen.kr(Env.linen(atkGlobal, 1, rlsEnv), doneAction: doneAction);
		globenv = EnvGen.kr(Env.asr(atkEnv, releaseTime: rlsEnv), gate, doneAction: doneAction);
		sig = sig * globenv;
		sig = LeakDC.ar(sig).tanh;
		// OffsetOut.ar(out, sig * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\tweetKickIntSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, impfreq = 2, phRate = 64, lagFreq = 2, inAmt = 99, coef1 = 0.9, coef2 = 0.99, doneAction = 2;
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

	SynthDef(\tabassSd, { arg out = 0, amp = 0.8, pan = 0, gate = 1, atk = 0.01, rls = 2, freq = 1, doneAction = 2;
		var sig, env;
		env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
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

	SynthDef(\kickySd,{ arg out = 0, amp=1, pan = 0, startFreq=80, endFreq=15, length=6, decay=4, lowpass=800, noiseAmp=0.0, gain=1, doneAction = 2;
		var sig, env, freq;
		freq = Line.kr(PinkNoise.kr(6,startFreq), PinkNoise.kr(3,endFreq), length, 1, 0);
		env = EnvGen.kr(Env.perc(0.014, length, 1, -5), 1, doneAction: doneAction);
		sig = {(LPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass) * amp) ! 2};
		sig = LPF.ar(sig,BrownNoise.kr(500,1500))*0.3;
		sig = sig * gain;
		sig = sig.softclip * amp * env;
		// OffsetOut.ar(out, [sig,sig]);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	// SynthDef(\kickeySd,{ arg out = 0, amp = 1, pan = 0, atk = 0.0014, rls = 0.8, curve = (-5), startFreq = 60, endFreq = 10, linedur = 0.8, dcy = 0.8, lowpass = 500, rq = 1, gain = 1, smoothLo = (-1), smoothHi = 1, foldRange = 1, smoothAmount = 0.5, doneAction = 2;
	// 	var sig, env, freq;
	// 	freq = XLine.kr(startFreq, endFreq, linedur, 1, 0);
	// 	env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
	// 	sig = {(RLPF.ar(Ringz.ar(Impulse.ar(0), freq, decay), lowpass, rq)) ! 2};
	// 	sig = sig * gain;
	// 	//sig = sig.softclip * amp * env;
	// 	sig = SmoothFoldS.ar(sig, smoothLo, smoothHi, foldRange, smoothAmount) * amp * env;
	// 	// OffsetOut.ar(out, [sig,sig]);
	// 	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	// }).add;

	SynthDef(\kickBoomySd, { arg out = 0, amp=1, pan = 0, atk = 0.0014, rls=0.4, curve = (-5), frq1 = 180, frq2 = 330, frq3 = 175, frq4 = 224, gain=1.1, doneAction = 2;
		var env, sig;
		env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
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
		t1atk = 0.0005, t1rls = 0.01, t1curve = (-4), t1del = 0, t1amp = 1,
		//tone2 arguments
		t2freq = 50, t2harmonic = 3.44, t2glide = 0.01,
		t2atk = 0.0001, t2rls = 0.3, t2curve = (-4), t2del = 0.005, t2amp = 1,
		//hit1 arguments
		h1freq = 100, h1harmonic = 8, h1glide = 0.01, h1rq = 0.6,
		h1atk = 0.001, h1rls = 0.02, h1curve = (-4), h1del = 0.001, h1amp = 1,
		//hit2 arguments
		h2freq = 1320, h2harmonic = 1, h2glide = 0,
		h2atk = 0.003, h2rls = 0.03, h2curve = (-4), h2del = 0, h2amp = 0.5,
		//click arguments
		cfreq = 6100, crq = 1, camp = 1.41,
		doneAction = 2;

	    var env, snd, noise, tone1, tone2, hit1, hit2, click;

		env = EnvGen.kr(Env.linen(0.01, 1, 6), doneAction: doneAction);
		noise = Hasher.ar(Sweep.ar); //deterministic white noise

	    tone1 = SinOsc.ar(
			freq: XLine.ar(start: t1freq * t1harmonic, end: t1freq, dur: t1glide),
			mul: Env.perc(attackTime: t1atk, releaseTime: t1rls, level: t1amp, curve: t1curve).delay(t1del).ar);

		tone2 = SinOsc.ar(
			freq: XLine.ar(start: t2freq * t2harmonic, end: t2freq, dur: t2glide),
			mul: Env.perc(attackTime: t2atk, releaseTime: t2rls, level: t2amp, curve: t2curve).delay(t2del).ar);

	    hit1 = BPF.ar(
			in: noise,
			freq: XLine.ar(start: h1freq * h1harmonic, end: h1freq, dur: h1glide),
			rq: h1rq,
			mul: Env.perc(attackTime: h1atk, releaseTime: h1rls, level: h1amp, curve: h1curve).delay(h1del).ar);

		hit2 = HPF.ar(
			in: noise,
			freq: XLine.ar(start: h2freq * h2harmonic, end: h2freq, dur: h2glide),
			mul: Env.perc(attackTime: h2atk, releaseTime: h2rls, level: h2amp, curve: h2curve).delay(h2del).ar);

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
		envf = EnvGen.kr(Env([envfL1, envfL2, envfL3, envfL4, envfL5], [envfT1, envfT2, envfT3, envfT4], [curve, curve/2, curve]), levelScale: envfAmt * mod, doneAction: doneAction);
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

	SynthDef(\kickRingzSd, { arg out = 0, amp = 1, pan = 0, envL1 = 0.1, envL2 = 1.2, envL3 = 3, envL4 = 2.1, envL5 = 0.1, envT1 = 0.1, envT2 = 0.2, envT3 = 0, envT4 = 0.1, curve = (-4), envpL1 = 0.1, envpL2 = 1.2, envpL3 = 3, envpL4 = 2.1, envpT1 = 0.1, envpT2 = 0, envpT3 = 1.2, curvep = (-4), freq = 40, dcy = 0.25, ffreq = 1000, doneAction = 2;
		var snd, env, envp;

		env = EnvGen.kr(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4], [curve, curve/2, curve]), doneAction: doneAction);
		envp = EnvGen.kr(Env([envpL1, envpL2, envpL3, envpL4], [envpT1, envpT2, envpT3], [curvep, curvep*1.25, curvep].midicps), doneAction: doneAction);
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

	SynthDef(\kick_chirpSd, { arg out = 0, amp = 0.1, pan = 0, curve = -20, atk = 0.001, rls = 0.5, maxFreq = 500, doneAction = 2;
	    var env, snd;

		env = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).exprange(0, maxFreq).kr(doneAction: doneAction);

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

	/*SynthDef(\kik3BrSd, { arg out = 0, amp = 1, pan = 0, freq = 66, atk = 0.01, dcy = 0.1, decaylevel = 0.8, rls = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = \exp, harmonic = 6, preamp = 3;
		var snd, env, fenv;

		env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [atk, dcy, rls], curve: envCurve).kr(doneAction: 2);

		fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

		snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

	    snd = Normalizer.ar(in: snd, level: env);

		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;*/

	// nouveau 05 09 2020
	SynthDef(\kik3BrSd, { arg out = 0, amp = 1, pan = 0, freq = 66, atk = 0.01, dcy = 0.1, decaylevel = 0.8, rls = 0.3, envCurve = -4, sweeptime = 0.08, sweepCurve = 2, harmonic = 6, preamp = 3;
		var snd, env, fenv;

		env = Env.new(levels: [0, amp, decaylevel * amp, 0], times: [atk, dcy, rls], curve: envCurve).kr(doneAction: 2);

		fenv = Env.new(levels: [freq * harmonic, freq], times: [sweeptime], curve: sweepCurve).kr;

		snd = SinOsc.ar(freq: fenv, mul: preamp).distort;

	    snd = Normalizer.ar(in: snd, level: env);

		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;


	SynthDef(\sosKickSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, subamp = 1, drumAmp = 1, beaterAmp = 0.02, clickAmp = 1,
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

		snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: doneAction);
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

	SynthDef(\technokickSusSd, {
		| out=0, amp=0.5, pan = 0, atk = 0.01, rls = 6, freq=51.913087197493, dcy=0.28571428571429, click=0.008, spread=0.1, damp=0.6, gate=1, sustain = 1, doneAction = 2 |
		var sig, env, env1, aEnv, env2, wEnv, vEnv, low, high, dry, verb, verbHi, verbLo;
		// env.ar is really good for this since thie envelopes are so short
		env = EnvGen.kr(Env.linen(atk, rls*2, rls), timeScale: sustain, doneAction: doneAction);
		env1 = EnvGen.ar(Env.adsr(0,0.1,0,0, curve: -8, bias: 1)); // initial attack
		env2 = EnvGen.ar(Env.adsr(0,click,0,0,32, bias:1)); // click adder
		aEnv = EnvGen.kr(Env.perc(0.005, rls/1.75, curve: 2), timeScale: sustain); // amplitude
		wEnv = EnvGen.ar(Env.adsr(0,0.01,0,0, curve: -4), timeScale: sustain);

		vEnv = EnvGen.kr(Env.adsr(dcy, dcy/2, 1, 0.01, curve: 3), gate, timeScale: sustain); // for reverb
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

)
