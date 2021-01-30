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
	(~path ++ "src/readwrite.scd").load;
	(~path ++ "src/spatialization.scd").load;

	// Set up busses and buffers
	~playBus = Bus.audio(s);
	~verbBus = Bus.audio(s);
	~filterBus = Bus.audio(s);
	~distortionBus = Bus.audio(s);
	~srcbuf = Buffer.readChannel(s, ~path ++ "audio/fieldrecording.aif", channels:0).normalize(0.8, false);
	~buf = Buffer.readChannel(s, ~path ++ "audio/noisedrone.aif", channels:0).normalize(0.8, false);

	s.sync;

	// Activate synths
	s.bind{
		~write = Synth(\write, [\in, ~distortionBus, \buf, ~buf]);
		~distortion = Synth(\distortion, [\in, ~filterBus, \gain, 3, \wetness, 0.5, \out, ~distortionBus, \out2, 0]);
		~filter = Synth(\filters, [\fundamental, 20, \spec, 500, \rq, 0.5,
			\in, ~verbBus, \maxDelaytime, 1, \delScale, 0, \amp, 0.1, \out, ~filterBus, \dryness, 0.9]);
		~verb = Synth(\spatialization, [\in, ~playBus, \fftsize, 4096, \buf, ~srcbuf, \predelay, 0.5,
			\dryness, 0, \amp, 0.5, \out, ~verbBus, \decaytime, 1]);
		~read = Synth(\read, [\buf, ~buf, \out, ~playBus, \fb, 1])};
};