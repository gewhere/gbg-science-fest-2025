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



/// PITCHED ENVELOPE SAMPLING

(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var b = Buffer.read(s, p);
var f, sf, window, knob, knobRate, knobImpulse, button, size = 32;
var knobL0, knobL1, knobL2, knobT1;
//var bufferLength = b.numFrames;
var x = SynthDef(\help_Buffer, { arg out = 0, rate=1, imp=1, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9;
	var env, pitchedEnv, signal, impulse;
	impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.35, 0.15], curve: [-5, 0, -5]), impulse);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), impulse);
	signal = BufRd.ar(1, bufnum, Phasor.ar(impulse, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
    Out.ar(out, signal)
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
knobL1 = Knob.new(window, Rect(10,120,size,size));
knobL1.action_{ |v| postf("value: %\n", v.value); x.set(\l1, v.value); };
knobL2 = Knob.new(window, Rect(60,120,size,size));
knobL2.action_{ |v| postf("value: %\n", v.value); x.set(\l2, v.value); };
knobT1 = Knob.new(window, Rect(110,120,size,size));
knobT1.action_{ |v| postf("value: %\n", v.value); x.set(\t1, v.value); };
button = Button.new(window, Rect(320,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
button.action_{ |v| v.value.postln;
		x.set(\imp, v.value);
};
sf = SoundFileView.new(window, Rect(20,20,360,100));
f = SoundFile.new;
f.openRead(p);
sf.soundfile = f;
sf.read(0, f.numFrames);
)

// MIDI + GUI


(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var b = Buffer.read(s, p);
var f, sf, window, knob, knobRate, knobImpulse, button, size = 32;
var knobL0, knobL1, knobL2, knobT1;
//var bufferLength = b.numFrames;
~synth = SynthDef(\help_Buffer, { arg out = 0, rate=1, imp=1, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9;
	var env, pitchedEnv, signal, impulse;
	impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.35, 0.15], curve: [-5, 0, -5]), impulse);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), impulse);
	signal = BufRd.ar(1, bufnum, Phasor.ar(impulse, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
    Out.ar(out, signal)
}).play(s,[\bufnum, b]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(1));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
window.onClose_{ ~synth.free; b.free; };
knobL2 = Knob.new(window, Rect(10,160,size,size));
knobT1 = Knob.new(window, Rect(60,160,size,size));
knobRate = Knob.new(window, Rect(110,160,size,size));
knobImpulse = Knob.new(window, Rect(160,160,size,size));
MIDIFunc.cc({ arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		~synth.set(\imp, midi_val * 10);
		{ knobImpulse.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
sf = SoundFileView.new(window, Rect(20,20,360,100));
f = SoundFile.new;
f.openRead(p);
sf.soundfile = f;
sf.read(0, f.numFrames);
)


/// RECORDING \\\


(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\help_Buffer, { arg out = 0, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.95, 0.15], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\bufnum, ~buffer]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(1));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:7000);
~a.start;
window.onClose_{ ~synth.free; ~buffer.free; ~f.kill; ~a.stop; };
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "startPos";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC_P", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		~synth.set(\startPos, midi_val * ~buffer.numFrames);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)



///////////////////////////////////
//           RECORDING           //  NO COMMIT YET
///////////////////////////////////





(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\help_Buffer, { arg out = 0, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.95, 0.15], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\bufnum, ~buffer]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(1));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:7000);
~a.start;
window.onClose_{ ~synth.free; ~buffer.free; ~f.kill; ~a.stop; };
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "startPos";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		~synth.set(\startPos, midi_val * ~buffer.numFrames);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)

///// =============== \\\\\\\\\
///// ROUTING EXAMPLE
///// =============== \\\\\\\\\


(

var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~bus = Bus.audio(s, 2);
~bus.index;
~bus.numChannels.postln;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\sampling, { arg out, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.95, 0.15], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\out, ~bus, \bufnum, ~buffer]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(0));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:7000);
~a.start;
window.onClose_{ ~synth.free; ~buffer.free; ~f.kill; ~a.stop; };
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "startPos";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		~synth.set(\startPos, midi_val * ~buffer.numFrames);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)



