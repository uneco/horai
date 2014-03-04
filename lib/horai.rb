# coding: utf-8

require 'horai/parser'
require 'horai/parser/ja_jp'

module Horai
  def self.parse(text)
    Horai::Parser::JaJP.new.parse(text)
  end
end
