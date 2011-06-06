/**
	reference and template synthdefs
*/



/*
	basic sine wave fixed duration sine wave == the only arg to replace is the
	freq, and the osc is the only sound generator to replace.
*/
// ** NOTE, all livecoding synthdefs should have a dklc prefix
SynthDef("dklc_SynGrain",
	{ arg freq=100, dur=0.2, curve=(-5),
		lev=0.2, pan=0, outBus=0;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0],
				[0.5, 0.5],
				curve
			),
			levelScale:lev,
			timeScale:dur,
			doneAction:2
		);
		sig = SinOsc.ar(freq, 0, env);
		Out.ar(outBus, Pan2.ar(sig, pan));
	}
).load(s);
