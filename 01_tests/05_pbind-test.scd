/**
	testing workflow with SynthDef
*/

s.options.device = ServerOptions.devices[0];
s.boot;


SynthDef("testCub",
	{ |freq=440, lev=0.2, coef=21, gate=1|
		var sig, env;
		// what would be the entire function with Proxies
		sig = SinOsc.ar(freq, 0, lev).pow(coef);
		env = Linen.kr(gate, 0.01, 1, 0.6, doneAction:2);
		Out.ar(0, Pan2.ar(sig, 0, env));
	}
).load(s)

~rt = Routine{
	var counter = 0;
	var list = [1,2,3,4,5];
	loop{
		list[counter].yield;
		counter = (counter  + 1) % (list.lastIndex + 1);
	}
}

~rt= Pseq([1,2,3,4,5], inf).asStream;
~rt.next;

play{ SinOsc.ar(100).pow(13) * 0.3 }

p = Pseq([30, 40, 40, 40, 43, 40, 40, 40, 40, 45,40, 40, 40].midicps, inf);
p = p.asStream
p.next

~seq = Pbind(\instrument, \testCub,
	\freq, Pseq([30, 40, 40, 40, 43, 40, 40, 40, 40, 45,40, 40, 40].midicps, inf),
	\dur, 0.2
)


~seq.stop
~seq.play
