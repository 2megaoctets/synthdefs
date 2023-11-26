(

///////////////////////////////////////  Tonal

SynthDef(\cowSd, { arg out=0, amp=0.5, pan=0, att = 0.001, rel=1, tu=1, gate=1, doneAction=2;
	var sig;
	var env = EnvGen.ar(Env.asr(att,1,rel), gate, doneAction: doneAction);
	sig = LFPulse.ar(550*tu)+LFPulse.ar(tu*400*(env+250));
	sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\notesSd,{arg out = 0, amp = 0.5, pan = 0, att = 0.01, rel = 0.1, freq = 69, tu = 1, gate = 1, doneAction = 2;
	var env = EnvGen.ar(Env.perc(att, rel), gate, doneAction: doneAction);
	var sig = WhiteNoise.ar(env);
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,1)+sig;
	sig = CombL.ar(sig,0.2,(freq+(432.cpsmidi-69)).midicps/SampleRate.ir,0.2)+sig;
	sig = sig *env *0.5;
	sig = CompanderD.ar(sig*2,0.5,1,0.5);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\notes2Sd, { arg out = 0, amp = 0.5, pan = 0, notes = 68, at = 0.01, sus = 0.4, snd = 18, gate = 1;
	var env = EnvGen.ar(Env.adsr(at,1,sus,1.4),gate,doneAction:2);
	//var env = EnvGen.ar(Env.perc(0.01,1),gate,doneAction:2);
	var note = (notes+(432.cpsmidi-69)).midicps;
	var sig = Mix.ar(SinOsc.ar([note,note*2,note/2]));
	sig = Splay.ar(sig*0.1);
	// OffsetOut.ar(out,sig*env*0.5);
	// Out.ar(snd,sig*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\sinusSd,{arg out = 0, amp = 0.5, pan = 0, freq = 100, gate = 1, attack = 0, release = 0.1, lfo = 1, doneAction = 2;
	var env  = EnvGen.ar(Env.perc(attack,  release), gate, doneAction: doneAction);
	var sig = SinOsc.ar(freq+(432-69.midicps)*SinOsc.kr(lfo),0,env);
	sig = HPF.ar(sig,100);
	sig = CompanderD.ar(sig,0.3,0.3,1.5,0.0001,0.01);
	// sig = Pan2.ar(sig, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\prayerBellSd, { |out = 0, gate = 1, amp = 0.5, pan = 0, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

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
	DetectSilence.ar(sig, doneAction: i_doneAction);
	// sig = Pan2.ar(sig, pan, level);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\prayerBellBrSd, { arg out = 0, amp = 0.5, pan = 0, singSwitch = 0, freq = 2434, decayScale = 1, lag = 10, doneAction = 2;
	var snd, input, first, freqScale, mallet, sing;
	freqScale = freq / 2434;
	freqScale = Lag3.kr(freqScale, lag);
	decayScale = Lag3.kr(decayScale, lag);

	// mallet
	mallet = LPF.ar(
		in: Impulse.ar(0) ! 2 * amp,
		freq: 10000 * freqScale
	);

	// sing
	sing = LPF.ar(
		in: {PinkNoise.ar * Integrator.kr(singSwitch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp} ! 2,
		freq: 2434 * freqScale
	);

	sing = sing + Dust.ar(0.1);
	sing = LPF.ar(sing, 10000 * freqScale);
	sing = sing * LFNoise1.kr(0.5).range(-45, -30).dbamp;

	// input = mallet + sing
	input = mallet + (singSwitch.clip(0, 1) * sing);

	// resonant filter bank
	snd = DynKlank.ar(
		specificationsArrayRef: `[
			// Array of filter frequencies
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
			// Array of filter amplitudes
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
			// Array of filter decay times
			[
				20 * freqScale.pow(0.2),
				20 * freqScale.pow(0.2),
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
			] * freqScale.reciprocal.pow(0.5)
		],
		input: input,
		freqscale: freqScale,
		freqoffset: 0,
		decayscale: decayScale
	);

	DetectSilence.ar(snd, doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(Mix.ar(snd), pan));
	OffsetOut.ar(out, DirtPan.ar(Mix.ar(snd), ~dirt.numChannels, pan));
}).add;

SynthDef(\glockenspielSd, { arg out = 0, amp = 0.01, pan = 0, att = 0.001, rel = 6, freq = 440, exciterRel = 0.05, doneAction = 2;
	var env, snd, exciter;

	env = Env.perc(att, exciterRel, 0.25).kr;

	exciter = WhiteNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
			        [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
		        	[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rel
	);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\rissetBellSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 2, freq = 400, gate = 1, doneAction = 2;
	var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];
	var doneActionEnv = Env.linen(0, att+rel, 0).ar(gate: gate, doneAction: doneAction);
	var snd = Mix.fill(11, {arg i;
		var env = Env.perc(
			attackTime: att,
			releaseTime: rel * durs[i],
			level: amps[i],
			curve: att.explin(0.005, 4, -4.5, 0)
	).ar(gate: gate);
		SinOsc.ar(
			freq: freq * frqs[i] + dets[i],
			mul: amp * env
		);
	});
	snd = snd * doneActionEnv * 0.5;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosBellSd, { arg out = 0, amp = 0.1, pan = 0, freq = 440, rel = 2, curve = \lin,
	//ring Controls (wobbleDepth goes from 0 to 1)
	ringAmp = 1, ringRel = 0.9, wobbleDepth = 0.6, wobbleMin = 1, wobbleMax = 1.8,
	//strike Controls
	strikeAmp = 1, strikeDec = 0.01, strikeRel = 0.04, strikeDepth = 0.028, strikeHarmonic = 8,
	//hum Controls
	humAmp = 0.5, humAtt = 0.5, humDec = 0.5, humRel = 1,
	doneAction = 2;

	var snd, ring, ringEnv, ringFreqs, strike, strikeEnv, strikeMod, hum, humEnv;

	ringFreqs = [2, 3, 4.1, 5.43, 6.8, 8.21];

	ringEnv = Env.new(
		            levels: [1, 0.3, 0.2, 0],
		            times: [1/3, 1/3, 1/3] * ringRel * rel,
		            curve: curve).kr;

	ring = SinOsc.ar(
		            freq: ringFreqs * freq,
		            mul: Array.series(6, 1, -0.1) * ringEnv);

	ring = ring * LFTri.ar(
		            freq: {Rand(wobbleMin, wobbleMax)}.dup(6)).range((1 - wobbleDepth), 1);

	strikeEnv = Env.new(
		            levels: [1, 0.1, 0],
		            times: [strikeDec, strikeRel * rel],
		            curve: curve).kr;

	strikeMod = LFNoise1.ar(freq * 36).range(1/ (strikeDepth + 1), strikeDepth + 1);

	strike = SinOsc.ar(
                    freq: freq * strikeHarmonic * strikeMod,
		            mul: strikeEnv);

	humEnv = Env.new(
		            levels: [0, 1, 0.8, 0],
		            times: [humAtt, humDec, humRel * rel],
		            curve: curve).kr;

	hum = SinOsc.ar(
		            freq: freq * [1.01, 0.47],
		            mul: humEnv);

	snd = Mix.ar((ring * ringAmp) + (strike * strikeAmp) + (hum * humAmp)) * amp;

	DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tubularBellSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.005, rel = 9, freq = 440, exciterRel = 0.05, doneAction = 2;

	var env, snd, exciter;

	env = Env.perc(att, exciterRel, 0.05).kr;

	exciter = GrayNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48],   // harmonics
			        [1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25], // amplitudes
		        	[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rel
	);

	snd = LPF.ar(snd, freq * 9.5);

	DetectSilence.ar(
		        in: snd,
		        amp: 0.001,
		        time: 0.5,
		        doneAction: doneAction
		    );

	// OffsetOut.ar(out, Pan2.ar(snd, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\waveguideFluteSd, { arg out = 0, amp = 0.5, pan = 0, scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 1, doneAction = 2;

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq;

	// noise envelope
	kenv1 = EnvGen.kr(Env.new(
		[ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' )
	);
	// overall envelope
	kenv2 = EnvGen.kr(Env.new(
		[ 0.0, amp, amp, 0.0 ], [ 0.1, dur - 0.02, 0.1 ], 'linear' ), doneAction: doneAction
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 1, 1, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear') );

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( 5, 0, 0.1 * kenvibr );

	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;

	fdbckArray = LocalIn.ar( 1 );

	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );

	//ax = DelayL.ar( asum2, ifqc.reciprocal * 0.5, afqc * 0.5 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );

	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );

	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );

	fdbckArray = [ aflute1 ];

	LocalOut.ar( fdbckArray );

	signalOut = avalue;

	// OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );
	OffsetOut.ar(out, DirtPan.ar(signalOut, ~dirt.numChannels, pan, kenv2));
}).add;

SynthDef(\justwannahavefunSd,{|out= 0 amp = 0.1 pan=0 freq = 440 ringTime=10.0 |

	var impulse, filter, env;

  	impulse = Impulse.ar(0);

	filter = Ringz.ar(impulse,(freq.cpsmidi + (Rand(0.2,1.2)*SinOsc.kr(Rand(10,50)))).midicps,ringTime);

	env = EnvGen.ar(Env([0.0,1.0,1.0,0.0],[0.001,0.04,0.04]),doneAction:2);

	// OffsetOut.ar(out,Pan2.ar((filter.softclip(0.9))*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(filter.softclip(0.9), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\marimba1Sd, { arg out = 0, amp = 0.4, pan = 0, freq = 440;
	var snd, env;
	env = Env.linen(0.015, 1, 0.5, amp).kr(doneAction: 2);
	snd = BPF.ar(Saw.ar(0), freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	// OffsetOut.ar(out, Splay.ar(snd));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(snd), ~dirt.numChannels, pan));
}).add;

SynthDef(\kalimbaSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.001, freq = 44,
	// Mix control goes from 0 to 1
	mix = 0.1,
	// Release controls for different parts of the sound
	minRel = 2.5, maxRel = 3.5, clickRel = 0.01,
	doneAction = 2;

	var note, env, body, snd;

	env = Env.perc(att * 3, Rand(minRel, maxRel), 1, -8).kr(doneAction: doneAction);
	note = SinOsc.ar(freq) * env;
	body = DynKlank.ar(
		specificationsArrayRef:
		Ref.new([
			[240 * ExpRand(0.9, 1.1), 2020 * ExpRand(0.9, 1.1), 3151 * ExpRand(0.9, 1.1)],
			[-7, 0, 3].dbamp, // same as 10.pow([-7, 0, 3] / 20),
			[0.75, 0.04, 0.06] + clickRel
		]),
		input:
		// Try BrownNoise, GrayNoise, etc. here, but you may need to change ring times above
		(PinkNoise.ar * Env.perc(att, clickRel).kr)
	);
	snd = (note * (1 - mix)) + (body * mix) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pmCrotalesSd, { arg out = 0, amp = 0.2, pan = 0, att = 0, rel = 2, curve = -6, freq = 261, tone = 3, modLo = 5.25, modHi = 5.5;
	var env, snd, mod;

	env = Env.perc(attackTime: 0, releaseTime: rel, curve: curve).kr(doneAction: 2);

	mod = Rand(modLo, modHi);

	snd = PMOsc.ar(
	    	carfreq: freq,
	    	modfreq: mod * freq,
	    	pmindex: env * tone,
	    	mul: env * amp
	    );

	snd = HPF.ar(snd, freq / 2);

	snd = Mix.ar(snd);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\steelDrumSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 1.5, curve = -6, freq = 440, filterHarmonic = 6, doneAction = 2;
	var resFreqArray, resAmpArray, resDecArray, enva, envb, envc, snda, sndb, sndc, snd;

	//Arrays for the bank of resonators, mostly harmonics near 5ths and 9ths, and random amplitudes:
	resFreqArray = [2, 2.98, 4.75, 6.21, 9, 9.15, 11.87];
	resAmpArray = [0.35, 0.23, 0.10, 0.06, 0.07, 0.05, 0.01];
	resDecArray = [0.86, 0.72, 0.37, 0.55, 0.32, 0.21, 0.16];

	//Custom envelope shapes attempting to capture the aparrent "bloom" of a note:
	enva = Env.pairs([[0, 0], [att, 1], [(att + dec), 0]], curve).kr;
	envb = Env.pairs([[0, 0], [(att * 5), 0.25], [(att * 6), 0.75], [((att * 6) + (dec / 2)), 0]], curve).kr;
	envc = Env.pairs([[0, 0], [(att * 5), 0.1], [(att * 8), 0.5], [((att * 8) + (dec / 3)), 0]], curve).kr;

	//Fundamental, octave up, and a bank of enharmonic resonators excited by a metalic sound:
	snda = SinOsc.ar(freq: freq, mul: enva);
	sndb = SinOsc.ar(freq: freq * 2.015, mul: envb);
	sndc = DynKlank.ar(
		specificationsArrayRef:
		    Ref.new([
		    	resFreqArray * freq,
		    	resAmpArray,
			    resDecArray * dec
		    ]),
		input:
		LPF.ar(HPF.ar(CombN.ar(PinkNoise.ar(1), 1/freq, 1/freq, -1, envc), freq * 2), freq * filterHarmonic)
	);

	//Output stages with a tiny bit of compression to smooth things out:

	snd = Mix.ar([snda, sndb, sndc]) * (amp / 3);
	snd = Limiter.ar(snd, amp);
	DetectSilence.ar(in: snd, amp: 0.0001, time: 0.5, doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\noisyToneSd, { arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ping_mhSd,{arg out=0, amp=0.2, pan=0, freq=440, dur=0.1, attack=0.001;
    var sig, freq2;
    freq=freq*rrand(1,1.01);
    freq2=freq*rrand(1,1.01);
	e=EnvGen.ar(Env.perc(attack,dur.max(0.01),curve:-4),doneAction:2);
    sig=SinOsc.ar([freq,freq2],0,amp*e);
    // sig=Pan2.ar(sig,pan);
    // OffsetOut.ar(out,sig)
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\pluckingSd, {arg out = 0, amp = 0.1, pan = 0, freq = 440, decay = 5, coef = 0.1;
	var env, snd;
	env = EnvGen.kr(Env.linen(0, decay, 0), doneAction: 2);
	snd = Pluck.ar(
		in: WhiteNoise.ar(amp),
		trig: Impulse.kr(0),

		maxdelaytime: 0.1,
		delaytime: freq.reciprocal,
		decaytime: decay,
		coef: coef);
	// OffsetOut.ar(0, [snd, snd]);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pwmblingSd, { |out= 0 amp = 0.1 pan = 0.0 freq = 440 lforate = 4.85 lfowidth= 0.5 cutoff= 12000 rq=0.25 gate=1|

	var lfo, pulse, filter, env;
	var basefreq =  ((freq.cpsmidi)+[0,12.12]).midicps;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

	pulse = Pulse.ar(basefreq,lfo*lfowidth+0.5);

	env = EnvGen.ar(Env.adsr(0.0,1.0,0.2,1.5),gate,doneAction:2);

	filter = RLPF.ar(pulse,(cutoff*(env.squared))+100,rq);

	// OffsetOut.ar(out,Pan2.ar(Mix(filter)*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(Mix(filter), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\ressquaresSd,{|out= 0 amp = 0.1 pan=(-0.1) freq = 440 cutoff=8000 rq=0.8 gate=1|

	var pulse, filter, env;

	//2 cents detune for second oscillator
	pulse = Mix(Pulse.ar( ((freq.cpsmidi)+[0,0.02]).midicps, 0.5))*0.5;

	filter =  BLowPass.ar(pulse,100+cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.002,0.1,1.0,0.2),gate,doneAction:2);

	// OffsetOut.ar(out,Pan2.ar(filter*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\glaukSd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 2, freq = 100, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = Splay.ar(
		SinOsc.ar(
			Array.fill(20,{arg i; freq+i; })
		)
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\scintySd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 10, gate = 1, doneAction = 2;
	var sig, env;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = Splay.ar(
		Array.fill(15,{Ringz.ar(Dust.ar(Rand(1,10)), Rand(50,9000).round(100), 2)},
			1,
			0.5,
			0
		)
	);
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bublybubSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, x = 165, gate = 1, doneAction = 2;
	var sig, env, waveForm, freq, dur, input;
	// env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	waveForm = SinOsc;
	freq = Trig.ar(Saw.ar(x),1);
	dur = waveForm.ar(freq * x);
	input = waveForm.ar(freq);
	sig = GVerb.ar(GrainIn.ar(2,dur,dur/2,input,freq*input,-1),9);
	sig = sig * env;
	//OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\chdegaulleaboutSd, { arg out = 0, amp = 1, pan = 0, freq = 0.01, attack = 0.01, release = 10, gate = 1, doneAction = 2;
	var sig, env;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = SinOsc.ar(LFNoise1.kr(freq).exprange(100,{exprand(300,10000)}!120)).mean;
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\t2001Sd, { arg out = 0, amp = 1, pan = 0, gate = 1, attack = 0.01, release = 0.8, sustain = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.perc(attack, release), timeScale: sustain, doneAction: doneAction);
	// env = Linen.kr(gate, attack, sustain, release, doneAction);
	sig = PinkNoise.ar(1);
	20.do{
		sig = BBandStop.ar(sig, LFNoise1.kr(0.05.rand).exprange(40,15000), exprand(0.1,2));
	};
	sig = sig * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\claudTweetSd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 10, gate = 1, doneAction = 2;
	var sig, env, x;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = LFTri.ar(
		Duty.ar(Dseq([3,1]/12,inf),
			0,
			Dseq(
				x = (3..6);
				allTuples(x/.t x).flat*[100,200,400]++0
			)
		)
	);
	sig = GVerb.ar(sig, 25, 5)/5;
	sig = sig * env;
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\ambitekSd, { arg out = 0, amp = 0.5, pan = 0, attack = 0.01, release = 10, envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, gate = 1, doneAction = 2;
	var sig, env, envS;
	//env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	env = Linen.kr(gate, attack, 1, release, doneAction);
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
	sig = sig * env;
	// OffsetOut.ar(out, sig!2 * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\mainSd, { arg out = 0, amp = 0.5, pan = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sinFreq = 30, sel = 0, envLevel1 = 0.0, envLevel2 = 1.0, envLevel3 = 0.0, levelScale = 1, levelBias = 0, att = 0.0, rel = 0.1, timeScale = 1, noiseAmp = 1, hpf = 8000, revtime = 3, damp = 0.5, revMix = 0, gate = 1, doneAction = 2;
	var revSig;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 600] + fmod, 0, [lev, 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpf),
		SinOsc.ar(sinFreq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];
	var env = EnvGen.kr(Env.new([envLevel1, envLevel2, envLevel3], [att, rel]), gate, levelScale, levelBias, timeScale, doneAction);
	sig = (Select.ar(sel, sig) * env).fold(-1, 1) * 0.7 + SinOsc.ar(40, 0, 0.3) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpf));
	revSig = GVerb.ar(sig, 10, revtime, damp);
	sig = SelectX.ar(revMix, [sig, revSig]);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\flashSd, { arg out = 0, amp = 0.3, pan = 0, fund = 400, decay = 4, filter = 1, doneAction = 2;
	var sig;
	sig = Mix.ar( Array.fill(7,
		{
			arg counter;
			var partial;
			partial = counter + 1;
			SinOsc.ar(fund*partial) * EnvGen.kr(Env.linen(0, 0, decay), levelScale: 1/(partial*filter)
			) * max(0, LFNoise1.kr(rrand(5.0, 12.0)));
		}
	)
	);
	sig = Pan2.ar(sig, Rand(-1.0, 1.0), amp);
	DetectSilence.ar(sig, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\elifmSd, { arg out = 0, freq = 500, mRatio = 1, cRatio = 1, index = 1, iScale = 5, amp = 0.2, atk = 0.01, rel = 3, cAtk = 4, cRel = (-4), pan = 0;
    var car, mod, env, iEnv;
    iEnv = EnvGen.kr(
        Env.new(
            [index, index * iScale, index],
            [atk, rel],
            [cAtk, cRel]
        )
    );
    env = EnvGen.kr(
        Env.perc(atk, rel, curve: [cAtk, cRel]),
        doneAction: 2
    );
    mod = SinOsc.ar(freq * mRatio, mul: freq * mRatio * iEnv);
    car = SinOsc.ar(freq * cRatio + mod) * env * amp;
    // car = Pan2.ar(car, pan);
    // OffsetOut.ar(out, car);
	OffsetOut.ar(out, DirtPan.ar(car, ~dirt.numChannels, pan));
}).add;

SynthDef(\polishFabSd, { arg out = 0, amp = 0.3, pan = 0, attack = 11, release = 6, feedBack = 2, phmodFrq = 0.5, freq1 = 64, freq2 = 23, envfL1 = 0, envfL2 = 500, envfL3 = 20, envfL4 = 0, envfT1 = 0.2, envfT2 = 0.01, envfT3 = 0.12, envfCure = (-4), frqScale = 0.5, gate = 1, doneAction = 2;
	var sig, env, envf, num, input;
	num = 8;
	input = LocalIn.ar(2) * feedBack;
	envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4], [envfT1, envfT2, envfT3], envfCure), gate) * frqScale;
	sig = Mix.arFill(
		num,
		{ arg i;
			var oddHarm = i * 2 + 1;
			var evenHarm = i * 2 + 2;
			SinOsc.ar(
				[freq1 * oddHarm, freq2 * evenHarm] + envf,
				Latch.kr((input * (i + 1)) * pi, Impulse.kr((oddHarm / (3 * pi)) + phmodFrq)),
				num.reciprocal
			)
			*
			EnvGen.kr(
				Env.sine(num / i)
			)
		}
	);
	env = EnvGen.kr(
		Env.perc(attack, release),
		gate,
		doneAction: doneAction,
		levelScale: 0.75
	);
	sig = (sig[0] + sig[1]) * env;
	LocalOut.ar(sig);
	sig = Splay.ar(sig, 1, amp);
	// OffsetOut.ar(out, sig /** amp*/);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\slatechreSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 3, gate = 1, doneAction = 2;
	var env, note, snd, delaytime, damp, size, diff, feedback, localout;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	note = Demand.kr(Impulse.kr(0) + Dust.kr(0.1), 0, Diwhite(60, 80, inf));
	delaytime = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(0.1, 0.3, inf));
	damp = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.2, 0.6, inf));
	size = Demand.kr(Impulse.kr(0) + Dust.kr(0.3), 0, Dwhite(2, 10, inf));
	diff = Demand.kr(Impulse.kr(0) + Dust.kr(0.2), 0, Dwhite(0.5, 1.0, inf));
	feedback = Demand.kr(Impulse.kr(0) + Dust.kr(0.4), 0, Dwhite(0.8, 1.0, inf));
	snd = SinOsc.ar(freq: [note, note+LFNoise1.kr(freq: 0.1).range(-0.25, 0.25)].midicps);
	localout = Mix.ar(3.collect({ |i|
		Pan2.ar(
			in: PitchShift.ar(in: snd, pitchRatio: i),
			pos: LFNoise1.ar(freq: TRand.ar(10.reciprocal, 1, Impulse.kr(8.reciprocal))).range(-1,1),
			level: (i+1).reciprocal
		) * -20.dbamp;
	}));
	localout = Compander.ar(in: localout, control: localout, thresh: -6.dbamp, slopeAbove: 3.reciprocal);
	LocalOut.ar(localout);
	snd = LocalIn.ar(2) * feedback;
	// OffsetOut.ar(out, (localout.tanh * env) * amp);
	OffsetOut.ar(out, DirtPan.ar(localout.tanh, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\ColleenSd, { arg out = 0, amp=1, pan = 0, atk=0.35, rel=2, freq=110, doneAction = 2;
	var sig, env;
	freq = 1*freq*(320/250)*PinkNoise.kr(0.05,1)*BrownNoise.kr(0.01,1)*2;
	sig = LPF.ar(CombC.ar(Decay.ar(Impulse.ar(0), 0.2, BrownNoise.ar), 4/(BrownNoise.kr(XLine.kr(10,1,0.2),freq)), 4/(PinkNoise.kr(XLine.kr(10,1,0.2),freq)), 3, 0.4),4000);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]),doneAction: doneAction);
	sig = sig + PinkNoise.ar(0.1);
	sig = LPF.ar(sig, XLine.kr(100,700,rel*0.1));
	sig = (sig*env*amp)*4;
	// sig = Pan2.ar(sig,pan);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\zeynepSd, { arg out = 0, amp=1, pan = 0, freq=440, envL1 = 0, envL2 = 0.03, envL3 = 0.1, envL4 = 0.2, envL5 = 0, envT1=1, envT2=1, envT3=4, envT4=0.2, dur = 1, beats=1, lpf = 9200, hpf = 60, doneAction = 2;
	var sig, env;
	sig = Resonz.ar(WhiteNoise.ar(0.5), freq, XLine.kr(0.1, 0.001, dur*beats))*50;
	env = EnvGen.kr(Env.new([envL1,envL2,envL3,envL4,envL5],[envT1,envT2,envT3,envT4],[1,-1]),doneAction: doneAction);
	sig = LPF.ar(sig, lpf);
	sig = HPF.ar(sig, hpf);
	sig = (sig*env*amp).tanh;
	// OffsetOut.ar(out, [sig, sig]);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sosTomSd, { arg out = 0, amp = 0.6, pan = 0, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, att = 0.005, curve = -6, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, snd;

	drumModeEnv = Env.perc(
		            attackTime: att,
		            releaseTime: drumRel,
		            level: 0.5,
		            curve: curve).kr(doneAction: doneAction);

	drumMode = PMOsc.ar(
		            carfreq: Saw.ar(freq: freq * 0.9),
					modfreq: freq * 0.85,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: att, releaseTime: stickRel, level: 3, curve: curve).kr;

	snd = Mix.ar(drumMode + stickEnv) * amp;

	snd = LeakDC.ar(snd);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\beatingSd, { arg out = 0, amp = 0.1, pan = 0, att = 0.01, dec = 1, freq = 440, curve = -4, beatFreq = 15, doneAction = 2;

	var env, snd, oscillator1, oscillator2;

	env = Env.perc(att, dec, amp, curve).kr(doneAction: doneAction);

	oscillator1 = SinOsc.ar(freq); //Try other waveforms for the oscillators! Mix and match, collect them all!
	oscillator2 = SinOsc.ar(Line.kr(freq + beatFreq, freq, dec));

	snd = Mix([oscillator1, oscillator2]);
	snd = snd * env;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\blip1Sd, {arg out = 0, amp = 0.1, pan = 0, att = 0.01, rel = 1, freq = 25, numharm = 10, doneAction = 2;
	var snd, env;
	env = Env.perc(att, rel, amp).kr(doneAction: doneAction);
	snd = Blip.ar(
		freq: freq * [1, 1.01],
		numharm: numharm,
		mul: env
	);
	snd = LeakDC.ar(snd);
	snd = Mix.ar(snd);
	// snd = Pan2.ar(snd, pan);
	// OffsetOut.ar(out, snd);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\laserbeamSd, { arg out = 0, amp = 0.6, pan = 0.0, freq = 40, att = 0.01, doneAction = 2;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [att, 0.01, 1.0]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
		levelScale: amp,
		doneAction: doneAction);
	snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\ping_mhSd,{ arg out = 0, amp = 0.2, pan = 0, att = 0.001, dur = 1, curve = -4, freq = 90, rate = 4, depth = 0.03, doneAction = 2;
	var snd, lfo, env;

	lfo = LFNoise2.ar(rate).range(1 / (1 + depth), (1 + depth));

	env = Env.perc(attackTime: att, releaseTime: dur, level: amp, curve: curve).kr(doneAction: doneAction);

	snd = SinOsc.ar(freq: [freq, freq * lfo], mul: env);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pulseRissetSd, {arg out = 0, amp = 0.1, pan = 0, att = 0.01, rel = 11, freq = 440, pulseFreq = 8;
    var partials, durs, amps, snd, env;
 	partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
	partials = (partials / 440) * freq; // consider 440 the 'root'
	durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
	amps = durs.linlin(1, 11, 0.2, 1);

	env = Env.perc(
		attackTime: att,
		releaseTime: durs * rel,
		level: amps
	).kr(doneAction: [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // only longest env gets doneAction: 2

	snd = Pulse.ar(partials) * env * amp / 11;

	snd = RLPF.ar(
		in: snd,
		freq: freq * LFPulse.ar(pulseFreq).range(2, 4),
		rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3)
	);

	snd = LPF.ar(snd, 12000);
	snd = Limiter.ar(Mix.ar(snd));

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\pitchTrackSynthIxiSd, {arg in = 0, out = 0, pan = 0, att = 0.51, dec = 0.52, sus = 1, rel = 0.51, curve = (-4);
	var sig, env, input, amp, freq, hasFreq;

	// the audio input
	// input = SoundIn.ar([in, in+1]);
	input = InFeedback.ar(in, 2);
	amp = Amplitude.kr(in, 0.25, 0.25);

	// the pitch variable and the hasFreq (Pitch.kr returns a list like this [freq, hasFreq])
	# freq, hasFreq = Pitch.kr(input, ampThreshold: 0.2, median: 7);

	// when the hasFreq is true (pitch is found) we generate a ADSR envelope that is open until
	// the hasFreq is false again or the amplitude is below the ampThreshold of the Pitch.
	env = EnvGen.ar(Env.adsr(att, dec, sus, rel, 1, curve), gate: hasFreq);

	// we plug the envolope to the volume argument of the Sine
	sig = SinOsc.ar(freq, 0, env * amp)/* ! 2*/;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\pitcherIxiSd,{ arg out = 0, in = 0, pan = 0, threshold = 0.5, lpf = 2000;
	var input, amp, freq, hasFreq, sig, gate;

	// input = SoundIn.ar([in, in + 1]);
	input = InFeedback.ar(in, 2);

	// using a LowPassFilter to remove high harmonics
	input = LPF.ar(Mix.new(input), lpf);
	amp = Amplitude.kr(input, 0.25, 0.25);

	// # freq, hasFreq = Pitch.kr(input, ampThreshold: 0.1, median: 7);
	# freq, hasFreq = Tartini.kr(input); // Tartini performs better than Pitch

	gate = Lag.kr(amp > threshold, 0.01);

	// sig = VarSaw.ar(freq, 0, 0.2, amp*hasFreq*gate);

	// 3 sines (octave lower, pitch and octave higher mixed into one signal
	sig = Mix.new(SinOsc.ar(freq * [0.5,1,2], 0, 0.2 * amp*hasFreq*gate));
	6.do({
		sig = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\sin_pulsarSd, { arg out = 0, pan = 0, doneAction = 2;
    var a, b, c, d, e, f, f_, fund, t, lev, formantA, formantB, overlapA, overlapB;
    lev = \lev.kr(0.3);
    f = \freq.kr(440);
    f_ = f.clip(50, 1500);
    formantA = \formantA.kr(2);
    formantB = \formantB.kr(6);
    overlapA = \overlapA.kr(2);
    overlapB = \overlapB.kr(2);

    e = EnvGen.kr(
        Env.perc(
            attackTime: f_.linlin(50, 1500, 0.1, 0.02),
            releaseTime: Rand(1, 7)
        ),
        gate: \gate.kr(1)
    );

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    fund = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f),
        dur: Rand(0.5, 2) * (1.05 - e.pow(1.1))
        // Rand(0.5, 2) * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * SinOsc.ar(e * 3, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    a = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapA * (1.05 + e.pow(1.5))
        // overlapA * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantA * SinOsc.ar(e * 4, {Rand(0, 6.28)}.dup).range(0.9, 1.1))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    b = GrainSin.ar(
        numChannels: 1,
        trigger: Impulse.ar(f + Rand(-3, 3)),
        dur: overlapB * (1.05 + e.pow(2.5))
        // overlapB * (0.05 + e.pow(1.1))
        * SinOsc.ar(e * 6, {Rand(0, 6.28)}.dup).range(0.87, 1.15)
        / f,
        freq: f
        * (formantB * SinOsc.ar(e * 5, {Rand(0, 6.28)}.dup).range(0.9, Rand(1, 1.5)))
        ,
        pan: PinkNoise.ar(0.5!2)
    );

    c = Mix([
        fund * (lev * e).pow(0.7),
        a * (lev * e).pow(f_.linlin(50, 1500, 1.1, 1.5)),
        b * (lev * e).pow(f_.linlin(50, 1500, 1.5, 2.5))
    ]);

    c =LeakDC.ar(c);

    d = c;

    4.do{ arg i;
        d = AllpassC.ar(
            d,
            delaytime: LFNoise1.kr(0.2!2).range(0.01, 0.02)
        )
    } *0.5;

    d = c * Rand(0.1, 0.9) + d;

    DetectSilence.ar(d, doneAction: doneAction);
    // Out.ar(out, d);
	OffsetOut.ar(out, DirtPan.ar(d, ~dirt.numChannels, pan));
}).add;

SynthDef(\fm_pulsarSd, { arg out = 0, pan = 0, doneAction = 2;
    var a, e, f;
    var t, overlap, carfreq, modfreq, mInd, vel, vel_;

    f = \freq.kr(100);
    f = f + SinOsc.ar(LFNoise1.kr(0.3!2).range(1, 4));

    vel = \vel.kr(0.5);
    vel_ = vel.clip(0, 1.0).linlin(0, 1, 2, 0.7);

    e = EnvGen.kr(
        Env.adsr(
            \att.kr(0.025) * vel_,
            \dec.kr(0.02) * vel_,
            \sus.kr(0.7),
            \rel.kr(4),
            curve: \curve.kr(-4)
        ),
        gate: \gate.kr(1),
        doneAction: doneAction
    ) * vel;

    e = e * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02);

    carfreq = f * \cf.kr(2) + LFNoise1.kr(3).range(0, 50);
    modfreq = carfreq * \mf.kr(2) + LFNoise1.kr(3).range(0, 100);

    t = Impulse.ar(f);
    mInd = e.pow(3.3) * LFNoise2.kr(5!2).range(\mIndMin.kr(0.1), \mIndMax.kr(2.3));
    overlap = 1.1 - e.pow(0.5) * LFNoise1.kr(0.3!2).range(\olapMin.kr(1), \olapMax.kr(8));
    d = overlap/f;

    a = Mix([
        SinOsc.ar(f),
        GrainFM.ar(1, t, d, carfreq, modfreq, mInd)
    ]);

    a = LeakDC.ar(a * e);
    // OffsetOut.ar(out, a * \gain.kr(0.1));
	OffsetOut.ar(out, DirtPan.ar(a * \gain.kr(0.1), ~dirt.numChannels, pan));
}).add;

SynthDef(\pm4Sd, {

    var numops = 4;
    var fb = LocalIn.ar(numops);

    var gate = \gate.kr(1);
    var in_freq = \freq.ar(261).lag(\glis.kr(0));
    var bend = \bend.ar(0).midiratio;
    var freqbend = in_freq * bend;
    var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.000));
    var detunehz = \detunehz.kr(0);
    var vel = \vel.kr(1);

    var car = numops.collect({arg i;
        var num = i+1;
        var ratio = ('op' ++ num ++ 'ratio').asSymbol;
        var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
        var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
        var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
        var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
        var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
        var env = Env.adsr(
            attackTime:atk,
            decayTime:dec,
            sustainLevel:suslevel,
            releaseTime:rel,
            curve:curve
        ).kr(gate:gate);

        [freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
    });

    var mods = numops.collect({arg i;
        var y = i + 1;
        numops.collect({arg j;
            var x = j + 1;
            var key = ('m' ++ y ++ '_' ++ x).asSymbol;
            key.kr(0);
        });
    });

    var sig = numops.collect({arg i;
        var num = i+1;
        var freq = car[i][0].clip(20, 20000);
        var index = mods[i];
        var mod = (fb * index).sum;
        var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
        var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(-1, 1);
        sig = OnePole.ar(sig, coef);
        sig;
    });

    sig = LeakDC.ar(sig);

    LocalOut.ar(sig);

    // set output level
    sig = sig * numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num).asSymbol;
        key.kr(1);
    }).normalizeSum;

    // set panning
    sig = numops.collect({arg i;
        var num = i + 1;
        var key = ('op' ++ num ++ 'pan').asSymbol;
        Pan2.ar(sig[i],    key.kr(0),    1)
    }).sum;

    sig = BLowPass.ar(
        BHiPass.ar(sig,
            \hpf.kr(20).clip(20, 18000),
            \hpfres.kr(0).linlin(0, 1, 1, 0.001)
        ),
        \lpf.kr(20000).clip(20, 20000),
        \lpfres.kr(0).linlin(0, 1, 1, 0.001)
    );

    sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
    sig = sig.softclip;
    DetectSilence.ar(sig, doneAction: \doneAction.ir(2));

    // Out.ar(\out.kr(0), sig);
	OffsetOut.ar(\out.kr(0), DirtPan.ar(sig, ~dirt.numChannels, \pan.kr(0)));

}).add;

SynthDef(\sawFiltKymaSd, { |out = 0, amp = 0.1, pan = 0, freq = 440, cf = 100, wobble = 3, t_bd, t_sd, pw = 0.4, gate = 1, doneAction = 2|
    var base = Splay.ar(RLPF.ar(Pulse.ar(freq * [0.99,0.5,1.01],pw),cf.lag(0.05),0.3).madd(SinOsc.ar(wobble).range(0.5,4)).sin) * 0.5;
    var env = Linen.kr(gate, attackTime: 0.01, releaseTime: 0.5, doneAction: doneAction);
    var sig = base;
    var bd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_bd,SampleDur.ir),1000),30,0.5,5).sin*2);
    var sd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_sd,SampleDur.ir),1000),120,0.75,PinkNoise.ar(2!2)).sin*2);
    sd = HPF.ar(sd,60);
    sig = tanh(GVerb.ar(HPF.ar(base * env,30), 70, 11, 0.15)*0.5 + sig + bd + sd);
	// Out.ar(out, sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig*amp*env, ~dirt.numChannels, pan));
}).add;

SynthDef(\s1Sd, {
	var pan = \pan.kr(0);
    var freq = \freq.kr(220);
    var cutoff = \cutoff.kr(100);
    var fvel = \fvel.kr(8);
    var res = \res.kr(0.5).linlin(0, 1, 1, 0.001);
    var aeg = Env.asr.ar(doneAction:Done.freeSelf, gate:\gate.kr(1));
    var sig = RLPF.ar(Saw.ar(freq), aeg.linlin(0, 1, cutoff, cutoff * fvel), res);
    sig = sig * aeg * \amp.kr(0.3);
    sig = Splay.ar(sig);
	OffsetOut.ar(\out.kr(0), DirtPan.ar(sig , ~dirt.numChannels, pan));
}).add;

SynthDef(\fakeResSd, {
    arg  out = 0, pan = 0, freq = 200, peamount = 900,
    pitchAtt = 0.001, pitchDec = 0.13,
    ampAtt = 0.03, ampDec = 1.0, level = 0.5, doneAction = 2;

    var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;

    pitchenv = EnvGen.ar(
        // Env([0, 1, 0], [pitchAtt, pitchDec], [0, 0])  // original
        Env([0, 1, 0], [pitchAtt, pitchDec],  \squared)
        // Env([0, 1, 0], [pitchAtt, pitchDec],  \cubed)
    );

    ampenv = EnvGen.ar(
        Env([0, 1, 0], [ampAtt, ampDec], [0, 0]),
        levelScale: level,
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
    sig = sig * ampenv ! 2;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\windowsyncSd, { |out = 0, pan = 0, frq = 65.40639132515, amp = 0.1,
    syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, gate = 1, doneAction = 2|
    var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
    var eg = EnvGen.kr(Env.adsr(0.01, 0.3, 0.6, 0.1), gate, doneAction: doneAction);
    var fundamental = LFTri.ar(frq);
    var syncFreq = frq * syncRatio * syncEg;
    // note, Phasor here is behaving like the Sweep above (retrigger behavior)
    // but Phasor loops around its range, eliminating the need for '% 1'
    var syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
    var sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;
    // OffsetOut.ar(out, (sig * (amp * eg)).dup);
	OffsetOut.ar(out, DirtPan.ar(sig * (amp * eg), ~dirt.numChannels, pan));
}).add;

SynthDef(\danUkSd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.3, sustain = 1, curve = (-4), envPow = 1, globalEnvNoise = 0.3, globalEnvInv = 0, sawFreq = 50, r = 12, doneAction = 2;
	var phi, x, y, sig, globalEnv, envShape;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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

SynthDef(\markSamFellSd,{ arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 8, sus = 1, crv = (-4), trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, harm1 = 0, harm2 = 2, harm3 = 4, harm4 = 5, harm5 = 7, harm6 = 9, harm7 = 10, plkDec = 0.9, plkCoeff = 0.5, filtFreqMin = 500, filterFreqMax = 16000, doneAction = 2;
    var env, trig, sig, freqs;

	env = EnvGen.kr(Env.perc(atk, dcy, 1, crv), timeScale: sus, doneAction: doneAction);

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));
    freqs = (tu + [harm1, harm2, harm3, harm4, harm5, harm6, harm7]).midicps;
    sig = Pluck.ar(Hasher.ar(Sweep.ar(trig)) * -10.dbamp, trig, freqs.reciprocal, freqs.reciprocal, plkDec, plkCoeff.min(1).max(-1));
    sig = LeakDC.ar(sig).sum;
    sig = MoogFF.ar(sig, LFNoise2.kr(1).linexp(-1, 1, filtFreqMin, filterFreqMax));
	/*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\markSamFellLowSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.0001, sus = 1, rls = 1.0, crv = (-8), atkf = 0.0001, rlsf = 0.4, crvf = (-8), trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, tuDiv = 16, freqEnvMin = 1, freqEnvMax = 40, index = 2, mratio = 4, boost = 2, doneAction = 2;
    var env, freq, freqenv, trig, sig;

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));

	env = EnvGen.ar(Env.perc(atk, rls, curve: crv), trig, doneAction: doneAction);

	freqenv = EnvGen.ar(Env.perc(atkf, rlsf, curve: crvf), trig);

    freq = tu.midicps / tuDiv;
    freq = freq * freqenv.linexp(0, 1, freqEnvMin, freqEnvMax);

	index = index.mod(3);

    sig = SinOsc.ar(freq, SinOsc.ar(freq * mratio) * index);
    sig = (sig * boost).tanh * env * amp;

	/*sig = Pan2.ar(sig, pan);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\gaborSd, { arg out = 0, amp = 0.25, pan = 0, doneAction = 2;

    var trig = \trig.tr;

    var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig);
    var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig);
    var gainEnv = EnvGen.kr(Env([0,1,0], [\atk.kr(0.01), \rel.kr(0.3)], \lin), trig, doneAction: doneAction);

    var numPartials = 40;
    var n = (1..numPartials);
    var freqs = \freq.kr(150) * (n + (n * n * 0.05));
    var cutoff, amps, sig;

    cutoff = fltEnv * \fltRange.kr(8000);

    amps = (
        (freqs.log2 - cutoff.log2).squared
        * \slope.kr(-5)
    ).dbamp;

    sig = SinOsc.ar(freqs * freqEnv.midiratio, 0, amps).sum * -25.dbamp;

    sig = sig * gainEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\additiveGaborSd, {
    arg out = 0, amp = 0.25, pan = 0, index=1, iScale=3, gate=1, time=1, doneAction = 2;

    var numPartials = 40;
    var bufAmps = LocalBuf(numPartials, 1);
    var f0 = \freq.kr(68);
    var sig, mod;

    var iEnv = EnvGen.kr(Env([index, index * iScale, index], [\iAtk.kr(0.2), \iRel.kr(0.5)], \lin), gate, timeScale: time);
    var gainEnv = EnvGen.kr(Env.linen(\atk.kr(0.1), \sus.kr(0.5), \rel.kr(1), curve: \sine), gate, doneAction: doneAction);

    BufWr.ar(
        LFGauss.ar(
            duration: SampleDur.ir * numPartials * \factor.kr(1, 0.5).reciprocal,
            width: \width.kr(0.2, 0.5),
            iphase: LFTri.ar(\phaseModFreq.kr(0.5)).linexp(-1, 1, 1, 2),
        ),
        bufnum: bufAmps,
        phase: Phasor.ar(end: numPartials)
    );

    mod = SinOsc.ar(f0 * \mRatio.kr(1), mul: iEnv);

    sig = Array.fill(numPartials, {|i|
        var freqs, partials;
        freqs = f0 * (i + (i * i * 0.05));
        partials = SinOsc.ar(
            freq: freqs * \cRatio.kr(1),
            phase: mod.wrap(0, 4pi),
            mul: Index.ar(bufAmps, i)
        ) / numPartials;
    }).sum;

    sig = LeakDC.ar(sig);

    sig = sig * gainEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef.new(\MC808HoriuchiSd, { arg out = 0, amp = 0.5, pan = 0, freq = 250, release = 0.5, curve = (-12.843224515159), doneAction = 2;
    var sig, fenv, env;
    env = EnvGen.kr(Env.new([0.15, 1, 0], [0, release], curve),doneAction: doneAction);
    fenv = Env([freq*1.24, freq*1.12, freq], [0.1, 0.5], -4).kr;
    sig = SinOsc.ar(fenv, pi/2);
    // sig = Pan2.ar(sig * env * amp * 2, pan);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env * amp * 2, ~dirt.numChannels, pan));
}).add;

SynthDef(\TonicSd, { | out=0,amp=0.7,pan=0,oscfreq=50,lfofreq=200,lfoamount=0,penvamount=200,	decaycurve=(-5),patt=0.001,pdec=0.200,shamount=0,shrate=3,ampatt=0.001,ampdec=0.7,ampdecaycurve=(-5),oscwaveform=1,noiseatt=0.001,noisedec=0.164,noiseamp=0.6,mixfade=0,nfiltfreq=1800,noisereso=0.2,noisefiltselect=0,
	drive=2, doneAction=2 |
	var sin,tri,saw,lfo,modsh,penv,ampenv,sh,signal,noisesig,noiseenv,noisesigbp,noisesighp,noisesiglp;
	noisesig=WhiteNoise.ar*noiseamp;
	noiseenv=EnvGen.ar(Env([0,1,0],[noiseatt,noisedec],[0,-5]));
	noisesig=noisesig*noiseenv;
	noisesigbp=BPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesighp=RHPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesiglp=RLPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesig=Select.ar(noisefiltselect,[noisesigbp,noisesighp,noisesiglp]);
	sh=LFNoise0.ar(shrate)*shamount;
	penv=EnvGen.ar(Env([0,1,0],[patt,pdec],[0,decaycurve]),doneAction:0)*penvamount;
	ampenv=EnvGen.ar(Env([0,1,0],[ampatt,ampdec],[0,ampdecaycurve]),doneAction:doneAction);
	lfo=SinOsc.ar(lfofreq)*lfoamount;
	sin=SinOsc.ar(oscfreq+penv+lfo+sh)*ampenv;
	tri=LFTri.ar(oscfreq+ penv +lfo+sh)*ampenv;
	saw=LFSaw.ar(oscfreq+penv+lfo+sh)*ampenv;
	signal=Select.ar(oscwaveform,[sin,tri,saw]);
	signal=XFade2.ar(signal,noisesig,pan:mixfade);
	signal=((signal)*drive).tanh;
	// signal=Pan2.ar(signal,pos:pan)*amp;
	// OffsetOut.ar(out,signal);
	OffsetOut.ar(out, DirtPan.ar(signal * amp, ~dirt.numChannels, pan));
}).add;

SynthDef(\dx11algo3Sd, { //v3-->v2-->v1<--v4
    arg out = 0, amp = 0.5, pan = 0, feedBack = 0.5, doneAction = 2;

    var allArguments = (
        \atk:  [\op1att.kr(0.001), \op2att.kr(0.001), \op3att.kr(0.001), \op4att.kr(0.001)],  // \atk.kr(0.00!4), or like this?
        \dec:  [\op1dec.kr(0.4),   \op2dec.kr(3.25),  \op3dec.kr(0.15),  \op4dec.kr(1.25)],   // \dec.kr(0.1!4),
        \sus:  [\op1sus.kr(0.01),  \op2sus.kr(0.1),   \op3sus.kr(0.1),   \op4sus.kr(0.1)],    // \sus.kr(0.1!4)
        \rel:  [\op1rel.kr(0.1),   \op2rel.kr(0.1),   \op3rel.kr(0.1),   \op4rel.kr(0.1)],    // \rel.kr(0.1!4),
        \amt:  [\op1amt.kr(1),     \op2amt.kr(4),     \op3amt.kr(2),     \op4amt.kr(2)],      // \amt.kr(2!4),
        \tune: [\op1tune.kr(0),    \op2tune.kr(12),   \op3tune.kr(0),    \op4tune.kr(0)]      // \tune.kr(2!4)
    );
    var voice1 = allArguments.collect{|a| a[0] };
    var voice2 = allArguments.collect{|a| a[1] };
    var voice3 = allArguments.collect{|a| a[2] };
    var voice4 = allArguments.collect{|a| a[3] };

    var mk_env = {
        |voice, done_action|
        EnvGen.ar(Env.adsr(voice[\atk], voice[\dec], voice[\sus], voice[\rel]), doneAction: done_action ? 0)
    };
    var mk_freq = {
        |voice|
        (\pitch.kr(48) + voice[\tune]).midicps
    };

    var env3 = mk_env.(voice3);
    var v3 = SinOsc.ar(mk_freq.(voice3)) * env3 * voice3[\amt];

    var env2 = mk_env.(voice2);
    var v2 = SinOsc.ar(mk_freq.(voice2), v3) * env2 * voice2[\amt];

    var env4 = mk_env.(voice4);
    var v4 = SinOscFB.ar(mk_freq.(voice4), env4 * feedBack) * env4 * voice4[\amt];

    var env1 = mk_env.(voice1, doneAction);
    var v1 = SinOsc.ar(mk_freq.(voice1), v2 + v4) * env1 * voice1[\amt];

    // var final = Pan2.ar(v1 * amp, pos: pan);
    //OffsetOut.ar(out, final);
    OffsetOut.ar(out, DirtPan.ar(v1 * amp, ~dirt.numChannels, pan));
}).add;

SynthDef(\SqwerSd, { | out = 0, amp = 0.1, pan = 0, ampattack = 0.001, ampdecay = 1, filtattack = 0.001, filtdecay = 0.500, osc1amp = 0.3, osc2amp = 0.3, osc3amp = 0.3, offset1 = -24, offset2 = -0.3, offset3 = 0.1, filterfreq = 800, res = 1, lp = 1, bp = 0, hp = 0, freq = 58, filteramount = 600, fsh = 3, mixfade = 0, doneAction = 2 |
    var sig, sig1, sig2, sig3, ampenvelope, filterenvelope;
    filterenvelope = EnvGen.ar(Env([0, 1, 0], [filtattack, filtdecay], [0, -5]), doneAction: 0);
    ampenvelope = EnvGen.ar(Env([0, 1, 0], [ampattack, ampdecay], [0, -5]), doneAction: doneAction);
    sig1 = Pulse.ar((freq * (offset1.midicps)), mul: osc1amp);
    sig2 = Pulse.ar((freq * (offset2.midicps) ), mul: osc2amp);
    sig3 = Pulse.ar((freq * (offset3.midicps) ), mul: osc3amp);
    sig = sig1 + sig2 + sig3;
    sig = SVF.ar(sig, (filterfreq + (filterenvelope * filteramount)).clip(20, 20000), lowpass: lp, bandpass: bp, highpass: hp, res: res);
    sig = sig * ampenvelope;
    sig = XFade2.ar(sig, FreqShift.ar(sig, fsh), pan: mixfade);
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\lazaerSd, { arg out = 0, amp = 0.03, pan = 0, doneAction = 2;
    var lpfEnv, gainEnv;
    var cutoff, tension, tilt, lpf, peakEQ;
    var sig, freqs, numPartials, spectrum;

    numPartials = 64;
    spectrum = (1..numPartials);

    lpfEnv = EnvGen.kr(Env(
        [0, 1, 0],
        [\fltAtk.kr(0.10), \fltRls.kr(0.90)],
        [\fltAtkCurve.kr(4.0), \fltRlsCurve.kr(-8.0)]
    ));

    gainEnv = EnvGen.ar(Env(
        [0, 1, 0],
        [\atk.kr(0.01), \rls.kr(0.99)],
        [\atkCurve.kr(4.0), \rlsCurve.kr(-4.0)]
    ), doneAction: doneAction);

    // harmonic tension
    tension = (1 + (spectrum * spectrum * \inharmonic.kr(0.01))).sqrt;

    // frequency spectrum
    freqs = \frq.kr(103.826) * spectrum * tension;
    sig = SinOsc.ar(freqs, { Rand(0, 2pi) } ! numPartials);

    // 3db/octave spectral tilt
    tilt = (log2(spectrum) * \tilt.kr(-3)).dbamp;

    // LPF
    cutoff = \lpfCutoff.kr(100) + lpfEnv.linlin(0, 1, 0, \lpfEnvAmount.kr(8000));
    lpf = ((log2(freqs) - log2(cutoff)) * \lpfSlope.kr(-12)).min(0).dbamp;

    // Peak EQ
    peakEQ = ((log2(freqs) - log2(cutoff)).abs * \peakSlope.kr(-12) + \peakRes.kr(24)).max(0).dbamp;

    sig = (sig * tilt * lpf * peakEQ).sum;

    sig = sig * gainEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\hooverSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0, stn = 1.0, rls = 4, crv = 6, frq = 440, envfL1 = (-5), envfL2 = 6, envfL3 = 0, envfT1 = 0.1, envfT2 = 1.7, crvf1 = 0, crvf2 = (-4), bw = 1.035, doneAction = 2;
    var snd;
    frq = frq * Env([envfL1, envfL2, envfL3], [envfT1, envfT2], [crvf1, crvf2]).kr.midiratio;
    snd = { DelayN.ar(Saw.ar(frq * ExpRand(bw, 1 / bw)) + Saw.ar(frq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0);
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * Env.asr(atk, stn, rls, crv).kr(doneAction);
    /*snd = Balance2.ar(snd[0], snd[1], pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\vowelsynthSd,{ arg out = 0, amp = 1, pan = 0, vel = 1, fq = 440, bend = 0, vow = 0, gate = 1, doneAction = 2;
    var a,b,c,d,e,
    vib1,vib2,vib3,vib4,vib5,vib6,vib7,vib8,
    gen1,gen2,gen3,gen4,gen5,gen6,gen7,gen8,ngen, env, snd,
    ah1,eh1,ih1,oh1,uh1,
    ah2,eh2,ih2,oh2,uh2,
    ah3,eh3,ih3,oh3,uh3,
    ah4,eh4,ih4,oh4,uh4,
    ah5,eh5,ih5,oh5,uh5,
    ah6,eh6,ih6,oh6,uh6,
    ah7,eh7,ih7,oh7,uh7,
    ah8,eh8,ih8,oh8,uh8,
    mod1,mod2,mod3,mod4,mod5,mod6,mod7,mod8,
    pan1,pan2,pan3,pan4,pan5,pan6,pan7,pan8;

    vib1=SinOsc.ar(5,0,EnvGen.kr(Env([0,2],[0.2],4),1));
    vib2=SinOsc.ar(5.2,0,EnvGen.kr(Env([0,1],[0.3],4),1));
    vib3=SinOsc.ar(4.3,0,EnvGen.kr(Env([0,2],[0.4],4),1));
    vib4=SinOsc.ar(5.4,0,EnvGen.kr(Env([0,1],[0.5],4),1));
    vib5=SinOsc.ar(4.5,0,EnvGen.kr(Env([0,2],[0.6],4),1));
    vib6=SinOsc.ar(5.25,0,EnvGen.kr(Env([0,1],[0.7],4),1));
    vib7=SinOsc.ar(4.35,0,EnvGen.kr(Env([0,2],[0.8],4),1));
    vib8=SinOsc.ar(5.45,0,EnvGen.kr(Env([0,1],[0.9],4),1));

    mod1=SinOsc.ar(0.1,mul:1);
    mod2=SinOsc.ar(-0.23,mul:1);
    mod3=SinOsc.ar(0.34,mul:1);
    mod4=SinOsc.ar(-0.44,mul:1);
    mod5=SinOsc.ar(0.5,mul:1);
    mod6=SinOsc.ar(-0.6,mul:1);
    mod7=SinOsc.ar(0.73,mul:1);
    mod8=SinOsc.ar(-0.81,mul:1);

    gen1=LFPulse.ar(fq*bend.midiratio+mod1+vib1,0,0.4*mod8/8+0.2,0.15,0);
    gen2=LFPulse.ar(fq*bend.midiratio+mod2+vib2,0,0.4*mod7/8+0.2,0.15,0);
    gen3=LFPulse.ar(fq*bend.midiratio+mod3+vib3,0,0.4*mod6/8+0.2,0.15,0);
    gen4=LFPulse.ar(fq*bend.midiratio+mod4+vib4,0,0.4*mod5/8+0.2,0.15,0);
    gen5=LFPulse.ar(fq*bend.midiratio+mod5+vib5,0,0.4*mod4/8+0.2,0.15,0);
    gen6=LFPulse.ar(fq*bend.midiratio+mod6+vib6,0,0.4*mod3/8+0.2,0.15,0);
    gen7=LFPulse.ar(fq*bend.midiratio+mod7+vib7,0,0.4*mod2/8+0.2,0.15,0);
    gen8=LFPulse.ar(fq*bend.midiratio+mod8+vib8,0,0.4*mod1/8+0.2,0.15,0);
    ngen=Pulse.ar(220)*GrayNoise.ar(0.005);

    //Female vowel charts.

    ah1=BBandPass.ar(gen1, 751,0.075) + BBandPass.ar(gen1, 1460,0.075) + BBandPass.ar(gen1, 2841,0.075);
    eh1=BBandPass.ar(gen1, 431,0.075) + BBandPass.ar(gen1, 2241,0.075) + BBandPass.ar(gen1, 2871,0.075);
    ih1=BBandPass.ar(gen1, 329,0.075) + BBandPass.ar(gen1, 2316,0.075) + BBandPass.ar(gen1, 2796,0.075);
    oh1=BBandPass.ar(gen1, 438,0.075) + BBandPass.ar(gen1, 953,0.075) + BBandPass.ar(gen1, 2835,0.075);
    uh1=BBandPass.ar(gen1, 350,0.075) +BBandPass.ar(gen1, 1048,0.075) + BBandPass.ar(gen1, 2760,0.075);

    ah2=BBandPass.ar(gen2, 751,0.075) + BBandPass.ar(gen2, 1460,0.075) + BBandPass.ar(gen2, 2841,0.075);
    eh2=BBandPass.ar(gen2, 431,0.075) + BBandPass.ar(gen2, 2241,0.075) + BBandPass.ar(gen2, 2871,0.075);
    ih2=BBandPass.ar(gen2, 329,0.075) + BBandPass.ar(gen2, 2316,0.075) + BBandPass.ar(gen2, 2796,0.075);
    oh2=BBandPass.ar(gen2, 438,0.075) + BBandPass.ar(gen2, 953,0.075) + BBandPass.ar(gen2, 2835,0.075);
    uh2=BBandPass.ar(gen2, 350,0.075) + BBandPass.ar(gen2, 1048,0.075) + BBandPass.ar(gen2, 2760,0.075);

    ah3=BBandPass.ar(gen3, 751,0.075) + BBandPass.ar(gen3, 1460,0.075) + BBandPass.ar(gen3, 2841,0.075);
    eh3=BBandPass.ar(gen3, 431,0.075) + BBandPass.ar(gen3, 2241,0.075) + BBandPass.ar(gen3, 2871,0.075);
    ih3=BBandPass.ar(gen3, 329,0.075) + BBandPass.ar(gen3, 2316,0.075) + BBandPass.ar(gen3, 2796,0.075);
    oh3=BBandPass.ar(gen3, 438,0.075) + BBandPass.ar(gen3, 953,0.075) + BBandPass.ar(gen3, 2835,0.075);
    uh3=BBandPass.ar(gen3, 350,0.075) + BBandPass.ar(gen3, 1048,0.075) + BBandPass.ar(gen3, 2760,0.075);

    ah4=BBandPass.ar(gen4, 751,0.075) + BBandPass.ar(gen4, 1460,0.075) + BBandPass.ar(gen4, 2841,0.075);
    eh4=BBandPass.ar(gen4, 431,0.075) + BBandPass.ar(gen4, 2241,0.075) + BBandPass.ar(gen4, 2871,0.075);
    ih4=BBandPass.ar(gen4, 329,0.075) + BBandPass.ar(gen4, 2316,0.075) + BBandPass.ar(gen4, 2796,0.075);
    oh4=BBandPass.ar(gen4, 438,0.075) + BBandPass.ar(gen4, 953,0.075) + BBandPass.ar(gen4, 2835,0.075);
    uh4=BBandPass.ar(gen4, 350,0.075) + BBandPass.ar(gen4, 1048,0.075) + BBandPass.ar(gen4, 2760,0.075);

    //Male vowel charts

    ah5=BBandPass.ar(gen5, 608,0.075) + BBandPass.ar(gen5, 1309,0.075) + BBandPass.ar(gen5, 2466,0.075);
    eh5=BBandPass.ar(gen5, 372,0.075) + BBandPass.ar(gen5, 1879,0.075) + BBandPass.ar(gen5, 2486,0.075);
    ih5=BBandPass.ar(gen5, 290,0.075) + BBandPass.ar(gen5, 1986,0.075) + BBandPass.ar(gen5, 2493,0.075);
    oh5=BBandPass.ar(gen5, 380,0.075) + BBandPass.ar(gen5, 907,0.075) + BBandPass.ar(gen5, 2415,0.075);
    uh5=BBandPass.ar(gen5, 309,0.075) +BBandPass.ar(gen5, 961,0.075) + BBandPass.ar(gen5, 2366,0.075);

    ah6=BBandPass.ar(gen6, 608,0.075) + BBandPass.ar(gen6, 1309,0.075) + BBandPass.ar(gen6, 2466,0.075);
    eh6=BBandPass.ar(gen6, 372,0.075) + BBandPass.ar(gen6, 1879,0.075) + BBandPass.ar(gen6, 2486,0.075);
    ih6=BBandPass.ar(gen6, 290,0.075) + BBandPass.ar(gen6, 1986,0.075) + BBandPass.ar(gen6, 2493,0.075);
    oh6=BBandPass.ar(gen6, 380,0.075) + BBandPass.ar(gen6, 907,0.075) + BBandPass.ar(gen6, 2415,0.075);
    uh6=BBandPass.ar(gen6, 309,0.075) + BBandPass.ar(gen6, 961,0.075) + BBandPass.ar(gen6, 2366,0.075);

    ah7=BBandPass.ar(gen7, 608,0.075) + BBandPass.ar(gen7, 1309,0.075) + BBandPass.ar(gen7, 2466,0.075);
    eh7=BBandPass.ar(gen7, 372,0.075) + BBandPass.ar(gen7, 1879,0.075) + BBandPass.ar(gen7, 2486,0.075);
    ih7=BBandPass.ar(gen7, 290,0.075) + BBandPass.ar(gen7, 1986,0.075) + BBandPass.ar(gen7, 2493,0.075);
    oh7=BBandPass.ar(gen7, 380,0.075) + BBandPass.ar(gen7, 907,0.075) + BBandPass.ar(gen7, 2415,0.075);
    uh7=BBandPass.ar(gen7, 309,0.075) + BBandPass.ar(gen7, 961,0.075) + BBandPass.ar(gen7, 2366,0.075);

    ah8=BBandPass.ar(gen8, 608,0.075) + BBandPass.ar(gen8, 1309,0.075) + BBandPass.ar(gen8, 2466,0.075);
    eh8=BBandPass.ar(gen8, 372,0.075) + BBandPass.ar(gen8, 1879,0.075) + BBandPass.ar(gen8, 2486,0.075);
    ih8=BBandPass.ar(gen8, 290,0.075) + BBandPass.ar(gen8, 1986,0.075) + BBandPass.ar(gen8, 2493,0.075);
    oh8=BBandPass.ar(gen8, 380,0.075) + BBandPass.ar(gen8, 907,0.075) + BBandPass.ar(gen8, 2415,0.075);
    uh8=BBandPass.ar(gen8, 309,0.075) + BBandPass.ar(gen8, 961,0.075) + BBandPass.ar(gen8, 2366,0.075);

    //Summing them all

    a = [ah1+ah2+ah3+ah4+ah5+ah6+ah7+ah8];
    b = [eh1+eh2+eh3+eh4+eh5+eh6+eh7+eh8];
    c = [ih1+ih2+ih3+ih4+ih5+ih6+ih7+ih8];
    d = [oh1+oh2+oh3+oh4+oh5+oh6+oh7+oh8];
    e = [uh1+uh2+uh3+uh4+uh5+uh6+uh7+uh8];

    //Panning and adding crossfading bwteeen vowels.

    pan1=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-1,1);
    pan2=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.8,1);
    pan3=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.6,1);
    pan4=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.4,1);
    pan5=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.4,1);
    pan6=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.6,1);
    pan7=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.8,1);
    pan8=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,1,1);
    env = EnvGen.ar(Env.asr(2, vel, 0.005), gate, doneAction: doneAction);
    snd = pan1+pan2+pan3+pan4+pan5+pan6+pan7+pan8 * env;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sillyVoiceSd, { arg out = 0, amp = 0.5, pan = 0,
    atk = 0.01,
    rls = 0.1,
	freq = 220,
    vibratoSpeed = 6,
    vibratoDepth = 4,
    vowel = 0,
    lag = 1,
    gate = 1, doneAction = 2;

    var in, vibrato, env, va, ve, vi, vo, vu, snd;

    vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
    in = Saw.ar(Lag.kr(freq, lag) + vibrato);
    env = EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: 2);

    va = BBandPass.ar(
        in: in,
        freq: [ 600, 1040, 2250, 2450, 2750 ],
        bw: [ 0.1, 0.067307692307692, 0.048888888888889, 0.048979591836735, 0.047272727272727 ],
        mul: [ 1, 0.44668359215096, 0.35481338923358, 0.35481338923358, 0.1 ]);

    ve = BBandPass.ar(
        in: in,
        freq: [ 400, 1620, 2400, 2800, 3100 ] ,
        bw: [ 0.1, 0.049382716049383, 0.041666666666667, 0.042857142857143, 0.038709677419355 ],
        mul: [ 1, 0.25118864315096, 0.35481338923358, 0.25118864315096, 0.12589254117942 ]);

    vi = BBandPass.ar(
        in: in,
        freq: [ 250, 1750, 2600, 3050, 3340 ] ,
        bw: [ 0.24, 0.051428571428571, 0.038461538461538, 0.039344262295082, 0.035928143712575 ],
        mul: [ 1, 0.031622776601684, 0.15848931924611, 0.079432823472428, 0.03981071705535 ] );

    vo = BBandPass.ar(
        in: in,
        freq:[ 400, 750, 2400, 2600, 2900 ] ,
        bw: [ 0.1, 0.10666666666667, 0.041666666666667, 0.046153846153846, 0.041379310344828 ],
        mul: [ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 ]);

    vu = BBandPass.ar(
        in: in,
        freq: [ 350, 600, 2400, 2675, 2950 ],
        bw: [ 0.11428571428571, 0.13333333333333, 0.041666666666667, 0.044859813084112, 0.040677966101695 ],
        mul: [ 1, 0.1, 0.025118864315096, 0.03981071705535, 0.015848931924611 ]);

    snd = SelectX.ar(Lag.kr(vowel, lag), [va, ve, vi, vo, vu]);
    snd = Mix.new(snd);
	OffsetOut.ar(out, DirtPan.ar(snd * env, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Sequence

SynthDef(\virgoSd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.01, release = 1, feedback = 7.5, freq1 = 32, freq2 = 33, delaytime = 2, decaytime = 40, gate = 1, doneAction = 2;
	var sig, input, modFreq;
	input = LocalIn.ar(2) * feedback;
	sig = input + Saw.ar([freq1, freq2], amp);
	modFreq = 2 ** LFNoise0.kr(4/3, 4) * 300;
	sig = BPF.ar(sig, modFreq, 0.1).distort;
	sig = CombN.ar(sig, 1, delaytime, decaytime);
	LocalOut.ar(sig);
	sig = sig * EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\scratchiSd, { arg out = 0, amp = 1, pan = 0, spread = 0, attack = 0.01, release = 2, freq = 0.5, gate = 1, doneAction = 2;
	var sig, env, waveForm, trig;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	waveForm = SinOsc.ar(freq,[0,1],3,1);
	trig = Impulse.ar([waveForm+0.2,waveForm]);
	sig = FreeVerb.ar(Decay.ar(trig,waveForm,MoogFF.ar(SinOsc.ar(([waveForm.asin])*50),400)).softclip/2);
	sig = sig * env;
	// OffsetOut.ar(out, Splay.ar(sig, spread, amp));
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig, spread, amp), ~dirt.numChannels, pan));
}).add;

SynthDef(\seqPureSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
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

SynthDef(\seqModulSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, gate = 1, doneAction = 2;
	var sig, env, buffer;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
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

/*SynthDef(\taltersSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, feedBack = 1, freq = 66, freqL1 = 0, freqL2 = 2, freqL3 = 4, freqL4 = 16, freqT1 = 0.01, freqT2 = 0.2, freqT3 = 0.12, freqCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, freqenv;
	env = Linen.kr(gate, attack, 1, release, doneAction);
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

SynthDef(\talters1Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = Linen.kr(gate, attack, 1, release, doneAction);
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

/*SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, gate = 1, doneAction = 2;
	var sig, env, input, ctrl;
	env = Linen.kr(gate, att, 1, rel, doneAction);
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

SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, gate = 1, doneAction = 2;
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
	sig = GVerb.ar(sig, 9, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, gate = 1, doneAction = 2;
	var sig, env, delayTime;
	env = Linen.kr(gate, att, 1, rel, doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	// OffsetOut.ar(out, sig * env * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;*/

SynthDef(\LiljedDrumSeqSd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 4, sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, gate = 1, doneAction = 2;
	var sig, env, imp, krps, kick;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
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

SynthDef(\LiljedKickSeqSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
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

SynthDef(\LiljedMetalicSd, { arg out = 0, amp = 0.05, pan = 0, attack = 0.01, release = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rDec = 0.7, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4],
		rDec
	).sum*2;

	sig = GVerb.ar(
		sin(sig),
		5,
		revTime,
		revDamp
	);

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedMetalic1Sd, { arg out = 0, amp = 0.05, pan = 0, attack = 0.01, release = 2, rTrgRate = 1, rFreq1 = 40, rFreq2 = 200, rFreq3 = 234, rFreq4 = 889, rFreq5 = 1320, rFreq6 = 150, rDec = 0.7, revTime = 2, revDamp = 0.7, gate = 1, doneAction = 2;
	var sig, env;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);

	sig = Ringz.ar(
		Impulse.ar(rTrgRate),
		[rFreq1, rFreq2, rFreq3, rFreq4, rFreq5, rFreq6],
		rDec
	).sum;

	sig = GVerb.ar(
		sin(sig),
		5,
		revTime,
		revDamp
	)/2;

	sig = Mix.ar(sig) * env;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\LiljedSoftRytmSd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.01, release = 2, impSigRate = 8, sawFreq = 3, impRevRate = 4, impRevPh = 0.5, blipFreq = 4.9, blipHarm = 7, blipAmp = 0.4, revTime = 1, gate = 1, doneAction = 2;
	var sig, env, imp, rev;
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	imp = Impulse;
	sig = imp.kr(impSigRate).lag * Crackle.ar(LFSaw.kr(sawFreq).abs.lag * 1.8);
	rev = GVerb.ar(
		imp.kr(impRevRate, impRevPh).lag * Blip.ar(blipFreq, blipHarm, blipAmp),
		1,
		revTime
	) * 5;
	sig = sig + rev;
	sig = Mix.ar(sig * env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\dannySimple1Sd, { arg out = 0, amp = 0.7, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, curve = (-4), envPow = 1, frq1_1 = 1, frq1_2 = 2, frq1_3 = 3, frq1_4 = 4, frq1_5 = 5, frq1_6 = 6, frq1_7 = 7, frq1_8 = 8, frq1_9 = 9, frq1_10 = 10, frq1_11 = 11, frq1_12 = 12, frq1_13 = 13, frq1_14 = 14, frq1_15 = 15, frq2_1 = 1, frq2_2 = 2, frq2_3 = 3, frq2_4 = 4, frq2_5 = 5, frq2_6 = 6, frq2_7 = 7, frq2_8 = 8, frq2_9 = 9, frq2_10 = 10, frq2_11 = 11, frq2_12 = 12, frq2_13 = 13, frq2_14 = 14, frq2_15 = 15, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, doneAction = 2;
    var sig, sig1, sig2, env, thr, frq1, frq2;

    thr = 0.03;
	env = EnvGen.kr(Env.asr(atk, 1, rls, curve), timeScale: sustain, doneAction: doneAction.pow(envPow));

    frq1 = [frq1_1, frq1_2, frq1_3, frq1_4, frq1_5, frq1_6, frq1_7, frq1_8, frq1_9, frq1_10, frq1_11, frq1_12, frq1_13, frq1_14, frq1_15];
    frq2 = [frq2_1, frq2_2, frq2_3, frq2_4, frq2_5, frq2_6, frq2_7, frq2_8, frq2_9, frq2_10, frq2_11, frq2_12, frq2_13, frq2_14, frq2_15];

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    /*sig = Pan2.ar(sig * env, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Rimshot

SynthDef(\rimSd, { arg out = 0, amp = 0.2, pan = 0, tu = 1, envLev1 = 1, envLev2 = 0, envLev3 = 1, envLev4 = 0,  att = 0, dec = 0.004, rel = 0.1, gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envLev1, envLev2, envLev3, envLev4], [att, dec, rel]), gate, doneAction: doneAction);
	var enf = EnvGen.ar(Env([1600,5600,800,250],[0.001,0.001,0.001],-4));
	var enf2 = EnvGen.ar(Env([1000,1600,700,200],[0.001,0.001,0.06,0.01],-4));
	sig = SinOsc.ar(tu*400)*env;
	sig =  WhiteNoise.ar(env)+sig;
	sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1))+sig;
	sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+WhiteNoise.ar(env)+BrownNoise.ar(env/8);
	sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5))+sig;
	sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([enf2,enf*0.9,enf2*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(env),enf*4,1,1)+sig )*env ;
	// sig = Pan2.ar(sig*env, pan, amp);
	sig = DirtPan.ar(sig*env, ~dirt.numChannels, pan, amp);
	sig = CompanderD.ar(sig*4,0.8,0.3,0.5,0.001,0.2,env);
	OffsetOut.ar(out, sig*amp);
}).add;

SynthDef(\rimnewSd, { arg out=0, amp=0.01, pan=0, tu=1, att = 0.0001, rel=1, freqTime1 = 0.001, freqTime2 = 0.01, gate=1, doneAction=2;
    var sig;
    var env = EnvGen.ar(Env.perc(att, rel), gate, doneAction: doneAction);
var frequ = EnvGen.ar(Env([1500,500,210.4],[freqTime1, freqTime2]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    // sig = Pan2.ar(sig*env, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\rim808Sd, { arg out=0, amp=0.01, pan=0, att = 0.001, rel=1, tu=1, tuf=1, gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(att, rel), gate, doneAction: doneAction);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tuf,1).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

///////////////////////////////////////  Bass

SynthDef(\bass1Sd,{arg out = 0, amp = 0.5, pan = 0, atk = 0, dcy = 8, sus = 1, rel = 4, envfL1 = 50, envfL2 = 40, envfT1 = 0.1, envfT2 = 0.3, envfT3 = 0.3, tu = 1, gate = 1, doneAction = 2;
    var env = EnvGen.ar(Env.adsr(atk, dcy, sus, rel), gate, doneAction: doneAction);
    var freq = EnvGen.ar(Env([envfL1, envfL2],[envfT1, envfT2, envfT3]));
    var sig = SyncSaw.ar(freq*tu,20);
    sig = BRF.ar(sig,432,1);
    sig = HPF.ar(sig,300);
	// sig = Pan2.ar(sig.distort, pan, amp) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig.distort, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\bass3Sd,{arg out=0, amp=1, pan = 0, tu = 1.54, gate = 1;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    // OffsetOut.ar(out,sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\bassSd,{arg out = 0, amp = 1, pan = 0, dis = 0.5, freq = 60, tu = 1, atf = 80, rel = 1, gate = 1;
    var env = EnvGen.ar(Env.adsr(0.05,0,1,rel),gate,doneAction:2);
    var frequ = EnvGen.ar(Env([freq+1000,freq-100],[0.05,0.1]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu),0,env);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(env);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,In.ar(0,1),0.05,1,0.1,0.01,0.1);
    // OffsetOut.ar(out,sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sinBassSd, { arg out = 0, gate = 1, amp = 1, pan = 0, loopNode = nil, attack = 0.2, release = 4, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
	var freqEnv, env, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
	env = EnvGen.kr(Env.asr(attack, 1, release, curve), gate, doneAction: doneAction);
	sig = SinOsc.ar(freqEnv, mul: env);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, 20, 1, env);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogbasstone2Sd,{ arg out = 0, amp = 0.1, pan = 0.0, attackTime = 0.2, freq = 440, fenvamount = 0.5, cutoff =  1000, gain = 2.0, gate = 1;

	var osc, filter, env, filterenv;

	//alternative: richer source
	osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));

	filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
	filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);

	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	// OffsetOut.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));
	OffsetOut.ar(out, DirtPan.ar((0.7*filter+(0.3*filter.distort)), ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\moogBassSd, { arg out = 0, amp = 0.1, pan = 0, freq = 40, cutoff = 1000, gain = 2.0, lagamount = 0.01, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7, gate = 1, doneAction = 2;
	var osc, filter, env, filterenv, snd, chorusfx;

	osc = Mix(VarSaw.ar(
		freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5));

	filterenv = EnvGen.ar(
		envelope: Env.asr(0.2, 1, 0.2),
		gate: gate);

	filter =  MoogFF.ar(
		in: osc,
		freq: cutoff * (1.0 + (0.5 * filterenv)),
		gain: gain);

	env = EnvGen.ar(
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
		gate: gate,
		doneAction: doneAction);

	snd = (0.7 * filter + (0.3 * filter.distort)) * env;

	chorusfx = Mix.fill(7, {

		var maxdelaytime = rrand(0.005, 0.02);
		DelayC.ar(
			in: snd,
			maxdelaytime: maxdelaytime,
			delaytime: LFNoise1.kr(
				freq: Rand(4.5, 10.5),
				mul: 0.25 * maxdelaytime,
				add: 0.75 * maxdelaytime)
		)
	});

	snd = snd + (chorusfx * chorus);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\tweetAnaBassSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, freq = 60, ffreq = 60, tu = 9, compTresh = 0.5, gate = 1, doneAction = 2;
	var sig, env, bw;
	bw = LFNoise0.ar(_);
	sig = max(
		max(bw.(4),l=bw.(6)),
		SinOsc.ar(freq * ceil(l*tu).lag(0.1))*0.7
	);
	sig = tanh(
		BBandPass.ar(sig, ffreq, bw.(1).abs/2)*700*l.lag(1)
	);
	env = EnvGen.kr(Env.asr(attack, releaseTime: release), gate, doneAction: doneAction);
	sig = sig * env;
	sig = Compander.ar(sig, sig, compTresh, 1, 1/8, 0.002);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\triangleWaveBellsSd,{ arg out = 0, amp = 1.0, pan = 0.0, att = 0.01, dec = 0.1, sus = 1, rel = 0.5, freq = 40, lforate = 10, lfowidth = 0.0, cutoff = 100, rq = 0.5, gate = 1, doneAction = 2;

	var osc1, osc2, vibrato, filter, env;
	vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
	osc1 = Saw.ar(freq * (1.0 + (lfowidth * vibrato)), 0.75);
	osc2 = Mix(LFTri.ar((freq.cpsmidi + [11.9, 12.1]).midicps));
	filter = RHPF.ar((osc1 + (osc2 * 0.5)) * 0.5, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: doneAction);
	// OffsetOut.ar(out, Pan2.ar(filter * env, pan));
	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\bassSatSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0, sus = 1, rls = 8, crv = (-4), rate = 3, soundmod = 60, sat = 0.1, noiseAmp1 = 0.04, noiseAmp2 = 0.04, noiseAtk = 0.005, noiseDcy = 0.5, doneAction = 2;
	var sig, env, exc, klankArr;

	env = EnvGen.kr(Env.asr(atk, sus, rls, crv), doneAction: doneAction);

	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(rate, 0, [noiseAmp1, noiseAmp2]), noiseAtk, noiseDcy));

    klankArr = Ref.new([soundmod, nil, Array.fill(16, {1.1})]);

    sig = (DynKlank.ar(klankArr, exc) * sat).softclip;

	/*sig = Pan2.ar(sig * env, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\turfuBassSd, { arg out = 0, amp = 0.25, pan = 0, index=1, iScale=5, doneAction = 2;
    var trig = \trig.tr(1);
    var trigMod = LFNoise0.ar(8).round;
    var sig, gainEnv, iEnv, mod;
    var low, mid, high;
    var lowFreq, highFreq, phase, waveform, shaped;

    iEnv = EnvGen.ar(Env([0, index, index * iScale, index], [0.0001, 5, 1], \lin), trig);
	gainEnv = EnvGen.ar(Env([0, 1, 1, 0], [0, \atk.kr(0.2), \rls.kr(0.01)], \curve.kr(-5)), (trig * trigMod).abs, doneAction: doneAction);
    mod = Sweep.ar(trig * trigMod, [51.913, 726.783]);

    phase = Phasor.ar(Impulse.ar(0), 51.913 / SampleRate.ir, 0, 1);
    waveform = (((phase % 0.5 * 2pi).sin * (2 * (phase % 0.5 < 0.25) - 1)) + (2 * (phase % 0.5 >= 0.25))) + (2 * (phase >= 0.5));
    sig = waveform + (((mod * 2pi) + (pi/3)).wrap(-pi, pi) * iEnv);
	sig = (Fold.ar(sig) * [2, 0.05]).mean;


    lowFreq = 207.652;
    highFreq = 1038.26;
    low = LPF.ar(LPF.ar(sig, lowFreq), lowFreq);
    sig = sig - low;
    mid = LPF.ar(LPF.ar(sig, highFreq), highFreq);
    high = sig - mid;

    // lows
    low = low + PitchShift.ar(low, 0.2, 2);
    k = 2 * \amount.kr(0.2) / (1 - \amount.kr(0.2));
    shaped = (1 + k) * low / (1 + (k * low.abs));
    low = XFade2.ar(low, shaped, 1);

    // highs
    high = (high * \boost.kr(3).dbamp).tanh;

    sig = low + mid + high;

    sig = sig * gainEnv * amp;

    sig = MidEQ.ar(sig, 13289.75, 0.7, 8);
    sig = LeakDC.ar(sig);
	/*sig = Pan2.ar(Limiter.ar(sig), pan);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(Limiter.ar(sig), ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Generative

SynthDef(\nvirgoSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 20, feedBack = 7.5, sawFreq1 = 32, sawFreq2 = 33, sawAmp = 0.2, bpff = 2, bpffModSpeed = 1.33, bpffModAmt = 4, delayTime = 2, decayTime = 40, doneAction = 2;
	var sig, env;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
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

SynthDef(\bozkurtSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 10, impFreq = 0.25, freq1 = 4, freq2 = 6, delTime = 0.3, decTime = 50, feedBack = 1, doneAction = 2;
	var sig, env, input, ctrl;
	//env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
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

SynthDef(\mcldSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 10, impFreq = 10, hpfFreq = 440, doneAction = 2;
	var sig, env, input;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
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
SynthDef(\padovanSd, { arg out = 0, amp = 1, pan = 0, tridDur = 1, freq = 165, gate = 1, doneAction = 2;
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
	sig = GVerb.ar(sig, 9, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

/*SynthDef(\batuhanSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, tridDur = 0.125, decayTime = 0.3, sawFreq = 8, brfFreq1 = 45.1, brfFreq2 = 45, doneAction = 2;
	var sig, env, core;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
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

SynthDef(\nozkurtSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, sinFreq = 55, impMin = 0.0002, impMax = 0.7, impFreq = 8, doneAction = 2;
	var sig, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
	sig = SinOsc.ar(sinFreq).tanh;
	delayTime = TExpRand.ar(impMin, impMax, Impulse.ar(impFreq)).round([2e-3, 4e-3]);
	sig = AllpassC.ar(sig, 1, delayTime, 2);
	sig = sig * env * amp;
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\tirgoSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, blipFreqMod = 2, blipHarmo = 400, brfFreq = 150, brfRq = 2, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
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

SynthDef(\lmcdSd, { arg out = 0, amp = 1, pan = 0, att = 0.01, rel = 5, trigDur = 0.1, lfCubTu = 1, hpfFreq = 440, doneAction = 2;
	var sig, noise, thunder, rainStep, env, delayTime;
	// env = Linen.kr(gate, att, 1, rel, doneAction);
	env = EnvGen.ar(Env.linen(att, 1, rel), doneAction: doneAction);
	sig = Duty.kr(trigDur, 0, Dseq(fib(32).wrap(20, 55).midicps, inf));
	sig = LFCub.ar([-1, sig, sig / 3, -2] * lfCubTu);
	sig = LeakDC.ar(sig) * 9;
	sig = HPF.ar(sig, hpfFreq).clip2 / 9;
	sig = sig * env;
	sig = Splay.ar(sig, 1, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\lcm2GeneSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2, doneAction = 2;
    var sig, sig1, sig2, mod1, mod2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    mod1 = TExpRand.kr(1, 1000, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TExpRand.kr(1, 1000, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sig1 = Saw.ar(mod1).range(-100,100).round(1);
    sig2 = LFCub.ar(mod2).range(-100,100).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * env;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdLcmDmGeneSd, { arg out = 0, amp = 0.1, pan = 0, spread = 0.5, atk = 0.001, rls = 0.2, sustain = 1, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0, doneAction = 2;
    var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    mod1 = TRand.kr(1, 300, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TRand.kr(1, 300, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sin1 = SinOsc.ar(mod1).range(1,100) * mul1;
    sin2 = SinOsc.ar(mod2) * mul2;

    sig1 = gcd(sin1, sin2) % modu1;
    sig2 = lcm(sin1, sin2) % modu2;

    sig = tanh([sig1 * sig2, sin1 * sin2] * mulTanh);

    sig = Splay.ar(sig, spread) * env;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm2GeneSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7, doneAction = 2;
    var sig, sig1, sig2, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + 41 * SampleDur.ir)) % mod1;
    sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + 40 * SampleDur.ir);) % mod2;

    sig = gcd(sig1, sig2 + [dev1, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

    sig = sig * env;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm5GeneSd, { arg out = 0, amp = 0.1, pan = 0, atk = 0.001, rls = 0.2, sustain = 1, seqOffSet = 0, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, env;

    env = EnvGen.kr(Env.asr(atk, 1, rls), timeScale: sustain, doneAction: doneAction);

    seq = Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99] + seqOffSet, inf);

    //envMod = XLine.kr(start, end, 100);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.3;

    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, 5000), 0.3);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\salledutempsSd, { arg out = 0, amp = 1, pan = 0, attack = 1, release = 4, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((55/2)+ (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(55/24))))*(2**(0..8))],Crackle.ar(2,0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\salledutemps1Sd, { arg out = 0, amp = 1, pan = 0, attack = 1, release = 4, tu = 1, myst = 55, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[((myst/2)+ (tu + (tu * (Demand.kr(Impulse.kr(0), 0, Diwhite(0, 6))*2*(myst/24)))))*(2**(0..8))],Crackle.ar(2, 0.005))*LFGauss.ar(dur,0.7,0,1)}!5;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\cormanSd, { arg out = 0, amp = 1, pan = 0, attack = 1, release = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu * Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98)))*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\corman1Sd, { arg out = 0, amp = 1, pan = 0, attack = 1, release = 10, tu = 1, dur = 9, gate = 1, doneAction = 2;
	var sig, rand, env;
	env = Linen.kr(gate, attack, 1, release, doneAction);
	sig = {DynKlank.ar(`[(tu + (tu * 52))/*Demand.kr(Impulse.kr(0), 0, Diwhite(0, 98))))*/*(1..9)],Crackle.ar(2,0.01))*LFGauss.ar(dur,0.7,0,1)}!2;
	sig = sig * env;
	sig = Splay.ar(sig);
	// OffsetOut.ar(out, sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\raisonne,{ arg out = 0, amp = 1, pan = 0, atk = 0, dcy = 8, stn = 1, rls = 4, sustain = 1, frq = 40, bwr = 0.001, doneAction = 2;
	var sig, n, env;
    env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls), timeScale: sustain, doneAction: doneAction);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
	sig = Pan2.ar(sig, pan, amp) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bigraphSd, { arg out = 0, amp = 0.2, pan = 0, atk = 0.0001, dcy = 0.1, stn = 1, rls = 2, sustain = 1, crv = (-12), envPow = 1, trig1Freq = 0, trig2Freq = 0, modulo1 = 128, modulo2Freq = 3, modulo2Mul = 9, modulo2Offset = 99, noteOffset = 33, srcFreq = 9, modPhaseMul = 3.1415926535898, doneAction = 2;
    var sig, modPhase, env, trig1, trig2;
    env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls, curve: crv), timeScale: sustain, doneAction: doneAction).pow(envPow);
    trig1 = Impulse.kr(trig1Freq);
    trig2 = Impulse.kr(trig2Freq);
    modPhase = SinOsc.ar(
        midicps(
            (
                Sweep.ar(trig1, (33..3)) % modulo1 & (Sweep.ar(trig2, (3..9)) % (LFSaw.ar(modulo2Freq) * modulo2Mul + modulo2Offset))
            ) + noteOffset
        ),
        0,
        modPhaseMul
    );
    sig = (SinOsc.ar(srcFreq, modPhase) / 3) * env;
    // sig = Pan2.ar(Splay.ar(sig), pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\floatingPointErrorsSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0001, dcy = 0.1, stn = 1, rls = 2, crv = (-12), envPow = 1, doneAction = 2;
    var sig, sig1, pink1, sig2, pink2, sig3, pink3, sig4, sig5, env;

	env = EnvGen.kr(Env.adsr(atk, dcy, stn, rls, curve: crv), doneAction: doneAction).pow(envPow);

    pink1 = PinkNoise.ar().range(0.08, 0.12) ! 2;
    sig1 = 0.5 * LeakDC.ar(Median.ar(2, Limiter.ar(99999999*(SawDPW.ar(pink1, 0) + SawDPW.ar(pink1, pi)), 0.9)));

    pink2 = PinkNoise.ar().range(0.0999/3, 0.1001/3) ! 2;
    sig2 = 0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink2, 0) + SawDPW.ar(pink2, pi)), 0.9)));

    pink3 = PinkNoise.ar().range(0.00999, 0.01001) ! 2;
    sig3 = 0.5 * Median.ar(20, Limiter.ar(999999*LeakDC.ar(SawDPW.ar(pink3, 0+(pi/2)) + SawDPW.ar(pink3, pi+(pi/2))), 0.1));

    sig4 = 0.5 * Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005, 0) + SinOsc.ar(0.005, pi)), 0.05))) ! 2;

    sig5 = 0.5 * SVF.ar((Median.ar(10, Limiter.ar(999999*LeakDC.ar(LFPulse.ar(0.5, 0) + LFPulse.ar(0.5, pi)), 0.6))), 800) ! 2;

    sig = sig1 + sig2 + sig3 + sig4 + sig5;
    sig = Limiter.ar(sig, 0.8);
    sig = Balance2.ar(sig[0], sig[1], pan, amp);

    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels));
}).add;

