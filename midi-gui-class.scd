// WORKING EXAMPLE

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd_1 = Platform.userHomeDir ++ "/samples" +/+ "train-noise-5sec.wav";
~sample_pwd_2 = Platform.userHomeDir ++ "/samples" +/+ "t-square-wave-1sec.wav";
~sample_pwd_3 = Platform.userHomeDir ++ "/samples" +/+ "squeak-5sec-48000.wav"
~buffers = [ Buffer.read(s, ~sample_pwd_1),	Buffer.read(s, ~sample_pwd_2), Buffer.read(s, ~sample_pwd_3) ];
~buffers[0].numFrames
~buffers[0].path

~buffers

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
q = Bus.control(s, 1);
b.index;
c.index;
q.index;

Help.gui;

(
SynthDef(\snd, { arg out, bufnum=0, numframes=1, imp=0, rate=1, startPos=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, updateRate=10, amt=5;
	var env, pitchedEnv, signal, phasor, sampledur;
	sampledur = numframes / 48000;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, sampledur - 0.10, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, (sampledur*t1)-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	phasor = Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * amt * pitchedEnv, 0, BufFrames.kr(bufnum));
	signal = BufRd.ar(1, bufnum, phasor, loop: lp) * env;
	SendReply.kr(Impulse.kr(updateRate), "/bufPos", [phasor, signal]);
	// signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), trig);
	Out.kr(\ctrlbus.index, A2K.kr(phasor));
    Out.ar(out, Pan2.ar(signal))
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 0;
	//var signal, fm;
	//fm = SinOsc.ar(modFreq,0,SinOsc.ar(modFreq/16,0,modFreq));
	Out.ar(outBus,
		[    // In.ar ugen reads from an audio bus
            In.ar(inBus, 1) * SinOsc.ar(modFreq),//,0,SinOsc.ar(modFreq/16,0,modFreq)),
            In.ar(inBus, 1) * SinOsc.ar(modFreq-0.02)//,0,SinOsc.ar((modFreq-0.02)/16,0,modFreq-0.02))
        ]
	)
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5, f1=0.5, l1=0.001, freq=0.0;
    Out.ar(
        outBus,
        Limiter.ar(PitchShift.ar(Lag.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq).fold(f1.neg,f1), l1), pitchRatio: freq), 0.95)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffers[0], \ctrlbus, q, \numframes, ~buffers[0].numFrames]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b], target: ~mod, addAction: \addAfter);


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "amt", "fold", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffers);

~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;