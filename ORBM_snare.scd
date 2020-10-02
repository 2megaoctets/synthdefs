(
	///////////////////////////////////////  Snare

	SynthDef(\sdSd, { | out = 0, amp = 1, pan = 0, atk = 0, rls = 0.05, freq = 200, ffreq = 12000 |
		var osc1, osc2, env, sig;
		osc1 = WhiteNoise.ar;
		osc2 = FSinOsc.ar(freq);
		env = EnvGen.kr(Env.perc(atk, rls), doneAction: 2);
		sig = LPF.ar(Mix([osc1, osc2]), ffreq) * env;
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\snareSd, { arg out=0, amp=0.1, pan = 0, tu=1, gate=1, freq=200, doneAction = 2;
		var sig;
		var env = EnvGen.ar(Env.perc(0.01,0.1));
		var enf = EnvGen.ar(Env([600,1057,230],[0.01,0.01],-4));
		sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
		sig = WhiteNoise.ar+sig;
		sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
		sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1);
		sig = RLPF.ar(sig, \lpf.kr(15100)*tu, \rq.kr(0.5));
		sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction: doneAction);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\snarenewSd, { arg out = 0, amp = 0.1, pan = 0, tu = 1, envpL1 = 110, envpL2 = 59, envpL3 = 29, envpT1 = 0.01, envpT2 = 0.2, curvep = (-4), envL1 = 0.5, envL2 = 1, envL3 = 0.5, envL4 = 0, envT1 = 0.005, envT2 = 0.058, envT3 = 0.261, curve = (-4), mixNoise = 0.5, hpFreq = 80, rqhpf = 0.8, freq1bpf = 527, freq2bpf = 530, rq1bpf = 0.5, rq2bpf = 0.5, lpf = 100, rqlpf = 0.8, mixBpf = 0.1, doneAction = 2;
	    var sig, env, envp;
	    /*var env = EnvGen.ar(Env.perc(0,0.8));
	    var enf = EnvGen.ar(Env([16000,57,15000,11188.8],[0.001,0.001,0.0001],-4));*/
		env = Env.new(levels: [envL1, envL2, envL3, envL4], times: [envT1, envT2, envT3], curve: [curve, curve/2, curve]).kr(doneAction: doneAction);
		envp = Env.new(levels: [envpL1, envpL2, envpL3], times: [envpT1, envpT2], curve: [curvep, curvep * 1.25]).kr.midicps;
	    sig = SinOsc.ar(tu*envp,0,0.5)*env;
		sig = ((PinkNoise.ar*env) * mixNoise) + (sig * (1 - mixNoise));
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

	SynthDef(\snare2Sd,{arg out=0, amp=1, pan = 0, gate = 1;
		var env = EnvGen.ar(Env.perc(0.001,0.2),gate,doneAction:2);
		var freq = EnvGen.ar(Env([12000,100,12000],[0.01,0.01]));
		var sig = WhiteNoise.ar(env);
		sig = LPF.ar(sig,freq);
		sig = sig.tanh;
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp) );
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\snare2newSd, { arg out = 0, amp = 0.1,  pan = 0, tu = 1, gate = 1, envAtt = 0.1, envRel = 0.1, enfL1= 1600, enfL2 = 177, enfL3 = 190, enfT1 = 0.01, enfT2 = 0.1;
	    var sig;
	    var env = EnvGen.ar(Env.perc(envAtt,envRel));
	    var enf = EnvGen.ar(Env([enfL1,enfL2,enfL3],[enfT1,enfT2],-4));
	    var sig2 = BrownNoise.ar(1);
	    sig = SinOsc.ar(tu*enf+27,0,0.1)*env;
	    sig = WhiteNoise.ar(0.6)+sig+(LPF.ar(sig2,250,0.5)*env);
	//    sig = RHPF.ar(sig, \hpf.kr(100)*tu, \rq.kr(1));
	//    sig = sig + Mix.ar(BPF.ar(sig,[1207,4300],[0.5,0.5])*0.1);
	    //sig = RLPF.ar(sig, \lpf.kr(11000)*tu, \rq.kr(1));
	    //sig = CombL.ar(sig,0.2,0.1);
	    sig = BRF.ar(sig,450,0.3);
	    sig = HPF.ar(sig,250);
	    sig = sig * EnvGen.ar(Env.perc(0.02,\rel.kr(0.4),-4),gate,doneAction:2);
	    //sig = Pan2.ar(sig, pan, amp);
		// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\jungleSnareSd, { arg out = 0, amp = 0.1, pan = 0, envL1 = 1, envL2 = 0, envL3 = 1, envL4 = 0, envT1 = 0, envT2 = 0.004, envT3 = 0.05, envCurve = (-4), envfL1 = 1600, envfL2 = 5600, envfL3 = 800, envfL4 = 250, envfT1 = 0.001, envfT2 = 0.001, envfT3 = 0.001, envfCurve = (-4), envnAtt = 0.01, envnRel = 1, envnCurve = -4, noiseAmp = 1, tu = 1, kracter = 10, gate = 1, doneAction = 2;
		var sig;
		var env = EnvGen.ar(Env([envL1, envL2, envL3, envL4], [envT1, envT2, envT3], envCurve), gate, doneAction: doneAction);
		var envf = EnvGen.ar(Env([envfL1, envfL2, envfL3, envfL4],[envfT1, envfT2, envfT3], envfCurve));
		var envn = EnvGen.ar(Env.perc(envnAtt, envnRel), 1, envnCurve);
		sig = SinOsc.ar(tu*envf+107,0,0.5)*env;
		sig = (WhiteNoise.ar(envn) * noiseAmp) + sig;
		sig = RHPF.ar(sig, \hpf.kr(100)*tu, \hpfRq.kr(1));
		sig = sig + Mix.ar(BPF.ar(sig,[327,430],[0.5,0.5])*0.1)+ (WhiteNoise.ar(envn)+BrownNoise.ar(envn/8) * noiseAmp);
		sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \lpfRq.kr(0.5));
		sig =( Ringz.ar(WhiteNoise.ar,Mix.ar([envf,envf*0.9,envf*0.8]),1,0.01*env) +RLPF.ar(BrownNoise.ar(envn) * noiseAmp,envf*4,1,1)+sig )*envn ;
		sig = CompanderD.ar(sig*kracter,0.8,0.3,0.5,0.001,0.2,env);
		// sig = Pan2.ar(sig, pan, amp);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	t5snareSd = SynthDef(\t5snareSd, { arg out=0, amp=0.3, pan=0, tu=1, freq=200, gate=1, doneAction = 2;
		var sig;
		var env = EnvGen.ar(Env.perc(0.01,1));
		var enf = EnvGen.ar(Env([600,177,230],[0.01,0.1],-4));
		//sig = SinOsc.ar(tu*enf+1207,0,0.5)*env;
		sig = WhiteNoise.ar;
		sig = FreeVerb.ar(sig,0.5,1);
		sig = RHPF.ar(sig, \hpf.kr(180)*tu, \hpfRq.kr(0.5));
		sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
		sig = RLPF.ar(sig, \lpf.kr(12100)*tu, \lpfRq.kr(0.5));
		sig = sig * EnvGen.ar(Env.perc(0,\rel.kr(1),-4),gate,doneAction: doneAction);
		sig = sig*amp;
		sig = CompanderD.ar(sig,1,1,0.1,0.01,0.4);
		sig = FreeVerb.ar(sig,1,1)+sig;
		// sig = Pan2.ar(sig, pan, amp);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\snare808Sd, { arg out = 0, amp = 0.1, pan = 0, freq = 200, tu = 1, gate = 1;
		var sig;
		var env = EnvGen.ar(Env.perc(0.01,1));
		var enf = EnvGen.ar(Env([600,177,230],[0.01,0.01],-4));
		sig = SinOsc.ar(tu*enf+127,0,0.5)*env;
		sig = WhiteNoise.ar+sig;
		sig = RHPF.ar(sig, \hpf.kr(170)*tu, \rq.kr(0.5));
		sig = sig + Mix.ar(BPF.ar(sig,[127,430],[0.5,0.5])*0.1);
		sig = RLPF.ar(sig, \lpf.kr(11100)*tu, \rq.kr(0.5));
		sig = sig * EnvGen.ar(Env.perc(0.01,\rel.kr(0.1),-4),gate,doneAction:2);
		// sig = Pan2.ar(sig, pan, amp);
		// OffsetOut.ar(out, sig);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
	}).add;

	SynthDef(\snaremedSd, { | out = 0, level = 1, pan = 0, noise = 1, dc = 1, env0L1 = 1, env0L2 = 1, env0L3 = 1, env0L4 = 1, atkEnv0 = 0.01, decEnv0 = 0.2, rlsEnv0 = 0.26, fratio = 1.5, env1L1 = 120, env1L2 = 30, env1L3 = 30, env1T1 = 0.1, env1T2 = 0.2, curve1 = (-4), curve2 = (-2), curve3 = (-4), phase = 0, oamp = 0.1, owhich2 = 0, ochoose = 0, doneAction = 2|
		var env0,env1,
		env1m, son, son2,son3,son4,p2;
		p2 = phase * (-pi);
		env0 = Env([env0L1,env0L2,env0L3,env0L4,0],[atkEnv0,decEnv0,rlsEnv0],[curve1, curve2, curve3]);
		env1 = Env([env1L1,env1L2,env1L3],[env1T1,env1T2],[curve1, curve2, curve3]);

		env0 = EnvGen.ar(env0, doneAction: doneAction);
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

	SynthDef(\snareAwSd, {arg out = 0, amp = 0.1, pan = 0, sinfreq = 180, atk = 0.01, rls = 0.2, ffreq = 2000;
		var snd1 = WhiteNoise.ar(amp);
		var snd2 = SinOsc.ar(sinfreq,0,amp);
		var env = EnvGen.kr(Env.perc(atk, rls), doneAction: 2);
		var sum = HPF.ar(snd1, ffreq) + snd2;
		// OffsetOut.ar(out, Pan2.ar(sum * env, pan));
		OffsetOut.ar(out, DirtPan.ar(sum, ~dirt.numChannels, pan, env));
	}).add;

	SynthDef(\snareySd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.3, freq=120, gain=0.5, doneAction = 2;
		var env, sig, snare;
		env = EnvGen.kr(Env.perc(atk, rls, 1, -9), 1, doneAction: doneAction);
		sig = {(SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5))!2};
		sig = sig * gain;
		sig = sig.softclip * amp * env;
		// OffsetOut.ar(out, [sig,sig]);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\snarySd,{ arg out = 0, amp=0.75, pan = 0, atk = 0.001, rls = 0.1, curve = (-5), freq=120, gain=1, doneAction = 2;
		var env, sig, snare;
		env = EnvGen.kr(Env.perc(atk, rls, 1, curve), 1, doneAction: doneAction);
		sig = (SinOsc.ar(freq) - WhiteNoise.ar(0.5, 0.5)) * env * amp;
		sig = sig * gain * 0.4;
		sig = sig.softclip * amp;
		// OffsetOut.ar(out, [sig,sig]);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\kraftySnareSd, { arg out = 0, amp = 1, pan = 0, freq = 6000, rq = 3, atk = 0.01, dcy = 0.2, curve = -6, doneAction = 2;
		var snd, env;

		env = Env.perc(attackTime: atk, releaseTime: dcy, curve: curve).kr(doneAction: doneAction);

		snd = PinkNoise.ar(amp);

		snd = BPF.ar(snd, freq, rq, env);

		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\neuroSnareSd, { arg out = 0, amp = 0.1, pan = 0, freq = 160, curve = -4, preamp = 1.4,
		//Click Controls
		clickatk = 0.001, clicksst = 0.01, clickrls = 0.001, clickamp = 1, hipass = 300, lopass = 8000,
		//Body Controls
		bodyatk = 0.04, bodyrls = 0.2, bodyamp = 2,
		//Rattle Controls
		rattlehold = 0.01, rattleatk = 0.05, rattlerls = 0.2, rattleamp = 0.7, rattlefreq = 4000, rq = 0.5, rattlepeak = 3,
		//Sweep Controls
		sweepatk = 0.001, sweeprls = 0.02, sweepamp = 1, sweepstart = 3000, sweepend = 1500,
		doneAction = 2;

	    var snd, click, cEnv, body, bEnvFreq, bEnvAmp, rattle, rEnv, sweep, sEnvFreq, sEnvAmp;

	    // a percussive click to give it some attack
		cEnv = Env.linen(
			            attackTime: 0.001,
			            sustainTime: 0.01,
			            releaseTime: 0.001,
				        level: clickamp
		            ).ar;

		click = Hasher.ar(Sweep.ar);

		click = HPF.ar(in: click, freq: hipass);

	    click = LPF.ar(in: click, freq: lopass);

		click = click * cEnv;

	    // sine sweep body
		bEnvFreq = Env.new(
				        levels: [2.5, 1.225, 1],
				        times: [bodyatk, bodyrls],
				        curve: \exp
		            ).ar;

		bEnvAmp = Env.perc(
			            attackTime: bodyatk,
			            releaseTime: bodyrls,
			            level: bodyamp,
			            curve: curve
		            ).ar;

		body = SinOsc.ar(freq: freq * bEnvFreq, mul: bEnvAmp);

		body = body.tanh;

	    // sound of snare coils rattling
		rEnv = Env.perc(
				        attackTime: rattleatk,
				        releaseTime: rattlerls,
				        level: rattleamp,
				        curve: curve
		            ).delay(rattlehold).ar;

		rattle = Hasher.ar(Sweep.ar);

		rattle = BPeakEQ.ar(in: rattle, freq: rattlefreq, rq: rq, db: rattlepeak);

		rattle = HPF.ar(in: rattle, freq: hipass);

		rattle = rattle * rEnv;

	    // another sound sweep to improve the atk, optional
		sEnvFreq = XLine.kr(
			    	    start: sweepstart,
			    	    end: sweepend,
			    	    dur: sweeprls / 2
		            );

		sEnvAmp = Env.perc(
				        attackTime: sweepatk,
				        releaseTime: sweeprls,
				        level: sweepamp,
				        curve: curve
		            ).ar;

		sweep = SinOsc.ar(freq: sEnvFreq, mul: sEnvAmp);

	    // distortion helps glue everything together and acts as a compressor
		snd = Mix.ar(click + body + rattle + sweep);

		snd = (snd * preamp).tanh * amp;

		DetectSilence.ar(in: snd, doneAction: doneAction);

		// OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\snare909Sd, { arg out = 0, amp = 0.5, pan = 0, freq = 85, atk = 0.0005, curve = -2, toneRel = 0.075, toneAmp = 0.25, noiseRel = 0.4, noiseAmp = 0.2, nyquist = 2200, lpFreq = 7040, hpFreq = 523, doneAction = 2;
		var rlsTimes, env, tone, noise, snd;

		rlsTimes = ([1, 0.733] * toneRel) ++ ([1, 0.708] * noiseRel);

		env = Env.perc(attackTime: atk, releaseTime: rlsTimes, level: amp, curve: curve).kr;

		tone = LFTri.ar(freq: [1, 1.78] * freq, mul: toneAmp);

		noise = Latch.ar(WhiteNoise.ar, Impulse.ar(nyquist * 2));

		noise = LPF.ar(in: noise, freq: lpFreq, mul: noiseAmp);

		snd = tone ++ [noise, HPF.ar(in: noise, freq: hpFreq)];

		snd = Mix.ar(snd * env);

		DetectSilence.ar(in: snd, doneAction: doneAction);

	    // OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\snareElectroSd, { arg out = 0, amp = 0.4, pan = 0, atk = 0.001, rls = 0.15, curve = -4, popfreq = 160, sweep = 0.01, noisefreq = 810, rq = 1.6, blend = 0.41, doneAction = 2;
	    var pop, popEnv, popSweep, noise, noiseEnv, snd;

	    // pop makes a click coming from very high frequencies
	    // slowing down a little and stopping in mid-to-low
	    popSweep = Env.new(levels: [20.4, 2.6, 1] * popfreq, times: [sweep / 2, sweep], curve: \exp).ar;

	    popEnv = Env.perc(attackTime: atk, releaseTime: 0.73 * rls, level: blend, curve: curve).kr;

		pop = SinOsc.ar(freq: popSweep, mul: popEnv);

	    // bandpass-filtered white noise
	    noiseEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 1 - blend, curve: curve).kr(doneAction: doneAction);

		noise = BPF.ar(in: WhiteNoise.ar, freq: noisefreq, rq: rq, mul: noiseEnv);

	    snd = Mix.ar(pop + noise) * amp;

	    // OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\snareSteinSd, { arg out = 0, amp = 1, pan = 0, atk = 0.0005, curve = -4, tonerls = 0.075, noiserls = 0.2,
		//Other Controls, blend ranges from 0 to 1.
		noisetop = 7040, noisebottom = 523, noiseamp = 0.2, tonelo = 185, tonehi = 330, toneamp = 0.5, blend = 0.2,
		doneAction = 2;

	    var env, tone, noise, snd;

		env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
		//Sines for the frequency of the drum:
	    tone = SinOsc.ar(freq: [tonelo, tonehi]);

		tone = tone * Env.perc(
			                attackTime: atk,
			                releaseTime: [tonerls, 0.73 * tonerls],
			                level: toneamp,
			                curve: curve
		                ).kr;

		//Noise for the rattling of the snares: (original used WhiteNoise alone)
		noise = PinkNoise.ar(noiseamp * (1 - blend)) + WhiteNoise.ar(noiseamp * blend);

		noise = LPF.ar(in: noise, freq: noisetop);

		snd = noise * Env.perc(
			                attackTime: atk,
			                releaseTime: noiserls,
			                curve: curve
		                ).kr;

		snd = snd +	HPF.ar(
			            in: noise,
			            freq: noisebottom,
			            mul: Env.perc(
				                    attackTime: atk,
				                    releaseTime: 0.915 * noiserls,
				                    curve: curve
				                ).kr
		            );

		//Mix it all together:
		snd = Mix.ar(snd + tone) * amp * env;

		//DetectSilence.ar(in: snd, doneAction: doneAction);

	    // OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	SynthDef(\sosSnareSd, { arg out = 0, amp = 0.8, pan = 0, atk = 0.005, rls = 0.1, curve = -4, freq = 405,
		//drumMode Controls
		drumModeAmp = 0.25, timbreIndex = 0.385, modHarmonic = 0.452,
		//snares controls
		snareAmp = 40, nyquist = 1700, snareRez = 1000, ffreq = 2000, rq = 0.1, bwr = 1,
		doneAction = 2;

		var env, drumMode, drumModeEnv, snares, snareEnv, snd;

		env = EnvGen.kr(Env.linen(0.01, 1, 2), doneAction: doneAction);
		drumModeEnv = Env.perc(attackTime: atk, releaseTime: rls, level: 0.5, curve: curve).kr;

		drumMode = SinOsc.ar(freq: freq * 0.53, mul: drumModeEnv);

		drumMode = drumMode + SinOsc.ar(freq: freq, mul: drumModeEnv);

		drumMode = drumMode + PMOsc.ar(
			            carfreq: Saw.ar(freq * 0.85),
						modfreq: freq * modHarmonic,
						pmindex: timbreIndex,
						mul: drumModeEnv * 10);

		drumMode = Mix.ar(drumMode) * drumModeAmp;

		snareEnv = Env.perc(attackTime: atk, releaseTime: rls, curve: curve).kr;

		snares = Latch.ar(WhiteNoise.ar(0.1), Impulse.ar(nyquist * 2));

		snares = BRF.ar(in: snares, freq: 4 * ffreq, mul: 0.5, rq: rq);

		snares = BRF.ar(in: snares, freq: 2.5 * ffreq, mul: 0.5, rq: rq);

		snares = BRF.ar(in: snares, freq: 1.8 * ffreq, mul: 0.5, rq: rq);

		snares = BRF.ar(in: snares, freq: ffreq, mul: snareEnv, rq: rq);

		snares = Resonz.ar(in: snares, freq: snareRez, bwr: bwr, mul: snareAmp) ;

		snd = Mix.new(drumMode + snares) * env * amp;

		//DetectSilence.ar(in: snd, doneAction: doneAction);

	    // OffsetOut.ar(out, Pan2.ar(snd, pan));
		OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan));
	}).add;

	)
