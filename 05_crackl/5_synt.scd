/**
	add sin waves
*/

// main server
// for recording, go through the soundflower output
s.options.outDevice = ServerOptions.outDevices[2]; //  the index is 1 without edirol
//s.options.outDevice = ServerOptions.outDevices[1]; //  the index is 2 with the edirol hooked up
p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;

// extra server

t = Server('q_aux', NetAddr("127.0.0.1", 58008));
t.options.device = ServerOptions.outDevices[1];
q = ProxySpace(t.boot);
q.know = true;
q.clock = TempoClock.default;
Server.named['q_aux'].makeWindow;

~root= 8000;
~off = -4400;
// sin gran --- main server
~lag = 0.00007;

Tdef(\singrain, {
	var freqs = Array.fill(21, { |i| ~root / (i + 1) });
	var fbs = Array.fill(10, { rrand(10, 29) }) ++ 10000;
	var durs = 64.collect{ 0.1.rand } ++ 1.0.rand;
	loop{		
		~off = ~off + rrand(-1.0, 1.0);
		
		//~off = ~off + rrand(-0.5, 1.0);
		s.sendMsg(\s_new, \dklc_SynGrain, s.nextNodeID, 0, 1,
			\freq, freqs.choose + ~off,
			\lev, \amp.asSpec.map(0.2.rand),
			\pan, [-1, -0.75, -0.5, 1, 0.75, 0.5].choose,
			\curve, -25,
			\dur, durs.choose,
			\bias, [0.1, 0.9].choose,
			\mfreq, 5.rand + 2,
			\fb, fbs.choose,
			\fblag, ~lag
		);
		0.00045.rand.wait;
	};
});

Tdef(\lagger, {
	//var lags = Pseq(Array.series(40, 0.00007, 0.00002).pyramid, inf).asStream
	var lags = Pseq(Array.series(40, 0.00001, 0.0001).pyramid, inf).asStream;
	loop{
		~lag = lags.next;
		postln(~lag);
		[1, 1, 1, 0.25].choose.wait;
	};
});

Tdef(\lagger).play
Tdef(\lagger).stop

Tdef(\singrain).play
Tdef(\singrain).stop

SynthDef("dklc_SynGrain",
	{ arg freq=100, dur=0.2, curve=(-5), mfreq=3, fb=10, fblag=0.007,
		lev=0.2, pan=0, outBus=0, bias=0.5;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0],
				[bias, 1 - bias],
				curve
			),
			levelScale:lev,
			timeScale:dur,
			doneAction:2
		);
		sig = SinOsc.ar(
			SinOsc.ar(dur * mfreq, Lag2.ar(LocalIn.ar(1) * fb, fblag) * Dust.kr(fb, freq), freq, freq),
			0, 
			env
		);
		LocalOut.ar(sig);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

// delay

p.del[0] = { |lev=0.8|
	var sig = DelayC.ar(In.ar(0), 0.5, 0.2, lev, p.ar(\del) * 0.9);
	Pan2.ar(sig, -1);
};

p.del[1] = { |lev=0.8|
	var sig = DelayC.ar(In.ar(1), 0.5, 0.2, lev, p.ar(\del) * 0.9);
	Pan2.ar(sig, 1);
};

p.del.play
p.del.stop
p.del.clear
// gverb

p.rv[0] = {
	var sig;
	sig = GVerb.ar(In.ar(0));
	Pan2.ar(sig, -1, 0.1);
};

p.rv[1] = {
	var sig;
	sig = GVerb.ar(In.ar(1));
	Pan2.ar(sig, 1, 0.1);
};

p.rv.play
p.rv.stop

// rone

p.test[0] = {SinOsc.ar([10, 11], SinOsc.ar([40, 41], 0, 3), 0.5 )}

p.test.play

p.test.stop

p.test[1] = {SinOsc.ar([20, 21], SinOsc.ar([80, 81], 0, 3), 0.15 )}

p.test.play; 

p.test.clear

//

