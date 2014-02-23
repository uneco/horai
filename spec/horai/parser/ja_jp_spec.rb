# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '../../../spec_helper')

$jajp = Horai::JaJP.new

def now (year = nil, month = nil, day = nil, hour = nil, minute = nil, second = nil)
  @now ||= $jajp.now

  DateTime.new(year   || @now.year,
               month  || @now.month,
               day    || @now.day,
               hour   || @now.hour,
               minute || @now.minute,
               second || @now.second,
               Rational(9, 24))
end

describe Horai::JaJP do
  context 'normalize' do
    it "number" do
      $jajp.normalize('０１２３４').should === '01234'
    end
    it "alphabet" do
      $jajp.normalize('ａｂｃｄｅ').should === 'abcde'
      $jajp.normalize('ＡＢＣＤＥ').should === 'ABCDE'
    end
    it "numeric kanji" do
      $jajp.normalize('十五').should === '15'
      $jajp.normalize('十四万二千三百四十五').should === '142345'
      $jajp.normalize('百五十時間後').should === '150時間後'

      pending "漢数字パースライブラリがだめ"
      $jajp.normalize('1万秒').should === '10000秒'
    end
  end

  context 'invalid cases' do
    it 'not even one filter passed' do
      $jajp.parse("なにもなし").should be_nil
    end
  end

  context 'parse absolute' do
    before :each do
      @sample_date = DateTime.new(2012, 4, 11, 12, 45, 30, Rational(9, 24))
      @sample_text = @sample_date.strftime('%Y年%m月%d日の%H時%M分%S秒')
    end
    it "year, month, day, hour, minute, second" do
      time = $jajp.parse(@sample_text)
      time.to_s.should === @sample_date.to_s
    end
    it "year" do
      time = $jajp.parse("1999年")
      time.to_s.should === now(1999, 1, 1, 0, 0, 0).to_s
    end
    it "month" do
      time = $jajp.parse("1月")
      time.to_s.should === now(nil, 1, 1, 0, 0, 0).to_s
    end
    it "half time" do
      time = $jajp.parse("1時半")
      time.to_s.should === now(nil, nil, nil, 1, 30, 0).to_s
    end
    it "half minute" do
      time = $jajp.parse("1分半後")
      time.to_s.should === (now + 1.5.minute).to_s
    end
    it "half hour and minute" do
      time = $jajp.parse("5時間半と1分半後")
      time.to_s.should === (now + 5.5.hour + 1.5.minute).to_s
    end
    it "at night" do
      time = $jajp.parse("夜の8時に")
      time.to_s.should === (now(nil, nil, nil, 20, 0, 0)).to_s
    end
    it "at afternoon" do
      time = $jajp.parse("午後一時に")
      time.to_s.should === (now(nil, nil, nil, 13, 0, 0)).to_s
    end
    it "at afternoon" do
      time = $jajp.parse("PM1時に")
      time.to_s.should === (now(nil, nil, nil, 13, 0, 0)).to_s
    end
    it "at AM and contains *pm*" do
      time = $jajp.parse("rpm 6時に")
      time.to_s.should === (now(nil, nil, nil, 6, 0, 0)).to_s
    end
    it "at noon" do
      time = $jajp.parse("10日の正午に")
      time.to_s.should === (now(nil, nil, 10, 12, 0, 0)).to_s
    end
    it "at hh:mm" do
      time = $jajp.parse("10:20")
      time.to_s.should === (now(nil, nil, nil, 10, 20, 0)).to_s
    end
    it "at hh:mm:ss" do
      time = $jajp.parse("10:20:30")
      time.to_s.should === (now(nil, nil, nil, 10, 20, 30)).to_s
    end
    it "at MM/DD" do
      time = $jajp.parse("10/20")
      time.to_s.should === now(nil, 10, 20, 0, 0, 0).to_s
    end
    it "at YYYY/MM/DD" do
      time = $jajp.parse("2000/10/20")
      time.to_s.should === now(2000, 10, 20, 0, 0, 0).to_s
    end
    it "at YY/MM/DD" do
      time = $jajp.parse("10/10/20")
      time.to_s.should === now(2010, 10, 20, 0, 0, 0).to_s
    end
    it "at YYYY/MM/DD hh:mm:ss" do
      time = $jajp.parse("2000/10/20 12:30:40")
      time.to_s.should === now(2000, 10, 20, 12, 30, 40).to_s
    end
    it "at YY (near current year)" do
      time = $jajp.parse("10年")
      time.to_s.should === now(2010, 1, 1, 0, 0, 0).to_s
    end
    it "at YY (near feature)" do
      time = $jajp.parse("30年")
      time.to_s.should === now(2030, 1, 1, 0, 0, 0).to_s
    end
    it "at YY (not near feature)" do
      time = $jajp.parse("90年")
      time.to_s.should === now(1990, 1, 1, 0, 0, 0).to_s
    end
  end

  context 'parse relative' do
    it "check" do
      $jajp.relative?("10分後").should be_true
      $jajp.relative?("10分経ったら").should be_true
      $jajp.relative?("10分したら").should be_true
      $jajp.relative?("10分").should be_false
      $jajp.relative?("10時10分").should be_false
    end
    context "year" do
      it "three years ago" do
        time = $jajp.parse("一昨々年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) - 3.year).to_s
      end
      it "two years ago" do
        time = $jajp.parse("一昨年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) - 2.year).to_s
      end
      it "last year" do
        time = $jajp.parse("昨年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) - 1.year).to_s
      end
      it "this year" do
        time = $jajp.parse("今年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0)).to_s
      end
      it "next year" do
        time = $jajp.parse("来年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) + 1.year).to_s
      end
      it "year after next" do
        time = $jajp.parse("再来年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) + 2.year).to_s
      end
      it "in three years time" do
        time = $jajp.parse("明明後年")
        time.to_s.should === (now(nil, 1, 1, 0, 0, 0) + 3.year).to_s
      end
    end

    context "month" do
      it "three monthes ago" do
        time = $jajp.parse("先々々月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) - 3.month).to_s
      end
      it "two monthes ago" do
        time = $jajp.parse("先々月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) - 2.month).to_s
      end
      it "last month" do
        time = $jajp.parse("先月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) - 1.month).to_s
      end
      it "this month" do
        time = $jajp.parse("今月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0)).to_s
      end
      it "next month" do
        time = $jajp.parse("来月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) + 1.month).to_s
      end
      it "month after next" do
        time = $jajp.parse("再来月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) + 2.month).to_s
      end
      it "in three month times" do
        time = $jajp.parse("再々来月")
        time.to_s.should === (now(nil, nil, 1, 0, 0, 0) + 2.month).to_s
      end
    end

    context "day" do
      it "thre days ago" do
        time = $jajp.parse("一昨々日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) - 3.day).to_s
      end
      it "day before yesterday" do
        time = $jajp.parse("一昨日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) - 2.day).to_s
      end
      it "yesterday" do
        time = $jajp.parse("昨日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) - 1.day).to_s
      end
      it "today" do
        time = $jajp.parse("今日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0)).to_s
      end
      it "tomorrow" do
        time = $jajp.parse("明日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) + 1.day).to_s
      end
      it "day after tomorrow" do
        time = $jajp.parse("明後日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) + 2.day).to_s
      end
      it "in three days time" do
        time = $jajp.parse("明々後日")
        time.to_s.should === (now(nil, nil, nil, 0, 0, 0) + 3.day).to_s
      end
    end

    context "complex" do
      it "numeric year after and absolute month" do
        time = $jajp.parse("10年後の8月")
        time.to_s.should === (now(nil, 8, 1, 0, 0, 0) + 10.year).to_s
      end
      it "numeric minute after" do
        time = $jajp.parse("10分後")
        time.to_s.should === (now + 10.minute).to_s
      end
      it "numeric day after" do
        time = $jajp.parse("10日後")
        time.to_s.should === (now + 10.day).to_s
      end
      it "tomorrow and absolute time" do
        time = $jajp.parse("明日の10時")
        time.to_s.should === (now(nil, nil, nil, 10, 0, 0) + 1.day).to_s
      end
      it "tomorrow and absolute hh:mm:ss" do
        time = $jajp.parse("明日の10:20:30")
        time.to_s.should === (now(nil, nil, nil, 10, 20, 30) + 1.day).to_s
      end
      it "tomorrow and afternoon" do
        time = $jajp.parse("明日の午後5時")
        time.to_s.should === (now(nil, nil, nil, 17, 0, 0) + 1.day).to_s
      end
      it "tomorrow and noon" do
        time = $jajp.parse("明日の正午")
        time.to_s.should === (now(nil, nil, nil, 12, 0, 0) + 1.day).to_s
      end
      it "numeric day after and absolute time" do
        time = $jajp.parse("3日後の12時")
        time.to_s.should === (now(nil, nil, nil, 12, 0, 0) + 3.day).to_s
      end
      it "numeric day after and absolute time" do
        time = $jajp.parse("3日後の12時45分")
        time.to_s.should === (now(nil, nil, nil, 12, 45, 0) + 3.day).to_s
      end
      it "numeric day after and absolute hh:mm:ss" do
        time = $jajp.parse("3日後の12:45:55")
        time.to_s.should === (now(nil, nil, nil, 12, 45, 55) + 3.day).to_s
      end
      it "numeric day after and relative time" do
        time = $jajp.parse("3日12時間45分後")
        time.to_s.should === (now + 3.day + 12.hour + 45.minute).to_s
      end
      it "half time after" do
        time = $jajp.parse("1時間半後")
        time.to_s.should === (now + 1.5.hour).to_s
      end
      it "half minute after" do
        time = $jajp.parse("1分半後")
        time.to_s.should === (now + 1.5.minute).to_s
      end
      it "half hour and half minute after" do
        time = $jajp.parse("5時間半と1分半後")
        time.to_s.should === (now + 5.5.hour + 1.5.minute).to_s
      end
    end
  end
end
