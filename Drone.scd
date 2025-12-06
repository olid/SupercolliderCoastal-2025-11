
s.boot;

~bpm = 170;

(
SynthDef(\metalDrone, { |verbWet, vibrato, tremolo, beats, dust|
	var sig;
	var top = 800;
	var prt = 12;
	var frq = 0.0;
	var bpf = ~bpm / (30.0 * beats);
	var len = ((60 * 32) / ~bpm) * 1.2;

	// life
	Line.kr(1.0, 0.0, len + 5.0, doneAction: 2);

	sig = 0.0;
	prt.do({ sig = SinOsc.ar({ 1.0.rand.linexp(0, 1, 40, top) } ! 2 * FSinOsc.kr(0.3, 0.0, vibrato, 1.0), 3.14.rand2, 1.0 / 8) * LFNoise1.kr(1.0.rand) + sig });

	sig = sig * SinOsc.kr(bpf, mul: 0.5 * vibrato, add: 1.0 - (0.5 * tremolo));
	sig = sig * EnvGen.kr(Env([0, 1, 0], [2.0, len])) * 1.0;

	4.do({ sig = RLPF.ar(sig, Line.kr(0, 1, len).linexp(0, 1, 50, top * 2), 1.0); });

	sig = HPF.ar(sig, 50);
	sig = FreeVerb.ar(sig, verbWet, 2.0, 0.01);

	Out.ar([0, 1], sig.tanh * 2.0);
}).add;
)

Synth(\metalDrone, [verbWet: 0.5, tremolo: 1.0, vibrato: 0.01, beats: 1, dust: 1]);

(
~dronePlay = Routine.new({
	inf.do({
		Synth(\metalDrone, [verbWet: 1.0.rand, tremolo: 0.0, vibrato: 0.01, beats: 1, dust: 1]);

		0.yield;
	});
})
)

(
~droneGen = Routine.new({
	inf.do({
		~dronePlay.next;
		((60 * 32) / ~bpm).wait;
	})
})
)

~droneGen.play;
~droneGen.stop;
~droneGen.reset;