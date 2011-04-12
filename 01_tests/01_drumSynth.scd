/**
	Testing Tdefs and adding synths.

	... using the drum SynthDefs from TheInstrument
*/


// specify the edirol
s.options.device = ServerOptions.devices[0]
s.serverRunning
currentEnvironment
p = ProxySpace(s.boot);
p.push;


~kik.play;
~osc.play;

~kik = 'dklc_grey_kik'
~osc = \dklc_osc;



~kik.spawn;
~kik.set(\fres, 0.4, \lev, 1.9, \rel, 0.7);

p.clock = TempoClock.default;
p.clock.tempo = 1
p.clock.tempo = 120 / 60
p.quant = 1

// locked together


Tdef(\kik).play;
Tdef(\kik).stop;

Tdef(\osc).play;
Tdef(\osc).stop;

~osc.set(\freq, 20.midicps);

Tdef(\osc, {
	loop{
		~osc.spawn;
		2.wait;
	}
});

~kik.set(\ffreq, 200)

Tdef(\kik, {
	var wait;
	loop{
		wait= [0.5, 0.25, 0.25, 0.5, 0.5, 1].choose;
		~kik.set(\lev, wait * 0.7);
		~kik.spawn;
		wait.wait;
	}
})
//

Tdef(\osc, {
	loop{
		~osc.set(\freq, (10 +[20,32].choose).midicps);
		~osc.spawn;
		[2,4].choose.wait;
	}
});

~kik.set(\ffreq, 8000, \lev, 0.2)
~osc.set(\rel, 1.5, \modAmt, 3, \drive, 4);


s.prepareForRecord
s.record
s.stopRecording

Tdef(\osc).play; Tdef(\kik).play;
Tdef(\osc).play;
Tdef(\kik).play;

Tdef(\osc).stop; Tdef(\kik).stop;
Tdef(\osc).stop;
Tdef(\kik).stop;

Tdef(\kik, {
	var ind, freq, wait;
	freq = [200,400,800];
	wait = [0.1, 0.2, 0.4].reverse;
	loop{
		ind = 3.rand;
		~kik.set(\ffreq, freq[ind]);
		~kik.spawn;
		wait[ind].wait;
	}
})

TempoClock.default.tempo = 1.6;

Tdef(\kik).play
Tdef(\kik).stop


s.queryAllNodes;
~out.setRates(\trig, \tr)

// altered for this script

SynthDef.new("dklc_osc",
	{ |att=0.001, rel=0.5, lev=1, curve=(-8), freq=80, modPhase=0, modFreq=(-1), modAmt=0,
		drive=0, trig=1, outBus=0| 
		var uMod, uOsc, uEnv, uDrive, kModFreq, kModAmt;
		kModFreq = (modFreq * 0.25) / (att + rel);
		kModAmt = modAmt * freq;  // mod amount range == an upper limit number > 1 and its reciprocal
		uMod = SinOsc.ar(kModFreq, modPhase, kModAmt, freq);
		uOsc = SinOsc.ar(uMod, 0);
		uEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
		uDrive = (uOsc * (drive + 1) * uEnv).distort;
		Out.ar(outBus, Pan2.ar(uDrive));
	}
).load(s);

SynthDef("dklc_grey_kik",
	{ |att=0.001, rel=0.5, lev=1, curve=(-8),
		ffreq=200, fres=0.5, trig=1, outBus=0|
		var aNoise, aEnv, aSig;
		aNoise = GrayNoise.ar;
		aEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
		aSig= RLPF.ar(aNoise * aEnv, ffreq, fres);
		Out.ar(outBus, Pan2.ar(aSig));
	}
).load(s);

/// from theInstrument
// Drums ~~~~~~~~~~
SynthDef.new("x_osc", { 
	|att=0.001, rel=0.5, lev=1, curve=(-8), freq=80, 
	modPhase=0, modFreq=(-1), modAmt=0, drive=0, trig=1, outBus=15| 
	var uMod, uOsc, uEnv, uDrive, kModFreq, kModAmt;
	
	kModFreq = (modFreq * 0.25) / (att + rel);
	kModAmt = modAmt * freq;  // mod amount range == an upper limit number > 1 and its reciprocal

	uMod = SinOsc.ar(kModFreq, modPhase, kModAmt, freq);
	uOsc = SinOsc.ar(uMod, 0);// + SinOsc.ar(uMod * 1.3061224489795, 0); // stacked septimal whole tones -- maj 3rd
	uDrive = (uOsc * (drive + 1)).distort;
	uEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
	Out.ar(outBus, uDrive * uEnv);

}).load(s);

