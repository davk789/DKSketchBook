/**
	scratch document to use proxyspace_examples.html code examples
*/

s.serverRunning;

s.options.device = ServerOptions.devices[0]; // use the edirol
s.boot;
s.quit
// other helpfiles to check out:
jitlib_fading
jitlib_efficiency
the_lazy_proxy

s.boot
p = ProxySpace(s)
p.push
currentEnvironment
p.clear
p
p.reduce// remember this command
p.clean// these two commands == p.clear
p.know = true

~out.play;
p.release
p.clear
p.free
~out.stop
// something about multichannel expansion
s.serverRunning

//granular synthesis = efficient code - see also [jitlib_efficiency]

p.clean
~out.play
~out = 0

SynthDef("grain", {|i_out=0,pan,freq=440|
	var env;
	env = EnvGen.kr(Env.perc(0.001, 0.003, 0.2), doneAction:2);
	Out.ar(i_out, Pan2.ar(FSinOsc.ar(freq), pan) * env);
}).send(s)

~someInput.ar(2);
~out = ~someInput;

t = Task({
	loop({
		s.sendMsg(\s_new, \grain, -1, 0, 0,
			\i_out, ~someInput.index, // returns the bus input of the proxy
			\pan, [-1,1].choose * 0.2,
			\freq, [1000,2000,7000,8000,9000].choose
		);
		[0.01, 0.02].choose.wait;
	})
})

t.play
t.stop

~out = BPF.ar(~someInput.ar * (LFNoise2.ar(2) > 0), 0.2, 0.2, MouseX.kr(0.1,5,1));

~out.fadeTime

// client side routines



~out.play;
~out.awake = false;

~out = SynthDef("a", {
	|out=0,freq=800,pmf=1.0,pan=0|
	var env,u;
	env = EnvGen.kr(Env.perc(0.001, 0.04, 0.4), doneAction:2);
	u = SinOsc.ar(freq * Rand(0.9, 1.1), SinOsc.ar(pmf, 0, pi), env);
	Out.ar(out, Pan2.ar(u, pan));
})

// use Tdefs to access the currentEnvironment
t = Task.new({
	loop({
		~out.spawn([\pmf, [1,20,300].choose, \pan, [0, -1, 1].choose]);
		[1.0, 0.01, 0.25].choose.wait;
	});
});

t.start;
t.stop;
t.start;

~out.set(\freq, 3300);
~out.set(\freq, 600);
~out.set(\freq, 1900);
~out.map(\freq, ~lfo);
~lfo = {SinOsc.kr(1, 0, 3000,4000)}


// change the definition while going along
(
~out = SynthDef("a", { arg out, freq=800;
var env;
env = EnvGen.kr(Env.perc(0.01, 0.1, 0.3),doneAction:2);
Out.ar(out, Pulse.ar(freq * Rand([0.9,0.9], 1.1), 0.5, env) )
});
)

t.stop
~out.awake = true
~lfoStereo = { LFNoise1.kr([1,1], 300, 10500) } //


// store and instrument
Instr(\test, {|dens=520,ffreq=7000| Ringz.ar(Dust.ar(dens, [1,1] * 0.1), ffreq, 0.02)})

~out = Patch(\test, [10, rrand(5000,8000)])


~out = InstrSpawner({ arg freq=1900,env,pan;
	Pan2.ar(SinOsc.ar(freq, 0.5pi, 0.3) * EnvGen.kr(env, doneAction: 2), pan)
},[
	700,//Prand([1500, 700, 800, 3000] + 170.rand2, inf),
	Env.perc(0.002,0.01),
	0.1//Prand([-1,1],inf)
],0.125)



~out.fadeTime = 3

~out = Pbind(\instrument, \who, \freq, ~lfoStereo, \legato, 0.02).trace;
~out = Pbind(\instrument, \who, \ffreq, ~lfoStereo, \legato, 0.02)
~out = Pbind(\instrument, \who, \freq, 500, \ffreq, ~lfoStereo, \legato, 0.02)

~lfoStereo = {[MouseX.kr(100, 15500, 1), SinOsc.kr(SinOsc.kr(0.2, 0, 10, 10),0, 400, 700)]}
~lfoStereo = {[MouseX.kr(100, 15500, 1), MouseY.kr(100, 15500, 1)]}
~out.fadeTime = 0.3;


~out = Pbind(
	\instrument, \who,
	\freq, Pshuf([500, 380, 200, 510, 390, 300, 300],inf) * rrand(1.0, 2.0),
	\legato, 0.1,
	\ffreq, Pshuf([~lfo, 100, ~lfo, 100, 300, 550], inf),
	\dur, Pshuf([1/3,1/3,1,0.5,0.5,0.5], inf)//0.125 * [1, 2, 3, 2/3].choose
);
~out.play

