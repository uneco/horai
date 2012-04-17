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

  RELATIVE_KEYWORDS_PATTERN = /後|(?:[経た]っ|し)たら/

  def self.datetime_unit_patterns
    DATETIME_UNIT_PATTERNS
  end

  def self.relative_time_fixer(options = {})
    lambda do |date|
      date.year   = DateTime.now.year   + options[:year]   if options[:year]
      date.month  = DateTime.now.month  + options[:month]  if options[:month]
      date.day    = DateTime.now.day    + options[:day]    if options[:day]
      date.hour   = DateTime.now.hour   + options[:hour]   if options[:hour]
      date.minute = DateTime.now.minute + options[:minute] if options[:minute]
      date.second = DateTime.now.second + options[:second] if options[:second]
    end
  end

  def self.special_patterns
    return @special_patterns if @special_patterns
    [{
      pattern: /一昨[々昨]日|さきおと[とつ]い|いっさくさくじつ/,
      filter: relative_time_fixer(year: 0, month: 0, day: -3)
    },{
      pattern: /一昨日|おと[とつ]い|いっさくじつ/,
      filter: relative_time_fixer(year: 0, month: 0, day: -2)
    },{
      pattern: /昨日|きのう|さくじつ/,
      filter: relative_time_fixer(year: 0, month: 0, day: -1)
    },{
      pattern: /今日|本日|きょう|ほんじつ/,
      filter: relative_time_fixer(year: 0, month: 0, day: 0)
    },{
      pattern: /明日|あした|みょうじつ/,
      filter: relative_time_fixer(year: 0, month: 0, day: 1)
    },{
      pattern: /明後日|あさって|みょうごにち/,
      filter: relative_time_fixer(year: 0, month: 0, day: 2)
    },{
      pattern: /明[々明]後日|しあさって|みょうみょうごにち/,
      filter: relative_time_fixer(year: 0, month: 0, day: 3)
    }, # -- end of day
    {  # -- start of month
      pattern: /[先前][々先前]{3}月|せんせんせんげつ/,
      filter: relative_time_fixer(year: 0, month: -3)
    },{
      pattern: /[先前][々先前]月|せんせんげつ/,
      filter: relative_time_fixer(year: 0, month: -2)
    },{
      pattern: /先月|前月|せんげつ/,
      filter: relative_time_fixer(year: 0, month: -1)
    },{
      pattern: /今月|こんげつ/,
      filter: relative_time_fixer(year: 0, month: 0)
    },{
      pattern: /来月|らいげつ/,
      filter: relative_time_fixer(year: 0, month: 1)
    },{
      pattern: /再来月|来[々来]月|さらいげつ|らいらいげつ/,
      filter: relative_time_fixer(year: 0, month: 2)
    },{
      pattern: /再[々再]来月|ささらいげつ/,
      filter: relative_time_fixer(year: 0, month: 3)
    }, # -- end of month
    {  # -- start of year
      pattern: /一昨[々昨]年|さきおととし|いっさくさくねん/,
      filter: relative_time_fixer(year: -3)
    },{
      pattern: /一昨年|おととし|いっさくねん/,
      filter: relative_time_fixer(year: -2)
    },{
      pattern: /去年|昨年|きょねん|さくねん/,
      filter: relative_time_fixer(year: -1)
    },{
      pattern: /今年|本年|ことし|ほんねん/,
      filter: relative_time_fixer(year: 0)
    },{
      pattern: /来年|明年|らいねん|みょうねん/,
      filter: relative_time_fixer(year: 1)
    },{
      pattern: /再来年|明後年|さらいねん|みょうごねん/,
      filter: relative_time_fixer(year: 2)
    },{
      pattern: /明[々明]後年|みょうみょうごねん/,
      filter: relative_time_fixer(year: 3)
    }].map(&:freeze).freeze
  end

  def self.relative_keyword_patterns
    RELATIVE_KEYWORD_PATTERNS
  end

  def self.date_default
    time = Time.new(1970)
    {
      year:   time.year,
      month:  time.month,
      day:    time.day,
      hour:   time.hour,
      minute: time.min,
      second: time.sec,
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

    special_patterns.each do |pattern|
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
