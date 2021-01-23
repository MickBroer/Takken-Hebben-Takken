// Resonator synth

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