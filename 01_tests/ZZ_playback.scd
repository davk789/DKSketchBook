/**
	testing recording and playing back samples
*/

~buf = Buffer.alloc(s, 44100 * 1.0, 1)

~buf.plot
/*

RecordBuf.ar(inputArray, bufnum, offset, recLevel, preLevel, run, loop, trigger, doneAction)

*/
s.boot

~rec = {
	RecordBuf.ar(SoundIn.ar(1), ~buf.bufnum, 0, 1, 0, 1, 0, 1, 2);
}

~play = {
	PlayBuf.ar(~buf.numChannels, ~buf.bufnum, 1);
}
~play.play
~play.stop
~buf.plot
~rec.play
~rec.stop



// Execute the following in order
(
// allocate a Buffer
s = Server.local;
b = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
)

// record for four seconds
(
SynthDef(\help_RecordBuf, { arg out = 0, bufnum = 0;
var formant;
formant = Formant.ar(XLine.kr(400,1000, 4), 2000, 800, 0.125);
RecordBuf.ar(formant, bufnum, doneAction: 2, loop: 0);
}).play(s,[\out, 0, \bufnum, b]);
)

// play it back
(
SynthDef(\help_RecordBuf_overdub, { arg out = 0, bufnum = 0;
var playbuf;
playbuf = PlayBuf.ar(1,bufnum);
FreeSelfWhenDone.kr(playbuf); // frees the synth when the PlayBuf is finished
Out.ar(out, playbuf);
}).play(s, [\out, 0, \bufnum, b]);
)

// overdub
(
SynthDef(\help_RecordBuf_overdub, { arg out=0, bufnum=0;
var formant;
formant = Formant.ar(XLine.kr(200, 1000, 4), 2000, 800, 0.125);
// mixes equally with existing data
RecordBuf.ar(formant, bufnum, 0, 0.5, 0.5, doneAction: 2, loop: 0); 
}).play(s, [\out, 0, \bufnum, b]);
)
b.plot
// play back the overdubbed version
Synth.new(\help_RecordBuf_overdub, [\out, 0, \bufnum, b], s);

// write the contents of the buffer to a file (see Buffer for more options)
(
b.write(sampleFormat: 'int16');
thisProcess.platform.recordingsDir +/+ "SC_" ++ Date.localtime.stamp ++ ".aiff"; // generated
//path
)

b.close; b.free; // cleanup


