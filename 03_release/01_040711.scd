/**
	new sketch
*/


p = ProxySpace(s.boot);
p.push;
p.clock = TempoClock.default;

e = Environment(); // environment for buffers
e.know = true;

s.prepareForRecord
s.record
s.stopRecording

~sidtrig = { |freq=111|
	Pulse.ar(freq)
}

Tdef(\pulseq, {
	var seq, count;
	seq = [200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 200, 100, 100,50,150,100,100, 25, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20, 10, 10, 20, 10, 20, 10, 20];
	count = 0;
	loop{
		~sidtrig.set(\freq, seq[count]);
		~sid.set(\freq, seq[count]);

		((1/seq[count] * 10)).wait;
		count = (count + 1) % seq.lastIndex;
	}
})

Tdef(\pulseq).play

~sid = {Pan2.ar(
	SID6581f.ar(
		20, 255, 0, 0.3, ~sidtrig * 100, 3, 200,
		0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
		0, 104, 1, 79, 3))}


~sid = { |freq=100|
	Pan2.ar(
	SID6581f.ar(
		freq, SinOsc.kr(freq * 100, p.kr(\sid) * 10, LFNoise0.kr(5).abs*10, 10), 0, 0.3, ~sidtrig * 100, 3, 200,
		0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
		0, 104, 1, 79, 3), -1)}

~sid.play
~sid.stop

~sid2.play
~sid2.stop

~sid2 = { |freq=100|
	var sid, del;
	sid = 	SID6581f.ar(
		freq, SinOsc.kr(freq * 100, p.kr(\sid) * 10, LFNoise0.kr(5).abs*10, 10), 0, 0.3, ~sidtrig * 100, 3, 200,
		0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
		0, 104, 1, 79, 3);
	Pan2.ar(sid,1)
}


//--lowpass filtered
~sid = {|lev=0.2|
	Pan2.ar(
		SID6581f.ar(
			LFNoise0.kr(5).abs*10, LFNoise0.kr(5).abs*10, 0, 1, 65, 0, 240,
			0, 0, 0, 0, 0, 0, 0,
			5, 0, 0, 0, 16, 0, 0,
			0, SinOsc.kr(0, p.kr(\sid) * 10, LFNoise0.kr(5).abs*10, 10), 2r11110001, 2r10011111, 1))* lev;
}

~sid.set(\lev, 0.2)

~sid.play
~sid.stop