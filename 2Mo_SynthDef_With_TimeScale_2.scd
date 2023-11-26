(
///////////////////////////////////////  Tonal

SynthDef(\fakeResSusSd, {
    arg  out = 0, pan = 0, freq = 200, peamount = 900,
    pitchAtt = 0.001, pitchDec = 0.13,
    ampAtt = 0.03, ampDec = 1.0, level = 0.5, sustain = 1, doneAction = 2;

    var sig, sig1, sig2, ampenv, pitchenv, sig2Phase;

    pitchenv = EnvGen.ar(
        // Env([0, 1, 0], [pitchAtt, pitchDec], [0, 0])  // original
        Env([0, 1, 0], [pitchAtt, pitchDec],  \squared)
        // Env([0, 1, 0], [pitchAtt, pitchDec],  \cubed)
    );

    ampenv = EnvGen.ar(
        Env([0, 1, 0], [ampAtt, ampDec], [0, 0]),
        levelScale: level,
		timeScale: sustain,
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
    sig = sig * ampenv;
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\ambitek_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.9, curve = (-4), envSL1 = 0, envSL2 = 0.72, envSL3 = 0.16, envSL4 = 0, envST1 = 0.2, envST2 = 0.6, envST3 = 0.8, envSCurve = (-4), sawFreq = 50, delTime = 0.1, delDecay = 2, brfRq = 2, gate = 1, doneAction = 2;
	var sig, globalEnv, envS;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), gate, doneAction: doneAction);
	// env = Linen.kr(gate, attack, 1, release, doneAction);
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
	sig = sig * globalEnv;
	// OffsetOut.ar(out, sig!2 * amp);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\main_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0.0, release = 2, sustain = 1, envPow = 1, curve = 1, levelScale = 1, levelBias = 0, lev = 10, freq = 50, wnoiseAmp = 1, sinAmp = 1, sin1Freq = 30, envL1 = 0, envL2 = 1, envL3 = 0.01, envL4 = 1.3, envL5 = 0, envT1 = 0.01, envT2 = 0, envT3 = 0.2, envT4 = 0.01, clickCurve = (-4), clickInScale = 1, clickEnvPow = 1, clickHpf = 80, clickHpRq = 1, clickLpf = 13000, clickLpRq = 1, clickAmp = 1, sel = 0, sin2Freq = 40, sin2Amp = 0.3, noiseAmp = 1, hpffreq = 8000, revtime = 3, room = 10, distAmt = 2, distMix = 0, doneAction = 2;
	var distSig, envClick, click;
	var fmod = SinOsc.ar(freq/60, 0, freq/60);
	var sig = [
		SinOsc.ar([freq, freq + 0.6] + fmod, 0, [lev, lev - 0.005]).mean.tanh,
		HPF.ar(WhiteNoise.ar(wnoiseAmp), hpffreq),
		SinOsc.ar(sin1Freq, 0, sinAmp),
		VarSaw.ar(freq/40, mul: lev * 10000)
	];

	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), 1, levelScale, levelBias, sustain, doneAction).pow(envPow);

	envClick = EnvGen.ar(Env([envL1, envL2, envL3, envL4, envL5], [envT1, envT2, envT3, envT4].normalizeSum * sustain, clickCurve), levelScale: clickInScale).pow(clickEnvPow);
	click = RHPF.ar(envClick, clickHpf, clickHpRq);
	click = RLPF.ar(click, clickLpf, clickLpRq);
	click = click * clickAmp;

	sig = (click + SelectX.ar(sel.wrap(0, 3), sig).fold(-1, 1) * 0.7 + SinOsc.ar(sin2Freq, 0, sin2Amp) * (1 + HPF.ar(WhiteNoise.ar(0.02 * noiseAmp), hpffreq)));

	distSig = Clip.ar(sig * distAmt);
	sig = SelectX.ar(distMix, [sig, distSig]);
	sig = LeakDC.ar(sig);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\windowsyncSusSd, { |out = 0, pan = 0, freq = 65.40639132515, amp = 0.1,
    syncEgTop = 20, syncRatio = 2, syncDcy = 0.5, gate = 1, sustain = 1, doneAction = 2|
    var syncEg = EnvGen.kr(Env([syncEgTop / syncRatio, 1], [syncDcy], \exp));
    var eg = EnvGen.kr(Env.adsr(0.01, 0.3, 0.6, 0.1), gate, timeScale: sustain, doneAction: doneAction);
    var fundamental = LFTri.ar(freq);
    var syncFreq = freq * syncRatio * syncEg;
    // note, Phasor here is behaving like the Sweep above (retrigger behavior)
    // but Phasor loops around its range, eliminating the need for '% 1'
    var syncPhase = Phasor.ar(fundamental, syncFreq * SampleDur.ir, 0, 1, 0);
    var sig = SinOsc.ar(0, syncPhase * 2pi) * fundamental;
    // OffsetOut.ar(out, (sig * (amp * eg)).dup);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * eg));
}).add;

SynthDef(\danUk_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0, release = 1.3, sustain = 1, curve = (-4), envPow = 1, globalEnvNoise = 0.3, globalEnvInv = 0, sawFreq = 50, r = 12, doneAction = 2;
	var phi, x, y, sig, globalEnv, envShape;

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1], 1, curve), doneAction: doneAction).pow(envPow);
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

SynthDef(\prayerBell_Sd, { |out = 0, gate = 1, amp = 0.5, pan = 0, attack = 0.001, release = 1.2, sustain = 1, curve = (-4), envPow = 1, sing_switch = 0, freq = 2434, decayscale = 1, lag = 10, level = 0.08, i_doneAction = 2|
	var sig, input, first, freqscale, mallet, sing, globalEnv, envShape;
	freq = freq.max(20).min(5000);
	freqscale = freq / 2434;
	decayscale = decayscale.min(1);
	freqscale = Lag3.kr(freqscale, lag);
	decayscale = Lag3.kr(decayscale, lag);

	envShape = [attack, release].normalizeSum * sustain;
	globalEnv = EnvGen.kr(Env.perc(envShape[0], envShape[1]), doneAction: i_doneAction).pow(envPow);

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
	// DetectSilence.ar(sig, doneAction: i_doneAction);
	sig = sig * globalEnv;
	// sig = Pan2.ar(sig, pan, level);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, level));
}).add;

