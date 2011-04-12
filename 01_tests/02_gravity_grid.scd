/**
	playing with the gravity grid, starting to use buffers
*/


p = ProxySpace.new(s.boot);
p.push;

s.prepareForRecord
s.record
s.stopRecording

~gg.rebuild
~gg = \lcGravityGrid;
~gg.setRates(\reset, \tr);

~gg.set(\reset, 0)
~gg.play;
~gg.free;
~gg.spawn;

~mx = { MouseX.kr(1,10)}
~gg.map(\rate, ~mx)
~gg.set(\newy, 0.1, \newx, -0.1)
~gg.set(\newx, rrand(-0.8,0.8), \newy, rrand(-0.8,0.8), \rate, rrand(1,10))
~gg.set(\newx, rrand(-0.8,0.8), \newy, rrand(-0.8,0.8), \reset, 1)

~gg.group.set(\reset, 1)
~gg.set(\reset, 0)
~gg.set(\newx, rrand(-0.8,0.8), \newy, rrand(-0.8,0.8));
~gg.set(\rrate, 0); // just pause the pulser ... not cool
~gg.set(\rrate, 1); // just pause the pulser ... not cool

~gg.free

SynthDef("lcGravityGrid",
	{ |rrate=1, rate=1, newx=0.6, newy=(-0.5), outBus=0, reset=0|
		//var sig = GravityGrid.ar(Impulse.kr(rrate), rate, newx, newy); // not using a buffer
		var sig = GravityGrid.ar(reset, rate, newx, newy); // not using a buffer
		Out.ar(outBus, Pan2.ar(sig));
	}
).load(s)

~ggS.play
~ggS.stop

~ggS = {
	Pan2.ar(
		0.05*GravityGrid.ar(
			Impulse.kr(2),
			MouseX.kr(0.1,10,'exponential'),
			LFNoise0.kr(2,0.8),
			LFNoise0.kr(2,0.8)
		),
		0.0
	)
}


/*

LFNoise0
	
(reset, rate, newx, newy, bufnum, mul, add)


*/