s.options.sampleRate = 48000;
s.options.memSize = 2**18;
s.boot;

~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "startPos", "eee", "ffff", "cutoff", "rq"];

MIDIClient.init;
MIDIClient.sources.at(1)


~bus = Bus.audio(s, 2);
~bus.index;
~bus.numChannels.postln;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec.wav";
~buffer = Buffer.read(s, ~sample_pwd);

SynthDef(\sampling, { arg out, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1, cutoff=10000, rq=0.6;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = RLPF.ar(signal * env, cutoff, rq);
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}, metadata: (
	specs: (
		out: 0,
	)
)).add;

~synth = Synth(\sampling, [\bufnum, ~buffer]);

MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~synth, ~buffer);
