// Granular synth

SynthDef(\grains, {
	var dry, wet, sig;
	dry = In.ar(\in.ir(0));
	wet = GrainBuf.ar(1, TChoose.kr(\trig.tr(1), [Impulse.ar(\freq.kr(50)), Dust.ar(\freq.kr)]),
		\overlap.kr(0.001), \buf.ir(0), \rate.kr(1),
		Phasor.ar(0, BufRateScale.kr(\buf.ir), 0, BufFrames.kr(\buf.ir)));
	wet = LeakDC.ar(wet);
	sig = Pan2.ar(((dry * \dryness.kr(0.5)) + (wet * (1 - \dryness.kr))) * \amp.kr(1),
		LFNoise1.kr(LFNoise1.kr(0.2).range(0, 1)).range(-1, 1));
	Out.ar(\out.ir(0), sig)}).add;