SynthDef.new("x_gray", { 
	|att=0.001, rel=0.5, lev=1, curve=(-8), 
	trig=1, outBus=10|
	var aNoise, aEnv;
	aNoise = GrayNoise.ar;
	aEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
	Out.ar(outBus, RLPF.ar(aNoise * aEnv, 200, 1));
}).load(s);

SynthDef.new("x_crackle", { 
	|att=0.001, rel=1.5, lev=1, curve=(-4), 
	trig=1, outBus=11, crackle=1.5, gain=1|
	var aNoise, aEnv;
	aNoise = Crackle.ar(crackle);
	aEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
	Out.ar(outBus, (aNoise * aEnv).softclip);//RLPF.ar(aNoise * aEnv, 200, 1));
}).load(s);

SynthDef.new("x_clip", { 
	|att=0.001, rel=0.5, lev=1, curve=(-8), 
	trig=1, outBus=10|
	var aNoise, aEnv;
	aNoise = ClipNoise.ar;
	aEnv = EnvGen.ar(Env.perc(att, rel, lev * 0.25, curve), trig, doneAction:2);
	Out.ar(outBus, RLPF.ar(aNoise * aEnv, 200, 1));
}).load(s);

SynthDef.new("x_whiteSnare", { 
	|outBus=10, freq=1200, gain=1, rez=2, trig=1, 
	att=0.011, rel=0.5, lev=1, curve=(-10)|
	var aNoise, aLo, aHi, aSig, kRez, aEnv;
	kRez = rez.reciprocal; 
	aNoise = ClipNoise.ar(gain);
	aLo = RLPF.ar(aNoise, freq, rez);
	aHi = RHPF.ar(aLo, freq, rez);
	aEnv = EnvGen.ar(Env.perc(att, rel, lev, curve), trig, doneAction:2);
	aSig = aLo + aHi;
	Out.ar(outBus, aSig * aEnv);
}).load(s);

// Resonators ~~~~~~~~~~ 
SynthDef.new("r_formlet", { |freq=1600, attTime=0.01, decTime=0.1,
	outBus=0, inBus=11, lev=1, pan=0|
	var aRez;
	aRez = Formlet.ar(In.ar(inBus), freq, attTime, decTime);
	Out.ar(outBus, Pan2.ar(aRez * lev, pan));
}).load(s);

SynthDef.new("r_lpf", { |freq=1600, res=10,
	outBus=0, inBus=12, lev=1, gain=1, pan=0|
	var aRez, aIn;
	aIn = (In.ar(inBus) * gain).softclip;
	aRez = RLPF.ar(aIn, freq, 1 / res);
	Out.ar(outBus, Pan2.ar(aRez * lev, pan));
}).load(s);	

SynthDef.new("r_hpf", { |freq=1600, res=10,
	outBus=0, inBus=13, lev=1, gain=1, pan=0|
	var aRez, aIn;
	aIn = (In.ar(inBus) * gain).softclip;
	aRez = RHPF.ar(aIn, freq, 1 / res);
	Out.ar(outBus, Pan2.ar(aRez * lev, pan));
}).load(s);	

SynthDef.new("r_klank", { |outBus=0, inBus=10, lev=1, 
	f1=80,f2=90,f3=145,
	r1=5,r2=4,r3=6,
	a1=0.7,a2=0.8,a3=0.4, pan=0|
	var aRez;
	aRez = DynKlank.ar(
		`[[f1, f2, f3],
			[a1, a2, a3],
			[r1, r2, r3]], 
		Limiter.ar(In.ar(inBus), 0.5, 0.02).softclip
	);
	Out.ar(outBus, Pan2.ar(aRez * lev, pan));
}).load(s);

