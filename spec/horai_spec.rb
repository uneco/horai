# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Horai do
  context 'normalization' do
    it "number" do
      Horai.normalize('０１２３４').should === '01234'
    end
    it "alphabet" do
      Horai.normalize('ａｂｃｄｅ').should === 'abcde'
      Horai.normalize('ＡＢＣＤＥ').should === 'ABCDE'
    end
    # it "numeric kanji" do
    #   pending "Yet implemented"
    #   Horai.normalize('十五').should === '15'
    #   Horai.normalize('十四万二千三百四十五').should === '142345'
    # end
  end
  context 'parse absolute' do
    before :each do
      @sample_date = DateTime.new(2012, 4, 11, 12, 45, 30, Rational(9, 24))
      @sample_text = @sample_date.strftime('%Y年%m月%d日の%H時%M分%S秒')
    end
    it "single" do
      time = Horai.parse(@sample_text)
      time.to_s.should === @sample_date.to_s
    end
  end

  context 'parse relative' do
    it "check" do
      Horai.relative?("10分後").should be_true
      Horai.relative?("10分経ったら").should be_true
      Horai.relative?("10分したら").should be_true
      Horai.relative?("10分").should be_false
      Horai.relative?("10時10分").should be_false
    end
    it "single" do
      time = Horai.parse("10分後")
      time.to_s.should === (DateTime.now + 10.minute).to_s
    end
    it "tomorrow" do
      time = Horai.parse("明日")
      time.to_s.should === (DateTime.now + 1.day).to_s
    end
    it "day after tomorrow" do
      time = Horai.parse("明後日")
      time.to_s.should === (DateTime.now + 2.day).to_s
    end
    it "yesterday" do
      time = Horai.parse("昨日")
      time.to_s.should === (DateTime.now - 1.day).to_s
    end
    it "day after" do
      time = Horai.parse("10日後")
      time.to_s.should === (DateTime.now + 10.day).to_s
    end
  end
end
