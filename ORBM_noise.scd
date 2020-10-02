(

// correction 02 10 20
SynthDef(\IkedaBreathSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0001, dcy = 0.4, rls = 0.01, note1 = 44, note2 = 90, amp1 = 0.5, amp2 = 0.6, lpfFreq = 2400, hpfFreq = 103.82, gate = 1, doneAction = 2;
	var sin, lpf, hpf, sig;
	sin = SinOsc.ar(note1.midicps, 0, amp1) + SinOsc.ar(note2.midicps, 0, amp2);
	lpf = LPF.ar(sin, lpfFreq.max(1));
	hpf = HPF.ar(LPF.ar(WhiteNoise.ar(0.008), 12000), hpfFreq.max(1));
	sig = (lpf + hpf) * EnvGen.kr(Env(#[0, 1, 0.6, 0], [atk, dcy, rls]), gate, doneAction: doneAction); // # makes a totally fixed (non-dynamic) Array and is slightly cheaper, especially where you're not going to change the Array once you make it
	// OffsetOut.ar(out, Pan2.ar(sig, pan, level));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\noise2Sd,{arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 0.01, a = 4;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [-4, -2, -4]), doneAction:2);
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

SynthDef(\noise2newSd,{arg out = 0, amp = 1, pan = 0, levelScale = 1, atk = 0.01, rls = 1, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 0.2, avar = 1, bvar = 1, xi = 0.5, hpf = 1000, del1 = 10, del2 = 20, doneAction = 2;
	var env, sig;
	env =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [curve1, curve2, curve3]), levelScale: levelScale, doneAction: doneAction);
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

SynthDef(\noiseSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls  = 0.25, curve1 = -4, curve2 = -2, curve3 = -4, coeff = 4, avar = 3, bvar = -3, cvar = 0.5, dvar = 1.5, xi = 0.5, yi = 0.5, hpf = 1000, doneAction = 2;
var env0 =  EnvGen.ar(Env.new([0.1, 1, 0.3, 0], [atk, rls], [curve1, curve2, curve3]), doneAction: doneAction);
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

/*SynthDef(\cosc, { arg out = 0, gate = 1, amp = 1, pan = 0, freq = 512, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(0.5,1,1,0), gate, doneAction: doneAction);
    var sig = COsc.ar(80,[freq,freq+0.5], 1, 0.1);
    sig  = sig + COsc.ar(80,[freq,freq+0.5]*2, 1, 0.1);
    sig = FreeVerb.ar(sig*env,1);
    sig = LeakDC.ar(sig);
    OffsetOut.ar(0,sig*amp);
}).add;*/

SynthDef(\jiletSd, { arg out=0, amp=0.20, pan = 0, atk = 0.005, dcy = 0.01, sst = 1.1, rls = 0.01, envOffset=0.5, freq=4, endReflection=1.5, jetReflection=0.5, jetRatio=10.72, noiseGain=0.35, vibFreq=5.925, vibGain=0.02, gate=1, doneAction = 2;

	var adsr = (envOffset*0.2) + EnvGen.ar(Env.adsr(atk, dcy, sst, rls), gate, doneAction: doneAction);
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

SynthDef(\pitchednoiseSd, { arg out = 0, amp=0.1, pan=0.0, atk=0.01, rls=10, freq=440, bandwidth=100, doneAction=2;
	var source, filter, env;
	// env = EnvGen.ar(Env([0,1,1,0],[atk, sustain, decay]), doneAction: doneAction);
	env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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

SynthDef(\resSd, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.7, freqSin = 52, ampSin = 1, freqSaw = 22, ampSaw = 1, oscMix = 0.5, freqClc = 7302, harmClc = 200, ampClc = 0.5, maxL = 1, t1Clc = 0.001, t2Clc = 0.03, t3Clc = 0.01, gFreq = 12, damp = 0, fric = 0.001, doneAction = 2|
	var aEnv, osc, sig, flt, clic;
	aEnv = EnvGen.kr(Env.perc(atk, rls), doneAction: doneAction);
	osc = Mix([SinOsc.ar(freqSin, 0, ampSin), Saw.ar(freqSaw, ampSaw)]) * aEnv;
	clic = Blip.ar(freqClc, harmClc, ampClc) * EnvGen.kr(Env.step([0, maxL, 0], [t1Clc, t2Clc, t3Clc]));
	sig = (osc * oscMix) + (clic * (1 - oscMix));
	sig = sig + Ball.ar(sig, LFNoise1.kr(gFreq, 0.5, 0.5), damp, fric) * aEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*~resSynthDef = SynthDef(\res, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.7, freqSaw = 40, freqPls = 62, wPls = 0.5, rlpfRq = 0.1, lfnFreq = 0.3, lfnMul = 1000, lfnAdd = 1500, gate = 1, doneAction = 2|
	var aEnv, osc, flt, fltBus;
	aEnv = EnvGen.kr(Env.perc(atk, rls), gate, doneAction: doneAction);
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

SynthDef(\tweetSynthSd, { arg out = 0, amp = 1, pan = 0, freq = 25, rate = 8, atk = 0.01, rls = 10, sigatk = 0.01, sigdcy = 3.16, thresh = 0.5, ratio = 1, revMix = 0, revRoom = 0.5, revDamp = 0.5, gate = 1, doneAction = 2;
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
	sigenv = EnvGen.kr(Env.asr(sigatk, 1, sigdcy), gate);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = sig * sigenv * env;
	sig = Compander.ar(sig, sig, thresh.max(0.01), 1, ratio);
	sig = FreeVerb2.ar(sig[0], sig[1], Lag2.kr(revMix), revRoom, revDamp);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetFogAttackSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, sigatk = 0.01, sigdcy = 3.16, feedBack = 0.2, freq = 0.8, gate = 1, doneAction = 2;
	var sig, env, coef, sigenv;
	sig = Pulse.ar(freq*(pi/[1,2.57]),[0.54,0.46]);
	coef = (1-LocalIn.ar(2)).fold(0,[0.9,0.85]);
	sig = LeakDC.ar(Integrator.ar(sig, coef).wrap2(pi).sin);
	LocalOut.ar(sig * feedBack);
	sigenv = EnvGen.kr(Env.asr(sigatk, 1, sigdcy), gate);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = (sig.mean!2) * sigenv * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\tweetErosionSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 10, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, div, envIndex, xyc;
	input = LocalIn.ar(2).range(0,0.9)+0.1;
	div = LagUD.ar(input, 0, 0.2);
	sig = PinkNoise.ar(1!2);
	sig = tanh(500 * (sig**(8/div)));
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	LocalOut.ar(sig * feedBack);
	sig = Splay.ar(sig,1-input);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\harshTextureSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 2, delTimeMod = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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

SynthDef(\ultraHiSummerSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, curve = (-4), blpFreq1 = 16e3, blpFreq2 = 16150, seqRate = 0.2, seqVal1 = 70, seqVal2 = 30, seqVal3 = 0, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls, curve: curve), gate, doneAction: doneAction);
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

SynthDef(\ambiantPicSd, { arg out = 0, amp = 0.3, pan = 0, atk = 0.01, rls = 10, lfnFreq = 22, lfnAmp = 5, lfnOffset = 9, ampDst1 = 4, ampDst2 = 2, durDst1 = 0.5, durDst2 = 1, adPar1 = 1/9, adPar2 = 1/4, ddPar1 = 1/2, ddPar2 = 1/8, delTime1 = 0.13, delTime2 = 0.1, decTime = 0.2, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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

SynthDef(\attBreathSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, seqv1 = 1, seqv2 = 1, seqv3 = 4, seqv4 = 2, seqv5 = 2, seqFreq = 0.2, freqMin = 250, freqMax = 800, bwrMod = 0.5, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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

SynthDef(\dStowellSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, freq = 6/3, width = 1/5, lpf = 20000, gate = 1, doneAction = 2;
	var sig, env, spec, input;
	spec = `[{exprand(100,1000)}.dup(50)];
	input = Saw.ar(
		LFPulse.kr(freq,0,width).range(3,3000),
		0.0005
	);
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Klank.ar(spec, input);
	sig = LPF.ar(sig, lpf);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\henonSd, { arg out = 0, amp = 0.1, pan = 0, freq = 440, a = 1.3, b = 0.3, x0 = 0.30501993062401, x1 = 0.20938865431933, atk = 0.01, sst = 1, rls = 1, ts = 1, gate = 1, doneAction = 2;
	var sig,env;
	sig = HenonN.ar(freq,a,b,x0,x1,amp);
	env = EnvGen.ar(Env.linen(atk,sst,rls),gate,1,0,ts,doneAction);
	sig = LeakDC.ar(sig);
	sig = sig*env;
	// OffsetOut.ar(out,Pan2.ar(sig,pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\harrishSd, {| out = 0, amp = 0.2, pan = 0, atk = 0, sustain = 0.2, rls = 0.1, curve = 0, clipLevel = 0.006, impFreq = 0, impPhase = 0, impLevel = 1, noiseLevel = 0.3, lpf = 20000, eqfreq = 4000, eqrq = 1, eqdb = 0, hpf = 20,  doneAction = 2|
	var env = EnvGen.ar(Env.linen(atk, sustain, rls, curve: curve), doneAction: doneAction);
	var snd = (ClipNoise.ar(clipLevel) + Impulse.ar(impFreq, impPhase, impLevel) + BrownNoise.ar(noiseLevel)) * env;
	snd = LPF.ar(snd, lpf);
	snd = BPeakEQ.ar(snd, Lag2.kr(eqfreq.max(20).min(20000), 0.5), eqrq, eqdb);
	snd = HPF.ar(snd, hpf);
	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\kSpluck3Sd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, rls = 0.01, midiPitch = 24, art = -3, noiseFreq = 1, noiseLev = 13000, noiseOffset = 14010, mix = 0.5, doneAction = 2;
	var burstEnv;
	var sig, delayTime;
	delayTime = [midiPitch, midiPitch + 12].midicps.reciprocal;
	burstEnv = EnvGen.kr(Env.perc(atk, rls));
	sig = PinkNoise.ar([burstEnv, burstEnv]); //Noise burst
	sig = CombL.ar(sig, delayTime, delayTime, art, add: sig); //Echo chamber
	sig = XFade2.ar(sig, RLPF.ar(sig, LFNoise1.kr(noiseFreq, noiseLev, noiseOffset), 0.1), mix, amp); //Filter ADSR GELSIN BURAYA
	DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lumbricostSd, {arg out = 0, amp = 0.2, pan = 0, attTim= 1, rlsTim=2.5, scale= 6, offset = 40, freq = 10, timescale = 10, widthmod = 0.4, width = 0.2, abc = 0, randLo = 0, randHi = 20000, bprq = 1, gate = 1, doneAction = 2;
	var generation =
	Pulse.ar(SinOsc.kr(5/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(30/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(7/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(7/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(9/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(2/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(10/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(5/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(3/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(9/freq),widthmod,width,timescale), mul: 0.1) +
	Pulse.ar(SinOsc.kr(2/freq, mul: scale, add: Rand(offset - abc,offset + abc)),EnvGen.kr(Env.perc(0.01, rlsTim), Impulse.ar(40/freq),widthmod,width,timescale), mul: 0.1);
	var env = generation * EnvGen.kr(Env.perc(attackTime:attTim,releaseTime: rlsTim), gate, doneAction: doneAction);
	var env1 = LeakDC.ar(env);
	var sig = env1 * amp;
	sig = BPF.ar(sig, Rand(randLo-100, randHi+100), bprq);
	// OffsetOut.ar(out, Pan2.ar(sig, pan));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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

/*SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\plouxSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.1, dcy = 0.1, stn = 0.8, rls = 0.1, feedBack = 0, fbPost = 0, dustfreq = 2, dustdecay = 0.7, frq = 200, fmfreq = 100, folAtt = 0.01, folDec = 0.2, sinMix = 1, a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, gate = 1, doneAction = 2;
    var sig, dust, input, inMod, envFol, freqMod;
	input = LocalIn.ar(2);
	inMod = input * feedBack;
    dust = Dust.ar(dustfreq);
    dust = Decay.ar(dust, dustdecay);
	freqMod = SinOsc.ar(fmfreq * dust) * inMod + 1;
    sig = SinOsc.ar(frq * freqMod);
	envFol = Amplitude.kr(sig, folAtt, folDec);
	sig = (sig * sinMix) + (RHPF.ar(LatoocarfianN.ar(freqMod.range(2000, 22050), a, b, c, d, xi, yi, LFNoise0.kr(dust)), input.range(20, 20000)) * (1 - sinMix));
    sig = sig * EnvGen.kr(Env.adsr(atk, dcy, stn, rls), gate, doneAction: doneAction);
	LocalOut.ar(sig * fbPost);
	sig = sig.tanh;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}, [\kr ! 22, \tr, \ir].flat).add;

SynthDef(\complexoscSd, { arg out = 0, amp = 1, pan = 0, feedBack = 1, envL1 = 0, envL2 = 2.2, envL3 = 0.12, envL4 = 0, envT1 = 0.01, envT2 = 0.24, envT3 = 0.12, envCurve = (-4), freq1 = 40, fm1 = 0.1, pm1 = 0, amp1 = 1, ring1 = 1, offset1 = 0, freq2 = 0.5, fm2 = 0.1, pm2 = 0, amp2 = 1, ring2 = 1, offset2 = 0, fold = 0.8, wrap = 0.9, switch = 2, gate = 1, doneAction = 2;
    var osc1, osc2, fbk, outlet, folded, wrapped, env, sigenv;
    fbk = LocalIn.ar(2) * feedBack;
	//env = Linen.kr(gate, atk, 1, rls, doneAction);
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


	output = Select.ar(outSignal, [
		tri1, osc1, tri2, osc2, pwm, sh0, filt

	]);
	output = LeakDC.ar(output * amp);
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

SynthDef.new(\ShaiSd, { arg out = 0, amp=0.1, pan = 0, freq=440, atk=1, rls=8, doneAction = 2;
	var sig, env;
	sig = Mix.new(
		Array.fill(32, { SinOsc.ar(freq + Line.kr(1536.0.rand,freq*1.5,8), 0, 0.05) })
	);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rls],[1,-1]),doneAction: doneAction);
	sig = sig*env*amp;
	// OffsetOut.ar(out, [sig, sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef.new(\Colleen3Sd, { arg out = 0, amp=1, pan = 0, freq=110, atk=0.01, rls=2, lpf = 4000, lpfmin = 500, lpfmax = 16000, hpfmin = 1, hpfmax = 2000, doneAction = 2;
	var sig, env;
	freq = freq*(565/250)*PinkNoise.kr(0.01,1)*BrownNoise.kr(0.00,1)*0.36;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),lpf);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rls],[1,-1]),doneAction: doneAction);
	env = env**2;
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(lpfmin,lpfmax,rls/6));
	sig = HPF.ar(sig, XLine.kr(hpfmin,hpfmax,rls/6));
	sig = (sig*env*amp)*0.7;
	// sig = Pan2.ar(sig,pan);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\combsSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 0.1, sst = 0.7, rls = 0.5, freq = 440, rate = 6, depth = 0.2, regen = -3, sweep = 16, rq = 0.5, harmonic = 1.5, gate = 1, doneAction = 2;

	var max, min, vibrato, snd, env, filterenv;

	//Setting some values for the filters:
	max = ((1 + depth) / freq);
	min = (1 / (freq * (1 + depth)));
	vibrato = LFNoise1.ar(rate).range(min, max);

	//Amplitude and filter cutoff envelopes
	env = Env.adsr(atk, dcy, sst, rls).kr(gate: gate, doneAction: doneAction);
	filterenv = Env.perc(atk, rls).kr;
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

SynthDef(\werkitSd, { arg out = 0, amp = 0.1, pan = 0.0, atk = 0.01, dcy = 0, sst = 1, rls = 1, freq = 440, rq = 0.1, gate = 1,doneAction = 2;

	var source, filter, env, snd, delayEnv;
	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, freq, rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(atk, dcy, sst, rls, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\werkit2Sd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, dcy = 0, sst = 1, rls = 0.1, freq = 440, rq = 0.1, gate = 1, doneAction = 2;

	var source, filter, env, snd;
	source = LFSaw.ar(Array.fill(16, { Rand(100, 200) }));
	filter = BLowPass4.ar(source, freq, rq) * 0.1;
	env = EnvGen.ar(
		envelope: Env.adsr(atk, dcy, sst, rls, amp),
		gate: gate,
		doneAction: doneAction);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	snd = HPF.ar(snd, 100);
	snd = Splay.ar(snd);
	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\impnSd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.1, curve = (-5), impRate = 10, kfreq = 1, kdcy = 1, tu = 1, freq = 10327, bwr = 1, delTime = 0.25, decTime = 1, doneAction = 2;
	var env, sig;
	env = EnvGen.kr(Env.linen(atk, 1, rls, 1, curve), doneAction: doneAction);
	sig = Impulse.ar(impRate);
	sig = DynKlank.ar(
		Ref.new([
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421] * tu,   // harmonics
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		]),
		sig,
		kfreq,
		decayscale: kdcy
	);
	sig = Resonz.ar(sig, freq, bwr);
	sig = CombL.ar(sig, 6, delTime, decTime);
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

)
