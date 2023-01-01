// https://github.com/v7b1/mi-UGens

(
SynthDef(\braids, {|out = 0, amp = 0.3, pan = 0, sustain = 1, begin = 0, end = 1, freq = 440, speed = 1, accelerate = 0, timbre = 0.5, color = 0.5, model = 0|
	var envLength = sustain*(end-begin)/speed;
	var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
	var env = Env.asr;
	var volume = IEnvGen.ar(env, line);
	var sig;

	freq = max(0, freq * speed * (1 + (accelerate * line)));
	sig = MiBraids.ar(pitch: freq.cpsmidi, timbre: timbre, color: color, model: model);

	OffsetOut.ar(out, DirtPan.ar(sig * amp * volume, ~dirt.numChannels, pan));
}).add;
);

(
  SynthDef(\omi, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiOmi.ar(pit: freq.cpsmidi);

    OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
  SynthDef(\plaits, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
      timbre=0.5,engine=0,harm=0.5,morph=0.5,level=1,lpgdecay=0,lpgcolour=0|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiPlaits.ar(
      pitch: freq.cpsmidi,
      timbre: timbre,
      harm: harm,
      engine: engine,
      morph: morph,
      level: level,
      decay: lpgdecay,
      lpg_colour: lpgcolour,
    );

    OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
  SynthDef(\tides, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,tidesshape=0.5,slope=0.5,tidessmooth=0.5,shift=0.5,mode=2|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiTides.ar(
      freq: freq,
      shape: tidesshape,
      slope: slope,
      smooth: tidessmooth,
      shift: shift,
      output_mode: mode,
      ramp_mode: 1,
      rate: 1
    );

    OffsetOut.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);