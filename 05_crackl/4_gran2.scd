/**
	actually try to granulate this time.
*/

// alt server

t = Server('q_aux', NetAddr("127.0.0.1", 58008));
q = ProxySpace(t.boot);
q.know = true;
q.clock = TempoClock();

Server.named['q_aux'].makeWindow;
// main server

p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;


// ** play a sound file

// granulation buffer
~buf = Buffer.read(t, "~/Music/SuperCollider Recordings/SC_110518_153135.aiff".standardizePath);
~buf2 = Buffer.read(t, "~/Music/SuperCollider Recordings/SC_110517_170706.aiff".standardizePath);
~buf3 = Buffer.read(t, "~/Music/SuperCollider Recordings/909-blastblast.aif".standardizePath);

q.test = { SinOsc.ar([200, 201] * 0.1, SinOsc.ar(50, 0, 3), 0.3) }
q.test.play
q.test.stop


//** resampling

q.rec = \resamp
q.rec.spawn

SynthDef(\resamp, {
	RecordBuf.ar(In.ar([0,1]), ~buf.bufnum, doneAction:2, preLevel:1.0)
}).load(t);

// ** granulate a sound file

~start = 0.6;
~wait = 0.00040;
61.noteNames
Tdef(\swp, {
	var starts = Pseq(Array.series(10000, 0, 0.0001), inf).asStream;
	loop{
		~start = starts.next;
		~wait.wait;
	}
});

Tdef(\swp).play
Tdef(\swp).pause
Tdef(\swp).resume
Tdef(\swp).stop

Tdef(\pauseres, {
	var rand;
	loop{
		rand = [0.25, 0.5, 0.75].choose;
		Tdef(\swp).pause;
		rand.wait;
		Tdef(\swp).resume;		
		rand.wait;
	}
});

Tdef(\pauseres).play
Tdef(\pauseres).stop

~llev = 0.4;
Tdef(\grr, {
	//	var buf, bufs = [~buf3, ~buf2];
	var buf, dur, bufs = [~buf3, ~buf];
	dur = Array.fill(5, 0.05, 0.10);
	loop{
		~start = ~start + rrand(-0.01,0.01);		
		buf = bufs[0.1.coin.toInt];
		if(0.1.coin){
			t.listSendMsg([\s_new, \grarr, s.nextNodeID, 0, 1, 
				//"rate", [0.5 * (14/8), 0.5].choose,
				"rate", [1 *  (7/8), 1, -1, -1 * (8/7)].choose,
				"pos", 0.0002.rand + ~start,
				//"pos", 0.0002.rand + ~start,
				"dur", dur.choose,
				"curve", -5,
				"lev", ~llev.rand,
				"bias", [0.1, 0.9].choose,
				//"lev", 0.1.rand,
				"pan", [-1.0, -0.5, -0.7, 0.5, 0.7, 1.0].choose,
				"buf", buf.bufnum,
				"numFrames", buf.numFrames 
			]);
				};
		0.0015.rand.wait;	
	};
});


Tdef(\grr).stop
Tdef(\grr).play


SynthDef("grarr", 
	{ arg lev=0.2, dur=1, pan=0,
		rate=1, pos=0, buf=0, numFrames=44100, bias=0.5,
		curve=(-9);
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0],
				[bias, 1 - bias],
				curve
			),
			levelScale:lev,
			timeScale:dur,
			doneAction:2
		);
		sig = PlayBuf.ar(
			2, 
			buf,
			rate:rate,
			startPos: numFrames * pos
		);
		Out.ar(0, Balance2.ar(sig[0] * env, sig[1] * env, pan));
	}).load(t);


// ** reverb section
~fftsize = 2048;
fork{
	~rvL = DKBufferUtils.loadIRBuffer(
		"/Users/davk/Music/Impulse Responses/Imreverbs/_mono2/Greek 7 Echo Hall L.aif",
		~fftsize,
		t
	);
	~rvR = DKBufferUtils.loadIRBuffer(
		"/Users/davk/Music/Impulse Responses/Imreverbs/_mono2/Greek 7 Echo Hall R.aif",
		~fftsize,
		t
	);
}

q.rv[0] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rvL.bufnum);
	Pan2.ar(sig, -1, lev)
};

q.rv[1] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rvR.bufnum);
	Pan2.ar(sig, 1, lev)
};

q.rv.setRates(\lev, 5);
q.rv.set(\lev, 0.015)
q.rv.set(\lev, 0.1)

q.rv.play
q.rv.stop
q.rv.clear


//** from file 3

p.bass = \s_bass;

~root = 160;
~dur = 0.6;
~notes = Pseq([
	[~root * 1/1, ~dur * 1],
	[~root * 1/1, ~dur * 1],
	//	[~root * 1/1, ~dur * 1],
	[~root * 1/1, ~dur * 1],
	[~root * (4/3), ~dur * 1],
	[~root * (6/5), ~dur * 1],
	[~root * (7/8), ~dur * 1],
	[~root * 1/1, ~dur * 1],
], inf).asStream;

