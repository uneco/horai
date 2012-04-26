# coding: utf-8

require 'active_support/time'
require "ja_number"

module Horai
  class Parser
    DATE_DELIMITER = (/[\/-]/)
    TIME_DELIMITER = (/[:]/)

    AFTERNOON_PATTERN = (/午後|ごご|夜|よる|(?<![a-z])pm(?![a-z])/i)

    def self.parse(text)
      @@instance ||= self.new
      @@instance.parse(text)
    end

    def filter(pattern, type = :absolute, &block)
      @filters = [] if @filters.nil?
      @filters << { pattern: pattern, type => block }
    end

    def truncate_time(date)
      datetime_delta(date, hour: 0, minute: 0, second: 0)
    end

    def datetime_delta(date, methods = {})
      date = date.dup
      methods.each_pair do |key, value|
        converter = 1.0.respond_to?(key) ? :to_f : :to_i;
        date += value.send(converter).send(key) - date.send(key).send(key)
      end
      date
    end

    def register_filters
    end

    def now
      @now ||= DateTime.now
      @now.dup
    end

    def filters
      return @filters if @filters
      register_filters
      @filters
    end

    def relative_keyword_patterns
      /after/
    end

    def relative?(text)
      text =~ relative_keyword_patterns
    end

    def normalize(text)
      text
    end

    def parse(text)
      normalized = normalize(text)
      contexts = (normalized + "$").split(relative_keyword_patterns)
      date = now

      filtered = false

      contexts.each_with_index do |context, index|
        if contexts.size >= 2 && index + 1 != contexts.size
          mode = :relative
        else
          mode = :absolute
        end

        filters.each do |filter|
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

    def year_normalize(year)
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
end