(
SynthDef(\sampling_am, { |freq=0.1, gain = 1.0|
	var in, signal;
	in = In.ar(~bus, 2);
	// in.poll(10);
	signal = In.ar(~bus, 2) * SinOsc.ar(freq, 0, SinOsc.ar(freq/2,0,freq)) * gain;
	Out.ar(~bus, signal)
}).add;
SynthDef(\sampling_fx, {
	var in, signal;
	in = In.ar(~bus, 2);
	Out.ar(0, FreeVerb.ar(in, 0.8, 0.8, 0.8))
}).add;
)

//~src = Synth(\snd);
~am = Synth(\sampling_am, target: ~synth, addAction: \addAfter);
~fx = Synth(\sampling_fx, target: ~am, addAction: \addAfter);

~gated.set(\p1, 34.2)
~gated.set(\w1, 0.39)
~gated.set(\w1, 0.19)
~fx.set(\gain, 2)
~fx.set(\gain, 3)

~synth.free; ~am.free; ~fx.free; ~bus.free


///

/// ROUTING REVISED  --  no commit yet


(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~bus = Bus.audio(s, 2);
~bus.index;
~bus.numChannels.postln;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\sampling, { arg out, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.95, 0.15], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = signal * env;
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\out, ~bus, \bufnum, ~buffer]);
SynthDef(\sampling_am, { |freq=0.1, gain = 1.0|
	var in, signal;
	in = In.ar(~bus, 2);
	// in.poll(10);
	signal = In.ar(~bus, 2) * SinOsc.ar(freq, 0, SinOsc.ar(freq/2,0,freq)) * gain;
	Out.ar(~bus, signal)
}).add;
SynthDef(\sampling_fx, {
	var in, signal;
	in = In.ar(~bus, 2);
	Out.ar(0, FreeVerb.ar(in, 0.8, 0.8, 0.8))
}).add;
~am = Synth(\sampling_am, target: ~synth, addAction: \addAfter);
~fx = Synth(\sampling_fx, target: ~am, addAction: \addAfter);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(0));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:7000);
~a.start;
window.onClose_{
	~synth.free; ~buffer.free;
	~f.kill; ~a.stop;
	~am.free; ~fx.free; ~bus.free;
};
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "startPos";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		~synth.set(\startPos, midi_val * ~buffer.numFrames);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)

//////

///////// ////
// FILTERING
///////////////



(
var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~bus = Bus.audio(s, 2);
~bus.index;
~bus.numChannels.postln;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\sampling, { arg out, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, freq=0.1, cutoff=10000, rq=0.6;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 0.95, 0.15], curve: [-5, 0, -5]), imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = RLPF.ar(signal * env, cutoff, rq);
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\out, 0, \bufnum, ~buffer]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(0));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:7000);
~a.start;
window.onClose_{
	~synth.free; ~buffer.free;
	~f.kill; ~a.stop;
};
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "filter";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		// ~synth.set(\startPos, midi_val * ~buffer.numFrames);
		~synth.set(\cutoff, midi_val * 10000);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)







///////////


///////// ////
// FILTERING
///////////////

// 250403-2035

