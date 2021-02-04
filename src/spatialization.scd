// Delay / convolution reverb synth

SynthDef(\spatialization, {
	var sig, local, dry;
	dry = In.ar(\in.ir(0), 2);
	sig = CombL.ar(dry, \maxDelaytime.ir(0.5), \predelay.kr(0.05), \decaytime.kr(0));
	sig = PartConv.ar(sig, \fftsize.ir(1024), \buf.kr(0));
	sig = (dry * \dryness.kr(0.5)) + (sig * (1-\dryness.kr)) * \amp.kr(1);
	Out.ar(\out.ir(0), sig)}).add;