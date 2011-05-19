/**
	actually try to granulate this time.
*/


p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;


Distortion


// ** reverb section

~fftsize = 2048;
fork{
	~rvL = DKBufferUtils.loadIRBuffer(
		//		"~/Music/Edits/khrush/khr-lowest-hip-imp-l.aif".standardizePath,
		~fftsize
	);
	~rvR = DKBufferUtils.loadIRBuffer(
		//"~/Music/Edits/khrush/khr-lowest-hip-imp-r.aif".standardizePath,
		~fftsize
	);
}

p.rv[0] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rvL.bufnum);
	Pan2.ar(sig, -1, lev)
}

p.rv[1] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rvR.bufnum);
	Pan2.ar(sig, 1, lev)
}

p.rv.setRates(\lev, 5);
p.rv.set(\lev, 0.55)

p.rv.play
p.rv.clear


//** SynthDefs