s.boot();

b = Buffer.alloc(s, 512, 1, {arg buf; buf.chebyMsg([0.25,0.5,0.25], false)});

(
SynthDef(\kick, { |amp = 0.0, out = 0, ptch = 1.0|
	var pitchEnv = XLine.kr(600, 40, 0.02) * ptch;
	var sig = SinOsc.ar(pitchEnv) * Line.kr(0.02, 0, 0.1, doneAction: Done.freeSelf);
	var shaped = 0;

	sig = RLPF.ar(sig, (amp).linexp(0, 1, 200, 500), 0.8);
	sig = Shaper.ar(b, sig * amp * 10.5, 0.8) * 10;

	Out.ar([0, 1], sig);
}).add;
)

(
SynthDef(\snare, { |amp = 0.0, out = 0, ptch = 1.0, cut = 1.0, res = 0.1 |
	var life = Line.kr(1.0, 0.0, 0.4, doneAction: Done.freeSelf);

	var prts = (1 + 16.0.rand).floor;
	var tp1 = 50 + 1000.0.rand;
	var tp2 = 50 + 8000.0.rand;

	var harmonicsHi = Mix.ar(SinOsc.ar({ 1.0.rand.linexp(0, 1, 50, tp1) * ptch } ! prts, mul: Line.kr(1.0.rand, 0.0, 1.0.rand.linexp(0, 1, 0.01, 0.2))));
	var harmonicsLo = Mix.ar(SinOsc.ar({ 1.0.rand.linexp(0, 1, 50, tp2) * ptch } ! prts, mul: Line.kr(1.0.rand, 0.0, 1.0.rand.linexp(0, 1, 0.01, 0.2))));
	var kicker = Shaper.ar(b, SinOsc.ar(Line.kr(100 + 3000.rand, 50 + 50.rand, 0.001 + 0.02.rand) * ptch, 0, Line.kr(1.0.rand, 0.0, (0.1 + 0.09.rand2))).tanh, 1.0 + 2.0.rand);
	var noise1 = BPF.ar(WhiteNoise.ar(), 1.0.rand.linexp(0, 1, 1000, 12000) * ptch, 0.01 + 0.4.rand, Line.kr(4.0.rand, 0.0, 1.0.rand.linexp(0, 1, 0.01, 0.2)));
	var noise2 = BPF.ar(WhiteNoise.ar(), 1.0.rand.linexp(0, 1, 1000, 12000) * ptch, 0.01 + 0.4.rand, Line.kr(4.0.rand, 0.0, 1.0.rand.linexp(0, 1, 0.01, 0.2)));

	var sig = ((harmonicsHi * 0.3) + (harmonicsLo * 0.3) + (kicker * 1.0) + (noise1 * 1.0) + (noise2 * 1.0) * 2).tanh * amp;
	sig = RLPF.ar(sig, (amp).linexp(0, 1, 50, 10000), 0.8);

	Out.ar([0, 1], sig);
}).add;
)

(
SynthDef(\click1, { |amp = 1.0, dec = 0.01, out = 0|
	var pitch = 5000;
	var spread = 0.9;

	var ampEnv = Line.kr(0.07, 0.0, dec, doneAction: Done.freeSelf);
	var sig = Mix.ar(FSinOsc.ar({ pitch + (pitch * spread).rand2 } ! 16, 0.0, 0.1, 0.0));

	Out.ar([0, 1], sig * 0.7 * amp);
}).add;
)

(
SynthDef(\click2, { |amp = 1.0, dec = 0.01, out = 0|
	var pitch = 11000;
	var spread = 0.8;

	var ampEnv = Line.kr(0.07, 0.0, dec, doneAction: Done.freeSelf);
	var sig = Mix.ar(FSinOsc.ar({ pitch + (pitch * spread).rand2 } ! 16, 0.0, 0.1, 0.0));

	Out.ar([0, 1], sig * 0.8 * amp);
}).add;
)

(
SynthDef(\hihat1, { |amp = 1.0, dec = 0.2, out = 0|
	var pitch = 7000;
	var spread = 0.4;

	var ampEnv = Line.kr(1.0, 0.0, dec, doneAction: Done.freeSelf);
	var sig = Mix.ar(FSinOsc.ar({ pitch + (pitch * spread).rand2 } ! 16, 0.0, 0.1, 0.0));

	Out.ar([0, 1], sig * 0.4 * ampEnv * ampEnv * ampEnv);
}).add;
)

