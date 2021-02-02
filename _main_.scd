// Mick Broer - Takken hebben takken hebben takken

~path = PathName(thisProcess.nowExecutingPath).parentPath;
~buffers = Array.new;

s.options.memSize = 65536;
s.waitForBoot{
	s.freeAll;
	s.newBusAllocators;
	Buffer.freeAll;

	s.sync;

	// Load dependencies
	PathName(~path ++ "src/").entries.collect{ |file| file.fullPath.load};
	PathName(~path ++ "audio/").entries.collect{ |file|
		~buffers = ~buffers.add(Buffer.readChannel(s, file.fullPath, channels:0).normalize(0.8, false))};

	// Allocate busses
	~playBus = Bus.audio(s);
	~verbBus = Bus.audio(s);
	~filterBus = Bus.audio(s);
	~grainBus = Bus.audio(s);
	~distortionBus = Bus.audio(s);

	s.sync;

	// Activate synths
	s.bind{
		~write = Synth(\write, [\in, ~distortionBus, \buf, ~buffers[1]]);
		~distortion = Synth(\distortion, [\in, ~filterBus, \dryness, 0.9, \out, ~distortionBus, \out2, 0]);
		~filter = Synth(\filters, [\fundamental, 20, \spec, 500, \rq, 0.5,
			\in, ~verbBus, \maxDelaytime, 1, \delScale, 0, \amp, 0.1, \out, ~filterBus, \dryness, 0.9]);
		~verb = Synth(\spatialization, [\in, ~grainBus, \fftsize, 4096, \buf, ~buffers[0], \predelay, 0.5,
			\dryness, 0.9, \amp, 0.5, \out, ~verbBus, \decaytime, 1, \maxDelaytime, 1]);
		~grains = Synth(\grains, [\in, ~playBus, \out, ~grainBus, \rate, 1,
			\buf, ~buffers[1], \dryness, 0.5, \freq, 400, \overlap, 0.01]);
		~read = Synth(\read, [\buf, ~buffers[1], \out, ~playBus, \amp, 1])};

	s.sync;

	Tdef(\manipulator, {
		loop{
			~distortion.set(\clip, rrand(0.5, 1), \gain, exprand(1, 5));
			~filter.set(\spec, exprand(20, 200), \rq, exprand(0.001, 1));
			~grains.set(\rate, rrand(-2, 2).round(0.5), \freq, exprand(50, 1000),
				\overlap, exprand(0.0001, 0.03));
			(~buffers[1].numFrames/s.sampleRate).wait}}).play
};