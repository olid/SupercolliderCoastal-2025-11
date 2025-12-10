s.boot;


(
SynthDef(\snh, { |time|
	var sig = 0;
	var env;
	var frq;
	var tmp = ~bpm / 60 * 4;
	var mod;
	var top = 3000;

	// life
	Line.kr(1.0, 0.0, time * 4, doneAction: 2);

	env = Line.kr(1.0, 0.0, time);
	mod = Decay.ar(Impulse.ar(tmp), 0.2, add: 0.2);

	frq = LFNoise0.kr(tmp, 180, 200);
	sig = Pulse.ar(frq, 0.5, env) + Saw.ar(frq * 2, env * 0.3);
	sig = sig * mod;
	sig = Mix.ar([
		RLPF.ar(sig, Line.kr(top, 200.0, time) * mod * 2, 0.1)
	]);
	sig = (sig * 2).tanh;
	sig = Decimator.ar(sig, 1.0);
	sig = AllpassN.ar(sig, 0.050, [LFNoise0.kr(tmp * 0.25, 0.024, 0.025),LFNoise0.kr(tmp * 0.25, 0.024, 0.025)], 2);
	sig = FreeVerb.ar(sig, 0.1, 1.0, 0.1);

	Out.ar([0, 1], sig * 0.4);
}).add;
)

(
SynthDef(\sinz, { |time, fnd, ratio, mix|
	var sig = 0;
	var sig1 = 0;
	var sig2 = 0;
	var delay = 0;
	var frq = fnd;
	var prt = 8;

	// life
	Line.kr(1.0, 0.0, 7.0, doneAction: 2);

	prt.do({
		frq = Wrap.kr(frq * ratio, 50, 8000);

		delay = delay + (time / 8.0);

		sig1 = sig1 + SinOsc.ar(frq, mul: EnvGen.kr(Env([0, 0, 1, 1, 0], [delay, 0.02, time - delay, 0.02])));
		sig2 = sig2 + SinOsc.ar(frq * (1.0 + 0.1.rand), mul: EnvGen.kr(Env([0, 0, 1, 1, 0], [delay, 0.02, time - delay, 0.02])));
	});

	sig = [sig1, sig2];

	sig = FreeVerb.ar(sig, 0.1, 1.0, 0.1);

	Out.ar([0, 1], (sig * 0.3 / prt).tanh);
}).add;
)

Synth(\bnk, [time: 2.0]);

(
SynthDef(\bnk, { |time, fnd|
	var sig = 0;
	var sig1 = 0;
	var sig2 = 0;
	var prt = 3;
	var modEnv = 0;
	var ampEnv = 0;
	var gatEnv = 0;
	var trig = 0;

	// life
	Line.kr(1.0, 0.0, time + 4.0, doneAction: 2);

	gatEnv = EnvGen.kr(Env([1, 1, 0], [time, 0.1]));
	modEnv = Line.kr(1, 30, time + 2.0);
	trig = Impulse.kr(modEnv);
	ampEnv = Decay.ar(T2A.ar(trig), 0.5) * gatEnv;

	prt.do({
		sig1 = sig1 + SinOsc.ar(Latch.kr(LFNoise1.kr(100, 1, 0).linexp(0, 1, 100, 7000), trig), mul: ampEnv / prt);
		sig2 = sig2 + SinOsc.ar(Latch.kr(LFNoise1.kr(100, 1, 0).linexp(0, 1, 100, 7000), trig), mul: ampEnv / prt);
	});

	sig = [sig1, sig2];

	sig = FreeVerb.ar(sig, 0.1, 1.0, 0.1);

	Out.ar([0, 1], (sig * 1).tanh);
}).add;
)