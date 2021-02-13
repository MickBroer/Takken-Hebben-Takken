// Distortion synth

SynthDef(\distortion, {
	var dry, wet, sig;
	dry = Normalizer.ar(In.ar(\in.ir(0), 2), 0.6, 0.02);
	wet = Normalizer.ar(Clip.ar(dry * \gain.kr(1, 0.05), \clip.kr(1) * -1, \clip.kr), 0.5);
	sig = (((dry * \dryness.kr(0.5, 0.05))) + (wet * (1 - \dryness.kr))) * \amp.kr(0.8);
	Out.ar(\out.ir(0), Normalizer.ar(sig[0], 0.6, 0.02));
	Out.ar(\out2.ir(0), Normalizer.ar(sig, 0.6, 0.02) * \outamp.kr(0.5))}).add;