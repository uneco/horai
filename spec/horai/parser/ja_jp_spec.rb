# coding: utf-8

require 'spec_helper'

describe Horai::JaJP do
  let(:jajp) { Horai::JaJP.new }

  context 'normalize' do
    it 'number' do
      expect(jajp.normalize('０１２３４')).to eql('01234')
    end
    it 'alphabet' do
      expect(jajp.normalize('ａｂｃｄｅ')).to eql('abcde')
      expect(jajp.normalize('ＡＢＣＤＥ')).to eql('ABCDE')
    end
    it 'numeric kanji' do
      expect(jajp.normalize('十五')).to eql('15')
      expect(jajp.normalize('十四万二千三百四十五')).to eql('142345')
      expect(jajp.normalize('百五十時間後')).to eql('150時間後')

      pending '漢数字パースライブラリがだめ'
      expect(jajp.normalize('1万秒')).to eql('10000秒')
    end
  end

  context 'invalid cases' do
    it 'not even one filter passed' do
      expect(jajp.parse('なにもなし')).to be_nil
    end
  end

  context 'parse absolute' do
    let(:sample_date) { DateTime.new(2012, 4, 11, 12, 45, 30, Rational(9, 24)) }
    let(:sample_text) { sample_date.strftime('%Y年%m月%d日の%H時%M分%S秒') }
    it 'year, month, day, hour, minute, second' do
      time = jajp.parse(sample_text)
      expect(time.to_s).to eql(sample_date.to_s)
    end
    it 'year' do
      time = jajp.parse('1999年')
      expect(time.to_s).to eql(now(1999, 1, 1, 0, 0, 0).to_s)
    end
    it 'month' do
      time = jajp.parse('1月')
      expect(time.to_s).to eql(now(nil, 1, 1, 0, 0, 0).to_s)
    end
    it 'half time' do
      time = jajp.parse('1時半')
      expect(time.to_s).to eql(now(nil, nil, nil, 1, 30, 0).to_s)
    end
    it 'half minute' do
      time = jajp.parse('1分半後')
      expect(time.to_s).to eql((now + 1.5.minute).to_s)
    end
    it 'half hour and minute' do
      time = jajp.parse('5時間半と1分半後')
      expect(time.to_s).to eql((now + 5.5.hour + 1.5.minute).to_s)
    end
    it 'at night' do
      time = jajp.parse('夜の8時に')
      expect(time.to_s).to eql((now(nil, nil, nil, 20, 0, 0)).to_s)
    end
    it 'at afternoon' do
      time = jajp.parse('午後一時に')
      expect(time.to_s).to eql((now(nil, nil, nil, 13, 0, 0)).to_s)
    end
    it 'at afternoon' do
      time = jajp.parse('PM1時に')
      expect(time.to_s).to eql((now(nil, nil, nil, 13, 0, 0)).to_s)
    end
    it 'at AM and contains *pm*' do
      time = jajp.parse('rpm 6時に')
      expect(time.to_s).to eql((now(nil, nil, nil, 6, 0, 0)).to_s)
    end
    it 'at noon' do
      time = jajp.parse('10日の正午に')
      expect(time.to_s).to eql((now(nil, nil, 10, 12, 0, 0)).to_s)
    end
    it 'at hh:mm' do
      time = jajp.parse('10:20')
      expect(time.to_s).to eql((now(nil, nil, nil, 10, 20, 0)).to_s)
    end
    it 'at hh:mm:ss' do
      time = jajp.parse('10:20:30')
      expect(time.to_s).to eql((now(nil, nil, nil, 10, 20, 30)).to_s)
    end
    it 'at MM/DD' do
      time = jajp.parse('10/20')
      expect(time.to_s).to eql(now(nil, 10, 20, 0, 0, 0).to_s)
    end
    it 'at YYYY/MM/DD' do
      time = jajp.parse('2000/10/20')
      expect(time.to_s).to eql(now(2000, 10, 20, 0, 0, 0).to_s)
    end
    it 'at YY/MM/DD' do
      time = jajp.parse('10/10/20')
      expect(time.to_s).to eql(now(2010, 10, 20, 0, 0, 0).to_s)
    end
    it 'at YYYY/MM/DD hh:mm:ss' do
      time = jajp.parse('2000/10/20 12:30:40')
      expect(time.to_s).to eql(now(2000, 10, 20, 12, 30, 40).to_s)
    end
    it 'at YY (near current year)' do
      time = jajp.parse('10年')
      expect(time.to_s).to eql(now(2010, 1, 1, 0, 0, 0).to_s)
    end
    it 'at YY (near feature)' do
      time = jajp.parse('30年')
      expect(time.to_s).to eql(now(2030, 1, 1, 0, 0, 0).to_s)
    end
    it 'at YY (not near feature)' do
      time = jajp.parse('90年')
      expect(time.to_s).to eql(now(1990, 1, 1, 0, 0, 0).to_s)
    end
  end

  context 'parse relative' do
    it 'check' do
      expect(jajp.relative?('10分後')).to be_true
      expect(jajp.relative?('10分経ったら')).to be_true
      expect(jajp.relative?('10分したら')).to be_true
      expect(jajp.relative?('10分')).to be_false
      expect(jajp.relative?('10時10分')).to be_false
    end
    context 'year' do
      it 'three years ago' do
        time = jajp.parse('一昨々年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) - 3.year).to_s)
      end
      it 'two years ago' do
        time = jajp.parse('一昨年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) - 2.year).to_s)
      end
      it 'last year' do
        time = jajp.parse('昨年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) - 1.year).to_s)
      end
      it 'this year' do
        time = jajp.parse('今年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0)).to_s)
      end
      it 'next year' do
        time = jajp.parse('来年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) + 1.year).to_s)
      end
      it 'year after next' do
        time = jajp.parse('再来年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) + 2.year).to_s)
      end
      it 'in three years time' do
        time = jajp.parse('明明後年')
        expect(time.to_s).to eql((now(nil, 1, 1, 0, 0, 0) + 3.year).to_s)
      end
    end

    context 'month' do
      it 'three monthes ago' do
        time = jajp.parse('先々々月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) - 3.month).to_s)
      end
      it 'two monthes ago' do
        time = jajp.parse('先々月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) - 2.month).to_s)
      end
      it 'last month' do
        time = jajp.parse('先月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) - 1.month).to_s)
      end
      it 'this month' do
        time = jajp.parse('今月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0)).to_s)
      end
      it 'next month' do
        time = jajp.parse('来月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) + 1.month).to_s)
      end
      it 'month after next' do
        time = jajp.parse('再来月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) + 2.month).to_s)
      end
      it 'in three month times' do
        time = jajp.parse('再々来月')
        expect(time.to_s).to eql((now(nil, nil, 1, 0, 0, 0) + 2.month).to_s)
      end
    end

    context 'day' do
      it 'thre days ago' do
        time = jajp.parse('一昨々日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) - 3.day).to_s)
      end
      it 'day before yesterday' do
        time = jajp.parse('一昨日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) - 2.day).to_s)
      end
      it 'yesterday' do
        time = jajp.parse('昨日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) - 1.day).to_s)
      end
      it 'today' do
        time = jajp.parse('今日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0)).to_s)
      end
      it 'tomorrow' do
        time = jajp.parse('明日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) + 1.day).to_s)
      end
      it 'day after tomorrow' do
        time = jajp.parse('明後日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) + 2.day).to_s)
      end
      it 'in three days time' do
        time = jajp.parse('明々後日')
        expect(time.to_s).to eql((now(nil, nil, nil, 0, 0, 0) + 3.day).to_s)
      end
    end

    context 'complex' do
      it 'numeric year after and absolute month' do
        time = jajp.parse('10年後の8月')
        expect(time.to_s).to eql((now(nil, 8, 1, 0, 0, 0) + 10.year).to_s)
      end
      it 'numeric minute after' do
        time = jajp.parse('10分後')
        expect(time.to_s).to eql((now + 10.minute).to_s)
      end
      it 'numeric day after' do
        time = jajp.parse('10日後')
        expect(time.to_s).to eql((now + 10.day).to_s)
      end
      it 'tomorrow and absolute time' do
        time = jajp.parse('明日の10時')
        expect(time.to_s).to eql((now(nil, nil, nil, 10, 0, 0) + 1.day).to_s)
      end
      it 'tomorrow and absolute hh:mm:ss' do
        time = jajp.parse('明日の10:20:30')
        expect(time.to_s).to eql((now(nil, nil, nil, 10, 20, 30) + 1.day).to_s)
      end
      it 'tomorrow and afternoon' do
        time = jajp.parse('明日の午後5時')
        expect(time.to_s).to eql((now(nil, nil, nil, 17, 0, 0) + 1.day).to_s)
      end
      it 'tomorrow and noon' do
        time = jajp.parse('明日の正午')
        expect(time.to_s).to eql((now(nil, nil, nil, 12, 0, 0) + 1.day).to_s)
      end
      it 'numeric day after and absolute time' do
        time = jajp.parse('3日後の12時')
        expect(time.to_s).to eql((now(nil, nil, nil, 12, 0, 0) + 3.day).to_s)
      end
      it 'numeric day after and absolute time' do
        time = jajp.parse('3日後の12時45分')
        expect(time.to_s).to eql((now(nil, nil, nil, 12, 45, 0) + 3.day).to_s)
      end
      it 'numeric day after and absolute hh:mm:ss' do
        time = jajp.parse('3日後の12:45:55')
        expect(time.to_s).to eql((now(nil, nil, nil, 12, 45, 55) + 3.day).to_s)
      end
      it 'numeric day after and relative time' do
        time = jajp.parse('3日12時間45分後')
        expect(time.to_s).to eql((now + 3.day + 12.hour + 45.minute).to_s)
      end
      it 'half time after' do
        time = jajp.parse('1時間半後')
        expect(time.to_s).to eql((now + 1.5.hour).to_s)
      end
      it 'half minute after' do
        time = jajp.parse('1分半後')
        expect(time.to_s).to eql((now + 1.5.minute).to_s)
      end
      it 'half hour and half minute after' do
        time = jajp.parse('5時間半と1分半後')
        expect(time.to_s).to eql((now + 5.5.hour + 1.5.minute).to_s)
      end
    end
  end
end
