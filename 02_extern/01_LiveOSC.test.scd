/**
	connecting SuperCollider to Ableton Live using LiveOSC 
	http://liine.net/livecontrol/ableton-liveapi/liveosc/
	.. Lots of control over clips and mixes here, not so much control over
	musical events. Seems like the potential usefulness of scripting here is
	limited. So, this document will take a look at:
	
	... midi also.

	LiveOSC accepts packets on port 9000 and sends data on port 9001
*/

1/5!5 * 4

~live = NetAddr("127.0.0.1", 9000);

~live.sendMsg("/live/tempo", 120); /// this works

/// there are a host of other calls that can be made including calls to control
// track volume. clip cueing and playing, etc.

//// MIDI stuff
s.boot;
MIDIClient.init
MIDIClient.destinations

~mid = MIDIOut(0)


~mid.noteOn(0,42,100);
~mid.noteOff(0,42,0);

TempoClock.default.schedAbs(TempoClock.default.beats.ceil + 4,
	~live.sendMsg("/live/play");
	nil;
);

t = Routine({
	var notes = [36, 38, 40];//Array.fill(12, { |ind| ind + 32 });
	~live.sendMsg("/live/play");
	loop{
		fork{
			~mid.noteOn(0,42,100);
			fork{ 0.2.wait; ~mid.noteOff(0,42,0); }
			0.5.wait;
			~mid.noteOn(0,42,100);
			fork{ 0.2.wait; ~mid.noteOff(0,42,0); }
			0.5.wait
		};
		if(0.9.coin){
			~pl.value(notes);
			1.wait;
		}{
			~pl.value(notes);
			0.5.wait;
			~pl.value(notes);
			0.5.wait;			
		}
	}
})

~pl = { |notes|
	var note = notes.choose;
	~mid.noteOn(0,note, 100);
	fork{
		0.1.wait;
		~mid.noteOff(0,note, 100);
	};
}

~live.sendMsg("/live/stop");

TempoClock.default.tempo= 2
t.play
t.reset
t.stop