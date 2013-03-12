require 'crawler.rb'
class String
  def episode() parse(self).episode end
  def season() parse(self).season end
end

describe Parse do
  context 'Simple case' do
    subject { parse 'Showname.S06E15' }
    specify { subject.episode.should == '15' }
    specify { subject.season.should == '6' }
    specify { subject.show.should == 'Showname' }
  end
  context 'Showname with dots' do
    specify { parse('Show.name.S06E05').show.should == 'Show name' }
  end
  context 'Episode title' do
    subject { parse 'Star.Wars.The.Clone.Wars.S05E19.To.Catch.a.Jedi.HDTV.x264-FQM.mp4'}
    specify { subject.episode.should == '19'} 
    specify { subject.show.should == 'Star Wars The Clone Wars'} 
  end
  context 'full path' do
    subject { parse '/home/user/Showname.S06E15.mp4' }
    specify { subject.episode.should == '15' }
    specify { subject.season.should == '6' }
    specify { subject.show.should == 'Showname' }
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

