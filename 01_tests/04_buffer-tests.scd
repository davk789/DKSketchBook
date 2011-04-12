/*
	try pulling and cutting some buffers
*/

// there is no file here
(Platform.userAppSupportDir ++ "/Extensions/DKSketchBook/SynthDefs/buffer-synthdefs.scd").load
// force use of the edirol
s.options.device = ServerOptions.devices[0]; // force edirol use

// recording
s.prepareForRecord
s.record
s.stopRecording

// startup the environment
p = ProxySpace(s.boot);
p.push;
p.fadeTime = 0.25;
p.clock = TempoClock.default;

e = Environment(); // environment for buffers
e.know = true;

// **********************************
// *** play back soundfiles PLAY
e.lastsf = Buffer.cueSoundFile(s, "~/Music/SuperCollider Recordings/*.aiff".standardizePath.pathMatch.sort.last);
~lastsf = { |lev=1|
	DiskIn.ar(2, e.lastsf.bufnum, 1) * lev;
}

~lastsf.set(\lev, 0.5)

~lastsf.play
~lastsf.stop

e.lastsf2 = Buffer.cueSoundFile(s, "~/Music/SuperCollider Recordings/*.aiff".standardizePath.pathMatch.sort.last);
~lastsf2 = { |lev=1|
	DiskIn.ar(2, e.lastsf2.bufnum, 1) * lev;
}

~lastsf2.set(\lev, 0.5)

~lastsf2.play
~lastsf2.stop

e.lastsf3 = Buffer.cueSoundFile(s, "~/Music/SuperCollider Recordings/*.aiff".standardizePath.pathMatch.sort.last);
~lastsf3 = { |lev=1|
	DiskIn.ar(2, e.lastsf3.bufnum, 1) * lev;
}

~lastsf3.set(\lev, 0.7)

~lastsf3.play
~lastsf3.stop


s.prepareForRecord
s.record
s.stopRecording

// **********************************
// *** click sample playback section CLK

e.clk1 = Buffer.read(s, "~/Music/SuperCollider Recordings/SC_110401_223323-norm.aiff".standardizePath);
e.clk2 = Buffer.read(s, "~/Music/SuperCollider Recordings/SC_110401_223812-norm.aiff".standardizePath);



~click.set(\rate, 2.0.rand);
~click.set(\rrate, 100);
~click.stop
~click2.stop
p.stop
~click.setRates(\rate, 120);
~click2.setRates(\rate, 120);

Tdef(\clickPitches, {
	var pitch;
	loop{
		pitch = rrand(0.1, 4.0, 5);
		~click.set(\rate, pitch);
		pitch.postln;
		120.rand.wait;
	}
});

Tdef(\clickPitches).play
Tdef(\clickPitches).stop

~click = { |rate=1, rrate=1|
	var sig, buf;
	buf = e.clk1;
	sig = PlayBuf.ar(
		buf.numChannels,
		buf.bufnum,
		rate,
		Dust.kr(2),
		LFNoise1.kr(1, buf.numFrames, buf.numFrames / 2),
		1 // loop
	);
	Pan2.ar(sig);
}


~click.play
~click.stop


~click.set(\rate,0)
~click.set(\rate,1)

~click2.set(\rate,0, \rrate, 0)
~click2.set(\rate,0, \rrate, 500)
~click2.set(\rate,1, \rrate, 100)

~click2.play
~click2.stop

~click.play
~click.stop

~click2 = { |rate=1, rrate=1|
	var sig, buf;
	buf = e.clk2;
	sig = PlayBuf.ar(
		buf.numChannels,
		buf.bufnum,
		rate,
		Pulse.kr(rrate),
		LFNoise1.kr(1, buf.numFrames, buf.numFrames / 2),
		1 // loop
	);
	Pan2.ar(sig);
}

