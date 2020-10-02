(
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

	SynthDef(\IkedaHiNoiseSd, { arg out = 0, level = 10, pan = 0, atk = 0.02, dcy = 0.1, rq = 0.9, amp = 0.05, gate = 0, doneAction = 2;
		var noise, sig;
		noise = WhiteNoise.ar(Decay2.kr(gate, atk, dcy, amp));
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

	SynthDef(\hatYSd,{arg gate = 1, pan = 0, amp = 1, out = 0, rls = 0.1, doneAction = 2;
		var env = EnvGen.ar(Env.perc(0,rls), gate, doneAction: doneAction);
		var freq = EnvGen.ar(Env([12000,80,20000],[0.1,0.1]));
		var sig = PinkNoise.ar(env);
		sig = HPF.ar(sig,freq);
		// sig = Pan2.ar(sig.tanh, pan, amp);
		// OffsetOut.ar(out,sig*12);
		OffsetOut.ar(out, DirtPan.ar(sig.tanh*12, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\hatnewSd, {|out=0, amp=1, pan=0, freq=230, hpf=8500, rls=0.15, fxb=0, fxv=0, bbcb=0, bbcv=0, doneAction = 2|
		var pulse, sig, env, freqs;
		freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
		pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6, mul: 1));
		sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
		env = EnvGen.kr(Env.perc(0,rls), doneAction: doneAction);
		// sig =  Pan2.ar(sig*env, pan, amp);
		// OffsetOut.ar(out,sig);
		OffsetOut.ar(out, DirtPan.ar(sig*env, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\hat909Sd, {|out=0, amp=1, pan=0, envL1 = 0, envL2 = 0.98, envL3 = 0.12, envL4 = 0.9, envT1 = 0.2, envT2 = 0.01, envT3 = 0.32, envCurve = (-4), freq=230, hpf=6500, doneAction = 2|
		var pulse, sig, env, freqs;
		freqs = [freq, freq*1.4471, freq*1.617, freq*1.9265, freq*2.5028, freq*2.6637];
		pulse = Mix.ar(Pulse.ar(freqs, {0.9.rand}!6));
		sig = RHPF.ar(RHPF.ar(pulse, hpf), hpf);
		// env = EnvGen.kr(Env.perc(0,rls),doneAction:2);
		env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve).kr(doneAction: doneAction);
		sig = sig * env;
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\hat808Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, gate = 1, atk = 0.01, rls = 0.1;
		var sig;
		var env = EnvGen.ar(Env.perc(atk, rls),doneAction:2);
		sig = Saw.ar((1..9)*1000.23*env*tu);
		sig = RHPF.ar(sig, \hpf.kr(5700), \rq.kr(0.5));
		sig = sig * (1+EnvGen.ar(Env.perc((-0.1),\rel.kr(0.1),-4),gate))*tu;
		sig = Ringz.ar(sig,(10..15)*1000.234,1).mean;
		sig = RHPF.ar(sig, \lpf.kr(2000)*env*tu, \rq.kr(0.5));
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\hihatAwSd, {arg out = 0, amp = 0.5, pan = 0, atk = 0.01, rls = 0.2, ffreq = 6000, doneAction = 2;
		var snd = WhiteNoise.ar(amp);
		var env = Env.perc(atk, rls).kr(doneAction: doneAction);
		snd = HPF.ar(snd * env, ffreq);
		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\hihatElectroSd, { arg out = 0, pan = 0, amp = 0.3, atk = 0.001, rls = 0.3, curve = -8, filterFreq = 4010, rq = 0.56, doneAction = 2;
		var env, snd;

		// noise -> resonance -> exponential dcy envelope
		env = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).kr(doneAction: doneAction);

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

	SynthDef(\ikedhatSd,{arg out = 0, amp = 1, pan = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, atk= 0.0, rls = 0.01, timeScale = 1, hpf = 6000, gate = 1, doneAction = 2;
		var sig = HPF.ar(WhiteNoise.ar(1), hpf);
		var env = EnvGen.ar(Env([envLevel1, envLevel2, envLevel3], [atk, rls]), gate, levelScale, levelBias, timeScale, doneAction);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, env*amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env * amp));
	}).add;

	SynthDef(\fabHiSd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatk = 0.001, envNrls = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatk = 0.001, envSrls = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
		var noise, sin1, sin2, sig, env, envNoise, envSin;
		envNoise = EnvGen.kr(Env.perc(envNatk, envNrls), gate);
		envSin = EnvGen.kr(Env.perc(envSatk, envSrls), gate);
		noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
		sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
		sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
		sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
		env = Env.step([envL1, envL2, envL3], [envT1, envT2, envT3]).kr(doneAction: doneAction);
		sig = HPF.ar(sig * env, ffreq);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\fabHi1Sd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatk = 0.001, envNrls = 0.2, wbpfFreq = 2800, wbpfRq = 1, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatk = 0.001, envSrls = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, gate = 1, doneAction = 2;
		var noise, sin1, sin2, sig, env, envNoise, envSin, delay;
		envNoise = EnvGen.kr(Env.perc(envNatk, envNrls), gate);
		envSin = EnvGen.kr(Env.perc(envSatk, envSrls), gate);
		noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
		sin1 = SinOsc.ar(sinFrq1, sinPh1, sinLev1);
		sin2 = SinOsc.ar(sinFrq2, sinPh2, sinLev2);
		sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
		env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(doneAction: doneAction);
		sig = HPF.ar(sig * env, ffreq);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\fabHi2Sd, {arg out = 0, amp = 0.2, pan = 0, wamp = 0.5, envNatk = 0.001, envNrls = 0.2, wbpfFreq = 2800, wbpfRq = 1, lfo1Frq = 32, lfo1Amnt = 0, lfo2Frq = 64, lfo2Amnt = 0, sinFrq1 = 2120, sinFrq2 = 12423, sinPh1 = 0, sinPh2 = 0.02, sinLev1 = 1, sinLev2 = 1, envSatk = 0.001, envSrls = 0.2, mix = 0.5, envL1 = 0, envL2 = 1, envL3 = 0.75, envL4 = 0, envT1 = 0.1, envT2 = 0.02, envT3 = 0.2, ffreq = 6000, sustain=1, gate = 1, doneAction = 2;
		var noise, sin1, sin2, sig, env, envNoise, envSin, delay, lfo1, lfo2;
		envNoise = EnvGen.kr(Env.perc(envNatk, envNrls), gate);
		envSin = EnvGen.kr(Env.perc(envSatk, envSrls), gate);
		noise = BPF.ar(WhiteNoise.ar(wamp) * envNoise, wbpfFreq, wbpfRq.max(0.01));
		lfo1 = LFNoise0.ar(lfo1Frq, lfo1Amnt);
		lfo2 = LFNoise2.ar(lfo2Frq, lfo2Amnt);
		sin1 = SinOsc.ar(sinFrq1 * (lfo1 + 1), sinPh1, sinLev1);
		sin2 = SinOsc.ar(sinFrq2 * (lfo2 + 1), sinPh2, sinLev2);
		sig = XFade2.ar(noise, Mix.ar([sin1, sin2]) * envSin, mix);
		env = Env.new([envL1, envL2, envL3, envL4], [envT1, envT2, envT3]).kr(timeScale:sustain, doneAction: doneAction);
		sig = HPF.ar(sig * env, ffreq);
		// OffsetOut.ar(o ut, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out,DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\metroSd, {arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, impFreq=1, theta = 0.5, rho = 0.8, filterfreq=1000, rq=1.0, doneAction = 2;
		var env, signal, b1, b2;
		env = EnvGen.kr(Env.linen(atk, 1, rls), doneAction: doneAction);
		b1 = 2.0 * rho * cos(theta);
		b2 = rho.squared.neg;
		signal = SOS.ar(Impulse.ar(impFreq, 0, env), 1.0, 0.0, 0.0, b1, b2);
		signal = RHPF.ar(signal, filterfreq, rq);
		// OffsetOut.ar(out, Pan2.ar(signal, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\hatySd,{ arg out = 0, pan = 0, atk = 0.001, rls = 0.1, curve = (-4), amp = 0.75, doneAction = 2;
		var env, sig;
		env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
		sig = HPF.ar((WhiteNoise.ar(0.5, 0.5) * env * amp), 4000);
		// OffsetOut.ar(out, [sig,sig]);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\haty48Sd,{ arg out = 0, amp = 0.75, pan = 0, atk = 0, rls = 0.12, curve = (-4), envaL1 = 1.81, envaL2 = 0, envaL3 = 2.52, envaL4 = 0.85, envaL5 = 0, envaT1 = 0.01, envaT2 = 0.02, envaT3 = 0, envaT4 = 0, envaCrv = 3.54, envpL1 = 0, envpL2 = 16936, envpL3 = 1279, envpL4 = 0, envpT1 = 0, envpT2 = 0.33, envpT3 = 0, envpT4 = 0.53, envpCrv = (-0.64), modFreq = 1, modAmt = 1.4, sinfAdd = 1.7, sinPhase = 0.28, sinpAdd = 1.7, rf1Freq = 16938.8, rf1Rq = 0.26, rf2Freq = 765, rf2Rq = 0.62, hpfFreq = 3699, doneAction = 2;
		var mod, env, enva, envp, sig;
		env = EnvGen.kr(Env.linen(atk, rls, rls/2, 1, curve), 1, doneAction: doneAction);
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
)
