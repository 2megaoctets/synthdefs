~nVirgo = Synth(\nVirgo, [\out, 2, \amp, 0.015]);

~nVirgo.set(\amp, 0.17);

~nVirgo.set(\delayTime, rrand(0.05,0.69), \feedBack, rrand(0.02, 0.17), \decayTime, rrand(5,39), \amp, 0.1, \pan, 0);

~nVirgo.release(28);

~talters = Synth (\talters, [\out, 2, \amp, 0.05, \pan, 0]);

~talters.set(\pan, 0, \out, 2);

~talters.release(8);

~lmcd = Synth(\lmcd, [\amp, 0.4, \out, 2, \pan, 0, \att, 0.01, \rel, 10, \trigDur, 0.3, \lfCubTu, 0.8, \hpfFreq, 440]);

~lmcd.set(\amp, 0.3, \pan, rrand(-1, 1), \att, 0.1, \rel, rrand(1, 10), \trigDur, rrand(0.2, 0.740), \hpfFreq, 100);

~lmcd.release(11);


// ajouts 1906
~tirgo = Synth(\tirgo, [\out, 2, \amp, 0.1, \pan, 0, \att, 0.01, \rel, 5, \blipFreqMod, 2, \blipHarmo, 400, \brfFreq, 150, \brfRq, 2]);

~tirgo.set(\amp, 0.1, \pan, 0, \att, rrand(0.005, 0.2), \blipFreqMod, rrand(0.5,10), \blipHarmo, rrand(80,800), \brfFreq, rrand(120,680), \brfRq, rrand(0.1,2));

~tirgo.release(7);


~nozkurt=Synth(\nozkurt, [\out, 2, \amp, 0.06, \pan, 0, \att, 0.01, \rel, 5, \sinFreq, 55, \impMin, 0.0002, \impMax, 0.7, \impFreq, 8]);

~nozkurt.set(\amp, 0.06, \pan, 0, \att, rrand(0.001,0.1), \rel, rrand(1,4.5), \sinFreq, exprand(55,70) , \impMin, rrand(0.0002,0.001), \impMax, rrand(0.6,0.8), \impFreq, rrand(2,18));

~nozkurt.release(19);




~padovan=Synth(\padovan, [\out, 2, \amp, 0.025, \tridDur, 1, \freq, 165, \roomSize, 9]);

~padovan.set(\amp,0.025, \tridDur, rrand(0.15,0.91), \freq, rrand(20,365), \roomSize, 9);

~padovan.release(11);




(

SynthDef(\nVirgo, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 20, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, gate = 1, doneAction = 2;
	var sig, env;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
	// var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
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
	OffsetOut.ar(out, DirtPan.ar(sig * amp, ~dirt.numChannels, pan, env))
}).add;


// edit 08 03 22 : remplace Env.linen par Env.asr() ok
// rajouter des gate = 1 comme dans batuhan


SynthDef(\talters, { arg out = 0, pan = 0, amp = 1, gate = 1, doneAction = 2;
	var sig, env;
	// env = Linen.kr(gate, 0.01, 1, 10, doneAction);
	env = EnvGen.ar(Env.asr(0.01, 1, 10), gate, doneAction: doneAction);
	sig = ({
		|k|
		({
			|i|
			y = SinOsc;
			y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
		}!4).product
	}!8).sum;
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp))
}).add;

SynthDef(\bozkurt, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	//env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
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
	sig = Splay.ar(sig * env, 1, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\mcld, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 10, impFreq = 10, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, env, input;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
	input = LocalIn.ar.clip2(LFPulse.kr([1,2,1/8]).sum/2)**100*100;
	sig = DynKlank.ar(
		`[input],
		Impulse.ar(impFreq)
	);
	LocalOut.ar(sig);
	sig = HPF.ar(sig, hpfFreq).clip2;
	sig = Splay.ar(sig * env, level: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\padovan, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, roomSize = 9, gate = 1, doneAction = 2;
	var sig, env, input, mod, grainTr, sinMod;
	// env = Linen.kr(gate, 0.1, 1, 5, doneAction);
	env = EnvGen.ar(Env.asr(0,1, 1, 5), gate, doneAction: doneAction);
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

SynthDef(\batuhan, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, gate = 1, doneAction = 2;
	var sig, env, core;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
	core = Duty.kr(tridDur, 0, Drand([0, Drand((0.4,0.5..1))], inf));
	sig = Decay2.kr(
		core,
		0.01,
		decayTime
	);
	sig = Saw.ar(sawFreq, sig) ** 1.5;
	sig = BRF.ar(sig, core * 20 + [brfFreq1, brfFreq2], 0.1);
	sig = LeakDC.ar(sig).tanh * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\nozkurt, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	sig = sig * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\tirgo, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
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
	sig = sig * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lmcd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, gate = 1, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = sig * env;
	sig = Splay.ar(sig, 1, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

)