(
// var p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
//var p = "/Users/geodia/data/samples/train-noise-mono.wav";
var p = "/Users/geodia/data/samples/train-noise-5sec.wav";
var f, sf, window, knob, knobRate, knobPos, button, buttonRec, size = 32;
var knobL0, knobL1, knobL2, knobT1;
var k1, k2, k3, k4;
//var bufferLength = b.numFrames;
~bus = Bus.audio(s, 2);
~bus.index;
~bus.numChannels.postln;
~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~buffer = Buffer.read(s, p);
~synth = SynthDef(\sampling, { arg out, rate=1, imp=0, startPos=0, bufnum, rst=0, lp=1, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=4.9, freq=0.1, cutoff=10000, rq=0.6;
	var env, pitchedEnv, signal, impulse;
	//impulse = Impulse.kr(imp);
	env = EnvGen.ar(Env.new(levels: [l0,l1,l2,l3], times: [t0,t1,t0], curve: [-5, 0, -5]), imp, timeScale: 2.0);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
	signal = RLPF.ar(signal * env, cutoff, rq);
	//amp = SinOsc.kr(freq,0,SinOsc.kr(freq/2,0,freq));
    Out.ar(out, signal)
}).play(s,[\out, 0, \bufnum, ~buffer]);
// MIDI INIT
MIDIClient.init;
MIDIIn.connect(0, MIDIClient.sources.at(0));
// GUI INIT
window = Window.new("Sampler", Rect(350,350,400,200)).front;
window.background = Color.fromHexString("#555555");
~f = FreqScopeView(window, Rect(20,20,360,50)); //////// <<<<<<----------------
~f.active_(true); // turn it on the first time;
~a = Spectrogram.new(window, Rect(20,70,360,50), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:4000);
~a.start;
window.onClose_{
	~synth.free; ~buffer.free;
	~f.kill; ~a.stop;
};
k1 = StaticText(window, Rect(10, 140, size, 20));
k1.string = "L2";
knobL2 = Knob.new(window, Rect(10, 160, size, size));       // 14
k1.stringColor = Color.white; k1.font = Font("Monaco", 11); k1.align = \center;
k3 = StaticText(window, Rect(60, 140, size, 20));
k3.string = "T1";
knobT1 = Knob.new(window, Rect(60, 160, size, size));       // 16
k3.stringColor = Color.white; k3.font = Font("Monaco", 11); k3.align = \center;
k2 = StaticText(window, Rect(110, 140, size, 20));
k2.string = "rate";
knobRate = Knob.new(window, Rect(110, 160, size, size));    // 15
k2.stringColor = Color.white; k2.font = Font("Monaco", 11); k2.align = \center;
k4 = StaticText(window, Rect(160, 140, size+18, 20));
k4.string = "filter";
knobPos = Knob.new(window, Rect(160,160,size,size)); // 17
k4.stringColor = Color.white; k4.font = Font("Monaco", 11); k4.align = \center;
button = Button.new(window, Rect(300,160,30,30));
button.states = [["OFF", Color.white, Color.red], ["ON", Color.black, Color.green]];
buttonRec = Button.new(window, Rect(350,160,30,30));
buttonRec.states = [["REC", Color.white, Color.red], ["REC", Color.black, Color.green]];
//button.action_{ |v| v.value.postln };
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 17){
		var midi_val = args[0]/127;
		// ~synth.set(\startPos, midi_val * ~buffer.numFrames);
		~synth.set(\cutoff, midi_val * 10000);
		~synth.set(\rq, 1.02 - midi_val);
		{ knobPos.value_(midi_val) }.defer;
	};
	if(args[1] == 16){
		var midi_val = args[0]/127;
		~synth.set(\rate, (2 * midi_val) - 1);
		{ knobRate.value_(midi_val) }.defer;
	};
	if(args[1] == 15){
		var midi_val = args[0]/127;
		~synth.set(\t1, midi_val);
		{ knobT1.value_(midi_val) }.defer;
	};
	if(args[1] == 14){
		var midi_val = args[0]/127;
		~synth.set(\l2, midi_val);
		{ knobL2.value_(midi_val) }.defer;
	};
}, [14, 15, 16, 17]); // match cc 1
// PADS
MIDIFunc.noteOn( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		"noteOn: ".post; midi_val.postln;
		if(midi_val > 1){ button_val = 1 };
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
MIDIFunc.noteOff( { arg ...args;
	args.postln;
	if(args[1] == 36){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		if(midi_val > 0){ button_val = 0 };
		"noteOff: ".post; midi_val.postln;
		"buttonVal: ".post; button_val.postln;
		~synth.set(\imp, button_val);
		{ button.value_(button_val) }.defer;
	};
}, [36, 38, 42, 46]);
// RECORDING BUTTON
MIDIFunc.cc( { arg ...args;
	args.postln;
	if(args[1] == 64){
		var midi_val, button_val;
		midi_val = args[0].asInteger;
		">> 64 CC: ".post; midi_val.postln;
		case
		{ midi_val == 127 } {
			button_val = 1;
			~rec = Recording(trigger: button_val, path: ~pwd +/+ ~date ++ ".wav", numchans: 2);
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording ON".postln;
		}
		{ midi_val == 0 }{
			button_val = 0;
			Recording(trigger: button_val); // SUS button
			{ buttonRec.valueAction = button_val; }.defer(0.1);
			"Recording OFF".postln;
		};
	};
}, 64);
)


//////////
///////////
///////////////
///////////////////////
///////////////////////////
///////////////////////////////
/////////////////////////////////////////





s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec.wav";
~sample_pwd = "/Users/geodia/data/samples/a11wlk01.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
b.index;
c.index;
c.numChannels;
b.numChannels