SynthDef(\sosTom_Sd, { arg out = 0, amp = 0.6, pan = 0, attack = 0.001, release = 1.2, sustain = 1, envPow = 1, curve = -6, atk = 0.005, drumRel = 0.4, stickRel = 0.01, drumModeAmp = 0.25, freq = 250, timbreIndex = 0.77, clickAtk = 0, clickRls = 0.2, clickSus = 1, clickLevScale = 5, clickEnvPow = 1, clickEnvNoiseAmp = 0.3, clickFreq = 224, clickAmp = 0.5, doneAction = 2;

	var drumMode, drumModeEnv, stick, stickEnv, snd, globalEnv, clickEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, amp, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	clickEnv = EnvGen.ar(Env.perc(clickAtk, clickRls), levelScale: clickLevScale, timeScale: clickSus).pow(clickEnvPow) * PinkNoise.ar(clickEnvNoiseAmp).range(0.1, 1).lag(0.02);

	drumModeEnv = Env.perc(
		            attackTime: atk,
		            releaseTime: drumRel,
		            level: 0.5,
		            curve: curve
	).kr;

	drumMode = PMOsc.ar(
		            carfreq: Saw.ar(freq: freq * 0.9),
					modfreq: freq * 0.85,
					pmindex: timbreIndex,
					mul: drumModeEnv * 10
	);

	drumMode = drumMode + SinOsc.ar(freq: [freq, freq * 0.8], mul: drumModeEnv);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	stick = Crackle.ar(chaosParam: 2.01);

	stickEnv = Env.perc(attackTime: atk, releaseTime: stickRel, level: 3, curve: curve).kr;

	snd = Mix.ar(drumMode + stickEnv + HPF.ar(clickEnv, clickFreq, clickAmp)) * globalEnv;

	snd = LeakDC.ar(snd);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\markSamFell_Sd,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, harm1 = 0, harm2 = 2, harm3 = 4, harm4 = 5, harm5 = 7, harm6 = 9, harm7 = 10, plkDec = 0.9, plkCoeff = 0.5, filtFreqMin = 500, filterFreqMax = 16000, doneAction = 2;
    var globalEnv, trig, sig, freqs;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));
    freqs = (tu + [harm1, harm2, harm3, harm4, harm5, harm6, harm7]).midicps;
	sig = Pluck.ar(Hasher.ar(Sweep.ar(trig)) * -10.dbamp, trig, freqs.reciprocal, freqs.reciprocal, plkDec, plkCoeff.min(1).max(-1));
    sig = LeakDC.ar(sig).sum;
    sig = MoogFF.ar(sig, LFNoise2.kr(1).linexp(-1, 1, filtFreqMin, filterFreqMax));
	/*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\markSamFellLow_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, atkf = 0.0001, rlsf = 0.4, crvf = (-8), trigSpeedMin = 1, trigSpeedMax = 100, tu = 60.5, tuDiv = 16, freqEnvMin = 1, freqEnvMax = 40, index = 2, mratio = 4, boost = 2, doneAction = 2;
    var globalEnv, freq, freqenv, trig, sig;

    trig = Impulse.ar(LFNoise2.kr(1).linexp(-1, 1, trigSpeedMin, trigSpeedMax));

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), trig, timeScale: sustain, doneAction: doneAction).pow(envPow);

	freqenv = EnvGen.ar(Env.perc(atkf, rlsf, curve: crvf), trig);

    freq = tu.midicps / tuDiv;
    freq = freq * freqenv.linexp(0, 1, freqEnvMin, freqEnvMax);

	index = index.mod(3);

    sig = SinOsc.ar(freq, SinOsc.ar(freq * mratio) * index);
    sig = (sig * boost).tanh * globalEnv * amp;

	/*sig = Pan2.ar(sig, pan);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\gabor_Sd, { arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;

    var trig = \trig.tr;

    var freqEnv = EnvGen.kr(Env([1,2,1], [0.5, 0.01], \lin), trig);
    var fltEnv = EnvGen.kr(Env([0.0125,1,0.0125], [\fAtk.kr(0.3), \fRel.kr(0.01)], \exp), trig);
    var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

    sig = sig * globalEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\additiveGabor_Sd, {
    arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, index=1, iScale=3, time=1, doneAction = 2;

    var numPartials = 40;
    var bufAmps = LocalBuf(numPartials, 1);
    var f0 = \freq.kr(68);
    var sig, mod;

    var iEnv = EnvGen.kr(Env([index, index * iScale, index], [\iAtk.kr(0.2), \iRel.kr(0.5)], \lin), timeScale: time);
	var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

    sig = sig * globalEnv;

    /*sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);*/

	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef.new(\MC808Horiuchi_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.5, sustain = 1, curve = (-12.843224515159), envPow = 1, freq = 250, doneAction = 2;
    var sig, fenv, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    fenv = Env([freq*1.24, freq*1.12, freq], [0.1, 0.5], -4).kr;
    sig = SinOsc.ar(fenv, pi/2);
    // sig = Pan2.ar(sig * globalEnv * amp * 2, pan);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv * amp * 2, ~dirt.numChannels, pan));
}).add;

SynthDef(\Tonic_Sd, { |  out=0,amp=0.7,pan=0,attack=0,release=0.5,sustain=1,curve=(-4),envPow=1,oscfreq=50,lfofreq=200,lfoamount=0,penvamount=200,decaycurve=(-5),patt=0.001,pdec=0.200,shamount=0,shrate=3,ampatt=0.001,ampdec=0.7,ampdecaycurve=(-5),oscwaveform=1,noiseatt=0.001,noisedec=0.164,noiseamp=0.6,mixfade=0,nfiltfreq=1800,noisereso=0.2,noisefiltselect=0,drive=2,doneAction=2 |
	var sin,tri,saw,lfo,modsh,penv,ampenv,sh,signal,noisesig,noiseenv,noisesigbp,noisesighp,noisesiglp, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	noisesig=WhiteNoise.ar*noiseamp;
	noiseenv=EnvGen.ar(Env([0,1,0],[noiseatt,noisedec],[0,-5]));
	noisesig=noisesig*noiseenv;
	noisesigbp=BPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesighp=RHPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesiglp=RLPF.ar(noisesig,nfiltfreq,rq:noisereso);
	noisesig=Select.ar(noisefiltselect,[noisesigbp,noisesighp,noisesiglp]);
	sh=LFNoise0.ar(shrate)*shamount;
	penv=EnvGen.ar(Env([0,1,0],[patt,pdec],[0,decaycurve]),doneAction:0)*penvamount;
	ampenv=EnvGen.ar(Env([0,1,0],[ampatt,ampdec],[0,ampdecaycurve]));
	lfo=SinOsc.ar(lfofreq)*lfoamount;
	sin=SinOsc.ar(oscfreq+penv+lfo+sh)*ampenv;
	tri=LFTri.ar(oscfreq+ penv +lfo+sh)*ampenv;
	saw=LFSaw.ar(oscfreq+penv+lfo+sh)*ampenv;
	signal=Select.ar(oscwaveform,[sin,tri,saw]);
	signal=XFade2.ar(signal,noisesig,pan:mixfade);
	signal=((signal)*drive).tanh;
	// signal=Pan2.ar(signal,pos:pan)*amp;
	// OffsetOut.ar(out,signal);
	OffsetOut.ar(out, DirtPan.ar(signal * globalEnv * amp, ~dirt.numChannels, pan));
}).add;

