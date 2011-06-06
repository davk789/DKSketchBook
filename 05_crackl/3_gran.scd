/**
	reverberate sequence thru mp3 artifacts
*/

p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;

// ** reverb section

~fftsize = 2048;
fork{
	~rvL = DKBufferUtils.loadIRBuffer(
		"~/Music/Edits/khrush/khr-lowest-hip-imp-l.aif".standardizePath,
		~fftsize
	);
	~rvR = DKBufferUtils.loadIRBuffer(
		"~/Music/Edits/khrush/khr-lowest-hip-imp-r.aif".standardizePath,
		~fftsize
	);
}

p.rv[0] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rvL.bufnum);
	Pan2.ar(sig, -1, lev)
};

p.rv[1] = { |lev=0.3|
	var in, sig;
	in = In.ar(1);
	sig = PartConv.ar(in, ~fftsize, ~rvR.bufnum);
	Pan2.ar(sig, 1, lev)
};

p.rv.setRates(\lev, 5);
p.rv.set(\lev, 0.0825)

p.rv.play
p.rv.stop
p.rv.clear
// ** bassline
p.bass = \s_bass;

~root = 160;
~dur = 0.6;
~notes = Pseq([
	[~root * 1/1, ~dur * 1],
	[~root * 1/1, ~dur * 1],
	//	[~root * 1/1, ~dur * 1],
	[~root * 1/1, ~dur * 1],
	[~root * (4/3), ~dur * 1],
	[~root * (6/5), ~dur * 1],
	[~root * (7/8), ~dur * 1],
	[~root * 1/1, ~dur * 1],
], inf).asStream;

~notes = Pseq(
	[
						[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (1/1),   ~dur * 1],
		[~root * (7/8),   ~dur * 1],
		[~root * (15/7),  ~dur * 1],
		//	[~root * (15/8),   ~dur * 1],
		[~root * (1/1),   ~dur * 1],
		[~root * (14/11), ~dur * 0.2],
		[~root * (3/2),   ~dur * 1],
	], inf).asStream;

~notes = Pseq(
	[
		[~root * (1/1),   ~dur * 1],
	], inf).asStream;

		p.bass.spawn([\freq, 60, \dur, 15, \lfreq, 5.rand]);

Tdef(\ba, {
	loop{
		postln("next");
		p.bass.spawn([\freq, [60,70,80,90,100,110,120].choose, \dur, 30, \lfreq, 45.rand]);
		15.wait;		
	}
});

p.clock.tempo = 1
Tdef(\ba).play
Tdef(\ba).stop

Tdef(\bassline, { arg root=100;
	var dur, notes;
	loop{
		dur = ~notes.next[1];
		p.bass.spawn([\freq, ~notes.next[0], \dur, dur, \lfreq, 45]);
		dur.wait;
	}
});

Tdef(\bassline).play;
Tdef(\bassline).stop;

Tdef(\bassline2, { arg root=100;
	var dur;
	loop{
		dur = ~notes.next[1];
		p.bass.spawn([\freq, ~notes.next[0], \dur, dur, \lfreq, 45.rand]);
		dur.wait;
	}
});

Tdef(\bassline2).play;
Tdef(\bassline2).stop;

p.clock.tempo = 0.125;

//** SynthDefs
// bassline synth
SynthDef("s_bass", 
	{ arg freq=220, pan=0, dur=1,
		  lfreq=10, lev=0.4;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0.6, 0.6, 0],
				[0.02, 0.1, 0.58, 0.3] * dur
			),
			doneAction:2
		);
		sig = SinOsc.ar(
			freq, 
			SinOsc.ar(freq * 1.7 * env + SinOsc.ar(lfreq, 0, 100), 0, 1),
			env);
		Out.ar(0, Pan2.ar(sig, pan, lev))
	}
).load(s);
