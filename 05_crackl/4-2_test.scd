/**
	testing buffer recorder.
*/

// server 1

p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock();


// server 2

t = Server('aux_resampler', NetAddr("127.0.0.1", 58009));
q = ProxySpace(t.boot);
q.know = true;
q.clock = TempoClock();

// record

~tb = Buffer.alloc(t, t.sampleRate * 4, 2);


q.recorder = {
	RecordBuf.ar(In.ar([0,1]), ~tb.bufnum, doneAction:2);
}
q.player.index
q.player = {
	PlayBuf.ar(2, ~tb.bufnum, loop:1)
}
q.player.play


// seq

Tdef(\bss, {
	var seq = Pseq([100,200,100,300,200] * 0.6, inf).asStream;
	loop{
		t.sendMsg('s_new', 'tseq', t.nextNodeID, 0, 1,
			'freq', seq.next,
			'dur', 0.2,
			'lfreq', 1
		);
		0.2.wait;
	}
});



Tdef(\bss).stop
Tdef(\bss).play

//** SynthDefs
// bassline synth
SynthDef("tseq", 
	{ arg freq=220, pan=0, dur=1,
		  lfreq=10;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0.6, 0.6, 0],
				[0.02, 0.1, 0.58, 0.3] * dur,
				curve: -2
			),
			doneAction:2
		);
		sig = SinOsc.ar(
			freq, 
			SinOsc.ar(freq * 1.7 * env + SinOsc.ar(lfreq, 0, 100), 0, 1),
			env);
		Out.ar(0, Pan2.ar(sig, pan))
	}
).load(t);


SynthDef("test").load(t);


RecordBuf.ar