/**
	drone
*/

// ouput to soundflower for recording
// the index is 1 without edirol, 2 with
s.options.outDevice = ServerOptions.outDevices[2]; 

p = ProxySpace(s.boot);
p.know = true;
p.clock = TempoClock.default;

p.main.set(\vol, 0.075)

p.spawn = \phaz;
p.spawn.free
p.spawn.spawn([\vol, 0.01, \offset, rrand(0.2, 2.0), \pan, rrand(-1.0, 1.0)]);

45.do {
	p.spawn.spawn([\freq, [890, 100].choose, \vol, 0.03.rand, \offset, rrand(0.2, 2.0), \pan, rrand(-1.0, 1.0)]);	
}


SynthDef("phaz", {
	arg afreq=50, offset=0.9, vol=0.2, pan=0;
	var freq = afreq + offset;
	var sig = SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				freq * 3/5, // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						freq * 6/25,
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								freq * 64/15,
								SinOsc.ar(
									freq * 72/17,
									SinOsc.ar(
										freq * 102/17,
										0, 
										20
									),  
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
	Out.ar(0, Balance2.ar(sig[0], sig[1], pan));
}).load(s);

p.main.play
p.main.stop

p.main.setRates(\freq, 4);
p.main[0] = { arg freq=50, vol=0.2;
	SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				freq * 3/5, // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						freq * 6/25,
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								freq * 64/15,
								SinOsc.ar(
									freq * 72/17,
									0, 
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
}

p.main[1] = { arg afreq=50, vol=0.2;
	var freq = SinOsc.ar(LFNoise2.ar(3, 10), 0, 6, afreq);
	SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				DelayC.kr(freq * 3/5, 1, LFNoise2.kr(1, 0.2, 0.3)), // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						DelayC.kr(freq * 6/25, 1, LFNoise2.kr(1.01, 0.2, 0.3)), // freq
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								DelayC.kr(freq * 64/15, 1, SinOsc.kr(2, 0, 0.2, 0.5)), // freq
								SinOsc.ar(
									freq * 72/17,
									0, 
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
}

p.main[2] = { arg afreq=50, interval=0.5, vol=0.2;
	var freq = afreq * interval;
	SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				DelayC.kr(freq * 3/5, 1, LFNoise2.kr(1, 0.2, 0.3)), // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						DelayC.kr(freq * 6/25, 1, LFNoise2.kr(1.01, 0.2, 0.3)), // freq
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								DelayC.kr(freq * 64/15, 1, SinOsc.kr(2, 0, 0.2, 0.5)), // freq
								SinOsc.ar(
									freq * 72/17,
									0, 
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
}

p.main[3] = { arg afreq=50, interval=0.9, vol=0.2;
	var freq = afreq * interval;
	SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				DelayC.kr(freq * 3/5, 1, LFNoise2.kr(1, 0.2, 0.3)), // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						DelayC.kr(freq * 6/25, 1, LFNoise2.kr(1.01, 0.2, 0.3)), // freq
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								DelayC.kr(freq * 64/15, 1, SinOsc.kr(2, 0, 0.2, 0.5)), // freq
								SinOsc.ar(
									freq * 72/17,
									0, 
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
}


p.main[5] = { arg freq=150, vol=0.2;
	SinOsc.ar(
		[freq,freq * 13/14],  // freq
		SinOsc.ar( // phase
			freq * 3/5, // freq
			SinOsc.ar( // phase
				DelayC.kr(freq * 3/5, 1, LFNoise2.kr(1, 0.2, 0.3)), // freq
				SinOsc.ar( // phase
					freq * 2/5, // freq
					SinOsc.ar( // phase
						DelayC.kr(freq * 6/25, 1, LFNoise2.kr(1.01, 0.2, 0.3)), // freq
						SinOsc.ar(  // phase
							freq * 7/2,
							SinOsc.ar(
								DelayC.kr(freq * 64/15, 1, SinOsc.kr(2, 0, 0.2, 0.5)), // freq
								SinOsc.ar(
									freq * 72/17,
									0, 
									20
								),  
								8
							), 
							7
						),
						2
					);
					3 // mul
				),
				3  // mul
			),  
			28 // mul
		), 
		vol.dup // mul
	);
}

p.spawn.setRates(\afreq, 1)

Tdef(\syp, {
	var counter=70;
	loop{
		counter = counter + (12.collect{ [-0.1, -0.2].choose} ++ 2).choose;
		p.spawn.set(\afreq, counter);
		if(counter < 50){counter = 70};
		0.1.rand.wait;
	}
});

Tdef(\syp).play

Tdef(\swp, {
	loop{
		p.main.set(\afreq, [45, 50, 60].choose);
		4.rand.wait;
		p.main.set(\freq, [45, 50, 60].choose);
		9.rand.wait;
	}
});

Tdef(\swp).play

p.main.play;
p.main.stop;


