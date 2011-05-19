/**
	Out of time. There can be no fancy routing, since JITLib does not allow it, so 
	instead work within the limitation of the tool set. Isn't that the point after all?
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

// *** ir buffer section
~fftsize = 2048;
// these are all corrupt. just use one for the hell of it
~samplicityIRs = "/Users/davk/Music/Impulse Responses/Samplicity T600 - 05 - Wave, 24 bit, 44.1 khz/_mono/";
~lmIRs = "/Users/davk/Music/Impulse Responses/Imreverbs/_mono/";

~bufNames = [
	~samplicityIRs ++ "T600 - 071 Slapback Piano C.wav",
	~lmIRs ++ "Small Prehistoric Cave.wav",	
	~lmIRs ++ "In The Silo Revised.wav",	
	~lmIRs ++ "Nice Drum Room.wav",	
	~lmIRs ++ "Greek 7 Echo Hall.wav",	
	~lmIRs ++ "Highly Damped Large Room.wav",
];

fork{
	~irBuffers = ~bufNames.collect{ |name|
		DKBufferUtils.loadIRBuffer(name, ~fftsize);
	};
};

// *** reverb/pulse section
p.pulse = { |freq=0.2|
	Ringz.ar(
		Impulse.ar(freq, 0, 0.2) + Impulse.ar(freq / 8, 0.29, 0.2),
		50,
		0.6);
}

p.pulse.play
p.pulse.stop

p.pulse = { |freq=0.2, rate=5000, smooth=0.7, lev=1|
	var rng;
	rng = Ringz.ar(
		Impulse.ar(freq, 0, 0.2) + Impulse.ar(freq / 8, 0.29, 0.2),
		50,
		0.6);
	SmoothDecimator.ar(rng, rate, smooth, lev);
}

p.pulse.set(\smooth, 0.1, \rate, 2000, \lev, 1)

// start very slow and speed up here
Tdef(\asd, {
	loop{ p.pulse.set(\rate, [2000, 3000].choose);
		2.wait
	}
})

Tdef(\asd).play
Tdef(\asd).stop

p.pulse.setRates(\freq, 320)
p.pulse.setRates(\freq, 0)
p.pulse.set(\freq, 0.0000000000001)
p.pulse.stop
p.pulse.set(\freq, 1)
p.pulse.set(\freq, 2)
p.pulse.set(\freq, 7)
p.pulse.set(\freq, 77)

p.con1 = { |bufnum=3, lev=1|
	var in  = p.ar(\pulse);
	//	var in = Ringz.ar(Impulse.ar(2, 0, 0.2), 50, 0.3);
	var sig = PartConv.ar(in, ~fftsize, ~irBuffers[3].bufnum); 
	Pan2.ar(sig, 0, lev);	
}
//&&&&

p.con1.set(\lev, 2);
p.con1.play
p.con1.stop

p.con1 = { |bufnum=3, lev=1, time=0.1, fbk=0|
	var in = DelayC.ar(p.ar(\pulse), 2, time, 1, p.ar(\con1) * fbk);
	//	var in = Ringz.ar(Impulse.ar(2, 0, 0.2), 50, 0.3);
	var sig = PartConv.ar(in, ~fftsize, ~irBuffers[2].bufnum); 
	Pan2.ar(sig, 0, lev);	
}

p.con1 = { |bufnum=3, lev=1, time=0.1, fbk=0|
	var in = DelayC.ar(p.ar(\pulse), 2, time, 1, p.ar(\con1) * fbk);
	//	var in = Ringz.ar(Impulse.ar(2, 0, 0.2), 50, 0.3);
	var sig = PartConv.ar(in, ~fftsize, ~irBuffers[0].bufnum); 
	Pan2.ar(sig, 0, lev);	
}


p.con1.set(\lev, 0.6)

Tdef(\cfuk, {
var times = [0.1, 0.125, 0.25, 0.375, 0.5];
	loop{
		p.con1.set(\time, times.choose); 
		0.5.wait;
	}
})

Tdef(\cfuk).play
Tdef(\cfuk).stop


// *** sharp sine section

fork{
	~wtBuffers = DKBufferUtils.prepareOddPowerWavetables(6);
};

p.sin.ar(nil,2);
p.sin.set(\buf1, ~wtBuffers.[0].bufnum, \buf2, ~wtBuffers[1].bufnum)

p.sin[0] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.01, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=15, pfreq2=25,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, freq1, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, 1)	
};

p.sin[1] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.01, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=15, pfreq2=25,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, freq1, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, -1)
}

p.sin[2] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.001, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=18, pfreq2=27,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, freq1, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, -1)
}

p.sin[0] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.01, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=15, pfreq2=25,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, p.ar(\con1) * freq1, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, 1)	
};

p.sin[3] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.01, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=15, pfreq2=25,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, p.ar(\con1) * freq1, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, -1)	
};

p.sin[1] = { |buf1=13,buf2=13, freq1=1000, freq2=1100,
	fb1=50, fb2=75,
	lu1=0.01, ld1=0.01,
	lu2=0.01, ld2=0.01,
	pfreq1=15, pfreq2=25,
	vol=7| // check the bufnum before setting the default arg
	var sin1 = VOsc.ar(buf1, p.ar(\con1) * freq2, p.ar(\sin) * fb2, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq1, 0, 0.5, 1), lu1, ld1);
	var sin2 = VOsc.ar(buf2, freq2, p.ar(\sin) * fb1, 0.2)
	    * LagUD.ar(LFPulse.ar(pfreq2, 0.5, 0.5, 1), lu2, ld2);
	var sig = Mix.ar(sin1 * sin2);
	//sig * vol
	Pan2.ar(sig * vol, -1)
}

p.sin.stop
p.sin.play
p.sin.set(\vol, 0.1)
p.sin.set(\vol, 3)
p.sin.setRates(\vol, 30)

p.sin.set(\pfreq1, 10, \pfreq2, 6, \ld2, 1, \freq1, 10030, \freq2, 30)
p.sin.set(\pfreq1, 12, \pfreq2, 6, \ld2, 1, \freq1, 1030, \freq2, 30)
p.sin.set(\pfreq1, 12, \pfreq2, 6, \ld2, 1, \freq1, 830, \freq2, 280)

Tdef(\asd).play
Tdef(\asd, {
	loop{p.sin.set(\pfreq1, 12, \pfreq2, 6, \ld2, 1, \freq1, 1030, \freq2, 30);
		4.wait;
p.sin.set(\pfreq1, 12, \pfreq2, 6, \ld2, 1, \freq1, 830, \freq2, 280);
4.wait;
}
})



p.sin.set(\freq2, 3, \freq1, 10000, \fb1, 9, \fb2, 90)
p.sin.set(\freq2, 10000, \freq1,10)
p.sin.setRates(\freq2, 1, \freq1,1)
p.sin.setRates(\freq2, 0, \freq1,0)
p.sin.set(\freq2, 8000, \freq1,20)
p.sin.set(\pfreq1, 10, \pfreq2, 6, \ld2, 1, \freq1, 10030, \freq2, 0.1)

p.sin.set(\pfreq1, 10, \pfreq2, 15, \ld2, 0.1, \ld1, 1)
p.sin.set(\pfreq1, 10, \pfreq2, 5, \freq1, 10, \freq2, 4, \ld1, 1, \ld2, 0.3)
p.sin.setRates(\buf1, 120, \buf2, 120)
p.sin.setRates(\buf1, 12, \buf2, 12)
p.sin.set(\buf1, ~wtBuffers[0].bufnum, \buf2, ~wtBuffers[4].bufnum)
p.sin.set(\buf1, ~wtBuffers[4].bufnum, \buf2, ~wtBuffers[0].bufnum)
p.sin.set(\buf1, ~wtBuffers[4].bufnum, \buf2, ~wtBuffers[4].bufnum)
p.sin.set(\buf1, ~wtBuffers.last.bufnum-0.1, \buf2, ~wtBuffers.last.bufnum-0.1)
p.sin.set(\buf1, ~wtBuffers[0].bufnum, \buf2, ~wtBuffers[0].bufnum)
p.sin[1].set(\buf1, ~wtBuffers[3].bufnum, \buf2, ~wtBuffers[2].bufnum)

p.mully = {
	p.sin * p.con1
}

p.mully.play
// *** global delay

p.gdelL = { |fbk=0, time=0.1, lev=0.2|
	var sig = DelayC.ar(In.ar(0), 2, time, 1, p.ar(\gdelL) * fbk);
	Pan2.ar(sig, -1, 0.5);
};

p.gdelR = { |fbk=0, time=0.1, lev=0.2|
	var sig = DelayC.ar(In.ar(1), 2, time, 1, p.ar(\gdelR) * fbk);
	Pan2.ar(sig, 1, 0.5);
}

p.gdelR.setRates(\time, 0.2); p.gdelL.setRates(\time, 0.2)
p.gdelR.set(\fbk, 0, \time, 0.125, \lev, 0.2); p.gdelL.set(\fbk, 0, \time, 0.125, \lev, 0.2)
p.gdelR.set(\time, 0.1); p.gdelL.set(\time, 0.1)
p.gdelR.set(\fbk, 0.5, \time, 0.5); p.gdelL.set(\fbk, 0.5, \time, 0.5)

p.gdelR.play; p.gdelL.play
p.gdelR.stop; p.gdelL.stop

Tdef(\dfuk, {
var times = [0.1, 0.125, 0.25, 0.375, 0.5];
	loop{
		p.gdelR.set(\time, times.choose); p.gdelL.set(\time, times.choose);
0.5.wait;
	}
})

Tdef(\dfuk).play
Tdef(\dfuk).stop
