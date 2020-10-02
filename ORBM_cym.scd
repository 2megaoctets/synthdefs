(
	///////////////////////////////////////  Cymbal

	SynthDef(\cymSd, { arg out=0, amp=0.5, pan=0, atk=0, rls=1, curve=(-8), tu=1, doneAction=2;
		var sig;
		var env = EnvGen.ar(Env.perc(atk,rls,1,curve),doneAction: doneAction);
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

	SynthDef(\cymnewSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, rls = 4, curve = (-8), tu = 6, gate = 1, doneAction = 2;
	    var sig;
	    var env = EnvGen.ar(Env.perc(atk,rls,1,curve), gate, doneAction: doneAction);
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

	SynthDef(\cymbalicMcldSd, { |out=0, amp=0.5, pan=0, attLowf = 0.5, rlsLowf = 5, lowNoiseLev = 0.1, attHif = 1, rlsHif = 3, hiNoiseLev = 0.1, attHi = 1, rlsHi = 2, hiLev = 0.25, attTh = 0.001, rlsTh = 0.001, freq1 = 627, freq2 = 2961, freq3 = 7824, freq4 = 476, gate = 1, doneAction = 2|
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack, sig;

		locutoffenv = EnvGen.kr(Env.perc(attLowf, rlsLowf), gate, doneAction: doneAction) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(lowNoiseLev), locutoffenv);

		hicutoffenv = 10001 - (EnvGen.kr(Env.perc(attHif, rlsHif), gate, doneAction: doneAction) * 10000);
		hidriver = HPF.ar(WhiteNoise.ar(hiNoiseLev), hicutoffenv);
		hidriver = hidriver * EnvGen.kr(Env.perc(attHi, rlsHi, hiLev));

		thwack = EnvGen.kr(Env.perc(attTh,rlsTh), gate, doneAction: doneAction);

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

	SynthDef(\cymbal808Sd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.002, dcy = 0.25, rls = 0.05, freqMultiplier = 4.09, decLevel = 0.4, reverb = 0.33, size = 0.5, damp = 0.5, doneAction = 2;
		var snda, sndb, snd, env, pulseEnv, freqs;

		freqs = [205.35, 304.41, 369.64, 522.71, 540.54, 812.21];

		env = Env.new(
			levels: [0, 1, decLevel, 0],
			times: [atk, dcy, rls],
			curve: [0, -0.5, 0]
		).kr;

		pulseEnv = Env.new(
			levels: [1.0, 0.6],
			times: dcy,
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

)
