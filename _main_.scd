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
	~verbBus = Bus.audio(s, 2);
	~filterBus = Bus.audio(s, 2);
	~playBus = Bus.audio(s, 2);
	~grainBus = Bus.audio(s, 2);
	~psBus = Bus.audio(s, 2);
	~distortionBus = Bus.audio(s);
	~sourceGroup = Group.new;
	~fxGroup = Group.after(~sourceGroup);
	~writeGroup = Group.after(~fxGroup);

	s.sync;

	// Activate synths
	~write = Synth(\write, [\in, ~distortionBus, \buf, ~buffers[0]], ~writeGroup);
	~distortion = Synth(\distortion, [\in, ~verbBus, \dryness, 0.8,
		\out, ~distortionBus, \out2, 0, \outamp, 1], ~fxGroup);
	~filter = Synth(\filters, [\in, ~verbBus, \maxDelaytime, 1,
		\amp, 1, \out, ~filterBus, \dryness, 0.7], ~fxGroup);
	~verb = Synth(\reverb, [\in, ~psBus, \out, ~verbBus, \feedback, 0.99,
	    \damp, 100, \dryness, 0], ~fxGroup);
	~ps = Synth(\pitchshifter, [\in, ~grainBus, \out, ~psBus], ~fxGroup);
	~grains = Synth(\grain, [\out, ~grainBus, \amp, 1.5, \in, ~playBus,
	    \buf, ~buffers[0]], ~fxGroup);
	~read = Synth(\read, [\buf, ~buffers[0], \out, ~playBus], ~sourceGroup);

	s.sync;

	// Making the different rooms breathe
	Tdef(\manipulator, {
		loop{
			~distortion.set(\clip, rrand(0.5, 1), \gain, exprand(1, 10));
			~filter.set(\fundamental, exprand(20, 500), \dryness, rrand(0,1),
				\spec, exprand(20, 500), \rq, exprand(0.001, 1), \delScale, rrand(0,0.1));
			~ps.set(\wet, rrand(0, 1));
			~grains.set(\rate, rrand(0.5, 2) * [-1, 1].choose, \freq, rrand(15, 40), \wet, rrand(0,1));
			(~buffers[0].numFrames/s.sampleRate).wait}}).play};