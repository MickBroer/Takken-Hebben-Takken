
SynthDef(\pitchshifter, {
	var sig, psArray;
	sig = In.ar(\in.ir(0), 2);
	//sig = SoundIn.ar;
	psArray = Array.fill(10, {DelayC.ar(sig, 0.2, Phasor.ar(0, 20, Rand(0, 0.2, Rand(0, 0.2))), Rand(0.0, 1))});
	//sig = sig + DelayC.ar(sig, 0.2, Phasor.ar(0, 20, \min.kr(0, 0.05), \max.kr(0.2, 0.05)));
	//sig = FreeVerb.ar(psArray.sum * \amp.kr(0.2));
	sig = sig.blend(psArray.sum, \wet.kr(0.5));
	sig = sig * \amp.kr(0.2);
	Out.ar(\out.ir(0), sig)}).add;

//Synth(\pitchshifter, [\wet, 1]);