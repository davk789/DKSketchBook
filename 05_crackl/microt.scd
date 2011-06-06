/**
	play with some microtonal scales
*/


// main server
// for recording, go through the soundflower output
s.options.outDevice = ServerOptions.outDevices[2]; //  the index is 2 with the edirol hooked up

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



// synthdefs are declared in 6_furthur.scd
~synthDefs = [
	\dklc_klink1,
	\dklc_klink2,
	\dklc_klink3,
	\dklc_klink4,
	//	\dklc_filtoid, 
	//\dklc_filtank, 
	//\dklc_filtank2, 
];
~bohlen = [
	1/1,
	27/25,
	25,21,
	9/7,
	7/5,
	75/49,
	5/3,
	9/5,
	49/25,
	15/7,
	7/3,
	63/25,
	25/9,
	// -> 3/1
];


Tdef(\filt, {
	var root=440, deg=0;
	loop{
		deg = deg + [1, 2, -1, -2, -4, 4].choose;
		case{deg > ~bohlen.lastIndex}{
			deg = deg - ~bohlen.lastIndex;
			root = root * 3;
		}{ deg < 0	}{
			deg = ~bohlen.lastIndex + deg;
			root = root / 3;
		};
		s.sendMsg(\s_new, ~synthDefs.choose, s.nextNodeID, 0, 1,
			\freq, ~bohlen[deg] * root,
			\dur, rrand(0.3, 1.3), // some SynthDefs have only this
			\rez, exprand(0.00000001, 0.001), // or this
			\lev, rrand(0.2, 0.6),
			\pan, rrand(-1.0, 1.0),
			\slop, 1
		);
		0.5.wait;
	};
});

Tdef(\filt).play

~func = {
	//var root=[440, 440 * 3, 440 / 3].choose, deg=[0, 1,3,5, 6, 9, 11].choose;
var root=[220, 220 * 3, 220 / 3].choose, deg=[0, 1,3,5, 6, 9, 11].choose;
	loop{
		deg = deg + [1, 2, -1, -2, -4, 4].choose;
		case{deg > ~bohlen.lastIndex}{
			deg = deg - ~bohlen.lastIndex;
			root = root * 3;
		}{ deg < 0	}{
			deg = ~bohlen.lastIndex + deg;
			root = root / 3;
		};
		s.sendMsg(\s_new, ~synthDefs.choose, s.nextNodeID, 0, 1,
			\freq, ~bohlen[deg] * root,
			\dur, rrand(0.3, 1.3), // some SynthDefs have only this
			\rez, exprand(0.00000001, 0.001), // or this
			\lev, rrand(0.01, 0.6),
			\pan, rrand(-1.0, 1.0),
			\slop, 1
		);
		[1.0, 0.25, 0.5].choose.wait;
	};
};

Tdef(\laincher, {
	loop{
		var name=(2**32).rand;
		Tdef(name.asSymbol, ~func);
		Tdef(name.asSymbol).play;
		p.clock.sched(rrand(1, 6), {
			Tdef(name.asSymbol).stop;
			Tdef(name.asSymbol).clear;
			nil;
		});
		4.rand.wait;
	};
});

Tdef(\laincher).play;
Tdef(\laincher).stop;
Tdef(\laincher).clear;


Tdef(\slimmer, {
	loop{
		p.clock.tempo = [0.125, 0.25, 2/3, 1].choose;
		postln("slimmer");
		rrand(2, 6).wait;
	}
});

Tdef(\slimmer).play

p.clock.tempo = 0.125
p.clock.tempo = 0.25
p.clock.tempo = 2/3
Tdef.all;

////// SynthDefs