~outB.stop
~out.stop

~outB = Pbind(
	\instrument, \who,
	\freq, Pseq([500, 380, 200, 510, 390, 300, 300],inf) * rrand(0.02, 0.2),
	\legato, 0.1,
	\ffreq, Pshuf([~lfoStereo, 10, ~lfoStereo, 10, 30, 55], inf),
	\dur, Pshuf([1,0.5,0.5], inf)//0.125 * [1, 2, 3, 2/3].choose
);

p.quant = 1

p.fadeTime = 0.1
~out.release
p.clock = TempoClock.default
p.clock.tempo = 100 / 60
p.clock.tempo = 60 / 60
p.quant = 1
s.queryAllNodes

~out.fadeTime = 3.2

~out = Pbind(
	\instrument, \who,
	\freq, Pshuf([~lfoStereo, 380, ~lfoStereo, 510, 390, 300, 300], inf),
	\ffreq, 401,
	\legato, 0.01
)


/////// playing with patterns

SynthDef(\who, { arg amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800;
	var env;
	env = Env.asr(0.01, amp, 0.5);
	Out.ar(out, Pan2.ar(
		Formant.ar(freq + [detune, detune], ffreq, 30, EnvGen.kr(env, gate, doneAction:2)),
		Rand(-1.0, 1.0))
	)
}).load(s);

~out = 0

~out = Pbind(
	\instrument, \who,
	\freq, Pshuf([500, 380, 200, 510, 390, 300, 300], inf),
	\ffreq, 401,
	\legato, 0.2
)

~out = Pbind(
	\instrument, \who,
	\freq, Pshuf([~lfo, 380, ~lfo, 510, 390, 300, 300], inf),
	\ffreq, 401,
	\legato, 0.01
)

~out = Pbind(\instrument, \who, \freq, 500, \ffreq, ~lfo, \legato, 0.02);
~out = Pbind(\instrument, \who, \freq, 20, \ffreq, ~lfo, \legato, 0.02);


~lfo = { SinOsc.kr(1, 1.5 * pi, 1700, 500) }

~clock

p.free
p.clock.tempo = 8;
p.clock = TempoClock.default;




// playing with rates

~out = { arg trig, dt=1, froot=7000, freqs=#[1,1.5,2,2.5,3]; Decay2.kr(trig, 0.01, dt) * Mix(SinOsc.ar(froot * freqs)) };
~out.setRates(\trig, \tr);

~out = SynthDef("poop", { |outBus=0, freq| Out.ar(outBus, Pan2.ar(SinOsc.ar(400, 0, 0.2)))})
~out.rebuild

~out = SynthDef("poo", { arg out=0, gate=1;
	Out.ar(out,
		SinOsc.ar([Rand(430, 800), Rand(430, 800)], 0, 0.2)
		* EnvGen.kr(Env.asr(1,1,1), gate, doneAction:2)
	)
});
/// using SynthDefs.... you have to explicitly use Out.ar in this case;
// hmm hmmm interesting
SynthDef("staub", { arg out, gate=1; 
Out.ar(out, 
Ringz.ar(Dust.ar(15), Rand(1, 3) * 3000*[1,1], 0.001) 
* EnvGen.kr(Env.asr, gate, doneAction:2)
) 
}).send(s);

~out = SynthDef("w", { arg out, lfo, f0=430;
Out.ar(out,
SinOsc.ar([Rand(f0, 800), Rand(f0, 800)]+lfo, 0, 0.2) 
* EnvGen.kr(Env.perc(0.01, 0.03), doneAction:2)
) 
});

~out.spawn;
~out.spawn([\f0, 5000.rand]);
fork{ 50.do{ ~out.spawn([\f0, 1000 + [1000,2000].choose]); [0.05,0.1,0.2].choose.wait; } };


SynthDef("staub", { arg out; 
	Out.ar(out, Ringz.ar(WhiteNoise.ar(0.01), 1000 * [1,1], 0.001)) 
}).memStore; // store the synth def so it is added to the SynthDescLib



~out = 0;
~out = nil;
p
~out = \staub;
~out.spawn;

~out.group.set(\gate, 0)

~out.set(\gate, 1)
s.queryAllNodes

// set the group, so the node proxy does not store the new value
~out.group.set(\trig, 0.1, \dt, 0.1); 
~out.group.set(\trig, 0.4, \dt, 0.31);



~out.setn(\freqs, Array.fill(3, { 1.0.rand + 1 }));
~out.setn(\freqs, Array.fill(4, { rrand(0.25, 2.0) }))
~out.group.set(\trig, 0.13, \dt, 2, \froot, [2000,3000].choose);
~out.group.set(\trig, 0.13, \dt, 2, \froot, 1000)
~out.lag(\froot, 0.4)
~out.setRates(\trig, nil)


p.pop;