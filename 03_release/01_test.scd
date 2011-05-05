/**
	playing with VOsc -- phase modulation matrix
*/

s.options.device = ServerOptions.devices[0]

p = ProxySpace(s.boot);
p.push;

e = Environment();
e.know = true;

s.prepareForRecord
s.record
s.stopRecording

e.buf = Buffer.allocConsecutive(16, s, 2048, 1);

e.sigs = Array.fill(16, { |ind|
	postln("raising to the " ++ ((ind * 2) + 1) ++ " power");
	Signal.fill(1024, { |i|
		var ret;
		var val = (i / 1024) * 2pi;
		ret = sin(val).pow((ind * 2) + 1);
		ret;
	}).asWavetableNoWrap
});

e.buf.do{|b,i|
	b.loadCollection(e.sigs[i]);
};

~osc = { |freq=440, lev=0.2, lagu=0.1, lagd=0.5, fbmod=75, tab=1|
	var sig, fb, table;
	fb = LagUD.ar(p.ar(\osc), lagu, lagd) * fbmod;
	//	table = (tab * e.buf.lastIndex) + e.buf[0].bufnum; // modulatable
	sig = VOsc.ar(tab, freq, fb, lev);
	Pan2.ar(sig);
};

~osc = { |freq=440, lev=0.2, lagu=0.1, lagd=0.5, fbmod=75, tab=1|
	var sig, fb, table;
	fb = LagUD.ar(p.ar(\osc), lagu, lagd) * fbmod;
	//	table = (tab * e.buf.lastIndex) + e.buf[0].bufnum; // modulatable
	sig = VOsc.ar(tab, DelayC.ar(p.ar(\osc), 1, 0.2, freq *4)+ 0.01 , fb + 1, lev);
	Pan2.ar(sig);
};
~osc.setRates(\tab, 100)
~osc.set(\lagu, 0.01, \lagd, 0.005, \freq, 100, \tab, 14)
~osc.set(\freq, 100, \fbmod, 0, \tab, e.buf.last.bufnum)
~osc.set(\freq, 100, \fbmod, 10, \lagu, 0.005, \lagd, 0.0002 )
~osc.set(\lagu, 0.05, \lagd, 0.02 )
~osc.set(\freq, 50)
~osc.play
~osc.stop



e.test.reset
e.test.stop
e.test.play
e.test = Routine{
	e.buf.do{ |buf,ind|
		~osc.set(\tab, buf.bufnum.min(e.buf.last.bufnum - 0.1));
		1.wait
	}
}

~osc.setRates(\tab, 15)
~osc.set(\tab, 6)
~osc.stop

Tdef(\tabsweep, {
	var val;
	val = Pseq(Array.series(2,1,1).mirror1, inf).asStream;
	loop{
		~osc.set(\tab, val.value);
		0.1.wait;
	}
});

~osc.setRates(\tab, 0.05);


Tdef(\tabsweep).play
Tdef(\tabsweep).stop

~osc.play
~osc.stop
~osc.clear

~osc.send(nil, 1)
~osc.free

~test = { SinOsc.ar([100, 101], 0, 0.2) }
~test.stop

{ 	VOsc.ar(1, 200, 0); }.plot
