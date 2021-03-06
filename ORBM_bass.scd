(

    ///////////////////////////////////////  Bass

    SynthDef(\bass1Sd,{arg out = 0, amp = 0.5, pan = 0, atk = 0, dcy = 8, sst = 1, rls = 4, tu = 1, gate = 1, doneAction = 2;
        var env = EnvGen.ar(Env.adsr(atk, dcy, sst, rls), gate, doneAction: doneAction);
        var freq = EnvGen.ar(\freqenv.kr(Env([50, 40],[0.1, 0.3, 0.3])));
        var sig = SyncSaw.ar(freq*tu,20);
        sig = BRF.ar(sig,432,1);
        sig = HPF.ar(sig,300);
    	// sig = Pan2.ar(sig.distort, pan, amp) * env;
        // OffsetOut.ar(out, sig);
    	OffsetOut.ar(out, DirtPan.ar(sig.distort, ~dirt.numChannels, pan, amp * env));
    }).add;

    SynthDef(\bass3Sd,{arg out=0, amp=1, pan = 0, rls = 0.1, tu = 1.54, gate = 1;
        var env = EnvGen.ar(Env.adsr(0,4,1,0.1),gate,doneAction:2);
        var freq = EnvGen.ar(Env([14000,50,30],[0.001,0.1,0.1]));
        var sig = LFPar.ar([tu,tu+1],SinOsc.kr([2,1]))+LFPar.ar(tu,SinOsc.kr([1,2]));
        sig = Splay.ar(sig,SinOsc.kr(0.1),1,SinOsc.kr(pan));
        // OffsetOut.ar(out,sig*amp*env);
    	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
    }).add;

    SynthDef(\bassSd,{arg out = 0, amp = 1, pan = 0, dis = 0.5, freq = 60, tu = 1, atf = 80, rls = 1, gate = 1;
        var env = EnvGen.ar(Env.adsr(0.05,0,1,rls),gate,doneAction:2);
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

    SynthDef(\sinBassSd, { arg out = 0, gate = 1, amp = 1, pan = 0, loopNode = nil, atk = 0.2, rls = 4, curve = (-4), envLevel1 = 0, envLevel2 = 40, envLevel3 = 32, envLevel4 = 50, envLevel5 = 0, envLevel6 = 60, envTime1 = 0.5, envTime2 = 0.3, envTime3 = 0.25, envTime4 = 1, envTime5 = 0.5, doneAction = 2;
    	var freqEnv, env, sig;
    	freqEnv = EnvGen.kr(Env([envLevel1, envLevel2, envLevel3, envLevel4, envLevel5, envLevel6], [envTime1, envTime2, envTime3, envTime4, envTime5], curve), gate);
    	env = EnvGen.kr(Env.asr(atk, 1, rls, curve), gate, doneAction: doneAction);
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

    SynthDef(\moogBassSd, { arg out = 0, amp = 0.1, pan = 0, freq = 40, cutoff = 1000, gain = 2.0, lagamount = 0.01, atk = 0.001, dcy = 0.3, sst = 0.9, rls = 0.2, chorus = 0.7, gate = 1, doneAction = 2;
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

    SynthDef(\tweetAnaBassSd, { arg out = 0, amp = 1, pan = 0, atk = 0.01, rls = 2, freq = 60, ffreq = 60, tu = 9, compTresh = 0.5, gate = 1, doneAction = 2;
    	var sig, env, bw;
    	bw = LFNoise0.ar(_);
    	sig = max(
    		max(bw.(4),l=bw.(6)),
    		SinOsc.ar(freq * ceil(l*tu).lag(0.1))*0.7
    	);
    	sig = tanh(
    		BBandPass.ar(sig, ffreq, bw.(1).abs/2)*700*l.lag(1)
    	);
    	env = EnvGen.kr(Env.asr(atk, releaseTime: rls), gate, doneAction: doneAction);
    	sig = sig * env;
    	sig = Compander.ar(sig, sig, compTresh, 1, 1/8, 0.002);
    	// OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp));
    }).add;

    SynthDef(\triangleWaveBellsSd,{ arg out = 0, amp = 1.0, pan = 0.0, atk = 0.01, dcy = 0.1, sst = 1, rls = 0.5, freq = 40, lforate = 10, lfowidth = 0.0, cutoff = 100, rq = 0.5, gate = 1, doneAction = 2;

    	var osc1, osc2, vibrato, filter, env;
    	vibrato = SinOsc.ar(lforate, Rand(0, 2.0));
    	osc1 = Saw.ar(freq * (1.0 + (lfowidth * vibrato)), 0.75);
    	osc2 = Mix(LFTri.ar((freq.cpsmidi + [11.9, 12.1]).midicps));
    	filter = RHPF.ar((osc1 + (osc2 * 0.5)) * 0.5, cutoff, rq);
    	env = EnvGen.ar(
    		envelope: Env.adsr(atk, dcy, sst, rls, amp),
    		gate: gate,
    		doneAction: doneAction);
    	// OffsetOut.ar(out, Pan2.ar(filter * env, pan));
    	OffsetOut.ar(out, DirtPan.ar(filter, ~dirt.numChannels, pan, env));
    }).add;

)
