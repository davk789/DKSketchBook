/**
	Pretend FFT noise. I want to generate a bunch of sine waves and have it
	sort of sound like it is resynthesizing something. And more importantly,
	I want the ugly pile of worms to contain some sort of musical sense.
	
*/

s.boot

s.prepareForRecord
s.record
s.stopRecording
/*
	this is the basic idea, but in place of random numbers, make better choices
	about everything.
*/


//// tuning

p = ProxySpace(s.boot);
p.know=true;
p.clock = TempoClock.default;

fork{
	~wtBuffers = DKBufferUtils.prepareOddPowerWavetables(6);
};

~wtBufnum = ~wtBuffers.collect{ |obj| obj.bufnum; };

p.sv = { |freq=200,buf=0,lev=0.2, lfreq1=10, interval=1.5|
	VOsc.ar(
		buf, 
		[freq*interval, freq * interval],
		[Lag2.ar(p.ar(\sv), 0.03) * 20, Lag2.ar(p.ar(\sv), 0.02) * 40],
		lev
	);
}

p.sv.set(\buf, ~wtBufnum[0])


~scale = [1/1, 9/8, 5/4, 4/3, 3/2, 9/8 + 4/3, 7/4];


Tdef(\melo, {
	var intervals = Pseq(
		~scale,
		inf
	).asStream;	
	loop{
		p.sv.set(\interval, intervals.next);
		wait(intervals.next.reciprocal * 1);
	}
});

Tdef(\melo).play
Tdef(\melo).stop

p.sv.set(\lev, 0.2, \buf, ~wtBufnum.last-1)

p.sv.play;
p.sv.stop;

p.s1 = { |freq=200,buf=0,lev=0.3, lfreq1=10, interval=1.65|
	var sig = VOsc.ar(
		buf,
		[freq, freq * interval],
		0,
		lev
	);
	sig;
}
p.s1.play
p

~scale = [1/1, 9/8, 5/4, 4/3, 3/2, 9/8 + 4/3, 7/4];
~intervals.next

Tdef(\mel2, {
	var intervals = Pseq(
		[1/1, 7/8, 8/7],
		inf
	).asStream;	
	loop{
		p.s1.set(\interval, intervals.next);
		wait(intervals.next.reciprocal * 5);
	}
});

p.s1.set(\interval, 1.65)

c = TempoClock.default;
c. = 1

Tdef(\mel2).play;
Tdef(\melo).play

Tdef(\mel2).stop
Tdef(\melo).stop


p.s1.set(\interval, 8/7)
p.s1.clear

p.s1.play;
p.s1.stop;

///

p.in0 = {	SoundIn.ar(0)};
p.in1 = {	SoundIn.ar(1)};



////////////////



p.s1 = { |freq=200,buf=0,lev=0.3, lfreq1=10|
	VOsc.ar(buf,// LFPulse.kr(lfreq1, 0, 0.5, freq* (11/10), freq)
		//[freq, freq*(11/10)]
		//freq
		freq*(11/10)
		, 0, lev);
}

p.s1.set(\freq, 200)
p.s1.set(\freq, 200 * (11/10))

Tdef(\tw, {
	loop{
		p.s1.set(\freq, 200);
		0.5.wait;
		p.s1.set(\freq, 200 * (11/10));
		1.wait;
	};
})

Tdef(\tw).play
Tdef(\tw).stop
	
p.s1.set(\lfreq1, 2, \freq, 150)
p.s1.play;
p.s1.stop;


///// seq

~dur = 0.11;

Task{
	25.do{ |ind|
		~dur = (ind * 0.01) + 0.02;
		1.wait;
	}
}.play



Tdef(\fftea, {
	var freq1, freq2, fchoice;
	var freqs = Array.series(36, 36,2.1).midicps;
	loop{
		freq1 = freqs.choose;
		freq2 = freqs.choose;
		///		fchoice = [freq1 - freq2, freq1 + freq2];
		s.listSendMsg(
			[\s_new, \PretendFFTNoise, s.nextNodeID, 0, 1] ++
			[
				"dur", ~dur.rand,
				"freq1", freq1,
				"freq2", 0.2.coin.if({freq1 - freq2}, {freq1 + freq2}),
				"lev", exprand(0.0001, 0.01),
				"pan", 2.0.rand - 1
			]
		);
		exprand(0.0002, 0.001).wait
	}
});

Tdef(\fftea).play
Tdef(\fftea).stop

// *** SynthDef section

SynthDef("PretendFFTNoise",
	{ arg freq1=440, freq2=220, mod=50, dur=0.1, lev=1, pan=0, outBus=0, curve=(-1);
		var kMod, kEnv, aSig;
		kMod = XLine.kr(freq1, freq2, dur);
		kEnv = EnvGen.kr(
			Env.linen(dur / 3.0, dur/3.0, dur/3.0, lev, curve),
			doneAction:2
		);
		aSig = SinOsc.ar(kMod, 0, kEnv);
		Out.ar(outBus, Pan2.ar(aSig, pan));
	}
).load(s)



// backups
Tdef(\fftea, {
	var freq;
	var freqs = Array.series(26, 36, 4).midicps;
	loop{
		freq = freqs.choose;
		Synth(\PretendFFTNoise,
			[
				"dur", 0.1.rand,
				"freq1", freq,
				"freq2", freq * 1.0.rand,
				"lev", 0.1.rand,
				"pan", 2.0.rand - 1
			]
		);
		0.005.rand.wait
	}
})
