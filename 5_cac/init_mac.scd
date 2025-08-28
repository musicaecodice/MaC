s.boot;

~lilypath="/Applications/lilypond-2.24.4/bin"; // Lilypond path
                               // Filename path without extension
~filepath=Platform.userHomeDir++"/Desktop/GHub/EMC/5_cac/score/test";

Fosc.lilypondPath = ~lilypath++"/lilypond";
Fosc.lilypondVersion;

~print = {arg pitch=[60], dur=[4], vel=[nil], bpm=60,
              filepath=Platform.userHomeDir++"/Desktop/GHub/EMC/5_cac/score/test";
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
                                                      ))
                                               });
            staff = FoscStaff(mus);
            staff.writePDF(filepath++".ly");

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