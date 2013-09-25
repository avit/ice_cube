require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe StringBuilder do

    describe :sentence do
      let(:rule) { double(:accept => nil) }
      subject    { StringBuilder.new(rule) }

      it 'should return empty string when none' do
        subject.format(:sentence, []).should == ''
      end

      it 'should return sole when one' do
        subject.format(:sentence, ['1']).should == '1'
      end

      it 'should split on and when two' do
        subject.format(:sentence, ['1', '2']).should == '1 and 2'
      end

      it 'should comma and when more than two' do
        subject.format(:sentence, ['1', '2', '3']).should == '1, 2, and 3'
      end

    end

  end
end
