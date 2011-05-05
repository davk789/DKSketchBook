/**
	performance script for 4.25.2011. This is for a performance at Weirdo records in 
	Cambridge. Small space, playing thru a stereo with speakers on opposite sides of
	the space. So, take advantage of this play around with sounds going hard left, 
hard right and center.
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
	[\out, 0, \inBus, 20, \fftsize, ~fftsize, \bufnum, ~bufLeft.bufnum]
);
~rv_right = Synth.new(\ConvoRouterMono,
	[\out, 1, \inBus, 21, \fftsize, ~fftsize, \bufnum, ~bufRight.bufnum]
);




// route some signals

p.ring0 ={Ringz.ar(Impulse.ar(1), 100, 1, 0.2);}
p.ring0.stop


p.toRVLeft = {
	var sig = p.ar(\ring0);
	Out.ar(21, sig);
	Pan2.ar(sig);
}

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
	{ |outBus=0, inBus=90, fftsize, bufnum| // start the inputs from 90, this should not lead to
		// conflicts here, hopefully
		var a_in = In.ar(inBus);
		var a_sig = PartConv.ar(a_in, fftsize, bufnum);
		Out.ar(outBus, a_sig);
	}
).load(s)


