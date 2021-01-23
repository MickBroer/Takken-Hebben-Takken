// Record / playback synths

SynthDef(\read, {
	var sig;
	sig = PlayBuf.ar(1, \buf.kr(0), 1, loop:1);
	Out.ar(\out.kr(0), sig * \fb.kr(0.7))}).add;

SynthDef(\write, {
	var sig;
	sig = In.ar(\in.kr(9));
	BufWr.ar(sig, \buf.kr(0),
	Phasor.ar(0, BufRateScale.kr(\buf.kr), 0, BufFrames.kr(\buf.kr)))}).add;