// Mick Broer - Takken hebben takken hebben takken

s.options.memSize = 65536;
s.waitForBoot{
	s.freeAll;
	s.newBusAllocators;
	Buffer.freeAll;
	s.sync;

	// Load dependencies
	~path = PathName.new(thisProcess.nowExecutingPath).parentPath;
	(~path ++ "src/distortion.scd").load;
	(~path ++ "src/filters.scd").load;
	(~path ++ "src/grains.scd").load;
	(~path ++ "src/readwrite.scd").load;
	(~path ++ "src/spatialization.scd").load;

	// Set up busses and buffers
	~playBus = Bus.audio(s);
	~verbBus = Bus.audio(s);
	~filterBus = Bus.audio(s);
	~grainBus = Bus.audio(s);
	~distortionBus = Bus.audio(s);
	~srcbuf = Buffer.readChannel(s, ~path ++ "audio/fieldrecording.aif", channels:0).normalize(0.8, false);
	~buf = Buffer.readChannel(s, ~path ++ "audio/noisedrone.aif", channels:0).normalize(0.8, false);

	s.sync;

	// Activate synths
	s.bind{
		~write = Synth(\write, [\in, ~distortionBus, \buf, ~buf]);
		~distortion = Synth(\distortion, [\in, ~filterBus, \dryness, 0.9, \out, ~distortionBus, \out2, 0]);
		~filter = Synth(\filters, [\fundamental, 20, \spec, 500, \rq, 0.5,
			\in, ~verbBus, \maxDelaytime, 1, \delScale, 0, \amp, 0.1, \out, ~filterBus, \dryness, 0.9]);
		~verb = Synth(\spatialization, [\in, ~grainBus, \fftsize, 4096, \buf, ~srcbuf, \predelay, 0.5,
			\dryness, 0.9, \amp, 0.5, \out, ~verbBus, \decaytime, 1, \maxDelaytime, 1]);
		~grains = Synth(\grains, [\in, ~playBus, \out, ~grainBus, \rate, 1,
			\buf, ~buf, \dryness, 0.5, \freq, 400, \overlap, 0.01]);
		~read = Synth(\read, [\buf, ~buf, \out, ~playBus, \fb, 1])};

		s.sync;

		Tdef(\manipulator, {
			loop{
				"loop".postln;
				~distortion.set(\clip, rrand(0.5, 1), \gain, exprand(1, 5));
				~filter.set(\spec, exprand(20, 200), \rq, exprand(0.001, 1));
				~grains.set(\rate, rrand(-2, 2).round(0.5), \freq, exprand(50, 1000),
					\overlap, exprand(0.0001, 0.03));
				(~buf.numFrames/s.sampleRate).wait}}).play
};