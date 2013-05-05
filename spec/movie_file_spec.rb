require 'subdl'

describe MovieFile do
  context 'filename parsing' do
    context 'should filter out year' do
      subject { MovieFile.new('Showname.2012.S06E15').show }
      it { should == 'Showname' }
    end
    context 'Simple case' do
      subject { MovieFile.new 'Showname.S06E15' }
      specify { subject.episode.should == '15' }
      specify { subject.season.should == '6' }
      specify { subject.show.should == 'Showname' }
    end
    context 'Showname with dots' do
      specify { MovieFile.new('Show.name.S06E05').show.should == 'Show name' }
    end
    context 'Episode title' do
      subject { MovieFile.new 'Star.Wars.The.Clone.Wars.S05E19.To.Catch.a.Jedi.HDTV.x264-FQM.mp4'}
      specify { subject.episode.should == '19'} 
      specify { subject.show.should == 'Star Wars The Clone Wars'} 
    end
    context 'full path' do
      subject { MovieFile.new '/home/user/Showname.S06E15.mp4' }
      specify { subject.episode.should == '15' }
      specify { subject.season.should == '6' }
      specify { subject.show.should == 'Showname' }
    end
    specify do
      MovieFile.new('/home/user/The.Show.S01E03.mp4').search_term.
        should == 'The Show 1x03'
    end
    it 'should extract season number from filename' do
      "The.Big.Bang.Theory.S06E14.HDTV.x264-LOL.mp4".season.should == "6"
      "The.Big.Bang.Theory.S07E14.HDTV.x264-LOL.mp4".season.should == "7"
      "The.Big.Bang.Theory.S14E14.HDTV.x264-LOL.mp4".season.should == "14"
      "The.SBig.Bang.Theory.S14E14.HDTV.x264-LOL.mp4".season.should == "14"
    end
    it 'should extract episode number from filename' do
      "The.Big.Bang.Theory.S06E14.HDTV.x264-LOL.mp4".episode.should == "14"
    end
  end
end 

class String
  def episode() MovieFile.new(self).episode end
  def season()  MovieFile.new(self).season end
end
