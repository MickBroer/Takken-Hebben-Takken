// Mick Broer

// Load dependencies
s.waitForBoot{

	~path = PathName.new(thisProcess.nowExecutingPath).parentPath;
	~synthdefs = ~path ++ "src/SynthDefs.scd";
	~synthdefs.load;

	~verbBus = Bus.audio(s);
	~playBus = Bus.audio(s);
	~filterBus = Bus.audio(s);

// Set up buffers and busses
	~srcbuf = Buffer.readChannel(s, ~path ++ "audio/fieldrecording.aif", channels: 0);
	~buf = Buffer.readChannel(s, ~path ++ "audio/plucks.wav", channels:0).normalize(0.8, false);

	s.sync;

	~write = Synth(\write, [\in, ~filterBus, \buf, ~buf]);
	~filter = Synth(\filters, [\fundamental, 100, \spec, 200, \rq, 0.5,
		\in, ~verbBus, \maxDelaytime, 1, \delScale, 0, \amp, 0.1, \out, ~filterBus, \dryness, 0.9]);
	~verb = Synth(\spatialization, [\in, ~playBus, \fftsize, 4096, \buf, ~srcbuf, \predelay, 0.5,
		\dryness, 0.6, \amp, 0.5, \out, ~verbBus, \decaytime, 1]);
	~read = Synth(\read, [\buf, ~buf, \out, ~playBus, \out2, 0, \fb, 1.4]);
}