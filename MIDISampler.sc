/*
	~dict = Dictionary.new;
	~dict[\knobs] = ["aa", "bb", "ccc", "ddd", "eee", "ffff", "ggg", "hhhh"];
	~synth= <SYNTH HERE>;
	~buffers= <BUFFER HERE>;

	MIDIClient.init;
	MIDIClient.sources.at(1)

	MIDISampler.new(MIDIClient.sources.at(1), ~dict, ~synth, ~buffers);
*/

MIDISampler {

	var <>midiDevice, <>dict, <>synth, <>osc;
	var <>mod, <>fx, <>buffers;
	var <window;
	var <freqAnalyzer, <spectroGram, <sf, <sfview;
	var <>width=800, <>height=500;
	var <>knob_text_1, <>knob_text_2, <>knob_text_3, <>knob_text_4, <>knob_text_5, <>knob_text_6, <>knob_text_7, <>knob_text_8;
	var <>knob_1, <>knob_2, <>knob_3, <>knob_4, <>knob_5, <>knob_6, <>knob_7, <>knob_8;
	var <>button;
	var <>size=50;
	var <>knobSize=40;
	var <>font_size = 14;


	*new { | midiDevice, dict, synth, mod, fx, buffers |
		^super.new.init(midiDevice, dict, synth, mod, fx, buffers)
		// ^super.newCopyArgs(midiDevice, dict, synth, buffers)
	}

	init { | midiDevice, dict, synth, mod, fx, buffers |
		MIDIClient.init;
		// midiDevice => MIDIClient.sources.at(1)
		MIDIIn.connect(0, midiDevice);
		this.makeWindow(synth, buffers);
		this.makeKnobs(dict);
		this.makeButton;
		this.midiConnections(dict, synth, mod, fx, buffers);
	}

	makeWindow { | synth, buffers |
		var local_height = 100;
		var popupMenu;

		window = Window.new("Sampler", Rect(500, 500, width, height), resizable: false).front;
		window.background = Color.fromHexString("#555555");
		freqAnalyzer = FreqScopeView(window, Rect(20, 40, width-50, local_height));
		freqAnalyzer.active_(true);
		spectroGram = Spectrogram.new(window, Rect(20, 40 + local_height + 5, width-50, local_height), background:Color(0.05, 0.05, 0.05), color:Color.green, lowfreq:20, highfreq:4000);
		spectroGram.start;

		sfview = SoundFileView.new(window, Rect(20, 40 + (2 * local_height) + 10, width-50, local_height));
		sf = SoundFile.new;
		sf.openRead(buffers[0].path); // initialize path
		sfview.soundfile = sf;
		sfview.read(0, sf.numFrames);
		sfview.timeCursorOn = true;          // a settable cursor
		//sfview.timeCursorPosition = 0;    // position is in frames.
		sfview.timeCursorColor = Color.red;
		// scroll to position
		//sfview.scrollTo(posData[0]);
		popupMenu = PopUpMenu(window, Rect(20, 10, 180, 20));
		//
		popupMenu.items = buffers collect: { |buffer| buffer.path.fileNameWithoutExtension };
		popupMenu.background_(Color.cyan(0.3));  // only changes the look of displayed item
		popupMenu.stringColor_(Color.black);   // only changes the look of displayed item
		popupMenu.font_(Font("Courier", 13));   // only changes the look of displayed item
		popupMenu.action = { |menu|
			var path = Platform.userHomeDir ++ "/samples" +/+ menu.item ++ ".wav";
			">> PopUp Action: "[menu.value, path].postln;
			// Update soundfile view
			sf.openRead(path);
			sfview.soundfile = sf;
			sfview.read(0, sf.numFrames);
			format("BUFFERS: %, NUMFRAMES: %", buffers[menu.value], buffers[menu.value].numFrames).postln;
			synth.set(\bufnum, buffers[menu.value], \numframes, buffers[menu.value].numFrames);
		};

		window.onClose = { this.windowClosed };

		^this.getTimeCursor(buffers)
	}

	makeKnobs { | dict |
		// TYPOGRAPHY
		knob_text_1 = StaticText(window, Rect(width-(3*size+10)-50,height-150,size,20));
		knob_text_2 = StaticText(window, Rect(width-(2*size+10)-50,height-150,size,20));
		knob_text_3 = StaticText(window, Rect(width-(1*size+10)-50,height-150,size,20));
		knob_text_4 = StaticText(window, Rect(width-(0*size+10)-50,height-150,size,20));
		knob_text_5 = StaticText(window, Rect(width-(3*size+10)-50,height-80,size,20));
		knob_text_6 = StaticText(window, Rect(width-(2*size+10)-50,height-80,size,20));
		knob_text_7 = StaticText(window, Rect(width-(1*size+10)-50,height-80,size,20));
		knob_text_8 = StaticText(window, Rect(width-(0*size+10)-50,height-80,size,20));
		//
		knob_text_1.string = dict[\knobs][0];
		knob_text_1.stringColor = Color.white;
		knob_text_1.font = Font("Monaco", font_size);
		knob_text_1.align = \center;
		knob_text_2.string = dict[\knobs][1];
		knob_text_2.stringColor = Color.white;
		knob_text_2.font = Font("Monaco", font_size);
		knob_text_2.align = \center;
		knob_text_3.string = dict[\knobs][2];
		knob_text_3.stringColor = Color.white;
		knob_text_3.font = Font("Monaco", font_size);
		knob_text_3.align = \center;
		knob_text_4.string = dict[\knobs][3];
		knob_text_4.stringColor = Color.white;
		knob_text_4.font = Font("Monaco", font_size);
		knob_text_4.align = \center;
		knob_text_5.string = dict[\knobs][4];
		knob_text_5.stringColor = Color.white;
		knob_text_5.font = Font("Monaco", font_size);
		knob_text_5.align = \center;
		knob_text_6.string = dict[\knobs][5];
		knob_text_6.stringColor = Color.white;
		knob_text_6.font = Font("Monaco", font_size);
		knob_text_6.align = \center;
		knob_text_7.string = dict[\knobs][6];
		knob_text_7.stringColor = Color.white;
		knob_text_7.font = Font("Monaco", font_size);
		knob_text_7.align = \center;
		knob_text_8.string = dict[\knobs][7];
		knob_text_8.stringColor = Color.white;
		knob_text_8.font = Font("Monaco", font_size);
		knob_text_8.align = \center;
		// GUI knobs
		knob_1 = Knob.new(window, Rect(width-(3*size+10)-50,height-(150-(knobSize/2)),knobSize,knobSize));
		knob_2 = Knob.new(window, Rect(width-(2*size+10)-50,height-(150-(knobSize/2)),knobSize,knobSize));
		knob_3 = Knob.new(window, Rect(width-(1*size+10)-50,height-(150-(knobSize/2)),knobSize,knobSize));
		knob_4 = Knob.new(window, Rect(width-(0*size+10)-50,height-(150-(knobSize/2)),knobSize,knobSize));
		knob_5 = Knob.new(window, Rect(width-(3*size+10)-50,height-(80-(knobSize/2)),knobSize,knobSize));
		knob_6 = Knob.new(window, Rect(width-(2*size+10)-50,height-(80-(knobSize/2)),knobSize,knobSize));
		knob_7 = Knob.new(window, Rect(width-(1*size+10)-50,height-(80-(knobSize/2)),knobSize,knobSize));
		knob_8 = Knob.new(window, Rect(width-(0*size+10)-50,height-(80-(knobSize/2)),knobSize,knobSize));

	}

	makeButton {
		button = Button.new(window, Rect(100,height-100,60,60));
		button.states = [["PLAY", Color.white, Color.red], ["PLAY", Color.black, Color.green]];
		button.font = Font("Monaco", font_size);
	}

	midiConnections{ | dict, synth, mod, fx, buffers |
		// KNOB CONTROLS
		MIDIFunc.cc( { arg ...args;
			args.postln;
			if(args[1] == 70){
				var midi_val = args[0]/127;
				synth.set(\l2, midi_val);
				{ knob_1.value_(midi_val) }.defer;
			};
			if(args[1] == 71){
				var midi_val = args[0]/127;
				synth.set(\t1, midi_val);
				{ knob_2.value_(midi_val) }.defer;
			};
			if(args[1] == 72){
				var midi_val = args[0]/127;
				synth.set(\rate, (2 * midi_val) - 1);
				{ knob_3.value_(midi_val) }.defer;
			};
			if(args[1] == 73){
				var midi_val = args[0]/127;
				//var start_val = (midi_val * numframes).asInteger;
				//"start_val: ".post; start_val.postln;
				var g = ControlSpec(1, 10, \lin, step: 1);
				">> g.map(midi_val) = ".post; g.map(midi_val).postln;
				synth.set(\amt, g.map(midi_val));
				{ knob_4.value_(midi_val) }.defer;
			};
			if(args[1] == 74){
				var midi_val = args[0]/127;
				//var g = ControlSpec(0.001, 1.0, \exp);
				fx.set(\f1, midi_val);
				{ knob_5.value_(midi_val) }.defer;
			};
			if(args[1] == 75){
				var midi_val = args[0]/127;
				var g = ControlSpec(0.001, 1.0, \exp);
				// 	linexp { arg inMin, inMax, outMin, outMax, clip = \minmax;
				mod.set(\modFreq, g.map(midi_val) * 75);
				{ knob_6.value_(midi_val) }.defer;
			};
			if(args[1] == 76){
				var midi_val = args[0]/127;
				var g = ControlSpec(0.001, 1.0, \exp, 0.001, 1.0);
				fx.set(\cutoff, g.map(midi_val) * 10000 + 1);
				{ knob_7.value_(midi_val) }.defer;
			};
			if(args[1] == 77){
				var midi_val = args[0]/127;
				//var g = ControlSpec(0.001, 1.0, \exp, 0.001, 1.0);
				fx.set(\rq, midi_val);
				{ knob_8.value_(midi_val) }.defer;
			};
		}, (70 .. 77)); // match cc 1
		// == BUTTONS == \\
		// NOTEON
		MIDIFunc.noteOn( { arg ...args;
			args.postln;
			if(args[1] == 40){
				var midi_val, button_val;
				midi_val = args[0];
				if(midi_val == 127){ button_val = 1 };
				"noteOn: ".post; midi_val.postln;
				"buttonVal: ".post; button_val.postln;
				synth.set(\imp, button_val);
				{ button.value_(button_val) }.defer;
			};
		}, (36 .. 43));
		// NOTEOFF
		MIDIFunc.noteOff( { arg ...args;
			args.postln;
			if(args[1] == 40){
				var midi_val, button_val;
				midi_val = args[0];
				if(midi_val == 0){ button_val = 0 };
				"noteOff: ".post; midi_val.postln;
				"buttonVal: ".post; button_val.postln;
				synth.set(\imp, button_val);
				{ button.value_(button_val) }.defer;
			};
		}, (36 .. 43));
	}

	getTimeCursor{ | buffers |
		osc = OSCdef(\messaging, {|msg|
			//var pos = (msg[3] / numframes);
			var val = msg[3].asInteger;
			// "position = ".post; val.postln;
			//">> OSC: ".post; msg.postln;
			{
				{
					if(msg[4] != 0.0){
						sfview.timeCursorPosition = val; "timeCursor = ".post; val.postln;
					}{
						sfview.timeCursorPosition = 0;
					}
				}.defer;
			}.fork(AppClock)
		}, "/bufPos");

	}

	windowClosed {
		synth.free;
		buffers.free;
		freqAnalyzer.kill;
		spectroGram.stop;
		osc.free;
		AppClock.clear;
	}
}