SynthDef(\dx11algo3_Sd, { //v3-->v2-->v1<--v4
    arg out = 0, amp = 0.5, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, feedBack = 0.5, doneAction = 2;

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

    var globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

    var env1 = mk_env.(voice1);
    var v1 = SinOsc.ar(mk_freq.(voice1), v2 + v4) * env1 * voice1[\amt];

    // var final = Pan2.ar(v1 * amp, pos: pan);
    //OffsetOut.ar(out, final);globalEnv
    OffsetOut.ar(out, DirtPan.ar(v1 * amp * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\Sqwer_Sd, { | out = 0, amp = 0.1, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, ampattack = 0.001, ampdecay = 1, filtattack = 0.001, filtdecay = 0.500, osc1amp = 0.3, osc2amp = 0.3, osc3amp = 0.3, offset1 = -24, offset2 = -0.3, offset3 = 0.1, filterfreq = 800, res = 1, lp = 1, bp = 0, hp = 0, freq = 58, filteramount = 600, fsh = 3, mixfade = 0, doneAction = 2 |
    var sig, sig1, sig2, sig3, ampenvelope, filterenvelope, globalEnv;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;

SynthDef(\lazaer_Sd, { arg out = 0, amp = 0.03, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;
    var lpfEnv, gainEnv, globalEnv;
    var cutoff, tension, tilt, lpf, peakEQ;
    var sig, freqs, numPartials, spectrum;

    numPartials = 64;
    spectrum = (1..numPartials);

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;

SynthDef(\hoover_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, frq = 440, envfL1 = (-5), envfL2 = 6, envfL3 = 0, envfT1 = 0.1, envfT2 = 1.7, crvf1 = 0, crvf2 = (-4), bw = 1.035, doneAction = 2;
    var snd, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    frq = frq * Env([envfL1, envfL2, envfL3], [envfT1, envfT2], [crvf1, crvf2]).kr.midiratio;
    snd = { DelayN.ar(Saw.ar(frq * ExpRand(bw, 1 / bw)) + Saw.ar(frq * 0.5 * ExpRand(bw, 1 / bw)), 0.01, Rand(0, 0.01)) }.dup(20);
    snd = (Splay.ar(snd) * 3).atan;
    snd = snd * Env.asr(0.01, 1.0, 1.0).kr(0);
    snd = FreeVerb2.ar(snd[0], snd[1], 0.3, 0.9);
    snd = snd * globalEnv;
    /*snd = Balance2.ar(snd[0], snd[1], pan, amp);
    OffsetOut.ar(out, snd);*/
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\vowelsynth_Sd,{ arg out = 0, amp = 1, pan = 0, attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1, vel = 1, fq = 440, bend = 0, vow = 0, doneAction = 2;
    var a,b,c,d,e,
    vib1,vib2,vib3,vib4,vib5,vib6,vib7,vib8,
    gen1,gen2,gen3,gen4,gen5,gen6,gen7,gen8,ngen, globalEnv, snd,
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
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    snd = pan1+pan2+pan3+pan4+pan5+pan6+pan7+pan8 * globalEnv;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\sillyVoice_Sd, { arg out = 0, amp = 0.5, pan = 0,
    attack = 0.001, release = 0.5, sustain = 1, curve = (-4), envPow = 1,
	freq = 220,
    vibratoSpeed = 6,
    vibratoDepth = 4,
    vowel = 0,
    lag = 1,
    doneAction = 2;

    var in, vibrato, globalEnv, va, ve, vi, vo, vu, snd;

    vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
    in = Saw.ar(Lag.kr(freq, lag) + vibrato);
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Sequence

SynthDef(\talters1SusSd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, sustain = 1, release = 10, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, gate = 1, doneAction = 2;
	var sig, env, input, modenv, harmk, ampk, ringk;
	env = EnvGen.kr(Env.perc(attack, release), gate, timeScale: sustain, doneAction: doneAction);
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
	OffsetOut.ar(out, DirtPan.ar(sig * env, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\talters1_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 0.5, sustain = 1, curve = (-12.843224515159), envPow = 1, feedBack = 1, envL1 = 0, envL2 = 2, envL3 = 4, envL4 = 16, envT1 = 0.01, envT2 = 0.2, envT3 = 0.12, envCurve = (-4), decDens = 0.25, decTimeFreq = 0.1, decamp = 999, doneAction = 2;
	var sig, globalEnv, input, modenv, harmk, ampk, ringk;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	input = LocalIn.ar(2) * feedBack;
	modenv = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve));
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
	// OffsetOut.ar(out, sig * globalEnv * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\padovan_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tridDur = 1, freq = 165, doneAction = 2;
	var sig, globalEnv, input, mod, grainTr, sinMod;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = SinOsc;
	mod = Trig.ar(
		Saw.ar(freq),
		tridDur // * sustain
	);
	grainTr = sig.ar(mod * freq);
	sinMod = sig.ar(mod);
	sig = GrainIn.ar(2, grainTr, grainTr / 2, sinMod, mod * sinMod, -1);
	sig = GVerb.ar(sig, 9, mul: amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedDrumSeq_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 4, sustain = 1, curve = (-4), sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, doneAction = 2;
	var sig, globalEnv, imp, krps, kick;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
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
		), // * Line.kr(0,1,16),
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
	// sig = sig * curve * amp;
	sig = Mix.ar(sig) * globalEnv * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedDrumSeq1_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.0001, release = 4, sustain = 1, curve = (-4), sawFrq = 4, plcTrigRate = 1, plcDelay = 1, plcDecay = 0.85714285714286, pCntTrigRate = 12, pCntResetRate = 5, krpsAtt = 0, krpsRel = 0.1, krpsSus = 1, krpsEnvPow = 1, krpsLev = 1, krpsLpfFrq = 2500, krpsHpfFrq = 750, kickLpfFrq = 3000, kickHpfFrq = 40, ringFrq = 60, ringDec = 0.8, doneAction = 2;
	var sig, krpsEnv, globalEnv, imp, krps, kick;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);

	krpsEnv = EnvGen.kr(Env.perc(krpsAtt, krpsRel), levelScale: krpsLev, timeScale: krpsSus).pow(krpsEnvPow);

	imp = { arg rate; Impulse.ar(rate); }; // * gate;

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
		), // * Line.kr(0,1,16),
		krpsLpfFrq
	) * krpsEnv;

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
	// sig = sig * curve * amp;
	sig = Mix.ar(sig) * globalEnv * amp;

	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

SynthDef(\LiljedKickSeq_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.01, release = 2, sustain = 1, curve = (-4), trgChance1 = 0.5, trgChance2 = 0.3, trgChance3 = 0.9, trgRate1 = 4, trgRate2 = 12, trgRate3 = 6, rFreq1 = 45, rFreq2 = 50, rDec1 = 0.6, rDec2 = 0.1, rDec3 = 1, rDec4 = 0.3, rAmp1 = 9, rAmp2 = 2, rAmp3 = 3, rAmp4 = 1, gate = 1, doneAction = 2;
	var sig, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction);
	sig = Ringz.ar(
		CoinGate.ar(
			[trgChance1, trgChance2, trgChance3],
			Impulse.ar([trgRate1, trgRate2, trgRate3])
		),
		[rFreq1, rFreq2],
		[rDec1, rDec2, rDec3, rDec4],
		[rAmp1, rAmp2, rAmp3, rAmp4]
	).sin.sum.tanh;
	sig = sig * globalEnv;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\dannySimple1_Sd, { arg out = 0, amp = 0.7, pan = 0, attack = 0.001, release = 0.2, sustain = 1, curve = (-4), envPow = 1, frq1_1 = 1, frq1_2 = 2, frq1_3 = 3, frq1_4 = 4, frq1_5 = 5, frq1_6 = 6, frq1_7 = 7, frq1_8 = 8, frq1_9 = 9, frq1_10 = 10, frq1_11 = 11, frq1_12 = 12, frq1_13 = 13, frq1_14 = 14, frq1_15 = 15, frq2_1 = 1, frq2_2 = 2, frq2_3 = 3, frq2_4 = 4, frq2_5 = 5, frq2_6 = 6, frq2_7 = 7, frq2_8 = 8, frq2_9 = 9, frq2_10 = 10, frq2_11 = 11, frq2_12 = 12, frq2_13 = 13, frq2_14 = 14, frq2_15 = 15, add1 = 970, add2 = 1030, div1 = 30, div2 = 30, rng1Lo = (-4), rng1Hi = 4, rng2Lo = (-4), rng2Hi = 4, thr = 0.03, doneAction = 2;
    var sig, sig1, sig2, globalEnv, frq1, frq2;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction.pow(envPow));

    frq1 = [frq1_1, frq1_2, frq1_3, frq1_4, frq1_5, frq1_6, frq1_7, frq1_8, frq1_9, frq1_10, frq1_11, frq1_12, frq1_13, frq1_14, frq1_15];
    frq2 = [frq2_1, frq2_2, frq2_3, frq2_4, frq2_5, frq2_6, frq2_7, frq2_8, frq2_9, frq2_10, frq2_11, frq2_12, frq2_13, frq2_14, frq2_15];

    sig1 = SinOsc.ar(frq1 + add1 / div1).range(rng1Lo, rng1Hi);
    sig2 = SinOsc.ar(frq2 + add2 / div2).range(rng2Lo, rng2Hi);

    sig = gcd(sig1.product.round(1), sig2.round(1));
    sig = Limiter.ar(LeakDC.ar(Splay.ar(sig)), thr).clip2(thr);
    /*sig = Pan2.ar(sig * globalEnv, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Bass

SynthDef(\bass_Sd,{arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, dis = 0.5, freq = 60, addFreq = 1000, sousFreq = 100, frqCurve1 = 0.05, frqCurve2 = 0.1, tu = 1, doneAction = 2;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: 2).pow(envPow);
    var frequ = EnvGen.ar(Env([freq + addFreq, freq, freq - sousFreq], [frqCurve1, frqCurve2]));
    var sig = LFSaw.ar(LFSaw.ar(frequ-100,0,frequ-200,frequ*tu), 0, globalEnv);
    sig = CrossoverDistortion.ar(sig,dis,0.05)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.001)+sig;
    sig = DelayL.ar(sig,0.05,0.01)+sig;
    sig = BPeakEQ.ar(sig,80,1,6);
    sig = sig *0.4*(globalEnv);
    //sig = LPF.ar(sig,100);
    sig = Compander.ar(sig,sig,0.05,1,0.1,0.01,0.1);
    // OffsetOut.ar(out,sig * amp);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bass3SusSd,{arg out=0, amp=1, pan = 0, tu = 1.54, sustain = 1, gate = 1;
    var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate, timeScale: sustain, doneAction:2);
    var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
    var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
    sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
    // OffsetOut.ar(out,sig*amp*env);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\sinBass_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0.2, release = 4, sustain = 1, curve = (-4), envPow = 1, envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, tu = 1, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, fcurve = 4, hpff = 20, doneAction = 2;
	var freqEnv, globalEnv, sig;
	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6] * tu, [envTime1, envTime2, envTime3, envTime4, envTime5].normalizeSum * sustain, fcurve));
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	sig = SinOsc.ar(freqEnv);
	//sig = HPF.ar(sig, 20);
	sig = BHiPass4.ar(sig, hpff);
	// OffsetOut.ar(out, Pan2.ar(sig, pan, Lag.kr(amp, 0.5)));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, Lag.kr(amp, 0.5)));
}).add;

SynthDef(\moogBass_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, ffreq = 1000, lagamount = 0.01, atkf = 0.2, stnf = 1, rlsf = 0.2, chorus = 0.7, doneAction = 2;
	var osc, filter, globalEnv, filterenv, snd, chorusfx;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: 2).pow(envPow);

	osc = Mix(VarSaw.ar(
		freq: frq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5
	)
	);

	filterenv = EnvGen.ar(Env.asr(atkf, stnf, rlsf), timeScale: sustain);

	filter =  MoogFF.ar(
		in: osc,
		freq: ffreq * (1.0 + (0.5 * filterenv)),
		gain: amp
	);

	snd = (0.7 * filter + (0.3 * filter.distort)) * globalEnv;

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

SynthDef(\bassSat_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, rate = 3, soundmod = 60, sat = 0.1, noiseAmp1 = 0.04, noiseAmp2 = 0.04, noiseAtk = 0.005, noiseDcy = 0.5, doneAction = 2;
	var sig, globalEnv, exc, klankArr;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	exc = BrownNoise.ar(Decay2.kr(Impulse.kr(rate, 0, [noiseAmp1, noiseAmp2]), noiseAtk, noiseDcy));

    klankArr = Ref.new([soundmod, nil, Array.fill(16, {1.1})]);

    sig = (DynKlank.ar(klankArr, exc) * sat).softclip;
	// sig = Mix.ar(sig);
	/*sig = Pan2.ar(sig * globalEnv, pan, amp);
	OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\turfuBass_Sd, { arg out = 0, amp = 0.25, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, index=1, iScale=5, doneAction = 2;
    var trig = \trig.tr(1);
    var trigMod = LFNoise0.ar(8).round;
    var sig, globalEnv, iEnv, mod;
    var low, mid, high;
    var lowFreq, highFreq, phase, waveform, shaped;

    iEnv = EnvGen.ar(Env([0, index, index * iScale, index], [0.0001, 5, 1], \lin), trig);

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), (trig * trigMod).abs, timeScale: sustain, doneAction: doneAction).pow(envPow);

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

    sig = sig * amp;

    sig = MidEQ.ar(sig, 13289.75, 0.7, 8);
    sig = LeakDC.ar(sig);
	/*sig = Pan2.ar(Limiter.ar(sig), pan);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(Limiter.ar(sig * globalEnv), ~dirt.numChannels, pan));
}).add;

///////////////////////////////////////  Snare

SynthDef(\snaremedSusSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, relEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, sustain = 1, doneAction = 2|
	var env0,env1,
	env1m, son, son2,son3,son4,p2;
	p2 = phase * (-pi);
	env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,relEnv0],[curve1, curve2, curve3]);
	env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

	env0 = EnvGen.ar(env0, timeScale: sustain, doneAction: doneAction);
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

SynthDef(\sosSnare_Sd, { arg out = 0, amp = 0.8, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, atk = 0.005, rls = 0.1, crv = (-4), atk1 = 0.05, rls1 = 0.6, crv1 = (-8), freq = 405,
	//drumMode Controls
	drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
	//snares controls
	snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 40, rq = 0.1, bwr = 1,
	doneAction = 2;

	var globalEnv, drumMode, drumModeEnv, snares, snareEnv, snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	drumModeEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 0.5, curve: crv).kr;

	drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

	drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

	drumMode = drumMode + PMOsc.ar(
		carfreq: Saw.ar(freq * 0.85),
		modfreq: freq * modHarmonic,
		pmindex: timbreIndex,
		mul: drumModeEnv // * 10
	);

	drumMode = Mix.ar(drumMode) * drumModeAmp;

	snareEnv = Env.perc(attackTime: atk1, releaseTime: rls1, curve: crv1).kr;

	snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

	snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

	snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

	snd = Mix.new(drumMode + snares) * globalEnv * amp;

	snd = LeakDC.ar(snd);

	//DetectSilence.ar(in: snd, doneAction: doneAction);

    // OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrumSusSd, {
	arg
	// Standard values
	out = 0, freq = 180, amp = 0.6, pan = 0,
	// Stick Controls
	atk = 0.001, dcy = 0.01, rls = 0.2,
	// Head Controls
	headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rel = 0.2,
	// Snares Controls (thresh goes from 0 to 1)
	snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
	snareGate = 0.6, rq = 0.5, sustain = 1,
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
		attackTime: atk,
		decayTime: dcy,
		mul: 0.005); // This keeps the volume at a sane level

	// Drum Head
	head = Klank.ar(
		specificationsArrayRef:
		Ref.new([freqarray, amparray, decarray]),
		input: stick,
		freqscale: freq,
		decayscale: rel);

	// Snares
	snares = PinkNoise.ar(
		Amplitude.ar(
			in: head,
			attackTime: followAtt,
			releaseTime: followRel));
	snares = CompanderD.ar(
		in: snares,
		thresh: thresh,
		slopeBelow: 1 + snareGate.clip(0, inf));
	snares = BRF.ar(
		in: snares,
		freq: freqarray[1..6],
		rq: rq);

	//Output Stuff
	snd = (head * headAmp) + (snares * snaresAmp);
	snd = Mix.ar(snd * amp);
	snd = Limiter.ar(snd);

	// DetectSilence.ar(in: snd, doneAction: doneAction);

	snd = snd * EnvGen.kr(Env.asr(atk, 1, rls), 1, timeScale: sustain, doneAction: doneAction);

	// Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\squareDrum_Sd, {
    arg
    // Standard values
    out = 0, freq = 180, amp = 0.6, pan = 0,
	// global env
	attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1,
    // Stick Controls
    atk = 0.001, dcy = 0.01,
    // Head Controls
    headAmp = 0.5, decCoef = 0.175, ampSlope = 3, rls = 0.2,
    // Snares Controls (thresh goes from 0 to 1)
    snaresAmp = 0.65, followAtt = 0.005, followRel = 0.075, thresh = 0.25,
    snareGate = 0.6, rq = 0.5,
	doneAction = 2;

    var globalEnv, freqarray, amparray, decarray, stick, head, snares, snd;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
        attackTime: atk,
        decayTime: dcy,
        mul: 0.005); // This keeps the volume at a sane level

    // Drum Head
    head = Klank.ar(
        specificationsArrayRef:
            Ref.new([freqarray, amparray, decarray]),
        input: stick,
        freqscale: freq,
        decayscale: rls);

    // Snares
    snares = PinkNoise.ar(
        Amplitude.ar(
            in: head,
            attackTime: followAtt,
            releaseTime: followRel));
    snares = CompanderD.ar(
        in: snares,
        thresh: thresh,
        slopeBelow: 1 + snareGate.clip(0, inf));
    snares = BRF.ar(
        in: snares,
        freq: freqarray[1..6],
        rq: rq);

    //Output Stuff
    snd = (head * headAmp) + (snares * snaresAmp);
    snd = Mix.ar(snd * amp);
	snd = snd * globalEnv;
    snd = Limiter.ar(snd);

    // Out.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\neuroSnareSusSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
	//Click Controls
	clickatt = 0.001, clicksus = 0.01, clickrel = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
	//Body Controls
	bodyatt = 0.04, bodyrel = 0.2, bodyamp = 2,
	//Rattle Controls
	rattlehold = 0.01, rattleatt = 0.05, rattlerel = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
	//Sweep Controls
	sweepatt = 0.001, sweeprel = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500, sustain = 1,
	doneAction = 2;

	var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

	// a percussive click to give it some attack
	cEnv = Env.linen(
		attackTime: clickatt,
		sustainTime: clicksus,
		releaseTime: clickrel,
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

	// DetectSilence.ar(in: snd, doneAction: doneAction);
	snd = snd * EnvGen.kr(Env.perc(0, sustain), doneAction: doneAction);

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snare909_Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 124, attack = 0, release = 0.1, sustain = 1, curve = 6, atk = 0, stn = 1, rls = 0.08, crv = 24, envNoiseAmp = 0.4, envTonePow = 12, envNoisePow = 0.63, toneRel = 0.1, toneAmp = 1, noiseRel = 0.06, noiseAmp = 0.4, nyquist = 12100, lpFreq = 14040, hpFreq = 83, doneAction = 2;
	var env, envTone, envNoise, envBlur, relTimes, globalEnv, tone, noise, snd;

	relTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

	env = Env([atk, stn, rls], relTimes, crv);

	envBlur = PinkNoise.kr(envNoiseAmp).range(0.1, 1).lag(0.02);

	envTone = EnvGen.kr(env, timeScale: toneRel) * envBlur;

	envNoise = EnvGen.kr(env, timeScale: noiseRel) * envBlur;

	globalEnv = Env.perc(attack, release, curve: curve).kr(timeScale: sustain, doneAction: doneAction);

	tone = LFTri.ar([1, 1.78] * freq, mul: toneAmp) * envTone.pow(envTonePow);

	noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

	noise = LPF.ar(noise, lpFreq, noiseAmp) * envNoise.pow(envNoisePow);

	snd = tone ++ [noise, HPF.ar(noise, hpFreq)];

	snd = Mix.ar(snd * globalEnv) * amp;

	// OffsetOut.ar(out, Pan2.ar(snd, pan));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
}).add;

SynthDef(\snarenew_Sd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), sustain = 1, mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var globalEnv, sig, envp;
    /*var env = EnvGen.ar(Env.perc(0,0.8));
    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
	globalEnv = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3].normalizeSum * sustain, curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu * envp,0,0.5) * globalEnv;
	sig = ((PinkNoise.ar * globalEnv) * mixNoise) + (sig * (1 - mixNoise));
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

SynthDef(\snarenew1_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 0.1, sustain = 1, curve = 6, envPow = 1, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, crv = (-4), stn = 1, mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
    var env, globalEnv, sig, envp;

	globalEnv = EnvGen.ar(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3].normalizeSum * stn, curve: [crv, crv/2, crv]).kr(doneAction: doneAction);
	envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
    sig = SinOsc.ar(tu * envp,0,0.5) * env;
	sig = ((PinkNoise.ar * env) * mixNoise) + (sig * (1 - mixNoise));
    sig = RHPF.ar(sig, hpFreq*tu, rqhpf);
	sig = (Mix.ar(BPF.ar(sig,[freq1bpf, freq2bpf],[rq1bpf, rq2bpf])) * mixBpf) + (sig * (1 - mixBpf));
    sig = RLPF.ar(sig, lpf, rqlpf);
    // sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),4,-8),gate, doneAction: doneAction);
    // sig = DelayL.ar(sig,0.05,0.001)+sig;
    // sig = DelayL.ar(sig,0.05,0.01)+sig;
    // sig = DelayL.ar(sig,0.1,0.1)+sig;
	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\natassnare_Sd, { arg out = 0, amp = 0.5, pan = 0, attack = 0, release = 0.1, sustain = 1, curve = 6, envPow = 1, freq = 260, modfreqamt = 3, modfreqtime = 0.04, modfreqcrv = (-6), modfreqfact1 = 4.3, modfreqfact2 = 8.4, rls1 = 0.3, rls2 = 0.1, rls3 = 0.03, bpffreq1 = 2310, bpfrq1 = 0.25, bpffreq2 = 7310, bpfrq2 = 0.3, pshiftwin1 = 0.06, pshiftratio1 = 2.4, pshiftwin2 = 0.08, pshiftratio2 = 1.3, doneAction = 2;
    var snd, globalEnv;
	globalEnv = EnvGen.ar(Env.perc(attack, release, curve: curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
	OffsetOut.ar(out, DirtPan.ar(snd * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

///////////////////////////////////////  Rimshot

SynthDef(\rim_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tu = 1, doneAction = 2;
	var sig;
	var globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	var envf = EnvGen.ar(Env([\envfL1.kr(1600), \envfL2.kr(5600), \envfL3.kr(800), \envfL4.kr(250)],[\envfT1.kr(0.001), \envfT2.kr(0.001), \envfT3.kr(0.001)].normalizeSum * sustain, -4));
	var envf2 = EnvGen.ar(Env([\envf2L1.kr(1000), \envf2L2.kr(1600), \envf2L3.kr(700), \envf2L4.kr(200)],[\envf2T1.kr(0.001), \envf2T2.kr(0.001), \envf2T3.kr(0.06)].normalizeSum * sustain, -4));
	sig = SinOsc.ar(tu * \sinFreq.kr(400)) * globalEnv;
	sig = WhiteNoise.ar(globalEnv) + sig;
	sig = RHPF.ar(sig, \rhpfFreq.kr(100) * tu, \rhpfRq.kr(1)) + sig;
	sig = sig + Mix.ar(BPF.ar(sig, [\bpfFreq1.kr(327), \bpfFreq2.kr(430)], [\bpfRq1.kr(0.5), \bpfRq2.kr(0.5)]) * 0.8) + WhiteNoise.ar(globalEnv) + BrownNoise.ar(globalEnv / 8);
	sig = RLPF.ar(sig, \rlpfFreq.kr(11100) * tu, \rlpfRq.kr(0.5)) + sig;
	sig = (Ringz.ar(WhiteNoise.ar, Mix.ar([envf2, envf * 0.9, envf2 * 0.8]), 1, globalEnv) + RLPF.ar(BrownNoise.ar(globalEnv), envf * 4, 1, 1) + sig) * globalEnv;
	// sig = Pan2.ar(sig*globalEnv, pan, amp);
	sig = DirtPan.ar(sig*globalEnv, ~dirt.numChannels, pan);
	sig = CompanderD.ar(sig * 4, 0.8, 0.3, 0.5, 0.001, 0.2, globalEnv);
	OffsetOut.ar(out, sig * amp);
}).add;

///////////////////////////////////////  Generatif

SynthDef(\raisonne,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, bwr = 0.001, doneAction = 2;
	var sig, n, env;
	env = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
	sig = Pan2.ar(sig, pan, amp) * env;
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\raisonne_Sd,{ arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, frq = 40, bwr = 0.001, dustFreq = 5, doneAction = 2;
	var sig, n, globalEnv;
	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
	n = 50;
	sig = Mix.fill(n, {|i| Resonz.ar(Dust2.ar(dustFreq), frq * (i + 1), bwr, 300)}) * n.reciprocal; // scale to ensure no clipping
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\lcm2Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, tRand1Min = 1, tRand1Max = 1000, tRand2Min = 1, tRand2Max = 1000, rate1 = 28, rate2 = 26, smooth1 = 0.4, smooth2 = 0.2, sig1RangeMin = (-100), sig1RangeMax = 100, sig2RangeMin = (-100), sig2RangeMax = 100, doneAction = 2;
    var sig, sig1, sig2, mod1, mod2, globalEnv;

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod1 = TExpRand.kr(tRand1Min, tRand1Max, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TExpRand.kr(tRand2Min, tRand2Max, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sig1 = Saw.ar(mod1).range(sig1RangeMin, sig1RangeMax).round(1);
    sig2 = LFCub.ar(mod2).range(sig2RangeMin, sig2RangeMax).round(1);

    sig = tanh(lcm(sig1, sig2) * 0.001);

    sig = sig * globalEnv;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdLcmDmGene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, randMin = 1, randMax = 300, mul1 = 1, mul2 = 40, mulTanh = 0.0001, modu1 = 100, modu2 = 300, rate1 = 0.6, rate2 = 0.06, smooth1 = 0.4, smooth2 = 0, doneAction = 2;
    var mod1, mod2, sin1, sin2, sig, sig1, sig2, sig3, globalEnv;

	// globalEnv = EnvGen.kr(Env.asr(attack, (1 - (attack + release)), release, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    mod1 = TRand.kr(randMin, randMax, Impulse.kr(rate1));
    mod1 = Lag2.kr(mod1, smooth1);

    mod2 = TRand.kr(randMin, randMax, Dust.kr(rate2));
    mod2 = Lag2.kr(mod2, smooth2);

    sin1 = SinOsc.ar(mod1).range(1,100) * mul1;
    sin2 = SinOsc.ar(mod2) * mul2;

    sig1 = gcd(sin1, sin2) % modu1;
    sig2 = lcm(sin1, sin2) % modu2;

    sig = tanh([sig1 * sig2, sin1 * sin2] * mulTanh);

    sig = Mix.ar(sig) * globalEnv;
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig);*/
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm2Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, seq1OffSet = 41, seq1Mul = 1, seq2OffSet = 40, seq2Mul = 1, mod1 = 20, mod2 = 20, dev1 = 3, dev2 = 7, doneAction = 2;
    var sig, sig1, sig2, globalEnv;

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    sig1 = PulseCount.ar(TDuty.ar(Dseq((1..20), inf) + seq1OffSet * seq1Mul * SampleDur.ir)) % mod1;
    sig2 = PulseCount.ar(TDuty.ar(Dseq((21..1), inf) + seq2OffSet * seq2Mul * SampleDur.ir);) % mod2;

    sig = gcd(sig1, sig2 + [dev1, dev2]);
    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 20), 10000), 0.3);

	sig = Mix.ar(sig) * globalEnv;
    // sig = Pan2.ar(sig, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\gcdDm5Gene_Sd, { arg out = 0, amp = 0.1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, seqOffSet = 0, seqMul = 1, start = 10, end = 0.01, rate1 = 1, mod2 = 500, mod3 = 501, dev1 = 1, dev2 = 3, add = 400, add1 = 61, mul1 = 53, bpff = 5000, doneAction = 2;
    var seq, envMod, src1, src2, src3, sig, sig1, globalEnv;

	globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    seq = Dseq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99] + seqOffSet * seqMul, inf);

    envMod = LFTri.kr(0.005, -1).exprange(start, end);

    src1 = TDuty.ar(seq * envMod * SampleDur.ir);
    src2 = PulseCount.ar(Impulse.ar(rate1)) % mod2;
    src3 = PulseCount.ar(src1) % mod3;

    sig = gcd(src2, src3 + [0, 2]);
    sig1 = gcd(lcm(src2 + [dev1, dev2], src3),sig);

    sig = SinOsc.ar(sig * 443 + add) * 0.1;
    sig1 = SinOsc.ar(sig1 * mul1 + add1) * 0.3;

    sig = Limiter.ar(LPF.ar(HPF.ar(sig, 50) + sig1, bpff), 0.3);
	sig = Mix.ar(sig);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\bigraph_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-12), envPow = 1, trig1Freq = 0, trig2Freq = 0, modulo1 = 128, modulo2Freq = 3, modulo2Mul = 9, modulo2Offset = 99, noteOffset = 33, srcFreq = 9, modPhaseMul = 3.1415926535898, doneAction = 2;
    var sig, modPhase, globalEnv, trig1, trig2;
    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
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
    sig = (SinOsc.ar(srcFreq, modPhase) / 3) * globalEnv;
    // sig = Pan2.ar(Splay.ar(sig), pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(Splay.ar(sig), ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\floatingPointErrors_Sd, { arg out = 0, amp = 1, pan = 0, attack = 0, release = 1.4, sustain = 1, curve = (-4), envPow = 1, doneAction = 2;
    var sig, sig1, pink1, sig2, pink2, sig3, pink3, sig4, sig5, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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
	OffsetOut.ar(out, DirtPan.ar(sig * globalEnv, ~dirt.numChannels));
}).add;