~notes = Pseq([
	[~root * 1/1, ~dur * 1],
	[~root * 1/2, ~dur * 0.5],
	[~root * 1/1, ~dur * 1],
	[~root * 1/2, ~dur * 0.5],
	[~root * 1/1, ~dur * 1],
	[~root * 1/2, ~dur * 0.5],
	[~root * 1/1, ~dur * 1],
	[~root * 1/1, ~dur * 0.5],
	//	[~root * 1/1, ~dur * 1],
	//	[~root * 1/1, ~dur * 1],
	//	[~root * 1/1, ~dur * 1],
	//[~root * (4/3), ~dur * 1],
	[~root * (6/5), ~dur * 1],
	[~root * (7/8), ~dur * 1],
	[~root * 1/1, ~dur * 1],
], inf).asStream;

~notes = Pseq(
	[
						[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (2/1),   ~dur * 1],
		[~root * (1/1),   ~dur * 1],
		[~root * (7/8),   ~dur * 1],
		[~root * (15/7),  ~dur * 1],
		//	[~root * (15/8),   ~dur * 1],
		[~root * (1/1),   ~dur * 1],
		[~root * (14/11), ~dur * 0.2],
		[~root * (3/2),   ~dur * 1],
	], inf).asStream;

~notes = Pseq(
	[
		[~root * (1/1),   ~dur * 1],
	], inf).asStream;

		p.bass.spawn([\freq, 60, \dur, 15, \lfreq, 5.rand]);

Tdef(\ba, {
	loop{
		postln("next");
		p.bass.spawn([\freq, [60,70,80,90,100,110,120].choose, \dur, 30, \lfreq, 45.rand, \lev, 0.1]);
		15.wait;		
	}
});

p.clock.tempo = 1
Tdef(\ba).play
Tdef(\ba).pause
Tdef(\ba).stop

Tdef(\bassline, { arg root=100;
	var dur, notes;
	loop{
		dur = ~notes.next[1];
		p.bass.spawn([\freq, ~notes.next[0], \dur, dur, \lfreq, 45, \lev, 0.2]);
		dur.wait;
	}
});

Tdef(\bassline).play;
Tdef(\bassline).pause;
Tdef(\bassline).resume;

Tdef(\bassline).stop;

Tdef(\bassline2, { arg root=100;
	var dur;
	loop{
		dur = ~notes.next[1];
		p.bass.spawn([\freq, ~notes.next[0], \dur, dur, \lfreq, 45.rand]);
		dur.wait;
	}
});

Tdef(\bassline2).play;
Tdef(\bassline2).stop;

p.clock.tempo = 1.25;

//** SynthDefs
// bassline synth
SynthDef("s_bass", 
	{ arg freq=220, pan=0, dur=1,
		  lfreq=10, lev=0.4;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0.6, 0.6, 0],
				[0.02, 0.1, 0.58, 0.3] * dur
			),
			doneAction:2
		);
		sig = SinOsc.ar(
			freq, 
			SinOsc.ar(freq * 1.7 * env + SinOsc.ar(lfreq, 0, 100), 0, 1),
			env);
		Out.ar(0, Pan2.ar(sig, pan, lev))
	}
).load(s);


// ** reverb section

~fftsize = 2048;
fork{
	~rsL = DKBufferUtils.loadIRBuffer(
		"~/Music/Edits/khrush/khr-lowest-hip-imp-l.aif".standardizePath,
		~fftsize,
		s
	);
	~rsR = DKBufferUtils.loadIRBuffer(
		"~/Music/Edits/khrush/khr-lowest-hip-imp-r.aif".standardizePath,
		~fftsize,
		s
	);
}

p.rv[0] = { |lev=0.3|
	var in, sig;
	in = In.ar(0);
	sig = PartConv.ar(in, ~fftsize, ~rsL.bufnum);
	Pan2.ar(sig, -1, lev)
};

p.rv[1] = { |lev=0.3|
	var in, sig;
	in = In.ar(1);
	sig = PartConv.ar(in, ~fftsize, ~rsR.bufnum);
	Pan2.ar(sig, 1, lev)
};

p.rv.play
p.rv.stop
p.rv.clear
p.rv.setRates(\lev, 5);
p.rv.set(\lev, 0.25)



//** SynthDefs
// bassline synth
SynthDef("s_bass", 
	{ arg freq=220, pan=0, dur=1,
		  lfreq=10, lev=0.4;
		var sig, env;
		env = EnvGen.ar(
			Env.new(
				[0, 1, 0.6, 0.6, 0],
				[0.02, 0.1, 0.58, 0.3] * dur
			),
			doneAction:2
		);
		sig = SinOsc.ar(
			freq, 
			SinOsc.ar(freq * 1.7 * env + SinOsc.ar(lfreq, 0, 100), 0, 1),
			env);
		Out.ar(0, Pan2.ar(sig, pan, lev))
	}
).load(t);


//

q.dron = { |freq=50|
	SinOsc.ar([freq, freq], 0, 0.2)
}

q.dron.setRates(\freq, 10)
q.dron.set(\freq,10)
Tdef(\grr).stop; q.dron.play;
Tdef(\grr).play; q.dron.stop;