~click2 = { |rate=1, rrate=1|
	var sig, buf;
	buf = e.clk2;
	sig = PlayBuf.ar(
		buf.numChannels,
		buf.bufnum,
		rate,
		Dust.kr(rrate),
		LFNoise1.kr(1, buf.numFrames, buf.numFrames / 2),
		1 // loop
	);
	Pan2.ar(sig);
}

~click2.play;
~click2.stop;

// **********************************
// *** click live section CLKL


~sidtrig = {LFPulse.kr(10)}
~sidtrig = {LFPulse.kr(MouseX.kr(1, 350, 2))+100}
~sidtrig = {LFPulse.kr(LFNoise0.kr(1, 350, 350))+100}
~sidtrig = {Dust.kr(LFNoise0.kr(1, 350, 350)) + 100}

p.stop

~sid.play

~sid = { |gain=1,rez=1,lev=1|
	Pan2.ar(
		 RHPF.ar(
			 SID6581f.ar(
				 20, 255, 0, 0.3, ~sidtrig, 3, 200,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 104, 1, 79, 3
			 ) * gain,
			 10,
			 0.01
		 ) * lev
	);
}

~sid = { |lev=1|
	Pan2.ar(
			 SID6581f.ar(
				 20, 255, 0, 0.3, ~sidtrig.ar, 7, 200,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 0, 0, 0, 0, 0, 0,
				 0, 104, 1, 79, 3
			 ) * lev
	);
}

~sid.fadeTime = 0.1
~sid.set(\lev, 0.3, \gain, 10, \rez, 0.01)
~sid.setRates(\lev, 2)
~sid.set(\lev, 1)
~sid.setRates(\gain, 2, \rez, 1)
~sid.set(\lev, 7, \gain, 1, \rez, 1) // dry
~sid.set(\lev, 1, \gain, 1, \rez, 1)
~sid.play
~sid.stop

// **********************************
// *** SinOsc phase mod section PHASE

~sin = { |freq=0, lev=0.2, lagu=1, lagd=1, pm=10|
	var in = SoundIn.ar(0);
	var lag = LagUD.ar(in, lagu, lagd, pm);
	Pan2.ar(SinOsc.ar(freq, lag, lev));
}

~sin = { |freq=0, lev=0.2, lagu=1, lagd=1, pm=10|
	var sig = LagUD.ar(~sid.ar, lagu, lagd, pm);
	Pan2.ar(SinOsc.ar(freq, sig, lev));
}
p.stop
~sin.play
~sin.stop
~sin3.stop

~sin.setRates(\lev, 5)
~sin.setRates(\pm, 1)
~sin.setRates(\freq, 120)

~sin.setRates(\freq, 200); ~sin2.setRates(\freq, 200)

~sin.setRates(\freq, 2); ~sin2.setRates(\freq, 2) // back to normal

~sin.set(\freq, 40); ~sin2.set(\freq, 35);

~sin2.setRates(\freq, 300)
~sin2.set(\freq, 65);
~sin2.set(\pm, 9.5)
~sin.set(\lev, 0.06, \pm, 9, \freq, 60)


~sin2 = { |freq=0, lev=0.2, lagu=1, lagd=1, pm=10|
	var in = SoundIn.ar(0);
	var lag = LagUD.ar(in, lagu, lagd, pm);
	Pan2.ar(SinOsc.ar(freq, lag, lev));
}


~sin2.setRates(\lev, 5)
~sin2.setRates(\pm, 1)
~sin2.setRates(\freq, 120)

~sin2.set(\freq, 190, \lev, 0.08)
~sin2.set(\lev, 0.06, \pm, 9, \freq, 60)

~sin2.play
~sin2.stop



~sin.set(\pm, 350, \freq, 60)

p.fadeTime = 5
p.stop
~sin.set(\pm, 200, \freq, 0)
~sin.set(\freq, 6, \pm, 350, \lagu, 0.01, \lagd, 0.0004, \lev, 0.08)



////// ******* etc

~testSin2 = { Pan2.ar(SinOsc.ar(440,0,0.2)) }

~testSin2.play
~testSin2.stop
