(

///////////////////////////////////////  Sequence

SynthDef(\virgoSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.01, rls = 1, feedback = 7.5, freq1 = 32, freq2 = 33, delaytime = 2, decaytime = 40, gate = 1, doneAction = 2;
	var sig, input, modFreq;
	input = LocalIn.ar(2) * feedback;
	sig = input + Saw.ar([freq1, freq2], amp);
	modFreq = 2 ** LFNoise0.kr(4/3, 4) * 300;
	sig = BPF.ar(sig, modFreq, 0.1).distort;
	sig = CombN.ar(sig, 1, delaytime, decaytime);
	LocalOut.ar(sig);
	sig = sig * EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\scratchiSd, { arg out = 0, amp = 1, pan = 0, spread = 0, atk = 0.01, rls = 2, freq = 0.5, gate = 1, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	waveForm = SinOsc.ar(freq,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	// OffsetOut.ar(out, Splay.ar(sig, spread, amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig, spread, amp), ~dirt.numChannels, pan));
}).add;

SynthDef(\seqPureSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Splay.ar({|i|
		RLPF.ar(0.6**i*40*Impulse.ar(2**i/32,1/2),4**LFNoise0.kr(1/16)*300,5e-3).sin;
	}!8);
	2.do{
		sig = FreeVerb2.ar(*sig++[0.1,1,1]);
	};
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\seqModulSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, gate = 1, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	buffer = LocalBuf(1e5,2).clear;
	sig = BufRd.ar(2,buffer,Phasor.ar(0,1,0,1e5))*0.6;
	BufWr.ar(Blip.ar([1,1.01],10)/5+sig,buffer,LFNoise1.ar(0.2)+1*5e4);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\nathanielVirgoSd, { arg out = 0, amp = 1, pan = 0, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	env = Linen.kr(gate, 0.01, 1, 20, doneAction);
	sig = LocalIn.ar(2) * feedBack + Saw.ar(
		[sawFreq1, sawFreq2],
		sawAmp
	) * env;
	sig = BPF.ar(
		sig,
		bpff ** LFNoise0.kr(bpffModSpeed, bpffModAmt) * 300,
		0.1
	).distort;
	sig = CombN.ar(sig, 2, delayTime, decayTime);
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

/*SynthDef(\taltersSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, feedBack = 1, freq = 66, freqL1 = 0, freqL2 = 2, freqL3 = 4, freqL4 = 16, freqT1 = 0.01, freqT2 = 0.2, freqT3 = 0.12, freqCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, freqenv;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	input = LocalIn.ar(2) * feedBack;
	freqenv = EnvGen.ar(Env([freqL1, freqL2, freqL3, freqL4], [freqT1, freqT2, freqT3], freqCurve), gate);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(
				(i*k*k) + freq * freqenv,
				y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(decDens**i), (y.ar(decTimeFreq)+1*k+i) * input, k*decamp))
		}!3).product;
	}!4).sum;
	LocalOut.ar(sig);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\talters1Sd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
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
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

/*SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	input = LocalIn.ar(2).tanh * feedBack;
	ctrl = Latch.kr(input[0].abs, Impulse.kr(impFreq));
	sig = Blip.ar([freq1, freq2], 100 * ctrl + 50, 0.9);
	sig = CombC.ar(
		sig,
		1,
		ctrl * delTime,
		decTime * input
	);
	LocalOut.ar(sig);
	sig = Splay.ar(sig * env, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;*/

SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, roomSize = 9, gate = 1, doneAction = 2;
	var sig, env, input, mod, grainTr, sinMod;
	env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(freq),
		tridDur
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1, mul: env);
	sig = GVerb.ar(sig, roomSize, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, atk, 1, rls, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\LiljedDrumSeqSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0001, rls = 4, sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, gate = 1, doneAction = 2;
	var sig, env, imp, krps, kick;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	imp = Impulse.ar(_); // * gate;

	krps = Pluck.ar(
		Saw.ar(sawFrq),
		imp.(plcTrigRate),
		1,
		plcDelay,
		plcDecay,
		SinOsc.ar(
			PulseCount.ar(
				imp.(pCntTrigRate),
				imp.(pCntResetRate)
			).cos%[3,4]*20
		),
		2.5
	).sin;

	krps = krps + LPF.ar(
		HPF.ar(
			FreeVerb.ar(
				krps.mean,
				1,
				0.999,
				0.2
			)*0.3,
			krpsHpfFrq
		) * Line.kr(0,1,16),
		krpsLpfFrq
	);

	kick = HPF.ar(
		Ringz.ar(
			LPF.ar(
				Impulse.ar(
					[0.5,1]!2,
					[1/6,0]
				).sum,
				kickLpfFrq
			),
			ringFrq,
			ringDec,
			3
		).sin * 3,
		kickHpfFrq
	).tanh.madd(0.6);

	sig = krps + kick;
	// sig = sig * env * amp;
	sig = Mix.ar(sig) * env * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedKickSeqSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	sig = Ringz.ar(
		CoinGate.ar(
			[trgChance1, trgChance2, trgChance3],
			Impulse.ar([trgRate1, trgRate2, trgRate3])
		),
		[rFreq1, rFreq2],
		[rDec1, rDec2, rDec3, rDec4],
		[rAmp1, rAmp2, rAmp3, rAmp4]
	).sin.sum.tanh;
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMetalicSd, { arg out = 0, amp = 0.05, pan = 0, atk = 0.01, rls = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4],
		rDec
	).sum*2;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	);

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMetalic1Sd, { arg out = 0, amp = 0.05, pan = 0, atk = 0.01, rls = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rFreq5 = 1320, rFreq6 = 150, rDec = 0.7, revSize = 5, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4, rFreq5, rFreq6],
		rDec
	).sum;

	sig = GVerb.ar(
		sin(sig),
		revSize,
		revTime,
		revDamp
	)/2;

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedSoftRytmSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 2, impSigRate = 8, sawFreq = 3, impRevRate = 4, impRevPh = 0.5, blipFreq = 4.9, blipHarm = 7, blipAmp = 0.4, revSize = 1, revTime = 1, gate = 1, doneAction = 2;
	var sig, env, imp, rev;
	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
	imp = Impulse;
	sig = imp.kr(impSigRate).lag * Crackle.ar(LFSaw.kr(sawFreq).abs.lag * 1.8);
	rev = GVerb.ar(
		imp.kr(impRevRate, impRevPh).lag * Blip.ar(blipFreq, blipHarm, blipAmp),
		revSize,
		revTime
	) * 5;
	sig = sig + rev;
	sig = Mix.ar(sig * env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

)
