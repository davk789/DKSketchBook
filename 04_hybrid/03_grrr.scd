/**

	let's see if I can apply a passive effect here
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


// ***** convolution reverb section. use two reverbs, hard left and hard right.

~fftsize = 2048;
~irPath = "/Users/davk/Music/Impulse Responses/Samplicity T600 - 05 - Wave, 24 bit, 44.1 khz/_mono/";

fork{
	~bufLeft = DKBufferUtils.loadIRBuffer(~irPath ++ "T600 - 084 Slapback Plate C.wav", ~fftsize);
	~bufRight = DKBufferUtils.loadIRBuffer(~irPath ++ "T600 - 069 Rap Club L.wav", ~fftsize);
}





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

p.plunk = {
	
}

~rv_right = Synth.new(\ConvoRouterMono,
	[\out, 1, \inBus, 21, \fftsize, ~fftsize, \bufnum, ~bufRight.bufnum]
);




// route some signals

p.ring0 ={Ringz.ar(Decay2.ar(Impulse.ar(1, 0, 0.05), 0.001, 0.01), 100, 1, 0.02);}
p.ring0.play
p.ring0.stop


p.toRVLeft = {
	var sig = p.ar(\ring0);

	Pan2.ar(sig);
}

p.toRVLeft.play
p.toRVLeft.stop

p.toRVLeft = {
	var sig = Ringz.ar(Impulse.ar(1), 100, 1, 0.2);
	Out.ar(21, sig);
	Pan2.ar(sig);
}

p.toRVLeft.play
p.toRVLeft.stop
p.clean
s.queryAllNodes




~to_rv = {
	var sig = Ringz.ar(Impulse.ar(1), 100, 1, 0.2);
	Out.ar(20, sig)
}
~to_rv.play
~to_rv.release
s.queryAllNodes




// ****** SynthDef section



SynthDef("ConvoRouterMono",
	{ |outBus=0, inBus=0, fftsize, bufnum| // start the inputs from 90, this should not lead to
		// conflicts here, hopefully
		var a_in = In.ar(inBus);
		var a_sig = PartConv.ar(a_in, fftsize, bufnum);
		Out.ar(outBus, a_sig);
	}
).load(s)


