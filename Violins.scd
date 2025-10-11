s.boot;


(
SynthDef(\violin, { |note|
	var sig;
	var env;

	// life
	Line.kr(1.0, 0.0, 12.0, doneAction: 2);

	env = EnvGen.kr(Env([0, 1, 0], [1, 5])) * 0.008;
	sig = SinOsc.ar(note.midicps * FSinOsc.kr(5.7, 0.0, 0.02, 1.0), mul: env);
	sig = FreeVerb.ar(sig, 1.0, 1.0, 0.1);

	Out.ar([0, 1], sig.tanh);
}).add;
)

(
~playViolin = Routine.new({
	inf.do({
		Synth(\violin, [note: [90, 91, 92, 93].choose + [12].choose]);
		((30 * 8) / ~bpm).yield;
	});
})
)

(
~violinGen = Routine.new({
	inf.do({
		~playViolin.next.wait;
	})
})
)

~violinGen.play;
~violinGen.stop;
~violinGen.reset;