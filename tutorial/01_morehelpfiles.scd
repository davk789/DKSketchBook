/**
	More junk code, going through some of the other help files. In this case, trying out
	patterns and routines, Pbind, Tdef and Ndef specifically. Still not attempting any 
	sound on my own, but my first sketches may come after this.
*/

p = ProxySpace(s.boot)
p.push; // so, it is possible to use multiple namespaces
   ////// though I don't see a point to doing this -- anything
///////// that elaborate should be hardcoded imo
s.boot


s.serverRunning
Pbind


//// Pbind help file


(
a = Pbind(\x, Pseq([1, 2, 3]), \y, Prand([100, 300, 200], inf), \zzz, 99);
x = a.asStream;
)

x.reset
x.next(()); // pass in an event ()
x.next(());
x.next(());
x.next(()); // end: nil

// sound examples

// using the default synth def
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, 0.1).play;
Pbind(\freq, Prand([300, 500, 231.2, 399.2], inf), \dur, Prand([0.1, 0.3], inf)).play;

Pbind(\freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200, \dur, 0.1).play;

(
// a SynthDef
SynthDef(\test, { | out, freq = 440, amp = 0.1, nharms = 10, pan = 0, gate = 1 |
var audio = Blip.ar(freq, nharms, amp);
var env = Linen.kr(gate, doneAction: 2);
OffsetOut.ar(out, Pan2.ar(audio, pan, env) );
}).memStore;
);

Pbind(\instrument, \test, \freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200, \dur, 0.1).play;

// standard syntax, arguments alternate symbols and patterns
(
Pbind(
\instrument, \test, 
\nharms, Pseq([4, 10, 40], inf), 
\dur, Pseq([1, 1, 2, 1]/10, inf), 
#[freq, sustain],  Ptuple([ // assignment to multiple keys
Pseq( (1..16) * 50, 4), 
Pseq([1/10, 0.5, 1, 2], inf)
])
).play

)

/// end pbind help file



SynthDef("pdef_grainlet",
	{ |out=0,freq=440,sustain=0.05|
		var env = EnvGen.kr(Env.perc(0.01, sustain, 0.03), doneAction:2);
		Out.ar(out, SinOsc.ar(freq, 0, env));
	}
).send(s);

Tdef(\z, Pseq([1,1,1,0.5,0.5], inf));

Pset(\instrument, \pdef_grainlet,
	Ppar([
		Pbind(
			\dur, Tdef(\z),
			\note, Pseq([1,3,2,1,0], inf),
			\x, Pfunc{ TempoClock.default.elapsedBeats.postln }
		),
		Pbind(
			\dur, 4, // reference beat?
			\sustain, 0.1,
			\note, 8
		)
	])
).play(quant:1)

Tdef(\z, Prand([1, 1, 0.23, 0.5, 0.5], inf)); // exchange time pattern
Tdef(\z, Pseq([1, 1, 1, 1], inf)); // pattern stays in sync.
Tdef(\z, Pseq([1, 1, 1, 0.5, 0.5], inf)); // but might be in different order.


// embed plays tdefs in sequence within a task.
(
Tdef(\a, { "one".postln; 1.wait; "two".postln });
Tdef(\c, { var z; z = Synth(\default); 0.5.wait; z.release });
r = Task({
	"counting...".postln;
	2.wait;
	Tdef(\a).embed;
	1.wait;
	Tdef(\c).embed;
	"done.".postln;
});
)

r.play; // play a stream

Tdef(\c, { var z; z = Synth(\default, [\freq, 300]); 1.5.wait; z.release }); // change the def

r.reset;
r.play;

// of course Tdefs can be used in other Tdefs:
(
Tdef(\a, { 10.do { |i| (" a: " + i).postln; 0.3.wait; } });
Tdef(\b, { 15.do { |i| ("\t\t b: " + i).postln; 0.2.wait; } });
Tdef(\c, { 5.do { |i| ("\t\t\t\t c: " + i).postln; 0.5.wait; } });

Tdef(\d, {
	"embed - sequence.".postln;
	1.wait;
	Tdef(\a).embed;
	1.wait;
	Tdef(\b).embed;
	1.wait; 
	Tdef(\c).embed;
	
	"done.".postln;
});
)

Tdef(\d).play;

// to start a tdef in its own separate thread, thus branching into parallel threads, 
// one can use .fork, or .playOnce
(
Tdef(\a, { 10.do { |i| (" a: " + i).postln; 0.3.wait; } });
Tdef(\b, { 15.do { |i| ("\t\t b: " + i).postln; 0.2.wait; } });
Tdef(\c, { 5.do { |i| ("\t\t\t\t c: " + i).postln; 0.5.wait; } });

Tdef(\d, {
	"fork - parallel.".postln;
	1.wait;
	Tdef(\a).fork;
	1.wait;
	Tdef(\b).fork;
	1.wait; 
	Tdef(\c).fork;
	
	"done.".postln;
});
)



/////////////// \/\/\/\/\/\/\/\/\/\/\


/// Tdef stuff

Tdef.removeAll
Tdef(\y, { loop{ s.sendMsg("/s_new", "pdef_grainlet", -1, 0, 0, \freq, 1500); 1.wait; } });
Tdef(\x).play
Tdef(\x).stop

SynthDef("pdef_grainlet",
	{ arg out=0, freq=440, sustain=0.05;
		var env;
		env = EnvGen.kr(Env.perc(0.01, sustain, 0.3), doneAction:2);
		Out.ar(out, SinOsc.ar(freq, 0, env))
	}
).memStore.send(s);

(
Tdef(\x, { 
	loop({
		s.sendMsg("/s_new", "pdef_grainlet", -1,0,0, \freq, rrand(600, 640));
		0.1.wait;
	})
})
)

(
Tdef(\x, { 
	var x;
	x = Pseries(300, 20, 100).loop.asStream;
	loop({
		s.sendMsg("/s_new", "pdef_grainlet", -1,0,0, \freq, x.next);
		0.05.wait;
	})
})
)

(
Tdef(\x, { 
	var x;
	x = Plazy({ Pseries(300 + 300.rand, 10 + 30.rand, 10 + 30.rand) }).loop.asStream;
	loop({
		s.sendMsg("/s_new", "pdef_grainlet", -1,0,0, \freq, x.next);
		0.05.wait;
	})
})
)






~out.play


~s1 = { Blip.ar(Rand(32,15), 100, 0.5) };
~s2 = { SinOsc.ar(740, 0, 0.1) };
~s3 = { Pulse.ar(140, 0.2, 0.1) };

~out = { Pan2.ar(~mix.ar(1), MouseX.kr(-1,1)) }

p.fadeTime = 0.3
~mix.read(~s1)

~mix = \default


// automation:
(
t = Task({
	var dt;
	loop({
		dt = rrand(0.01, 0.1);
		~mix.fadeTime = dt;
		~mix.read([~s1, ~s2, ~s3].choose);
		dt.wait;
	});
});
)

t.play
t.stop


// change the sources meanwhile:
~s1 = { Blip.ar(105, 100, 0.2) };
~s2 = { SinOsc.ar(350, 0, 0.1) };
~s3 = { Pulse.ar(60, 0.2, 0.1) };

~freq = { MouseY.kr(200, 600, 2) };

~s1 = { Blip.ar(~freq.kr * 0.3, 10, 0.2) };
~s2 = { SinOsc.ar(~freq.kr, 0, 0.1) };
~s3 = { Pulse.ar(~freq.kr * 0.2, 0.2, 0.1) };

t.stop