(
SynthDef(\hihat2, { |amp = 1.0, dec = 0.04, out = 0|
	var pitch = 7000;
	var spread = 0.4;

	var ampEnv = Line.kr(1.0, 0.0, dec, doneAction: Done.freeSelf);
	var sig = Mix.ar(FSinOsc.ar({ pitch + (pitch * spread).rand2 } ! 16, 0.0, 0.1, 0.0));

	Out.ar([0, 1], sig * 0.4 * ampEnv * ampEnv * ampEnv);
}).add;
)

(
SynthDef(\scridge, { |amp = 1.0, dec = 0.01, out = 0, timbre = 300|
	var pitch = timbre;
	var spread = 0.7;

	var ampEnv = Line.kr(1.0, 0.0, dec, doneAction: Done.freeSelf);
	var sig = Mix.ar(FSinOsc.ar({ pitch + (pitch * spread).rand2 } ! 16, 0.0, 0.1, 0.0));
	sig = (sig * 10.0).tanh;

	Out.ar([0, 1], sig * 0.4 * ampEnv);
}).add;
)

(
~drumCommandGen = Routine.new({
	var drum = 0;
	var beats = 0;
	var roll = 0;
	var decay = 1.0;
	var hold = 0.0;
	var count = 0;
	var click = 0;
	var hat = 0;
	var amp = 0;

	var rollType;

	var drums = [0, 1];// 0, 0, 1];

	var beatsByDrum = [
		[1, 1, 1, 1, 1, 8],//1, 1, 1, 3, 3, 8],//1, 1, 1, 1, 2, 2, 3],//, 4, 8],
		[1, 2, 3],//, 1, 1, 1, 1, 1, 2, 2, 3],
		[2]
	];

	var rollsByDrum = [
		[1, 1, 1, 1, 1, 1, 1, 2, 3, 4],//, 3, 3],
		[1, 1, 1, 1, 1, 1, 1, 2, 3, 4],//, 2, 3, 4],
		[1]
	];

	inf.do({
		drum = drums.choose;
		beats = beatsByDrum[drum].choose;
		roll = rollsByDrum[drum].choose;

		click = 2;//[0, 1].choose;
		hat = 2;//[0, 1].choose;

		rollType = [1, 2, 3, 3].choose;
		if (rollType == 0, { amp = 0.0; decay = 0.0 }, { });
		if (rollType == 1, { amp = 1.0; decay = 0.0 }, { });
		if (rollType == 2, { amp = 0.1; decay = 1.2 + 0.3.rand }, { });
		if (rollType == 3, { amp = 1.0; decay = 0.5 + 0.4.rand }, { });

		count = beats * roll;
		hold = beats / count;

		[drum, beats, roll, decay, hold, count, hat, amp, click, 1.0].yield;
	})
})
)

~bpm = 170;
~scrodBase = 300;
~scrodRand = 10000;

(
~soundGen = Routine.new({
	inf.do({
		var command = ~drumCommandGen.next;
		var drum = command[0];
		var beats = command[1];
		var roll = command[2];
		var decay = command[3];
		var hold = command[4];
		var count = command[5];
		var hat = command[6];
		var amp = command[7];
		var click = command[8];
		var ptch = command[9];

		var timbre = ~scrodBase + ~scrodRand.rand;

		var waitTime = if (drum == 2, { ~bpm / 60.0 }, { (hold / (~bpm / 15.0)) });
		var loopCount = if (drum == 2, { 1 }, { count });

/*		if (hat == 0, { Synth(\hihat1, [amp: amp]) });
		if (hat == 1, { Synth(\hihat2, [amp: amp]) });*/

		for (1, loopCount, {
			if (drum == 0, { Synth(\kick, [amp: amp, ptch: ptch]) });
			if (drum == 1, { Synth(\snare, [amp: amp, ptch: ptch]) });

			if (click == 0, { Synth(\click1, [amp: amp]) });
			if (click == 1, { Synth(\click2, [amp: amp]) });

			if (hat == 0, { Synth(\hihat1, [amp: amp]) });
			if (hat == 1, { Synth(\hihat2, [amp: amp]) });
			// if (hat == 1, { Synth(\scridge, [amp: amp, timbre: timbre]) });

			amp = amp * decay;

			if (amp > 1.0, { amp = 1.0 }, { });

			waitTime.wait;
		});
	})
})
)

~soundGen.play;
~soundGen.stop;
~soundGen.reset;



