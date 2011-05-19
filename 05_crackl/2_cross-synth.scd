/**
	Play some more with convolution.
*/



p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;


~crossL = "~/Music/Edits/khrush/khr-lowest-hip-imp-l.aif".standardizePath;
~crossR = "~/Music/Edits/khrush/khr-lowest-hip-imp-r.aif".standardizePath;
~fftSize = 2048;

fork{
	~whisImpL = DKBufferUtils.loadIRBuffer(~crossL, ~fftSize);
	~whisImpR = DKBufferUtils.loadIRBuffer(~crossR, ~fftSize);
}

p.ruff = { |freq=100, fbk=0.1, lev=0.2, mod=2, del=0.1|
	SinOsc.ar(
		freq,
		DelayC.ar(p.ar(\ruff), 1, del, fbk, p.ar(\ruff)) * mod,
		lev
	);
}

p.ruff = { Saw.ar(500, 0.2); }
p.ruff = { WhiteNoise.ar(0.2) }

p.ruff.play
p.ruff.stop

p.ruff.set(\mod, 6, \fbk, 0.5, \del, 0.01, \freq, 20)

// convolver - cross-synthesis, uses p.ruff input
p.convL = { |lev|
	var sig, in;
	in = p.ar(\ruff);
	sig = PartConv.ar(in, ~fftSize, ~whisImpL.bufnum);
	Pan2.ar(sig, -1, lev)
};

p.convR = { |lev|
	var sig, in;
	in = p.ar(\ruff);
	sig = PartConv.ar(in, ~fftSize, ~whisImpR.bufnum);
	Pan2.ar(sig, 1, lev)
};

p.convL.play; p.convR.play;


p.con1 = { |bufnum=3, lev=1|
	var in  = p.ar(\pulse);
	//	var in = Ringz.ar(Impulse.ar(2, 0, 0.2), 50, 0.3);
	var sig = PartConv.ar(in, ~fftsize, ~irBuffers[4].bufnum); 
	Pan2.ar(sig, 0, lev);	
}
//&&&&

