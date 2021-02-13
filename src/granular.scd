SynthDef(\grain, {
	arg rate=1, modFreq=0, modAmp=5, amp = 1;
	var sig, ptr;
	ptr = (Phasor.ar(0, BufRateScale.kr(\buf.kr(0)), 0, BufFrames.ir(\buf.kr))
		+ \delay.kr(132300)) / BufFrames.ir(\buf.kr);
	sig = GrainBuf.ar(
		1, //numChannels
		Dust.ar(\freq.kr(20)!2), //trigger
		LFNoise1.kr(0.15).exprange(0.1, 3),
		\buf.kr, //soundfile
		rate, ptr);
	sig = Normalizer.ar(sig, 0.6, 0.02) * amp;
	Out.ar(\out.ir(0),sig)}).add;