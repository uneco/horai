# coding: utf-8

require 'horai/parser'

module Horai
  class Parser::JaJP < Parser
    NORMALIZE_FROM = '０-９ａ-ｚＡ-Ｚ：'.freeze
    NORMALIZE_TO   = '0-9a-zA-Z:'.freeze

    def register_filters
      dd = DATE_DELIMITER
      td = TIME_DELIMITER

      # 年 (絶対)
      filter /(\d+)年/, :absolute do |text, matches, date|
        year = year_normalize(matches[1].to_i, date)
        truncate_time(datetime_delta(date, year: year, month: 1, day: 1))
      end

      filter /1昨[々昨]年|さきおととし|いっさくさくねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 3.year, month: 1, day: 1))
      end

      filter /1昨年|おととし|いっさくねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 2.year, month: 1, day: 1))
      end

      filter /去年|昨年|きょねん|さくねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 1.year, month: 1, day: 1))
      end

      filter /今年|本年|ことし|ほんねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date, month: 1, day: 1))
      end

      filter /明[々明]後年|みょうみょうごねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 3.year, month: 1, day: 1))
      end

      filter /再来年|明後年|さらいねん|みょうごねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 2.year, month: 1, day: 1))
      end

      filter /来年|明年|らいねん|みょうねん/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 1.year, month: 1, day: 1))
      end

      # 月 (絶対)
      filter /(\d+)月/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date, month: matches[1].to_i, day: 1))
      end

      filter /[先前][々先前]{2}月|せんせんせんげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 3.month, day: 1))
      end

      filter /[先前][々先前]月|せんせんげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 2.month, day: 1))
      end

      filter /先月|前月|せんげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date - 1.month, day: 1))
      end

      filter /今月|こんげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date, day: 1))
      end

      filter /再[々再]来月|ささらいげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 3.month, day: 1))
      end

      filter /再来月|来[々来]月|さらいげつ|らいらいげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 2.month, day: 1))
      end

      filter /来月|らいげつ/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date + 1.month, day: 1))
      end

      # 日 (絶対)
      filter /(\d+)日/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date, day: matches[1]))
      end

      filter /1昨[々昨]日|さきおと[とつ]い|いっさくさくじつ/, :absolute do |text, matches, date|
        truncate_time(date - 3.day)
      end

      filter /1昨日|おと[とつ]い|いっさくじつ/, :absolute do |text, matches, date|
        truncate_time(date - 2.day)
      end

      filter /昨日|きのう|さくじつ/, :absolute do |text, matches, date|
        truncate_time(date - 1.day)
      end

      filter /今日|本日|きょう|ほんじつ/, :absolute do |text, matches, date|
        truncate_time(date)
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
      filter /(?<![\d\/-])(?<!\d)(\d{1,2})#{dd}(\d{1,2})(?!\d)(?!#{dd})/, :absolute do |text, matches, date|
        truncate_time(datetime_delta(date, month: matches[1], day: matches[2]))
      end

      # 年月日表現 (絶対)
      filter /(?<![\d\/-])(\d{2}|\d{4})#{dd}(\d{1,2})#{dd}(\d{1,2})(?!\d)(?!#{dd})/, :absolute do |text, matches, date|
        year = year_normalize(matches[1].to_i, date)
        truncate_time(datetime_delta(date, year: year, month: matches[2], day: matches[3]))
      end

      # 時分表現 (絶対)
      filter /(?<![\d:])(\d{1,2})#{td}(\d{2})(?!\d)(?!#{td})/, :absolute do |text, matches, date|
        datetime_delta(date, hour: matches[1], minute: matches[2], second: 0)
      end

      # 時分秒表現 (絶対)
      filter /(?<![\d:])(\d{1,2})#{td}(\d{2})#{td}(\d{2})(?!\d)(?!#{td})/, :absolute do |text, matches, date|
        datetime_delta(date, hour: matches[1], minute: matches[2], second: matches[3])
      end

      # 時間 (絶対)
      filter /正午/, :absolute do |text, matches, date|
        datetime_delta(date, hour: 12, minute: 0, second: 0)
      end

      filter /(\d+)時(半)?/, :absolute do |text, matches, date|
        hour = matches[1]
        minute = matches[2] ? 30 : 0
        date = datetime_delta(date, hour: hour, minute: minute, second: 0)
        date += 12.hour if date.hour <= 12 && text =~ AFTERNOON_PATTERN
        date
      end

      filter /(\d+)分(半)?/, :absolute do |text, matches, date|
        minute = matches[1]
        second = matches[2] ? 30 : 0
        datetime_delta(date, minute: minute, second: second)
      end

      filter /(\d+)秒/, :absolute do |text, matches, date|
        datetime_delta(date, second: matches[1])
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

    def relative_keyword_patterns
      (/(?<![明午])後(?![年月日])|(?:[経た]っ|し)たら/)
    end

    def relative?(text)
      unit = /(?:年|ねん)|(?:月|がつ)|(?:日|にち)|(?:分|ふん|ぷん)|(?:時間?|じ(?:かん)?)|(?:秒|びょう)/
      text =~ (/(\d+)#{unit}#{relative_keyword_patterns}/)
    end

    def normalize(text)
      normalized = text
      normalized.tr!(NORMALIZE_FROM, NORMALIZE_TO)
      digits = "一二三四五六七八九十百千"
      classes = "万億兆"
      normalized.gsub!(/[#{digits}][#{digits}#{classes}]*/) do |match|
        JaNumber::JaNumberParser::parse(match)
      end
      return normalized
    end
  end
end
