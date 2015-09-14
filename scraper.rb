#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'open-uri'
require 'pry'
require 'scraperwiki'
require 'csv'

file = 'https://raw.githubusercontent.com/teampopong/data-for-rnd/master/assembly.csv'
raw = open(file).read

csv = CSV.parse(raw, headers: true, header_converters: :symbol)
csv.each do |row|
  data = { 
    id: row[:person_id],
    identifier__popong: row[:person_id],
    name: row[:name_en].strip,
    name__ko: row[:name],
    name__cn: row[:name__cn],
    birth_date: row[:birth],
    party: row[:party],
    area: row[:district],
    phone: row[:off_phone],
    homepage: row[:homepage],
    email: row[:email],
    photo: 'http://www.assembly.go.kr/photo/%s.jpg)' % row[:photo_id],
    term: 19,
    source: "github.com/teampopong/data-for-rnd",
  }
  ScraperWiki.save_sqlite([:id, :term], data)
end


