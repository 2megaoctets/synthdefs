(
///////////////////////////////////////  Rimshot

SynthDef(\rimSd, { arg out = 0, amp = 0.2, pan = 0, tu = 1, envLev1 = 1, envLev2 = 0, envLev3 = 1, envLev4 = 0,  atk = 0, dcy = 0.004, rls = 0.1, gate = 1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env([envLev1, envLev2, envLev3, envLev4], [atk, dcy, rls]), gate, doneAction: doneAction);
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

SynthDef(\rimnewSd, { arg out=0, amp=0.01, pan=0, tu=1, atk = 0.0001, rls=1, freqTime1 = 0.001, freqTime2 = 0.01, gate=1, doneAction=2;
    var sig;
    var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
var frequ = EnvGen.ar(Env([1500,500,210.4],[freqTime1, freqTime2]));
    sig = SinOsc.ar(tu*frequ)*env;
    sig = Ringz.ar(sig,(30..35)*10.234*tu,1).mean;
    // sig = Pan2.ar(sig*env, pan, amp);
    // OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

SynthDef(\rim808Sd, { arg out=0, amp=0.01, pan=0, atk = 0.001, rls=1, tu=1, tuf=1, gate=1, doneAction = 2;
	var sig;
	var env = EnvGen.ar(Env.perc(atk, rls), gate, doneAction: doneAction);
	sig = SinOsc.ar(tu*400)*env;
	sig = Ringz.ar(sig,(30..35)*10.234*tuf,1).mean;
	// sig = Pan2.ar(sig*env, pan, amp);
	// OffsetOut.ar(out, sig);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, amp * env));
}).add;

)
