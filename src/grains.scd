// Granular synth

SynthDef(\grains, {
	var dry, wet, sig;
	dry = In.ar(\in.ir(0));
	wet = LeakDC.ar(GrainBuf.ar(1, Impulse.ar(\freq.kr(50)), \overlap.kr(0.001), \buf.ir(0), \rate.kr(1),
		Phasor.ar(0, BufRateScale.kr(\buf.ir), 0, BufFrames.kr(\buf.ir))));
	sig = ((dry * \dryness.kr(0.5)) + (wet * (1 - \dryness.kr))) * \amp.kr(1);
	Out.ar(\out.ir(0), sig)}).add;