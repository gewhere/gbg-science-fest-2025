s.options.sampleRate = 48000;
s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2;
s.plotTree;

Help.gui;


////

(
w = Window.new('spectrogram'.asString.scramble, Rect(0,1000, 600, 300)).front;
a = Spectrogram.new(w, w.view.bounds.insetAll(30, 10, 42, 10), background:Color(0.2, 0.25, 0.2), color:Color.green, lowfreq:20, highfreq:10000);
a.start;
)

////


(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var b = Buffer.read(s, p);
var f, sf, window, knob, knobRate, knobImpulse, button, size = 32;
//var bufferLength = b.numFrames;
var x = SynthDef(\help_Buffer, { arg out = 0, rate=1, imp=1, startPos=0, bufnum, rst=0, lp=1;
	var env, signal, impulse;
	impulse = Impulse.kr(imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(impulse, BufRateScale.kr(bufnum) * rate, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.35, 0.15], curve: [-5, 0, -5]), impulse) * signal;
    Out.ar(out, env)
}).play(s,[\bufnum, b]);
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
window.onClose_{ x.free; b.free; };
knob = Knob.new(window, Rect(10,160,size,size));
knob.action_{ |v| postf("value: %\n", v.value); x.set(\startPos, v.value * b.numFrames); };
knobRate = Knob.new(window, Rect(60,160,size,size));
knobRate.action_{ |v| postf("value: %\n", v.value); x.set(\rate, (2 * v.value) - 1); };
knobImpulse = Knob.new(window, Rect(110,160,size,size));
knobImpulse.action_{ |v| postf("value: %\n", v.value); x.set(\imp, 10 * v.value); };
button = Button.new(window, Rect(320,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
button.action_{ |v| v.value.postln;
		x.set(\rst, v.value);
};
sf = SoundFileView.new(window, Rect(20,20,360,100));
f = SoundFile.new;
f.openRead(p);
sf.soundfile = f;
sf.read(0, f.numFrames);
)
