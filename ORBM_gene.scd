(
	///////////////////////////////////////  Generative

	SynthDef(\nvirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 20, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, doneAction = 2;
		var sig, env;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
	}).add;

	SynthDef(\taltersSd, { arg out = 0, pan = 0, amp = 1, doneAction = 2;
		var sig, env;
		// env = Linen.kr(gate, 0.01, 1, 10, doneAction);
		env = EnvGen.ar(Env.linen(0.01, 1, 10), doneAction: doneAction);
		sig = ({
			|k|
			({
				|i|
				y = SinOsc;
				y.ar(i*k*k, y.ar(i*k**i/[{4.rand}, {5.rand}]) * Decay.kr(Dust.kr(1/4**i), y.ar(0.1)+1*k+i, k*999))
			}!4).product
		}!8).sum;
		// OffsetOut.ar(out, sig * env * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
	}).add;

	SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, doneAction = 2;
		var sig, env, input, ctrl;
		//env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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
	}).add;

	SynthDef(\mcldSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 10, impFreq = 10, hpfFreq = 440, doneAction = 2;
		var sig, env, input;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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
	}).add;

	// new
	/*SynthDef(\rohrhuberSd, { arg out = 0, amp = 1, pan = 0, lfnFreq1 = 2, lfnFreq2 = 62, atk = 0.01, rls = 2, doneAction = 2;
		var sig, env;
		//env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
		Ndef(\x, {
			SinOsc.ar(
				BrownNoise.ar(30 ! 2, 200),
				Ndef(\x).ar * LFNoise1.kr([17, 4], 1, 1)
				)
			});
		sig = Ndef(\x) * LFNoise0.kr([lfnFreq1, lfnFreq2]) * env * amp;
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
		}).add;
	*/

	/* SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, roomSize = 9, doneAction = 2;
		var sig, env, input, mod, grainTr, sinMod;
		// env = Linen.kr(gate, 0.1, 1, 5, doneAction);
		env = EnvGen.ar(Env.linen(0,1, 1, 5), doneAction: doneAction);
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
	*/

	/*SynthDef(\batuhanSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, doneAction = 2;
		var sig, env, core;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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
	}).add;*/

	SynthDef(\lirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 1, gate = 1, doneAction = 0;
		var sig, env, bpf;

		env = Linen.kr(gate, atk, 1, rls, doneAction);
		//env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
		sig = Ndef('x', {
			sig = Ndef('x').ar + 0.01;
			bpf = BPF.ar(sig, 6 ** Latch.ar(sig, Dust.ar(sig)) * 150, 0.2).sin;
			4.do{
				bpf = AllpassN.ar(bpf, 0.2, {0.2.rand}!2, 9)
			};
			bpf + bpf.mean;
		});
		sig = sig * env * amp * 0.1;
		OffsetOut.ar(out, sig);
		// OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, doneAction = 2;
		var sig, env, delayTime;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
		sig = SinOsc.ar(sinFreq).tanh;
		delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
		sig = AllpassC.ar(sig, 1, delayTime, 2);
		sig = sig * env * amp;
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, doneAction = 2;
		var sig, noise, thunder, rainStep, env, delayTime;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
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

	SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, doneAction = 2;
		var sig, noise, thunder, rainStep, env, delayTime;
		// env = Linen.kr(gate, atk, 1, rls, doneAction);
		env = EnvGen.ar(Env.linen(atk, 1, rls), doneAction: doneAction);
		sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
		sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
		sig = LeakDC.ar(sig) * 9;
		sig = HPF.ar(sig, hpfFreq).clip2 / 9;
		sig = sig * env;
		sig = Splay.ar(sig, 1, amp);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\salledutempsSd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 4, tu = 1, dur = 9, gate = 1, doneAction = 2;
		var sig, rand, env;
		env = Linen.kr(gate, atk, 1, rls, doneAction);
		sig = {DynKlank.ar(`[((55/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(55/24))))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
		sig = sig * env;
		sig = Splay.ar(sig);
		// OffsetOut.ar(out, sig * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\salledutemps1Sd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 4, tu = 1, myst = 55, dur = 9, gate = 1, doneAction = 2;
		var sig, rand, env;
		env = Linen.kr(gate, atk, 1, rls, doneAction);
		sig = {DynKlank.ar(`[((myst/2)+ (tu + (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24)))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
		sig = sig * env;
		sig = Splay.ar(sig);
		// OffsetOut.ar(out, sig * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\cormanSd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
		var sig, rand, env;
		env = Linen.kr(gate, atk, 1, rls, doneAction);
		sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
		sig = sig * env;
		sig = Splay.ar(sig);
		// OffsetOut.ar(out, sig * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\corman1Sd, { arg out = 0, amp = 1, pan = 0, atk = 1, rls = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
		var sig, rand, env;
		env = Linen.kr(gate, atk, 1, rls, doneAction);
		sig = {DynKlank.ar(`[(tu + (tu * 52))/*Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98))))*/*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
		sig = sig * env;
		sig = Splay.ar(sig);
		// OffsetOut.ar(out, sig * amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\LiljedMystSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 4, pNoiseFreq = 5e-3, hpfFreq = 10, modDur = 9, lfnFreq = 0.05, ringFreq = 55, ringDec = 0.2, revSize = 70, revTime = 99, gate = 1, doneAction = 2;
		var sig, env;
		env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
		sig = HPF.ar(PinkNoise.ar(pNoiseFreq), hpfFreq) * Line.kr(0, 1, modDur);
		sig = GVerb.ar(
			({ |i|
				Ringz.ar(
					sig * LFNoise1.kr(lfnFreq + 0.1.rand),
					ringFreq * i + 60,
					ringDec
				)
			}!44).sum,
			revSize,
			revTime
		).tanh;
		sig = Mix.ar(sig * env);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\LiljedRainSd, { arg out = 0, amp = 0.6, pan = 0, atk = 0.01, rls = 2, nFrqR = 0.08, lfnFrqR1 = 0.3, lfnFrqR2 = 0.2, lpfR = 7000, hpfR = 400, revSizeR = 250, revTimeR = 100, revDampR = 0.25, dryLevR = 0.3, modDurR = 10, lfnFrqT1 = 3, lfnFrqT2 = 2, hpfT = 20, revSizeT = 270, revTimeT = 30, revDampT = 0.7, dryLevT = 0.5, modDurT = 30, gate = 1, doneAction = 2;
		var sig, env, rain, thunder;
		env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);

		rain = PinkNoise.ar(nFrqR + LFNoise1.kr(lfnFrqR1, 0.02));
		rain = rain + LPF.ar(Dust2.ar(LFNoise1.kr(lfnFrqR2).range(40, 50)), lpfR);
		rain = tanh(
			3 * GVerb.ar(
				HPF.ar(
					rain,
					hpfR
				),
				revSizeR,
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
			revSizeT,
			revTimeT,
			revDampT,
			drylevel: dryLevT
		) * Line.kr(0, 0.7, modDurT);

		sig = (rain + thunder) * env;
		sig = Mix.ar(sig);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

)
