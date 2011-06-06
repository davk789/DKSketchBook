xf`/**
	Answer to the routing problem -- add the reverb synths to the tail. give EVERYTHING reverb!!
*/



s.options.device = ServerOptions.devices[0];
s.boot

// ProxySpace 
p = ProxySpace.new(s.boot);
p.know = true;
p.clock = TempoClock();
// access the proxyspace as p.whatever

s.prepareForRecord
s.record
s.stopRecording

// *** reverb section

~fftsize = 2048;
~irPath = "/Users/davk/Music/Impulse Responses/Samplicity T600 - 05 - Wave, 24 bit, 44.1 khz/_mono/";

fork{
	~bufLeft = DKBufferUtils.loadIRBuffer(~irPath ++ "T600 - 079 Fat Drum Plate C.wav", ~fftsize);
	~bufRight = DKBufferUtils.loadIRBuffer(~irPath ++ "T600 - 088 Out in the Dark L.wav", ~fftsize);
};


~rv_left = Synth.new(\ConvoRouterMono,
	[\outBus, 0, \inBus, 0, \fftsize, ~fftsize, \bufnum, ~bufLeft.bufnum],
	0,
	\addToTail
);

~rv_right = Synth.new(\ConvoRouterMono,
	[\outBus, 1, \inBus, 1, \fftsize, ~fftsize, \bufnum, ~bufRight.bufnum],
	0,
	\addToTail
);

s.queryAllNodes

// ******** VOsc section

fork {
	~vBufs = DKBufferUtils.prepareOddPowerWavetables(8);
}

p.vosc_l = { |buf=0, freq=100, pan=0, lev=0.1|
	// i know there is a function that puts these calls together but I can't remember
	// what it is
	var lbuf = buf.max(~vBufs.first.bufnum).min(~vBufs.last.bufnum - 0.1);
	var sig = VOsc.ar(lbuf, freq, 0, lev);
	Pan2.ar(sig, pan)
};

p.vosc_r = { |buf=0, freq=100, pan=0, lev=0.1|
	// i know there is a function that puts these calls together but I can't remember
	// what it is
	var lbuf = buf.max(~vBufs.first.bufnum).min(~vBufs.last.bufnum - 0.1);
	var sig = VOsc.ar(lbuf, freq, 0, lev);
	Pan2.ar(sig, pan)
}

p.vosc_l.play
p.vosc_l.stop
p.vosc_r.stop
p.vosc_r.set(\lev, 0.6)
p.vosc_l.set(\lev, 0.6)


Tdef(\frqs, {
	loop{
		p.vosc_l.set(\freq, [100, 110, 120].choose);
		0.1.rand;
		p.vosc_r.set(\freq, [100, 110, 120].choose);
		1.wait
	}
})


Tdef(\frqs).play
// vosc fucken with params
// set slow rates here


// Pbind ... what to do with the Pbind ... nothing , stuck with Tdefs for now





// *** synthdefs
/*  ... um, remember to keep synthdefs in their own files
	this is a duplicate from another file in the project
*/


SynthDef("ConvoRouterMono",
	{ |outBus=0, inBus=0, fftsize, bufnum| // start the inputs from 90, this should not lead to
		// conflicts here, hopefully
		var a_in = In.ar(inBus);
		var a_sig = PartConv.ar(a_in, fftsize, bufnum);
		Out.ar(outBus, a_sig);
	}
).load(s)

