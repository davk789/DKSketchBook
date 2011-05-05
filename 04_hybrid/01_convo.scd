/**
	Instead of relying completely on livecoding for everything, try accessing the proxyspace
	from a default namespace, and use some more traditional coding, in order to be able to 
	run static code a little more clearly, while adding flexibility on top of everything.
*/


s.options.device = ServerOptions.devices[0];

// ProxySpace 
p = ProxySpace.new(s.boot);
p.know = true;
p.clock = TempoClock();
// access the proxyspace as p.whatever

s.prepareForRecord
s.record
s.stopRecording

s.queryAllNodes

// ****** Convolution Reverb Section

~fftsize = 2048;
~irPath = "/Users/davk/Music/Impulse Responses/Imreverbs/_mono/";
~bufnames = ["Block Inside.wav", "Bottle Hall.wav", "Deep Space.wav", "Nice Drum Room.wav"];

fork{
	~buffers = ~bufnames.collect{ |name,ind|
		DKBufferUtils.loadIRBuffer(~irPath ++ name, ~fftsize);
	};
};


// create the PartConv synths
~synths = ~bufnames.collect{ |name, ind|
	Synth.new(\convoOut, [\inBus, ind + 21, \pan, ind / 2 -0.75, \fftsize, ~fftsize, \bufnum, ~buffers[ind].bufnum]);
}

// **** testing routing with the NodeProxies

p.testVOsc = { |auxOut=21, freq=100, lev=0.2, buf=0|
	var sig;
	sig = VOsc.ar(buf.max(~vBufs.first.bufnum).min(~vBufs.last.bufnum - 0.1), [freq, freq + 1], 0, lev);
	Out.ar(auxOut, sig);
	Pan2.ar(sig);
}

p.testVOsc.set(\auxOut, 23, \freq, 200, \lev, 0.01, \buf, ~vBufs.first.bufnum)
p.testVOsc.play
p.testVOsc.stop
// ***** testing odd power VOsc

fork{
	~vBufs = DKBufferUtils.prepareOddPowerWavetables(8);
}

~testSig = Synth.new(\vOscTest, [\outBus, 21, \buf, ~vBufs.first.bufnum]);
~testSig.set(\buf, (~vBufs.first.bufnum + 1).min(~vBufs.lastIndex - 0.1))
~testSig.set(\freq, 50)
~testSig.free

s.sendMsg(\g_new, 1, 0, 0)
//

// Replace this with a Pseq if possible
// play a sequence
Tdef(\router, {
	var seq = Pseq([21,22,23,24,23,22],  inf).asStream;
	var pitches = Prand([100, 66, 50], inf).asStream;
	var bufs = Pseq(~vBufs.collect{|obj| obj.bufnum.min(~vBufs.last.bufnum - 0.1) }, inf).asStream;
	var count = 0;
	loop{
		~testSig.set("outBus", seq.next, "freq", pitches.next, "buf", bufs.next);
		1.wait;
	};
	// this is definitely not very elegant -- I need to learn to
	// deal with sequences better
})

Tdef(\router).play
Tdef(\router).stop


//// SynthDefs

SynthDef("vOscTest",
	{ |buf=0,freq=100,lev=0.2, outBus=21|
		Out.ar(outBus, VOsc.ar(buf, freq, 0, lev));
	}
).load(s)

SynthDef("convoOut",
	{ |pan=0, inBus=21, fftsize, bufnum|
		var in, sig;
		in = In.ar(inBus);
		sig = Pan2.ar(
			PartConv.ar(in, fftsize, bufnum),
			pan
		);
		Out.ar(0, sig);
	}
).load(s)


SynthDef("testSig",
	{ |freq=100, outBus=21 lev=0.2|
		Out.ar(outBus, LFTri.ar(freq, 0, lev));
	}
).load(s)
