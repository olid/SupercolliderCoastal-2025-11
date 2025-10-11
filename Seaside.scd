s.boot;

(
SynthDef(\seawave, { |strength = 1, pan = 0|
	var sig = 0;
	var peb = 0;
	var sea = 0;
	var env = 0;

	pan = [strength * pan, strength * (1.0 - pan)];

	// life
	Line.kr(1.0, 0.0, 12.0, doneAction: 2);

	env = EnvGen.kr(Env([0, 1, 0], [2, 10]));
	sea = WhiteNoise.ar(mul: pan) * 0.3;
	sea = BPF.ar(sea, 400 + (strength * 500), 0.8);

	// peb = SinOsc.ar(400, 3.14.rand2, Decay.kr(Dust.kr(5), 0.1)) * env;
	// peb = PitchShift.ar(peb, 0.1, 0.0, 4.0, 1.0);
	// peb = FreeVerb.ar(peb, 1.0, 0.01, 0.0);
	// peb = FreeVerb.ar(peb, 0.4, 1.0, 0.0);
	// peb = FreeVerb.ar(peb, 0.4, 1.0, 0.1);

	sig = (sea + peb) * env * env;

	Out.ar([0, 1], sig.tanh);
}).add;
)

(
~playWave = Routine.new({
	inf.do({
		Synth(\seawave, [strength: 0.2 + 0.8.rand, pan: 1.0.rand]);
		(6.0 + 2.0.rand).yield;
	});
})
)

(
~seaGen = Routine.new({
	inf.do({
		~playWave.next.wait;
	})
})
)

~seaGen.play;
~seaGen.stop;
~seaGen.reset;