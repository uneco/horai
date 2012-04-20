# coding: utf-8
# original: http://d.hatena.ne.jp/terazzo/20101226/1293313464

module JaNumber
  module Constants
    DIGITS  = "一二三四五六七八九"
    CLASSES = "十百千"
    UNITS   = "万億兆" # 増やしたければどーぞ
  end

  module JaNumberParser
    require 'rparsec'

    # <digit> ::= "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九"
    digits = 
      Constants::DIGITS.split(//).map.with_index {
      |c, i| RParsec::Parsers.char(c).map {|c| 1 + i}
    }.inject(RParsec::Parsers.zero) {|result, p| result.plus(p)}

    # <class> ::= "千" | "百" | "十"
    classes = 
      Constants::CLASSES.split(//).map.with_index {
      |c, i| RParsec::Parsers.char(c).map {|c| 10 ** (1 + i)}
    }.inject(RParsec::Parsers.zero) {|result, p| result.plus(p)}

    # <unit> ::= "万" | "億" | "兆"
    units = 
      Constants::UNITS.split(//).map.with_index {
      |c, i| RParsec::Parsers.char(c).map {|c| 10000 ** (1 + i)}
    }.inject(RParsec::Parsers.zero) {|result, p| result.plus(p)}

    # <singlet> ::= <digit>
    singlet = digits

    # <quadruplet> ::= <digit>? <class> <quadruplet>? | <singlet>
    quadruplet = nil
    lazy_quadruplet = RParsec::Parsers.lazy{quadruplet}
    quadruplet = 
      RParsec::Parsers.sequence(digits.optional(1), classes, lazy_quadruplet.optional(0)) {
      |digit_value, class_value, next_value| digit_value * class_value + next_value
    } | singlet

    # <number> ::= <quadruplet> <unit> <number>? | <quadruplet>
    number = nil
    lazy_number = RParsec::Parsers.lazy{number}
    number = 
      RParsec::Parsers.sequence(quadruplet, units, lazy_number.optional(0)) {
      |quadruplet_value, unit_value, next_value| quadruplet_value * unit_value + next_value
    } | quadruplet

    define_method :parse do |ja_number|
      number.parse ja_number
    end
    module_function :parse
  end
end
