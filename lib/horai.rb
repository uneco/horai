# coding: utf-8

require 'hashie'
require 'active_support/time'

class Horai
  NORMALIZE_FROM = '０-９ａ-ｚＡ-Ｚ'
  NORMALIZE_TO   = '0-9a-zA-Z'

  DATETIME_UNIT_PATTERNS = {
    :year   => (/年|ねん/),
    :month  => (/月|がつ/),
    :day    => (/日|にち/),
    :minute => (/分|ふん|ぷん/),
    :hour   => (/時間?|じ(?:かん)?/),
    :second => (/秒|びょう/),
  }.freeze

  SPECIAL_PATTERNS = [{
    pattern: /一昨[々昨]日|さきおと[とつ]い|いっさくさくじつ/,
    filter: lambda {|date| date.day = DateTime.now.day - 3 },
  },{
    pattern: /一昨日|おと[とつ]い|いっさくじつ/,
    filter: lambda {|date| date.day = DateTime.now.day - 2 },
  },{
    pattern: /昨日|きのう|さくじつ/,
    filter: lambda {|date| date.day = DateTime.now.day - 1 },
  },{
    pattern: /今日|本日|きょう|ほんじつ/,
    filter: lambda {|date| date.day = DateTime.now.day },
  },{
    pattern: /明日|あした|みょうじつ/,
    filter: lambda {|date| date.day = DateTime.now.day + 1 },
  },{
    pattern: /明後日|あさって|みょうごにち/,
    filter: lambda {|date| date.day = DateTime.now.day + 2 },
  },{
    pattern: /明[々明]後日|しあさって|みょうみょうごにち/,
    filter: lambda {|date| date.day = DateTime.now.day + 3 },
  }, # -- end of day
  {  # -- start of month
    pattern: /[先前][々先前]{3}月|せんせんせんげつ/,
    filter: lambda {|date| date.month = DateTime.now.month - 3 },
  },{
    pattern: /[先前][々先前]月|せんせんげつ/,
    filter: lambda {|date| date.month = DateTime.now.month - 2 },
  },{
    pattern: /先月|前月|せんげつ/,
    filter: lambda {|date| date.month = DateTime.now.month - 1 },
  },{
    pattern: /今月|こんげつ/,
    filter: lambda {|date| date.month = DateTime.now.month },
  },{
    pattern: /来月|らいげつ/,
    filter: lambda {|date| date.month = DateTime.now.month + 1 },
  },{
    pattern: /明後日|あさって|みょうごにち/,
    filter: lambda {|date| date.month = DateTime.now.month + 2 },
  },{
    pattern: /明[々明]後日|しあさって|みょうみょうごにち/,
    filter: lambda {|date| date.month = DateTime.now.month + 3 },
  }, # -- end of month
  {  # -- start of year
    pattern: /一昨[々昨]年|さきおととし|いっさくさくねん/,
    filter: lambda {|date| date.year = DateTime.now.year - 3 },
  },{
    pattern: /一昨年|おととし|いっさくねん/,
    filter: lambda {|date| date.year = DateTime.now.year - 2 },
  },{
    pattern: /去年|昨年|きょねん|さくねん/,
    filter: lambda {|date| date.year = DateTime.now.year - 1 },
  },{
    pattern: /今年|本年|ことし|ほんねん/,
    filter: lambda {|date| date.year = DateTime.now.year },
  },{
    pattern: /来年|明年|らいねん|みょうねん/,
    filter: lambda {|date| date.year = DateTime.now.year + 1 },
  },{
    pattern: /再来年|明後年|さらいねん|みょうごねん/,
    filter: lambda {|date| date.year = DateTime.now.year + 2 },
  },{
    pattern: /明[々明]後年|みょうみょうごねん/,
    filter: lambda {|date| date.year = DateTime.now.year + 3 },
  }].map(&:freeze).freeze

  RELATIVE_KEYWORDS_PATTERN = /後|(?:[経た]っ|し)たら/

  def self.datetime_unit_patterns
    DATETIME_UNIT_PATTERNS
  end

  def self.special_patterns
    SPECIAL_PATTERNS
  end

  def self.relative_keyword_patterns
    RELATIVE_KEYWORD_PATTERNS
  end

  def self.date_default
    time = Time.now
    {
      year:   time.year,
      month:  time.month,
      day:    time.day,
      hour:   time.hour,
      minute: time.minute,
      second: time.second,
    }.freeze
  end

  def self.all_datetime_units_pattern
    /(\d+)(?:#{datetime_unit_patterns.values.join('|')})/
  end

  def self.relative_pattern
    /#{all_datetime_units_pattern}#{RELATIVE_KEYWORDS_PATTERN}/
  end

  def self.relative?(text)
    text =~ relative_pattern
  end

  def self.parse(text)
    relative = relative?(text)
    normalized = normalize(text)
    date = Hashie::Mash.new
    date_default.each_pair do |key, value|
      date[key] = parse_unit(normalized, key) || value
    end

    datetime = DateTime.new(date.year, date.month, date.day, date.hour, date.minute, date.second)

    if relative
      datetime = DateTime.now + datetime.to_i.seconds
    end

    return datetime
  end

  def self.parse_unit(text, unit)
    pattern = datetime_unit_patterns[unit]
    if pattern.nil?
      assumed = datetime_unit_patterns.keys.map(&:to_s)
      raise ArgumentError, "bad datetime unit \"#{unit.to_s}\" (assumed: #{assumed})"
    end
    return text =~ /(\d+)(?:#{pattern})/ ? $1.to_i : nil
  end

  def self.normalize(text)
    normalized = text
    normalized.tr!(NORMALIZE_FROM, NORMALIZE_TO)
    return normalized
  end
end
