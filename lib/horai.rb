# coding: utf-8

require 'hashie'
require 'active_support/time'

class Horai
  NORMALIZE_FROM = '０-９ａ-ｚＡ-Ｚ'
  NORMALIZE_TO   = '0-9a-zA-Z'

  RELATIVE_KEYWORDS_PATTERN = /後|(?:[経た]っ|し)たら/
  RELATIVE_PATTERN = /(\d+)(?:(?:年|ねん)|(?:月|がつ)|(?:日|にち)|(?:分|ふん|ぷん)|(?:時間?|じ(?:かん)?)|(?:秒|びょう))#{RELATIVE_KEYWORDS_PATTERN}/

  def self.relative_time_fixer(options = {})
    lambda do |matches, date|
      date += options[:year].year     if options[:year]
      date += options[:month].month   if options[:month]
      date += options[:day].day       if options[:day]
      date += options[:hour].hour     if options[:hour]
      date += options[:minute].minute if options[:minute]
      date += options[:second].second if options[:second]
      date
    end
  end

  def self.filter(pattern, type = :absolute, &block)
    @filters = [] if @filters.nil?
    @filters << { pattern: pattern, type => block }
  end

  def self.datetime_delta(date, method, value)
    (-date.method(method).call.method(method).call + value.to_i.method(method).call)
  end

  def self.register_filters
    # 時間 (絶対)
    filter /(\d+)時/, :absolute do |matches, date|
      date += datetime_delta(date, :hour,   matches[1])
      date += datetime_delta(date, :minute, 0)
      date += datetime_delta(date, :second, 0)
      date
    end

    filter /(\d+)分/, :absolute do |matches, date|
      date += datetime_delta(date, :minute, matches[1])
      date += datetime_delta(date, :second, 0)
      date
    end

    filter /(\d+)秒/, :absolute do |matches, date|
      date += datetime_delta(date, :second, matches[1])
      date
    end

    # 日 (絶対)
    filter /(\d+)日/, :absolute do |matches, date|
      date += datetime_delta(date, :day, matches[1].to_i)
      date
    end
    filter /一昨[々昨]日|さきおと[とつ]い|いっさくさくじつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: -3).call(matches, date)
    end
    filter /一昨日|おと[とつ]い|いっさくじつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: -2).call(matches, date)
    end
    filter /昨日|きのう|さくじつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: -1).call(matches, date)
    end
    filter /今日|本日|きょう|ほんじつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: 0).call(matches, date)
    end
    filter /明日|あした|みょうじつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: 1).call(matches, date)
    end
    filter /明後日|あさって|みょうごにち/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: 2).call(matches, date)
    end
    filter /明[々明]後日|しあさって|みょうみょうごにち/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0, day: 3).call(matches, date)
    end

    # 月 (絶対)
    filter /(\d+)月/, :absolute do |matches, date|
      date += datetime_delta(date, :month, matches[1].to_i)
    end
    filter /[先前][々先前]{3}月|せんせんせんげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: -3).call(matches, date)
    end
    filter /[先前][々先前]月|せんせんげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: -2).call(matches, date)
    end
    filter /先月|前月|せんげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: -1).call(matches, date)
    end
    filter /今月|こんげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 0).call(matches, date)
    end
    filter /来月|らいげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 1).call(matches, date)
    end
    filter /再来月|来[々来]月|さらいげつ|らいらいげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 2).call(matches, date)
    end
    filter /再[々再]来月|ささらいげつ/, :absolute do |matches, date|
      relative_time_fixer(year: 0, month: 3).call(matches, date)
    end

    # 年 (絶対)
    filter /(\d+)年/, :absolute do |matches, date|
      date + datetime_delta(date, :year, matches[1].to_i)
    end
    filter /一昨[々昨]年|さきおととし|いっさくさくねん/, :absolute do |matches, date|
      relative_time_fixer(year: -3).call(matches, date)
    end
    filter /一昨年|おととし|いっさくねん/, :absolute do |matches, date|
      relative_time_fixer(year: -2).call(matches, date)
    end
    filter /去年|昨年|きょねん|さくねん/, :absolute do |matches, date|
      relative_time_fixer(year: -1).call(matches, date)
    end
    filter /今年|本年|ことし|ほんねん/, :absolute do |matches, date|
      relative_time_fixer(year: 0).call(matches, date)
    end
    filter /来年|明年|らいねん|みょうねん/, :absolute do |matches, date|
      relative_time_fixer(year: 1).call(matches, date)
    end
    filter /再来年|明後年|さらいねん|みょうごねん/, :absolute do |matches, date|
      relative_time_fixer(year: 2).call(matches, date)
    end
    filter /明[々明]後年|みょうみょうごねん/, :absolute do |matches, date|
      relative_time_fixer(year: 3).call(matches, date)
    end

    # 時間 (相対)
    filter /(\d+)時/, :relative do |matches, date|
      date + matches[1].to_i.hour
    end
    filter /(\d+)分/, :relative do |matches, date|
      date + matches[1].to_i.minute
    end
    filter /(\d+)秒/, :relative do |matches, date|
      date + matches[1].to_i.second
    end
    
    # 日 (相対)
    filter /(\d+)日/, :relative do |matches, date|
      date + matches[1].to_i.day
    end

    # 月 (相対)
    filter /(\d+)月/, :relative do |matches, date|
      date + matches[1].to_i.month
    end

    # 年 (相対)
    filter /(\d+)年/, :relative do |matches, date|
      date + matches[1].to_i.year
    end

  end

  def self.now
    DateTime.now
  end
  
  def self.filters
    return @filters if @filters
    register_filters
    @filters
  end

  def self.relative_keyword_patterns
    RELATIVE_KEYWORD_PATTERNS
  end

  def self.date_default
    return @date_default if @date_default
    time = Time.new(1970)
    @date_default = Hashie::Mash.new({
      year:   time.year,
      month:  time.month,
      day:    time.day,
      hour:   time.hour,
      minute: time.min,
      second: time.sec,
    })
    return @date_default
  end

  def self.relative_pattern
    RELATIVE_PATTERN
  end

  def self.relative?(text)
    text =~ relative_pattern
  end

  def self.parse(text)
    normalized = normalize(text)
    mode = relative?(normalized) ? :relative : :absolute;
    date = DateTime.now

    self.filters.each do |filter|
      if (matches = normalized.match(filter[:pattern])) && filter[mode]
        `echo "#{date} - #{filter[:pattern]}" >> log`
        date = filter[mode].call(matches, date)
      end
    end
    `echo --------------- >> log`

    return date
  end

  def self.normalize(text)
    normalized = text
    normalized.tr!(NORMALIZE_FROM, NORMALIZE_TO)
    return normalized
  end
end
