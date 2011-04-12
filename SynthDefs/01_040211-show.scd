/*

	This is usually a larger nuisance than it is worth, but I am going to try to keep
	the SynthDefs in their own file for now.
*/

SynthDef("lcPhaseModder",
	{ |freq=0, phase=0, lev=1, outBus=0|
		var sig = SinOsc.ar(freq, phase, lev);
		Out.ar(outBus, Pan2.ar(sig))
	}
).add;

SynthDef("lcPhaseModFB",
	{ |freq=0,fb=10,mul=0.2,outBus=0|
		var fbin, sig;
		fbin = LocalIn.ar();
		sig = SinOsc.ar(freq, fb * fbin, mul);
		LocalOut.ar(sig);
		Out.ar(outBus, Pan2.ar(sig));
	}
).add;

SynthDef("lcGravityGrid",
	{ |rrate=1, rate=1, newx=0.6, newy=(-0.5), outBus=0, reset=0|
		//var sig = GravityGrid.ar(Impulse.kr(rrate), rate, newx, newy); // not using a buffer
		var sig = GravityGrid.ar(reset, rate, newx, newy); // not using a buffer
		Out.ar(outBus, Pan2.ar(sig));
	}
).add;
