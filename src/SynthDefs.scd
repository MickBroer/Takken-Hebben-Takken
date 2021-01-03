// SynthDefs
// Takken Hebben Takken Hebben Takken

// Delay / Reverb SynthDef
SynthDef(\spatialization, {
	var sig, local, dry;
	dry = In.ar(\in.kr(0));
	sig = CombL.ar(dry,
		maxdelaytime: \maxDelaytime.ir(0.5),
		delaytime: \predelay.kr(0.05),
		decaytime: \decaytime.kr(0));
	sig = PartConv.ar(sig, \fftsize.ir(1024), \buf.kr(0));
	sig = (dry * \dryness.kr(0.5)) + (sig * (1-\dryness.kr)) * \amp.kr(1);
	Out.ar(\out.kr(8), sig)}).add;

// Resonator SynthDef
SynthDef(\filters, {
	var array, sig, in;
	in = In.ar(\in.kr(0));
	array = Array.fill(10, {
		|i|
		var band = Resonz.ar(in, \fundamental.kr(100) +
			(i * \spec.kr(20,0.1) + SinOsc.kr(0.25 / i).range(0, 500)),
			\rq.kr(1), \rq.kr.reciprocal);
		CombC.ar(band, \maxDelaytime.ir(0.2), (0 + i * \delScale.kr(0)))});
	sig = Mix.ar((in * \dryness.kr(0.5))
		+ (Mix.ar([array, LPF.ar(in, \fundamental.kr)]) * (1 - \dryness.kr)) * \amp.kr(0.5));
	Out.ar(\out.kr(0), sig);
	Out.ar(\out2.kr(0), Normalizer.ar(sig!2, 0.6, 0.02))}).add;

// SynthDefs for recording and playing back
SynthDef(\read, {
	var sig;
	sig = PlayBuf.ar(1, \buf.kr(0), 1, loop:1);
	Out.ar(\out.kr(0), sig * \fb.kr(0.7))}).add;

SynthDef(\write, {
	var sig;
	sig = In.ar(\in.kr(9));
	BufWr.ar(sig, \buf.kr(0),
	Phasor.ar(0, BufRateScale.kr(\buf.kr), 0, BufFrames.kr(\buf.kr)))}).add;