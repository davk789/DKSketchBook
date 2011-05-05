/**
	simple sounds
 --- try changing sound routings quickly... I want to play with 
filters and constantly shuffling sound sources right now.
*/

s.options.device = ServerOptions.devices[0];

p = ProxySpace(s.boot);
p.push;

e = Environment();
e.know = true;

p.clock = TempoClock()


s.prepareForRecord
s.record
s.stopRecording


~sig = { WhiteNoise.ar() }
~sig = { PinkNoise.ar() }
~sig = { GrayNoise.ar() }

~del = { DelayN.ar(~sig.ar, 1, [0.1, 0.15], 0.2) }

~del.index
~del.stop


Tdef(\sw, {
	var sounds = [{ WhiteNoise.ar() }, { BrownNoise.ar() }, { GrayNoise.ar() }, { PinkNoise.ar() }];
	loop{
		~sig = sounds.choose;
		0.1.wait;
	}
})

Tdef(\sw).play
Tdef(\sw).stop

~sig.play
~sig.stop
