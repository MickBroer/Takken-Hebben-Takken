
SynthDef(\reverb, {
	arg feedback, in=8, size=1, dryness=1;
	var sig, local, dry;
	dry = Normalizer.ar(In.ar(in, 2), 0.6, 0.02);
	local = LocalIn.ar(2) + dry;
	dry = dry * dryness;
	10.do{local = AllpassC.ar(local, 1, [Rand(0.0,0.5), Rand(0.0,0.5)], 1)};
	LocalOut.ar(LPF.ar(local, \damp.kr(200)) * feedback);
	local = local * (1 - dryness);
	sig = (dry + local) * \amp.kr(0.2);
	Out.ar(\out.ir(0), sig)}).add;