SynthDef("dklc_klink1",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, dur=0.2; // audio values
		var sig, env, imp;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.1, 0.8, 0.1],
				curve
			),
			levelScale:lev,
			timeScale:1.0,
			doneAction:2
		);
		imp = Impulse.ar(2, 0.0);
		sig = DynKlank.ar(
			`[
				[freq, freq * (3/2), freq * (5/2)],
				[lev,lev*0.5,lev*0.25],
				[dur, dur, dur],
			],
			imp
		);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

SynthDef("dklc_klink2",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, dur=0.2; // audio values
		var sig, env, imp;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.1, 0.8, 0.1],
				curve
			),
			levelScale:lev,
			timeScale:1.0,
			doneAction:2
		);
		imp = Impulse.ar(2, 0.0);
		sig = Mix.new(
			[
				DynKlank.ar(
					`[
						[freq, freq * (3/2), freq * (5/3)],
						[lev,lev*0.5,lev*0.25],
						[dur, dur, dur],
					],
					imp
				),
				DynKlank.ar(
					`[
						[freq, freq * (7/2), freq * (11/5)],
						[lev * 0.125,lev*0.125,lev*0.225],
						[dur, dur, dur],
					],
					imp
				),
			]
);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

SynthDef("dklc_klink3",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, dur=0.2; // audio values
		var sig, env, imp;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.1, 0.8, 0.1],
				curve
			),
			levelScale:lev,
			timeScale:1.0,
			doneAction:2
		);
		imp = EnvGen.ar(Env.perc(0.01, 0.2)) * Crackle.ar();
		sig = Mix.new(
			[
				DynKlank.ar(
					`[
						[freq, freq * (3/2), freq * (5/3)],
						[lev,lev*0.5,lev*0.25],
						[dur, dur, dur],
					],
					imp
				),
				DynKlank.ar(
					`[
						[freq, freq * (7/2), freq * (11/5)],
						[lev * 0.125,lev*0.125,lev*0.225],
						[dur, dur, dur],
					],
					imp
				),
			]
);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);



SynthDef("dklc_klink4",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, dur=0.2; // audio values
		var sig, env, imp;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.1, 0.8, 0.1],
				curve
			),
			levelScale:lev,
			timeScale:1.0,
			doneAction:2
		);
		imp = EnvGen.ar(Env.perc(0.01, 0.2)) * Crackle.ar();
		sig = DynKlank.ar(
			`[
				[freq, freq * (3/2), freq * (5/2)],
				[lev,lev*0.5,lev*0.25],
				[dur, dur, dur],
			],
			imp
		);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);


/// resamp 

~buf = Buffer.alloc(s, s.sampleRate * 6, 2)

SynthDef(\dklc_res1, {
	RecordBuf.ar(In.ar([0,1]), ~buf.bufnum, doneAction:2, preLevel:1.0)
}).load(s);


p.rec = \dklc_res1;
p.rec.spawn;

p.pl.play
p.pl.stop
p.pl.set(\lev, 1)
p.pl.set(\lev, 0.1)

p.pl = { |lev=1|
	PlayBuf.ar(2, ~buf.bufnum, loop:1) * lev;
}

SynthDef.new();


p.osc[0] = { arg freq=50, lev=0.2, lag=0.2, fbk=20;
	SinOsc.ar(
		[freq,freq+1],
		SinOsc.ar(
			freq* (3/5), 
			Lag2.ar(p.ar(\osc), lag) * fbk
		, 10),
		lev
	)
}

p.osc[1] = { arg freq=50, lev=0.2, lag=0.2, fbk=20;
	SinOsc.ar(
		[freq * 2,(freq+1) * 2],
		SinOsc.ar(
			freq * 2* (3/5), 
			Lag2.ar(p.ar(\osc), lag) * fbk
		, 10),
		lev
	)
}

p.osc.play
p.osc.stop

p.osc.set(\freq,300)
p.osc.set(\freq,100000)

Tdef(\loll, 
	{var freq=300;
	loop{
		freq = freq +  [10,  -10].choose;
		p.osc.set(\freq,freq);
		0.0001.wait;
	}}
);

Tdef(\loll).play
Tdef(\loll).stop



//// distop
p.disto = {
	Distortion.ar(In.ar([0,1]))
}