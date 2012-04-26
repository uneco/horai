# coding: utf-8

require 'horai/parser'
require 'horai/parser/ja_jp'

module Horai
  def self.parse(text)
    @@instance ||= Horai::JaJP.new
    @@instance.parse(text)
  end
end
