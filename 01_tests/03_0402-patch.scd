/**
	This is where the code for the performance on 4/2 will go. Perhaps the rule can 
	be to make a separate file for each performance. SynthDefs should go in their own
	files, I think.
*/


// load all the SynthDefs at once
(Platform.userAppSupportDir ++ "/Extensions/DKSketchBook/SynthDefs/01_040211-show.scd").load
s.options.device = ServerOptions.devices[0]; // force edirol use
p

p = ProxySpace(s.boot);
p.push;
p.fadeTime = 0.25;
p.clock = TempoClock.default

s.prepareForRecord
s.record
s.stopRecording

// run number 5

~rpcm.stop
~rpcm.clear
~rpcm.play
~rpcm = {|vol=1| RedDPCMdecode.ar(SoundIn.ar([0,1]) * vol) * (1/vol) }
~rpcm = {|vol=0.2,freq=100| RedDPCMdecode.ar(
	SinOsc.ar([freq, freq+1], 0, 1)
) * vol }

~rpcm.set(\vol, 1)


~sin = {SinOsc.ar(100, 0, 1)}

~sid.play
~sid.stop
~sid.clear

//{Pan2.ar(SID6581f.ar(
// 0, 100, 0, 0, LFPulse.kr(0.1)+18, 219, 0,
// 0, 0, 0, 0, 0, 0, 0,
// 0, 28, 0, 0, 0, 0, 0,
// 0, 0, 0, 15))}.play


~sidtrig = {LFPulse.kr(MouseX.kr(1, 350, 2))+100}
~sidtrig = {LFPulse.kr(LFNoise0.kr(1, 350, 350))+100}

~sid = {Pan2.ar(
	SID6581f.ar(
		20, 255, 0, 0.3, ~sidtrig, 3, 200,
		0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
		0, 104, 1, 79, 3))}


~sid = {
	Pan2.ar(
		SID6581f.ar(
			0, 100, 0, 0, LFPulse.kr(0.1)+18, 219, 0,
			// 32,      200,     0.1,   0.6,   4,     5,       5,
			// freqLo0, freqHi0, pwLo0, pwHi0, ctrl0, atkDcy0, susRel0,
			   0,       0,       0,     0,     0,     0,       0,
			// freqLo1, freqHi0, pwLo0, pwHi0, ctrl0, atkDcy0, susRel0, < -- ignore these for now
			   0,       0,       0,     0,     0,     0,       0,
			// freqLo2, freqHi0, pwLo0, pwHi0, ctrl0, atkDcy0, susRel0,
			   2,    200,  7,       13,      1
			// fcLo, fcHi, resFilt, modeVol, rate
		)
	)
};

~sid.play
// don't bother with using synthdefs, it seems to break the parts of the
// model that interest me

~osc = \lcPhaseModFB;


// too much wirdness using SynthDef -- the explicit calls to "Out"
// confuse the play/stop model, as well as other things like the rates
~osc = { |freq=0,fb=10,mul=0.2,outBus=0|
	var fbin, sig;
	fbin = LocalIn.ar();
	sig = SinOsc.ar(freq, fb * fbin, mul);
	LocalOut.ar(sig);
	Pan2.ar(sig);
};
~osc.play;
~osc.stop;
// lag doesn't work with the SynthDefs?

~osc.lag(\fb, 1000);
~osc.lag(\fb, 0);
~osc.set(\fb, 5)

~osc.spawn;
~osc.free;

~osc.set(\freq, 440);

// fourth try ... still running in to problems with multiple
// feedback loops

~osc.play
~osc.stop


~osc = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};


~osc.map(\phase, ~mod)
~osc.set(\freq, 0, \pmul, 200)


// use this as an input to the phase mod
// this is a good ugen to use at very slow rates
~mod = { |lev=1| Lag.ar(RedNoise.ar(MouseX.kr(1000, 100000), lev), 0.2) }





// third try


~osc.stop

~osc = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};
~osc.set(\freq, 0.0, \pmul, 14)

~fb2 = { |inBus,lev=1| In.ar(inBus) * lev }
~osc2.play
~osc2 = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};
~osc2.map(\phase, ~fb2)
~osc2.set(\freq, 0, \pmul, 8, \mul, 0.12)