SynthDef(\circSegs_Sd, { arg out = 0, amp = 0.3, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = 0, envPow = 1, tu = 1, segments = 49, xMajor = 10.0, yMajor = 1.0, rMajor = 100.1, rMinor = 1.1, circlefreq = 0.0001, doneAction = 2;
    var sig, xMinor, yMinor, freqs, amps, phase, shuheiKawachi, globalEnv;

    shuheiKawachi = { arg x, y, a, b;
        ((cos(x) * cos(y))
            + (cos((sqrt(a) * x - y) / b)
                * cos((x + (sqrt(a) * y) ) / b))
            + (cos(( sqrt(a) * x + y) /b)
                * cos((x - (sqrt(a) * y*y)) / b)))/3;
    };

    globalEnv = EnvGen.kr(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // freqs = Array.exprand(49, 50, 1500).sort.debug;
	freqs = [50.909089430214, 63.608512393358, 65.056484949596, 67.985432742352, 68.449254734715, 71.154462801524, 75.153162666907, 80.159090540174, 88.650405760834, 89.244467136653, 89.787749814836, 94.804318696787, 97.17438072031, 104.06610340747, 105.58273927332, 105.70848787891, 118.14763403707, 122.30357892333, 125.91379530205, 138.19911121285, 157.10948972852, 194.04854760832, 198.76041832049, 198.847779932, 201.92012940761, 230.06225552661, 237.68115421845, 290.73868194269, 293.38951591388, 336.31430916388, 341.91511960964, 349.4171680391, 393.59846721581, 409.2946639466, 413.5242979, 425.15780461208, 465.90490967238, 492.76629119068, 549.91655801867, 645.03288565102, 700.87369257369, 709.96409772057, 716.96599236393, 843.4571242342, 898.23211278398, 1024.3564550409, 1077.5384208642, 1122.7178267914, 1356.4674355527] * tu;

    phase = #[0.0]!49;
    //phase = Array.rand(49, 0, 2*pi);
    amps = Array.new;
    xMinor = xMajor + (rMajor * SinOsc.ar(circlefreq));
    yMinor = yMajor + (rMajor * SinOsc.ar(circlefreq, pi/2));
    amps = Array.fill(49,
        {
            arg seg;
            var x = xMinor + (rMinor * sin(seg*2*pi/segments));
            var y = yMinor + (rMinor * cos(seg*2*pi/segments));
            var grey = abs(shuheiKawachi.(x, y, 2*pi, 0.5))/12;
            grey
        }
    );
    sig = DynKlang.ar(`[freqs, amps, phase]);
    /*sig = Pan2.ar(sig, pan, amp);
    OffsetOut.ar(out, sig * globalEnv);*/
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * globalEnv));
}).add;

SynthDef(\easel_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, selSnd = 3, doneAction = 2;
    var snd, numInputs, numOutputs, globalEnv;
    numInputs = 12;
    numOutputs = 6;
    snd = LocalIn.ar(numOutputs);

    globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);
    // Matrix-vector multiplication using multichannel expansion.
    snd = snd * ({ { LFNoise2.kr(0.5)/*.round*/ } ! numInputs } ! numOutputs);
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
        FreeVerb.ar(snd[10], mix: 1)
        // Five-step sequencer
        // Demand.ar(Impulse.ar(snd[11].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
    ];

    if(snd.size != numOutputs) {
        Error("Please ensure numOutputs matches number of modules").throw;
    };
    snd = Sanitize.ar(snd);
    LocalOut.ar(snd);

    snd = Select.ar(selSnd.mod(7), snd ++ snd.sum);

    snd = Limiter.ar(LeakDC.ar(snd * globalEnv));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\easelDeter_Sd, { arg out = 0, amp = 0.2, pan = 0, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfRate = 7, lfPhase = (-2), selSnd = 3, rotate = 0, doneAction = 2;
    var snd, numInputs, numOutputs, globalEnv;
    numInputs = 6;
    numOutputs = 6;
    snd = LocalIn.ar(numOutputs);

    globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

    // Matrix-vector multiplication using multichannel expansion.
    snd = snd * ({arg j;
		{ arg i;
			var offset = i;
			if(i.odd, { offset = i.neg; });
			LFGauss.ar((lfRate + (offset * j)).reciprocal, 0.1, (i + j + lfPhase.round) * pi).round;
		} ! numInputs
	} ! numOutputs);

    snd = snd.sum;

    // If additional modules are added, remember to update numInputs and numOutputs.
    // numInputs should equal the maximum i in snd[i], plus one.
    // numOutputs should equal the number of entries in the snd array.
    snd = [
        // Oscillator that reaches LFO range
        SinOsc.ar(snd[0].linexp(-1, 1, 0.1, 8000)),
        // Oscillator in audio range only
        SinOsc.ar(snd[4].linexp(-1, 1, 100, 8000)),
        // Wavefolder with controllable gain
        (snd[2] * snd[3].linexp(-1, 1, 1, 8)).fold2,
        // Two filters with controllable cutoff and resonance
        MoogFF.ar(snd[4], snd[5].linexp(-1, 1, 10, 8000), snd[0].linlin(-1, 1, 0, 4)) * 3.dbamp,
        MoogFF.ar(snd[1], snd[2].linexp(-1, 1, 10, 8000), snd[3].linlin(-1, 1, 0, 4)) * 3.dbamp,
		// FreeVerb.ar(snd[0], mix: 1),
        // Five-step sequencer
        Demand.ar(Impulse.ar(snd[5].linexp(-1, 1, 0.1, 1000)), 0, Dseq([0.1, 0.5, 0.9, 0.3, 0.4]))
    ];

    if(snd.size != numOutputs) {
        Error("Please ensure numOutputs matches number of modules").throw;
    };
    snd = Sanitize.ar(snd);
    LocalOut.ar(snd);

    snd = Select.ar(selSnd.mod(7), snd ++ snd.sum);

    snd = Limiter.ar(LeakDC.ar(snd * globalEnv));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, amp));
}).add;

SynthDef(\rungler_Sd, { arg out = 0, amp = 0.2, pan = 0.3, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfoTrigRate = 0.4, tu = 24, ffreq = 24, doneAction = 2;
    var rungler, lfo, snd, runglerOut, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

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

SynthDef(\runglerDeter_Sd, { arg out = 0, amp = 0.2, pan = 0.3, attack = 0.001, release = 1.4, sustain = 1, curve = (-4), envPow = 1, lfSrc1Sel = 0, lfSrc1Rate = 0.7, lfSrc2Sel = 1, lfSrc2Rate = 0.24, switchSrcRate = 0.4, tu = 24, ffreq = 24, doneAction = 2;
    var rungler, lfo, lfSource1, lfSource2, snd, runglerOut, globalEnv;

	globalEnv = EnvGen.ar(Env.perc(attack, release, 1, curve), timeScale: sustain, doneAction: doneAction).pow(envPow);

	lfSource1 = Select.ar(lfSrc1Sel.round.mod(5), [BlitB3Tri.ar(lfSrc1Rate), DPW4Saw.ar(lfSrc1Rate), SinOsc.ar(lfSrc1Rate), LFCub.ar(lfSrc1Rate), LFGauss.ar(lfSrc1Rate)]);
	lfSource2 = Select.ar(lfSrc2Sel.round.mod(5), [BlitB3Tri.ar(lfSrc2Rate), DPW4Saw.ar(lfSrc2Rate), SinOsc.ar(lfSrc2Rate), LFCub.ar(lfSrc2Rate), LFGauss.ar(lfSrc2Rate)]);

    lfo = {
        var trigger;
        trigger = Impulse.ar(switchSrcRate);
        Select.ar(ToggleFF.ar(trigger), [
            lfSource1,
            lfSource2
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