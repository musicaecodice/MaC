s.boot;

~lilypath=Platform.userHomeDir++"/Desktop/lilypond-2.24.4/bin";// Lilypond path
~filepath=Platform.userHomeDir++"/Desktop/test";   // Filename without extension

Fosc.lilypondPath = ~lilypath++"/lilypond.exe";
Fosc.lilypondVersion;

~print = {arg pitch=[60], dur=[1/4], vel=[nil], bpm=60,
              filepath=Platform.userHomeDir++"/Desktop/test";
          var staff, mus, seq, dn;
          Routine{
          dur = dur.collect{arg i;
                      if(i.isInteger)
                         {1/i}
                         {(1/i[0])*i[1].normalizeSum} }.flat;
          mus = FoscLeafMaker().(pitches:pitch, durations:dur);
          dn = #['!','-','|','>'];
          mus.selectLeaves().do({arg item, id;
                                 item.attach(FoscArticulation(
                                                      i = vel.wrapAt(id);
                                                      case
                                                      {i==nil}{dn[0]}
                                                      {i>=1 && i<=42} {dn[1]}
                                                      {i>=43 && i<=80} {dn[2]}
                                                      {i>=81 && i<=127}{dn[3]}
                                                      )) });
          staff = FoscStaff(mus);

          staff.writeLY(filepath++".ly");
("cd" + ~lilypath + "&& lilypond -o" + filepath + filepath ++ ".ly").unixCmd;

          seq = Pbind(
	            \midinote, Pseq(pitch.replace([nil],\rest),
                                            if(dur.size > pitch.size){inf}{1}),
	            \dur,      Pseq(dur*4,
                                            if(dur.size>pitch.size){1}{inf}),
              \amp,      Pseq((vel.replace([nil],64)/127)**4,inf) );
          ~midi = SimpleMIDIFile.new( filepath++'.mid' );
          ~midi.init;
          ~midi.init0(bpm, "4/4");
          ~midi.timeMode = \ticks;
          ~midi.fromPattern(seq);
          ~midi.checkWrite(filepath++'.mid', true);
          1.wait;
          ~midi.play(TempoClock(bpm/60));
          }.play;
        }