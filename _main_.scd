// Mick Broer - Takken hebben takken hebben takken

ServerTree.removeAll;
~path = PathName(thisProcess.nowExecutingPath).parentPath;
~buffers = Array.new;

s.options.memSize = 2.pow(15);
s.waitForBoot{
	s.freeAll;
	s.newBusAllocators;
	Buffer.freeAll;

	s.sync;

	// Load dependencies
	PathName(~path ++ "src/").entries.collect{ |file| file.fullPath.load};
	PathName(~path ++ "audio/").entries.collect{ |file|
		~buffers = ~buffers.add(Buffer.readChannel(s, file.fullPath, channels:0).normalize(0.8, false))};

	// Allocate busses and groups
	~playBus = Bus.audio(s);
	~verbBus = Bus.audio(s, 2);
	~filterBus = Bus.audio(s, 2);
	~grainBus = Bus.audio(s, 2);
	~distortionBus = Bus.audio(s);
	~sourceGroup = Group.new;
	~fxGroup = Group.after(~sourceGroup);
	~writeGroup = Group.after(~fxGroup);

	s.sync;

	// Activate synths
		~write = Synth(\write, [\in, ~distortionBus, \buf, ~buffers[0]], ~writeGroup);
		~distortion = Synth(\distortion, [\in, ~filterBus, \dryness, 0.9,
			\out, ~distortionBus, \out2, 0, \outamp, 1], ~fxGroup);
		~filter = Synth(\filters, [\in, ~verbBus, \maxDelaytime, 1,
			\amp, 0.1, \out, ~filterBus, \dryness, 0.9], ~fxGroup);
		~verb = Synth(\spatialization, [\in, ~grainBus, \fftsize, 4096, \buf, ~buffers[0], \predelay, 0.5,
			\dryness, 0.5, \amp, 0.5, \out, ~verbBus, \decaytime, 1, \maxDelaytime, 1], ~fxGroup);
		~grains = Synth(\grains, [\in, ~playBus, \out, ~grainBus,
			\buf, ~buffers[0], \dryness, 0], ~fxGroup);
		~read = Synth(\read, [\buf, ~buffers[0], \out, ~playBus, \amp, 1], ~sourceGroup);

	s.sync;

	// Making the different rooms breathe
	Tdef(\manipulator, {
		loop{
			~distortion.set(\clip, rrand(0.5, 1), \gain, exprand(1, 5));
			~filter.set(\fundamental, exprand(20, 500),
				\spec, exprand(20, 500), \rq, exprand(0.001, 1), \delScale, rrand(0,0.1));
			~grains.set(\rate, rrand(-2, 2).round(0.5), \freq, exprand(50, 1000),
				\overlap, exprand(0.0001, 0.03));
			(~buffers[0].numFrames/s.sampleRate).wait}}).play};