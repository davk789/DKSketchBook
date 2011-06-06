// bunko


// alt server

t = Server('q_aux', NetAddr("127.0.0.1", 58008));
q = ProxySpace(t.boot);
q.know = true;
q.clock = TempoClock();

Server.named['q_aux'].makeWindow;
// main server

p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;



SynthDef(\drun, 
	{arg lev=1, pan=0;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01, 1, curve: -24), doneAction:2);
		sig = WhiteNoise.ar() * env * lev;
		Out.ar(0, Pan2.ar(sig, pan))
	}
).load(s);

SynthDef(\drub, 
	{arg lev=1, freq=300, pan=0;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.1, 0.5, curve: -12), doneAction:2);
		sig = SinOsc.ar(
			freq + SinOsc.ar(LFNoise2.ar(10, 100), 0, 20), 
			SinOsc.ar(freq / 2, 0, 4)) * env * lev;
		Out.ar(0, Pan2.ar(sig, pan))
	}
).load(s);

SynthDef(\druz, 
	{arg lev=1, freq=300, pan=0;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.1, 0.5, curve: -12), doneAction:2);
		sig = SinOsc.ar(
			freq) * env * lev;
		Out.ar(0, Pan2.ar(sig, pan))
	}
).load(s);

p.drum = \drun;
p.drum = \drub;

~du = Prand([1.0, 0.5, 0.5, 0.5, 1.0, 0.5, 0.5, 0.5], inf).asStream;
~seq = Pseq([60,64,67,60,60,60,64,64] - 7, inf).asStream;
~seq = Pseq([60,64,67,60,60,60,64,64] - 13, inf).asStream;
~seq = Pseq([60,64,67,60,60,60,64,64] - 37, inf).asStream;
~seq = Pseq([60,64,67,60,60,60,64,64] - [7, 13, -12].choose, inf).asStream;
Tdef(\ned, {
	loop{
		p.drum.set(
			\lev, 0.9.rand,
			\freq, ~seq.next.midicps
		);
		p.drum.spawn;
		~du.next.wait
	}
});

Tdef(\ned).play;
Tdef(\ned).stop; Tdef(\n2).stop; Tdef(\n3).stop; 
Tdef(\ned).play; Tdef(\n2).play; Tdef(\n3).play; 

Tdef(\n2, {
	loop{
		p.drum = [\drun, \drub, \drub, \druz].choose;
		p.drum.set(
			\lev, 0.9.rand,
			\freq, (~seq.next + 0 ).midicps
		);
		p.drum.spawn;
		~du.next.wait
	}
});

Tdef(\n2).play

Tdef(\n3, {
	loop{
		p.drum.set(
			\lev, 0.9.rand,
			\freq, (~seq.next + 24).midicps
		);
		p.drum.spawn;
		~du.next.wait
	}
});

Tdef(\n3).play


s.query

Tdef(\temple, {
	loop{
		p.clock.tempo = [3, 3 * 3/2].choose;
		2.wait;		
	}
});



Tdef(\temple).play
p.clock.tempo = 2;
p.clock.tempo = 2 * 3/2;

//// del

p.del = { |lev=0.4|
	DelayC.ar(In.ar(0), 6, 1, lev, p.ar(\del) * 0.8)
}


p.del.play

p.del.stop
p.del.clear