Tdef(\mul2, {
	loop{
		~osc2.set(\pmul, [8,9,10,11,12,11].choose);
		1.wait
	}
})
p.clock.tempo = 0.5

Tdef(\mul2).play
Tdef(\mul2).stop
~osc[2] = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};


~fb = { |inBus,lev=1| In.ar(inBus) * lev }

~osc.free
~osc.map(\phase, ~fb)
~osc.unmap(\phase)

~osc.set(\freq, 100, \pmul, 0)
~osc[2].set(\freq, 1000, \pmul, 0)
~osc[1].set(\freq, 5000, \pmul, 0)
~osc[1].play



// maybe not worry so much about SynthDefs for now
~in.stop
~in.play

~in = { |lev=1| Pan2.ar(SoundIn.ar(0) * lev) };
~in = { |lev=1| SoundIn.ar([0,1]) * lev };


~fbk = { |lev=1| p.ar(\osc) * lev }

~osc.play
~osc.stop
~osc = { SinOsc.ar([440,444], 0, 0.2) }

~osc = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};
~osc.set(\pmul, 14.9, \freq, 0)

~osc[1].set(\pmul, 0, \freq, 1000)
~osc.map(\phase, ~in)
~osc[1].map(\phase, ~in)
~osc[1].free
~osc[1].play

~osc[1] = { |freq=0,phase=0,pmul=10,mul=0.2|
	SinOsc.ar([freq,freq],phase * pmul, mul);
};




~osc.free
~osc.play


~osc.map(\phase, ~in)
~osc.map(\phase, ~fbk)



// doesn't work so well

~pm = \lcPhaseModder;

~pm.free
~pm.spawn

~pm.play

~drive = { |mul=1000,add=1| (In.ar(1) * mul) + add }
~drive.set(\mul, 100, \add, 300)

~drive = { |freq=10,phase=0,mul=100,add=0| SinOsc.ar(freq,phase,mul,add) }
~drive = { SinOsc.ar(440, 0, 200, 200) }
~drive.setRates(\phase, \tr) // for some reason resetting persistent

// synths does not really work very well here, but re-setting the control to
// trigger rate achieves the same effect

~drive.set(\phase, 0)
~drive.set(\freq, 0.01, \mul, 10000)

~pm.map(\freq, ~drive)
~pm.unmap(\freq)

~pm.map(\phase, ~drive)
~pm.unmap(\phase)

~pm.set(\freq, 0)
~pm.set(\freq, 100)
~pm.set(\freq, 0)
~pm.fadeTime = 1





// i don't think this will work
// **********************************
// *** resampling REC
s.serverRunning
e.mrec1 = Buffer.alloc(s, s.sampleRate * 5, 1);
//e.mrec2 = Buffer.alloc(s, s.sampleRate * 60, 1);
//e.rec1 = Buffer.alloc(s, s.sampleRate * 5, 2);
//e.rec2 = Buffer.alloc(s, s.sampleRate * 60, 2);

//inputArray, bufnum, offset, recLevel, preLevel, run, loop, trigger, doneAction
Tdef(\recsample, {
	s.sendMsg(\s_new, \lcRecordBuf, s.nextNodeID, 1, 1, \bus, ~click.index, \bufnum, e.mrec1.bufnum);
	
	(e.mrec1.numFrames / s.sampleRate).wait;
	postln("mrec1 is ready to play");
	e.mrec1.close;
});
Tdef(\recsample).play

SynthDef("lcRecordBuf", { |bus,bufnum|
	// numChannels, bufnum, rate, trigger, startPos, loop, doneAction
	RecordBuf.ar(bus, bufnum, 0.0, 1, 0, doneAction:2);	
}).load(s);

e.mrec1.close
e.mrec1.plot
// numChannels, bufnum, rate, trigger, startPos, loop, doneAction

~play = { |rate=0.001, lev=0.2|
	var sig, buf = e.mrec1;
	sig = Pan2.ar(PlayBuf.ar(buf.numChannels, buf.bufnum, rate, 1, 0, 1)) * lev;
}

~play.set(\lev, 0.07)
~play.set(\rate, 0.000001)
~play.setRates(\rate, 30)
~play.play
~play.stop

s.prepareForRecord
s.record
s.stopRecording
