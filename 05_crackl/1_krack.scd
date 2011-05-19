/**
	crackling percussion
*/



s.boot

p = ProxySpace(s.boot);
p.know = true;

p.clock = TempoClock.default


p.stop

/// Crackle

p.krak = { |tempo=1|
	var env = LagUD.kr(Impulse.kr(tempo), 0.01, 2);
	var sig = env * Crackle.ar();
	Pan2.ar(sig * p.ar(\mod));
}
p.krak.stop

Routine{
	32.do{ |ind|
		p.krak[ind] = { |tempo=1, lev=1|
			var env = LagUD.kr(Impulse.kr(tempo), 0.01, 2);
			var sig = env * Crackle.ar();
			Pan2.ar(sig * p.ar(\mod), 2.0.rand - 1, lev);
		};
		(4.rand / 2).rand.wait
	}
}.play

p

p.krak.setRates(\tempo, 10)
p.krak.set(\tempo, 1)

p.krak.set(\tempo, 0.5)

p.krak.set(\lev, 0.5)


p.krak.clear
p.krak.play(\ar, 2)
p.krak.stop

p.krak.quant =  nil
p.mod.stop

p.mod = {
	SinOsc.ar(
		[60, 63],
		Lag2.ar(p.ar(\krak), 0.027) * 10
	)
}

// ****** whistle

~whis = Buffer.read(s, "~/Music/Edits/khrush/khr-lowest-hip.aif".standardizePath);

p.wh = { |start=0, trig=0|
	PlayBuf.ar(2, ~whis.bufnum, trigger:trig, startPos:start, loop:1)
}

p.wh.play

p.wh.set(\trig, 0);
p.wh.set(\start, ~whis.numFrames.rand); p.wh.set(\trig, 1);

Tdef(\skip, {
	loop{
		0.01.wait;
		p.wh.set(\trig, 0);
		0.05.rand.wait;
		p.wh.set(\start, ~whis.numFrames.rand);
		0.01.wait;
		p.wh.set(\trig, 1);
	}
})

Tdef(\skip).play
Tdef(\skip).stop


p.wh.play


p.stop