(
SynthDef(\snd, { arg out, imp=0, rate=1, startPos=0, bufnum, rst=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9;
	var env, pitchedEnv, signal;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	signal = BufRd.ar(1, bufnum, Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, startPos, BufFrames.kr(bufnum), resetPos: rst), loop: lp)!2;
    Out.ar(out, signal)
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 1;
    Out.ar(outBus, In.ar(inBus, 2) * SinOsc.kr(modFreq))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5;
    Out.ar(
        outBus,
        RLPF.ar(In.ar(inBus, 2), cutoff, rq)
    )
}).add;
)


~src = Synth(\snd, args: [\bufnum, ~buffer, \out, c]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b], target: ~mod, addAction: \addAfter);

~fx.set(\cutoff, 10000)
~src.set(\imp, 0)
~src.set(\imp, 0, \lp, 0, \rst, 0)

~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "startPos", "modfreq", "boost", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer);


~src.free; ~gated.free; ~fx.free; ~buffer.free;


(
x = {
	var freq, gate=0;
	freq = DemandEnvGen.ar(
		Dseq([204, 400, 201, 502, 300, 200], inf),
		Drand([1.01, 0.2, 0.1, 2], inf) * MouseY.kr(0.01, 3, 1),
		7, gate: gate
	);
	SinOsc.ar(freq * [1, 1.01]) * 0.1
};
)

x.play;
x.gate_(1)


///////  TIME CURSOR

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec.wav";
// ~sample_pwd = "/Users/geodia/data/samples/a11wlk01.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames
~buffer

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
q = Bus.control(s, 1);
b.index;
c.index;
q.index;

Help.gui;




(
SynthDef(\snd, { arg out, ctrlbus, bufnum=0, imp=0, rate=1, startPos=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9;
	var env, pitchedEnv, signal, phasor;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	phasor = Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, 0, BufFrames.kr(bufnum));
	signal = BufRd.ar(1, bufnum, phasor, loop: lp) * env;
	// signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), trig);
	//Out.kr(ctrlbus.index, A2K.kr(phasor));
    Out.ar(out, Pan2.ar(signal))
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 1;
    Out.ar(outBus, In.ar(inBus, 2) * SinOsc.kr(modFreq))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5;
    Out.ar(
        outBus,
        RLPF.ar(In.ar(inBus, 2), cutoff, rq)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffer, \ctrlbus, q]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b], target: ~mod, addAction: \addAfter);

~fx.set(\cutoff, 10000)
~src.set(\imp, 0)
~src.set(\imp, 0, \lp, 0, \rst, 0)
~src.set(\imp, 0, \lp, 0, \rst, 1)

~src.set(\imp, 1)
~src.set(\imp, 0)


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "--", "--", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer, ~buffer.numFrames, ~sample_pwd);

~src.free; ~gated.free; ~fx.free; ~buffer.free;



// ================================ \\
////  TIME CURSOR \\\\\\
// ================================ \\

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec.wav";
// ~sample_pwd = "/Users/geodia/data/samples/a11wlk01.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames
~buffer

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
q = Bus.control(s, 1);
b.index;
c.index;
q.index;

Help.gui;




(
SynthDef(\snd, { arg out, ctrlbus, bufnum=0, imp=0, rate=1, startPos=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9;
	var env, pitchedEnv, signal, phasor;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	phasor = Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, 0, BufFrames.kr(bufnum));
	signal = BufRd.ar(1, bufnum, phasor, loop: lp) * env;
	// signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), trig);
	//Out.kr(ctrlbus.index, A2K.kr(phasor));
    Out.ar(out, Pan2.ar(signal))
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 1;
    Out.ar(outBus, In.ar(inBus, 2) * SinOsc.kr(modFreq))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5;
    Out.ar(
        outBus,
        RLPF.ar(In.ar(inBus, 2), cutoff, rq)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffer, \ctrlbus, q]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b], target: ~mod, addAction: \addAfter);

~fx.set(\cutoff, 10000)
~src.set(\imp, 0)
~src.set(\imp, 0, \lp, 0, \rst, 0)
~src.set(\imp, 0, \lp, 0, \rst, 1)

~src.set(\imp, 1)
~src.set(\imp, 0)


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "--", "--", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer, ~buffer.numFrames, ~sample_pwd);

~src.free; ~gated.free; ~fx.free; ~buffer.free;



