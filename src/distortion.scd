// Distortion synth

SynthDef(\distortion, {
	var dry, wet, sig;
	dry = In.ar(\in.ir(0));
	wet = Normalizer.ar(Clip.ar(dry * \gain.kr(1, 0.05), \clip.kr(1) * -1, \clip.kr), 0.5);
	sig = (((dry * \dryness.kr(0.5, 0.05))) + (wet * (1 - \dryness.kr))) * \amp.kr(0.8);
	Out.ar(\out.ir(0), sig);
	Out.ar(\out2.ir(0), Normalizer.ar(sig!2, 0.6, 0.02) * \outamp.kr(0.5))}).add;