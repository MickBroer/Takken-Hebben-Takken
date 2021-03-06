// Record / playback synths

SynthDef(\read, {
	var sig;
	sig = PlayBuf.ar(1, \buf.kr(0), 1, loop:1);
	Out.ar(\out.ir(0), sig!2 * \amp.kr(0.7))}).add;

SynthDef(\write, {
	var sig;
	sig = In.ar(\in.ir(0));
	BufWr.ar(sig, \buf.kr(0),
		Phasor.ar(0, BufRateScale.kr(\buf.kr), 0,
			BufFrames.kr(\buf.kr)))}).add;