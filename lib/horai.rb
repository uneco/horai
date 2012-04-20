# coding: utf-8

require 'active_support/time'
require "ja_number"

class Horai
  NORMALIZE_FROM = '０-９ａ-ｚＡ-Ｚ：'
  NORMALIZE_TO   = '0-9a-zA-Z:'

  DATE_DELIMITER = (/[\/-]/)
  TIME_DELIMITER = (/[:]/)

  AFTERNOON_PATTERN = (/午後|ごご|夜|よる|(?<![a-z])pm(?![a-z])/i)
  RELATIVE_KEYWORDS_PATTERN = (/(?<![明午])後(?![年月日])|(?:[経た]っ|し)たら/)
  RELATIVE_PATTERN = (/(\d+)(?:(?:年|ねん)|(?:月|がつ)|(?:日|にち)|(?:分|ふん|ぷん)|(?:時間?|じ(?:かん)?)|(?:秒|びょう))#{RELATIVE_KEYWORDS_PATTERN}/)

  def self.filter(pattern, type = :absolute, &block)
    @filters = [] if @filters.nil?
    @filters << { pattern: pattern, type => block }
  end

  def self.truncate_time(date)
    date = date.dup
    date += datetime_delta(date, :hour,   0)
    date += datetime_delta(date, :minute, 0)
    date += datetime_delta(date, :second, 0)
    date
  end

  def self.datetime_delta(date, method, value)
    date = date.dup
    if 1.0.respond_to? method
      return (-date.method(method).call.method(method).call + value.to_f.method(method).call)
    else
      return (-date.method(method).call.method(method).call + value.to_i.method(method).call)
    end
  end

  def self.register_filters
    dd = DATE_DELIMITER
    td = TIME_DELIMITER

    # 年 (絶対)
    filter /(\d+)年/, :absolute do |text, matches, date|
      year = year_normalize(matches[1].to_i)
      date + datetime_delta(date, :year, year)
    end

    filter /一昨[々昨]年|さきおととし|いっさくさくねん/, :absolute do |text, matches, date|
      date - 3.year
    end

    filter /一昨年|おととし|いっさくねん/, :absolute do |text, matches, date|
      date - 2.year
    end

    filter /去年|昨年|きょねん|さくねん/, :absolute do |text, matches, date|
      date - 1.year
    end

    filter /今年|本年|ことし|ほんねん/, :absolute do |text, matches, date|
    end

    filter /来年|明年|らいねん|みょうねん/, :absolute do |text, matches, date|
      truncate_time(date + 1.year)
    end

    filter /再来年|明後年|さらいねん|みょうごねん/, :absolute do |text, matches, date|
      truncate_time(date + 2.year)
    end

    filter /明[々明]後年|みょうみょうごねん/, :absolute do |text, matches, date|
      truncate_time(date + 3.year)
    end

    # 月 (絶対)
    filter /(\d+)月/, :absolute do |text, matches, date|
      date += datetime_delta(date, :month, matches[1].to_i)
    end

    filter /[先前][々先前]{3}月|せんせんせんげつ/, :absolute do |text, matches, date|
      date - 3.month
    end

    filter /[先前][々先前]月|せんせんげつ/, :absolute do |text, matches, date|
      date - 2.month
    end

    filter /先月|前月|せんげつ/, :absolute do |text, matches, date|
      date - 1.month
    end

    filter /今月|こんげつ/, :absolute do |text, matches, date|
    end

    filter /来月|らいげつ/, :absolute do |text, matches, date|
      truncate_time(date + 1.month)
    end

    filter /再来月|来[々来]月|さらいげつ|らいらいげつ/, :absolute do |text, matches, date|
      truncate_time(date + 2.month)
    end

    filter /再[々再]来月|ささらいげつ/, :absolute do |text, matches, date|
      truncate_time(date + 3.month)
    end

    # 日 (絶対)
    filter /(\d+)日/, :absolute do |text, matches, date|
      date += datetime_delta(date, :day, matches[1])
      date  = truncate_time(date)
      date
    end

    filter /一昨[々昨]日|さきおと[とつ]い|いっさくさくじつ/, :absolute do |text, matches, date|
      truncate_time(date - 3.day)
    end

    filter /一昨日|おと[とつ]い|いっさくじつ/, :absolute do |text, matches, date|
      truncate_time(date - 2.day)
    end

    filter /昨日|きのう|さくじつ/, :absolute do |text, matches, date|
      truncate_time(date - 1.day)
    end

    filter /明日|あした|みょうじつ/, :absolute do |text, matches, date|
      truncate_time(date + 1.day)
    end

    filter /明後日|あさって|みょうごにち/, :absolute do |text, matches, date|
      truncate_time(date + 2.day)
    end

    filter /明[々明]後日|しあさって|みょうみょうごにち/, :absolute do |text, matches, date|
      truncate_time(date + 3.day)
    end

    # 月日表現 (絶対)
    filter /(?<![\d\/-])(?<!\d)(\d{1,2})#{dd}(\d{1,2})(?!#{dd})/, :absolute do |text, matches, date|
      date += datetime_delta(date, :month,  matches[1])
      date += datetime_delta(date, :day,    matches[2])
      date  = truncate_time(date)
      date
    end

    # 年月日表現 (絶対)
    filter /(?<![\d\/-])(\d{1,2}|\d{4})#{dd}(\d{1,2})#{dd}(\d{1,2})(?!#{dd})/, :absolute do |text, matches, date|
      year = year_normalize(matches[1].to_i)

      date += datetime_delta(date, :year,   year)
      date += datetime_delta(date, :month,  matches[2])
      date += datetime_delta(date, :day,    matches[3])
      date  = truncate_time(date)
      date
    end

    # 時分表現 (絶対)
    filter /(?<![\d:])(\d{1,2})#{td}(\d{2})(?!#{td})/, :absolute do |text, matches, date|
      date += datetime_delta(date, :hour,   matches[1])
      date += datetime_delta(date, :minute, matches[2])
      date += datetime_delta(date, :second, 0)
      date
    end

    # 時分秒表現 (絶対)
    filter /(?<![\d:])(\d{1,2})#{td}(\d{2})#{td}(\d{2})(?!#{td})/, :absolute do |text, matches, date|
      date += datetime_delta(date, :hour,   matches[1])
      date += datetime_delta(date, :minute, matches[2])
      date += datetime_delta(date, :second, matches[3])
      date
    end

    # 時間 (絶対)
    filter /正午/, :absolute do |text, matches, date|
      date += datetime_delta(date, :hour,   12)
      date += datetime_delta(date, :minute, 0)
      date += datetime_delta(date, :second, 0)
      date
    end

    filter /(\d+)時(半)?/, :absolute do |text, matches, date|
      date += datetime_delta(date, :hour,   matches[1])
      date += datetime_delta(date, :minute, matches[2] ? 30 : 0)
      date += datetime_delta(date, :second, 0)
      if date.hour <= 12 && text =~ AFTERNOON_PATTERN
        date += 12.hour
      end
      date
    end

    filter /(\d+)分(半)?/, :absolute do |text, matches, date|
      date += datetime_delta(date, :minute, matches[1])
      date += datetime_delta(date, :second, matches[2] ? 30 : 0)
      date
    end

    filter /(\d+)秒/, :absolute do |text, matches, date|
      date + datetime_delta(date, :second, matches[1])
    end

    # 年 (相対)
    filter /(\d+)年/, :relative do |text, matches, date|
      date + matches[1].to_i.year
    end

    # 月 (相対)
    filter /(\d+)月/, :relative do |text, matches, date|
      date + matches[1].to_i.month
    end

    # 日 (相対)
    filter /(\d+)日/, :relative do |text, matches, date|
      date + matches[1].to_f.day
    end

    # 時間 (相対)
    filter /(\d+)時間(半)?/, :relative do |text, matches, date|
      date + matches[1].to_f.hour + (matches[2] ? 0.5 : 0.0).hour
    end

    filter /(\d+)分(半)?/, :relative do |text, matches, date|
      date + matches[1].to_f.minute + (matches[2] ? 0.5 : 0.0).minute
    end

    filter /(\d+)秒/, :relative do |text, matches, date|
      date + matches[1].to_f.second
    end

  end

  def self.now
    @now ||= DateTime.now
    @now.dup
  end

  def self.filters
    return @filters if @filters
    register_filters
    @filters
  end

  def self.relative?(text)
    text =~ RELATIVE_PATTERN
  end

  def self.parse(text)
    normalized = normalize(text)
    contexts = (normalized + "$").split(RELATIVE_KEYWORDS_PATTERN)
    date = now

    filtered = false

    contexts.each_with_index do |context, index|
      if contexts.size >= 2 && index + 1 != contexts.size
        mode = :relative
      else
        mode = :absolute
      end

      self.filters.each do |filter|
        if (matches = context.match(filter[:pattern])) && filter[mode]
          date = filter[mode].call(normalized, matches, date)
          filtered = true unless filtered
        end
      end
    end

    @now = nil

    return nil unless filtered
    return date
  end

  def self.normalize(text)
    normalized = text
    normalized.tr!(NORMALIZE_FROM, NORMALIZE_TO)
    digits = "一二三四五六七八九十百千"
    classes = "万億兆"
    normalized.gsub!(/[#{digits}][#{digits}#{classes}]*/) do |match|
      JaNumber::JaNumberParser::parse(match)
    end
    return normalized
  end

  def self.year_normalize(year)
    if year < 100
      year_xx = (now.year / 100).to_i
      if (year_xx - year).abs < 50
        year += year_xx * 100
      else
        year += (year_xx - 1) * 100
      end
    end
    year
  end
end
