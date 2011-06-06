/**
	more experiments with abundance. this time, use a range of SynthDefs.
*/

// main server
// for recording, go through the soundflower output
s.options.outDevice = ServerOptions.outDevices[1]; //  the index is 2 with the edirol hooked up

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

///// standard proxy space stuff

~delay = 2.collect{
	Buffer.alloc(s, s.sampleRate * 16, 1);
};

p.del[0] = { |del0=1, lev=0.5, fb=0.9|
	var sig = BufDelayC.ar(~delay[0].bufnum, In.ar(1), del0, lev, p.ar(\del)[0] * fb);
	Pan2.ar(sig, -1);
};

p.del[1] = { |del1=1, lev=0.5, fb=0.9|
	var sig = BufDelayC.ar(~delay[1].bufnum, In.ar(0), del1, lev, p.ar(\del)[1] * fb);
	Pan2.ar(sig, 1);
};

p.del.play
p.del.stop

p.del.set(\del0, 12.35, \del1, 12.3, \fb, 0.8, \lev, 1)
p.del.set(\lev, 1)

ThyInstrument

////// run the synthdefs
~root = 220;

p.clock.tempo = 1 + (0/3)

Tdef(\rooto, {
	var roots = Prand([9/8, 7/8, 8/7, 8/9], inf).asStream;
	loop{
		~root = ~root * roots.next;
		rrand(1.6, 5.2).wait;
	}
});

Tdef(\rooto).play
Tdef(\rooto).stop

~synthDefs = [
	\dklc_filtoid, 
	\dklc_filtank, 
	\dklc_filtank2, 
	\dklc_filtow, 
	//\dklc_filtorr,
	\dklc_filtarr,
];

Tdef(\filtops, {
	var freqs = Pseq([
		{~root * 1/1},
		{~root * 10/9},
		{~root * 9/8},
		{~root * 8/7},
		{~root * 7/6},
		{~root * 6/5},
		{~root * 5/4},
		{~root * 4/3},
	], inf).asStream;
	loop{
		s.sendMsg(\s_new, ~synthDefs.choose, s.nextNodeID, 0, 1,
			\freq, freqs.next.value,
			\dur, rrand(0.3, 1.3), // some SynthDefs have only this
			\rez, exprand(0.00000001, 0.001), // or this
			\lev, rrand(0.2, 0.6),
			\pan, rrand(-1.0, 1.0),
			\slop, 1
		);
		0.1.wait;
		//[0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.05].choose.wait;
	};
});

Tdef(\filtops).play
Tdef(\filtops).stop
s.queryAllNodes

///// synthdefs


SynthDef("dklc_filtoid",
	{ arg lev=0.2, pan=0, outBus=0, dur=0.2, curve=(-9), // permanent values.
		freq=200; // audio values
		var sig, env, imp;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 1, 0],
				[0.1, 0.8, 0.1],
				curve
			),
			levelScale:lev,
			timeScale:dur,
			doneAction:2
		);
		imp = Impulse.ar(dur / 2, 0.0);
		sig = Ringz.ar(imp, freq, dur, env);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

SynthDef("dklc_filtank",
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
				[freq, freq * (13/4), freq * (14/4)],
				[lev,lev*0.5,lev*0.25],
				[dur, dur, dur],
			],
			imp
		);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

SynthDef("dklc_filtank2",
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
						[freq, freq * (13/4), freq * (14/4)],
						[lev,lev*0.5,lev*0.25],
						[dur, dur, dur],
					],
					imp
				),
				DynKlank.ar(
					`[
						[freq, freq * (3), freq * (16/5)],
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

SynthDef("dklc_filtorr",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, slop=0.001; // audio values
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
		sig = RLPF.ar(imp, freq, rez * slop, env);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);

SynthDef("dklc_filtarr",
	{ arg lev=0.2, pan=0, outBus=0, rez=0.1, curve=(-9), // permanent values.
		freq=200, slop=0.001; // audio values
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
		sig = BAllPass.ar(imp, freq, rez * slop * 0.000000001, env);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);


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
			SinOsc.ar(dur * mfreq, Lag2.ar(LocalIn.ar(1) * fb, fblag), freq, freq),
			0, 
			env
		);
		LocalOut.ar(sig);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);