SynthDef(\easelSd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.0001, release = 1.2, sustain = 1, curve = 0, envPow = 1, selFilt = 3, doneAction = 2;
    var snd, numInputs, numOutputs, globalEnv;
    numInputs = 12;
    numOutputs = 7;
    snd = LocalIn.ar(numOutputs);

    globalEnv = EnvGen.ar(Env.asr(attack, sustain, release, curve), doneAction: doneAction).pow(envPow);
    // Matrix-vector multiplication using multichannel expansion.
    snd = snd * ({ { LFNoise2.kr(0.5).round } ! numInputs } ! numOutputs);
    snd = snd.sum;
    // If additional modules are added, remember to update numInputs and numOutputs.
    // numInputs should equal the maximum i in snd[i], plus one.
    // numOutputs should equal the number of entries in the snd array.
    snd = [
        // Oscillator that reaches LFO range
        SinOsc.ar(snd[0].linexp(-1, 1, 0.1, 8000)),
        // Oscillator in audio range only
        SinOsc.ar(snd[1].linexp(-1, 1, 100, 8000)),
        // Wavefolder with controllable gain
        (snd[2] * snd[3].linexp(-1, 1, 1, 10)).fold2,
        // Two filters with controllable cutoff and resonance
        MoogFF.ar(snd[4], snd[5].linexp(-1, 1, 10, 8000), snd[6].linlin(-1, 1, 0, 4)) * 3.dbamp,
        MoogFF.ar(snd[7], snd[8].linexp(-1, 1, 10, 8000), snd[9].linlin(-1, 1, 0, 4)) * 3.dbamp,
        // Metallic reverb (spring reverb in the Easel)
        FreeVerb.ar(snd[10], mix: 1),
        // Five-step sequencer
        Demand.ar(Impulse.ar(snd[11].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
    ];

    if(snd.size != numOutputs) {
        Error("Please ensure numOutputs matches number of modules").throw;
    };
    snd = Sanitize.ar(snd);
    LocalOut.ar(snd);

    snd = Select.ar(selFilt.mod(8), snd ++ snd.sum);

    snd = Limiter.ar(LeakDC.ar(snd * globalEnv));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\runglerSd, { arg out = 0, amp = 0.2, pan = 0.3, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfoTrigRate = 0.4, tu = 24, ffreq = 24, doneAction = 2;
    var rungler, lfo, snd, runglerOut, globalEnv;

	globalEnv = EnvGen.ar(Env.asr(attack, sustain, release, curve), doneAction: doneAction).pow(envPow);

    lfo = {
        var trigger;
        trigger = Dust.ar(lfoTrigRate);
        Select.ar(ToggleFF.ar(trigger), [
            LFNoise2.ar(TExpRand.ar(0.5, 10, trigger)),
            TRand.ar(-1, 1, trigger),
        ]);
    };

    rungler = { |dataSignal, clockSignal|
        var numBits, bits, bit, out, doDAC;
        doDAC = { |bits|
            var result;
            result = bits[0] + (bits[1] * 2) + (bits[2] * 4);
            result = result / 7;
            result = (result * 2) - 1;
            result;
        };
        bit = dataSignal > 0;
        numBits = 8;
        bits = [];
        numBits.do {
            bit = Latch.ar(bit, clockSignal);
            bits = bits.add(bit);
            bit = Delay1.ar(bit);
        };
        (
            out: doDAC.(bits[numBits - 3..numBits - 1]),
            outReverse: doDAC.(bits[numBits - 2..numBits - 4]),
        );
    };
    snd = LocalIn.ar(2);
    runglerOut = rungler.(snd[0], snd[1]);
    snd = [runglerOut[\out], runglerOut[\outReverse]];
    snd = LFTri.ar(({ lfo.() } ! 2).linexp(-1, 1, [10, 1], 8000) * (snd * tu).midiratio);
    LocalOut.ar(LeakDC.ar(Sanitize.ar(snd)));
    snd = (snd[0] > snd[1]) - 0.5;
    snd = MoogFF.ar(snd, ({ lfo.() } ! 2).linexp(-1, 1, 100, 8000) * (runglerOut[\out] * ffreq).midiratio, 3);
    snd = snd * globalEnv * -10.dbamp;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

)