// TIME CURSOR WORKING

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec-mono.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames
~buffer

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
q = Bus.control(s, 1);
b.index;
c.index;
q.index;

Help.gui;


(
SynthDef(\snd, { arg out, bufnum=0, imp=0, rate=1, startPos=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, updateRate=10;
	var env, pitchedEnv, signal, phasor;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	phasor = Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * pitchedEnv, 0, BufFrames.kr(bufnum));
	signal = BufRd.ar(1, bufnum, phasor, loop: lp) * env;
	SendReply.kr(Impulse.kr(updateRate), "/bufPos", [phasor, signal]);
	// signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), trig);
	Out.kr(\ctrlbus.index, A2K.kr(phasor));
    Out.ar(out, Pan2.ar(signal))
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 1;
    Out.ar(outBus, In.ar(inBus, 2) * SinOsc.kr(modFreq))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5;
    Out.ar(
        outBus,
        RLPF.ar(In.ar(inBus, 2), cutoff, rq)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffer, \ctrlbus, q]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b], target: ~mod, addAction: \addAfter);

~fx.set(\cutoff, 10000)
~src.set(\imp, 0)
~src.set(\imp, 0, \lp, 0, \rst, 0)
~src.set(\imp, 0, \lp, 0, \rst, 1)

~src.set(\imp, 1)
~src.set(\imp, 0)


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "--", "--", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer, ~buffer.numFrames, ~sample_pwd);

~src.free; ~gated.free; ~fx.free; ~buffer.free;


// END OF DAY 5 Apr 2025

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
// ~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec-mono.wav";
// ~sample_pwd = "/Users/geodia/data/samples/test-sqeak-4sec-mono.wav";
~sample_pwd = "/Users/geodia/data/samples/t-square-wave-1sec.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames
~buffer

b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
q = Bus.control(s, 1);
b.index;
c.index;
q.index;

Help.gui;

(
SynthDef(\snd, { arg out, bufnum=0, imp=0, rate=1, startPos=0, lp=0, l0=1, l1=1, l2=1, l3=1, t0=0.05, t1=0.9, updateRate=10, amt=5;
	var env, pitchedEnv, signal, phasor;
	env = EnvGen.ar(Env.new(levels: [0, 1, 0.9, 0], times: [0.05, 4.90, 0.05], curve: [-5, 0, -5]), gate: imp);
	pitchedEnv = EnvGen.ar(Env.new(levels: [l0, l1, l2, l3], times: [t0, t1-(2*t0), t0], curve: [-5, 0, -5]), gate: imp);
	phasor = Phasor.ar(imp, BufRateScale.kr(bufnum) * rate * amt * pitchedEnv, 0, BufFrames.kr(bufnum));
	signal = BufRd.ar(1, bufnum, phasor, loop: lp) * env;
	SendReply.kr(Impulse.kr(updateRate), "/bufPos", [phasor, signal]);
	// signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), trig);
	Out.kr(\ctrlbus.index, A2K.kr(phasor));
    Out.ar(out, Pan2.ar(signal))
}).add;
SynthDef(\snd_gated, { arg inBus, outBus, modFreq = 0;
	var signal, fm;
	fm = SinOsc.kr(modFreq,0,SinOsc.kr(modFreq/32,0,modFreq));
	//signal = if(DC.kr(modFreq), DC.kr(1), fm);
	//Out.ar(outBus, In.ar(inBus, 2) * signal)
	Out.ar(outBus, Limiter.ar(In.ar(inBus, 2) * fm, 0.95))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, bufnum, cutoff = 2300, rq = 0.5;
    Out.ar(
        outBus,
        Limiter.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq), 0.95)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffer, \ctrlbus, q]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b, \bufnum, ~bufalloc], target: ~mod, addAction: \addAfter);


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "amt", "freeze", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer, ~buffer.numFrames, ~sample_pwd);

~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;

//////////////
// NUM FRAMES
// debug GPT
//////////////

