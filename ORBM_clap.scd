(
///////////////////////////////////////  Clap

SynthDef(\clapSd, {| out=0, amp = 1, pan=0, q=0.1, fq=1, rnd1=0, rnd2=0, rnd3=0, gate=1, doneAction=2 |
	var env1, env2, noise1, noise2, sig;
	env1 = EnvGen.ar(\env1.kr(Env([0, 1, 0.5, 0.5, 0, 1, 0, 0.3, 0],	[0.001, 0.0013, 0, 0.01, 0, 0.001, 0, 0.03],[0, -3, 0, -3, 0, -3, 0, -4])),doneAction:2);
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

// SynthDef(\clappingSd, {arg out = 0, amp=0.5, pan = 0, atk = 0.01, rls = 1, atk = 0.003, rls = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, gate=1, doneAction=2;
// 	var env, signal, noise, hpf1, hpf2, fx;
// 	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
// 	hpf1 = RLPF.ar(noise, lpfFreq, rq);
// 	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
// 	env = EnvGen.kr(Env.perc(atk, rls));
// 	signal = (hpf1+hpf2) * env;
// 	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
// 	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
// 	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
// 	signal = (signal * (1 - delMix)) + (fx * delMix) ;
// 	signal = signal * EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
// 	// DetectSilence.ar(signal, doneAction: doneAction);
// 	// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
// 	OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
// }).add;

SynthDef(\clappingSd, {arg out = 0, amp=0.5, pan = 0, atkSig = 0.01, rlsSig = 1, atkEnv = 0.003, rlsEnv = 0.035, noiseAmp = 1, filterfreq=120, rq=0.1, sinAmpStart = 1, sinAmpEnd = 0.01, sinAmpDur = 4, lpfFreq = 400, hpfFreq = 120, delMix = 1, delTimeL = 0.03, delDecL = 0.031, delTimeR = 0.03016, delDecR = 0.06, gate=1, doneAction=2;
	var env, signal, noise, hpf1, hpf2, fx;
	noise = WhiteNoise.ar(noiseAmp)+SinOsc.ar([filterfreq/2,filterfreq/6 ], pi*0.5, XLine.kr(sinAmpStart, sinAmpEnd, sinAmpDur));
	hpf1 = RLPF.ar(noise, lpfFreq, rq);
	hpf2 = RHPF.ar(noise,  hpfFreq, rq/4);
	env = EnvGen.kr(Env.perc(atkEnv, rlsEnv));
	signal = (hpf1+hpf2) * env;
	fx = CombC.ar(signal, 0.5, delTimeL, delDecL)+CombC.ar(signal, 0.5, delTimeR, delDecR);
	// signal = FreeVerb.ar(signal, 0.1, 0, 0.5);
	// signal = Limiter.ar(signal, 0.7, 0.01) * amp;
	signal = (signal * (1 - delMix)) + (fx * delMix) ;
	signal = signal * EnvGen.kr(Env.linen(atkSig, 1, rlsSig), doneAction: doneAction);
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
var env, signal, atk, noise, hpf1, hpf2;
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

SynthDef(\oneclapThorBrSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.01, rls = 1, atkT = 0.003, rlsT = 0.00035, tone = 0.4, noiseAmp = 1, freq = 100, rq = 0.1,
	//Other Controls
	echohz1 = 33.333, echohz2 = 33.156, curve = -4, dcy = 0.06, shelfFreq = 7000, rs = 0.5, db = -3,
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

	env = Env.perc(attackTime: atkT, releaseTime: rlsT, curve: curve).kr;

	snd = Mix.ar(hpf1 + hpf2) * env;

	delay1 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz1, delaytime: 1/echohz1, decaytime: dcy / 2);

	delay2 = CombN.ar(in: snd, maxdelaytime: 1.1/echohz2, delaytime: 1/echohz2, decaytime: dcy);

	snd = FreeVerb.ar(in: Mix.ar(delay1 + delay2), mix: mix, room: size, damp: damp, mul: amp);

	snd = BHiShelf.ar(in: snd, freq: shelfFreq, rs: rs, db: db);

	snd = snd * EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
	// DetectSilence.ar(snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapySd, { arg out = 0, amp = 0.5, pan = 0, atk = 0.02, rls = 0.3, curve1 = 0, curve2 = (-4), hpf1 = 600, hpf2 = 1000, bpf1 = 2000, bpf2 = 1200, gain = 1.5, doneAction = 2;
	var env1, env2, sig, noise1, noise2;
	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [atk, rls], [curve1, curve2]), doneAction: doneAction);
	noise1 = BPF.ar(HPF.ar(GrayNoise.ar(env1), hpf1), bpf1, 3);
	noise2 = BPF.ar(HPF.ar(GrayNoise.ar(env2), hpf2), bpf2, 0.7, 0.7);
	sig = noise1 + noise2;
	sig = sig * gain;
	sig = 0.4 * sig.softclip * amp;
	// OffsetOut.ar(out, [sig,sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\clapGraySd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.25, curve = -4, spreadRate = 75, minDelay = 0.025, maxDelay = 0.05, dcy = 0.15, rq = 0.4, blend = 0.7, reverb = 0.1, size = 0.25, damp = 1, doneAction = 2;
	var env1, env2, snd, noise1, noise2, spread;

	//Multiple Shorter Claps
	spread = LFNoise1.kr(spreadRate).range(minDelay, maxDelay);

	env1 = Env.perc(attackTime: atk / 10, releaseTime: rls / 8, curve: [0, curve]).kr;
	env1 = CombC.ar(in: env1, maxdelaytime: maxDelay, delaytime: spread, decaytime: dcy);

	noise1 = GrayNoise.ar(env1); //Play with frequencies here:
	noise1 = RHPF.ar(in: noise1, freq: 1000, rq: rq);
	noise1 = BPF.ar(in: noise1, freq: 2000, rq: 3);

	//One Longer Clap
	env2 = Env.perc(attackTime: atk, releaseTime: rls, curve: [0, curve]).kr;

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

)
