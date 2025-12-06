s.boot;


(
SynthDef(\violin, { |note|
	var sig;
	var env;
	var frq;

	// life
	Line.kr(1.0, 0.0, 12.0, doneAction: 2);

	frq = note.midicps;
	env = EnvGen.kr(Env([0, 1, 0], [1, 5])) * 0.008;
	sig = Pulse.ar(frq * FSinOsc.kr(5.7, 0.0, 0.02, 1.0), mul: 0)
	// + Pulse.ar(frq * (1.0 / 16) * FSinOsc.kr(3.3, 0.0, 0.02, 1.0), mul: env * 2.0)
	  + Pulse.ar(frq * (1.0 / 16) * FSinOsc.kr(3.4, 0.2, 0.02, 1.0), mul: env * 2.0);

	sig = Mix.ar(BPF.ar(sig, LFNoise1.kr({ 0.1 + 1.0.rand } ! 4, 1000, 1200), 0.1));

	sig = Resonz.ar(sig, Latch.kr(EnvGen.kr(Env([0, 1, 0.5], [3, 3])).linexp(0, 1, 100, 5000), Pulse.kr(8)), 0.1);

	sig = FreeVerb.ar(sig * 96, 0.1, 1.0, 0.1);

	Out.ar([0, 1], sig.tanh);
}).add;
)

(
~playViolin = Routine.new({
	inf.do({
		var waitTime = ((30 * 16) / ~bpm);
		Synth(\violin, [note: [0, 2].choose + 1.0.rand + 90 + [-12].choose]);
		waitTime.yield;
	});
})
)

(
~violinGen = Routine.new({
	var waitTime = 2.0;

	postln("Starting...");
	inf.do({
		~playViolin.next.wait;
	})
})
)

~playViolin.play;

~violinGen.play;
~violinGen.stop;
~violinGen.reset;