s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
// ~sample_pwd = "/Users/geodia/data/samples/train-noise-5sec-mono.wav";
// ~sample_pwd = "/Users/geodia/data/samples/test-sqeak-4sec-mono.wav";
~sample_pwd = "/Users/geodia/data/samples/t-square-wave-1sec.wav";
~buffer = Buffer.read(s, ~sample_pwd);
~buffer.numFrames
~buffer

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
	var signal, fm;
	fm = SinOsc.ar(modFreq,0,SinOsc.ar(modFreq/16,0,modFreq));
	//signal = if(DC.kr(modFreq), DC.kr(1), fm);
	//Out.ar(outBus, In.ar(inBus, 2) * signal)
	Out.ar(outBus, Pan2.ar(In.ar(inBus, 2), 0, fm.abs))
}).add;
SynthDef(\snd_fx, { arg inBus, outBus, bufnum, cutoff = 2300, rq = 0.5, f1=0.5, l1=0.001;
    Out.ar(
        outBus,
        Limiter.ar(Lag.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq).fold(f1.neg,f1), l1), 0.95)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffer, \ctrlbus, q, \numframes, ~buffer.numFrames]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b, \bufnum, ~bufalloc], target: ~mod, addAction: \addAfter);


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "amt", "fold", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffer, ~buffer.numFrames, ~sample_pwd);

~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;


///////////////////////////////
// PopUpMeny Loading Buffers
///////////////////////////////


s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd_1 = Platform.userHomeDir ++ "/samples/train-noise-5sec-mono.wav";
~sample_pwd_2 = Platform.userHomeDir ++ "/samples/t-square-wave-1sec.wav";
~buffers = [ Buffer.read(s, ~sample_pwd_1),	Buffer.read(s, ~sample_pwd_2) ];
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
SynthDef(\snd_fx, { arg inBus, outBus, bufnum, cutoff = 2300, rq = 0.5, f1=0.5, l1=0.001;
    Out.ar(
        outBus,
        Limiter.ar(Lag.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq).fold(f1.neg,f1), l1), 0.95)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffers[0], \ctrlbus, q, \numframes, ~buffers[0].numFrames]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b, \bufnum, ~bufalloc], target: ~mod, addAction: \addAfter);


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "amt", "fold", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffers);

//	*new { | midiDevice, dict, synth, mod, fx, buffer, numframes, path, ctrlBus |


~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;


//// Dropdown menu filename only




s.options.memSize = 2**18;
s.boot;
FreqScope.new;
s.meter;
s.volume.gui;
Stethoscope.new;
scope(s).style=2

~pwd = "/Users/geodia/data/recordings";
~date = Date.getDate.format("%Y-%m-%d-%H%M").asString;
~sample_pwd_1 = Platform.userHomeDir ++ "/samples" +/+ "train-noise-5sec-mono.wav";
~sample_pwd_2 = Platform.userHomeDir ++ "/samples" +/+ "t-square-wave-1sec.wav";
~sample_pwd_3 = Platform.userHomeDir ++ "/samples" +/+ "sqeek-mono-part-2-48000.wav"
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
SynthDef(\snd_fx, { arg inBus, outBus, bufnum, cutoff = 2300, rq = 0.5, f1=0.5, l1=0.001;
    Out.ar(
        outBus,
        Limiter.ar(Lag.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq).fold(f1.neg,f1), l1), 0.95)
    )
}).add;
)

~src = Synth(\snd, args: [\out, c, \bufnum, ~buffers[0], \ctrlbus, q, \numframes, ~buffers[0].numFrames]);
~mod = Synth(\snd_gated, args: [\outBus, b, \inBus, c], target: ~src, addAction: \addAfter);
~fx = Synth(\snd_fx, args: [\outBus, 0, \inBus, b, \bufnum, ~bufalloc], target: ~mod, addAction: \addAfter);


~dict = Dictionary.new;
~dict[\knobs] = ["l2", "t1", "rate", "amt", "fold", "AM", "cutoff", "rq"];
MIDIClient.init;
MIDIClient.sources.at(1)
MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~src, ~mod, ~fx, ~buffers);

//	*new { | midiDevice, dict, synth, mod, fx, buffer, numframes, path, ctrlBus |


~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;


///////



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
SynthDef(\snd_fx, { arg inBus, outBus, cutoff = 2300, rq = 0.5, f1=0.5, l1=0.001;
    Out.ar(
        outBus,
        Limiter.ar(Lag.ar(RLPF.ar(In.ar(inBus, 2), cutoff, rq).fold(f1.neg,f1), l1), 0.95)
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

//	*new { | midiDevice, dict, synth, mod, fx, buffer, numframes, path, ctrlBus |


~src.free; ~gated.free; ~fx.free; ~buffer.free; b.free; c.free; q.free;