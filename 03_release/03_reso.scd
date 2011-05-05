/**
	play with resonators
*/


s.options.device = ServerOptions.devices[0];

p = ProxySpace(s.boot);
p.push;
p.clock = TempoClock();

e = Environment();
e.know = true;


s.prepareForRecord
s.record
s.stopRecording

// ---- reverb

~verb = {
	GVerb.ar(~sig.ar)
}

~verb.play

~sig = { SinOsc.ar(60, 0, 0.2) }
~pulse = { |pfreq=1|LFPulse.ar(pfreq, 0, 0.2, 1)}
~sig = {   SinOsc.ar(50, ~pulse, 0.2) * ~pulse }
~pulse.set(\pfreq, 0.5)

// ------------------ klank

~ex = { |freq=100, width=0.5, lev=0.2| LFPulse.ar(freq, 0, width, lev) };
~ex.set(\freq, 30, \lev, 0.1)
~ex.setRates(\freq, 0.1);
~ex.set(\freq, 50);

Tdef(\wakka, {
	// stupid use of stutter
	var freqs = Pstutter(Pseq([1,2,3,2,2,1,2,3,4,2,1], inf), Pseq([50,100,50,40,50,50,100,200],inf)).asStream;
	loop{
		~ex.set(\freq, freqs.next);
	0.5.wait;
	}
})

Tdef(\wakka).play
Tdef(\wakka).stop


~klank.set(	\f0, 50, \f1,90, \f3,140, \f4,180,
      	    \a0,0.1,  \a1,0.1, \a3,0.1, \a4,0.1,
	        \t0,0.1,    \t1,0.1,   \t3,1,   \t4,1)

~klank.set(\pan, -0.2); ~klank2.set(\pan, 0.2);

~klank = { |pan=0.5,
	f0=100, f1=200, f3=400, f4=800,
	a0=0.1, a1=0.1, a3=0.1, a4=0.1,
	t0=1, t1=1, t3=1, t4=1|
	var sig;
	sig = DynKlank.ar(
		`[
			[f0, f1, f3, f4], // freqs
			[a0, a1, a3, a4], // amps
			[t0, t1, t3, t4]  // times
		],
		~ex.ar
	);
	Pan2.ar(sig, pan);
};



~klank.play

~klank.stop; ~klank2.stop



~klank2.set(	\f0, 60, \f1,110, \f3,170, \f4,220,
      	    \a0,0.1,  \a1,0.1, \a3,0.1, \a4,0.1,
	        \t0,0.1,    \t1,0.1,   \t3,1,   \t4,1)

~klank2 = { |pan=(-0.5),
	f0=100, f1=200, f3=400, f4=800,
	a0=0.1, a1=0.1, a3=0.1, a4=0.1,
	t0=1, t1=1, t3=1, t4=1|
	var sig;
	sig = DynKlank.ar(
		`[
			[f0, f1, f3, f4], // freqs
			[a0, a1, a3, a4], // amps
			[t0, t1, t3, t4]  // times
		],
		~ex.ar
	);
	Pan2.ar(sig, pan);
};

~klank2.play
