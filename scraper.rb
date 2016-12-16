#!/bin/env ruby
# encoding: utf-8

require 'csv'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

file = 'https://raw.githubusercontent.com/teampopong/data-assembly/master/assembly.csv'
raw = open(file).read

csv = CSV.parse(raw, headers: true, header_converters: :symbol)
csv.each do |row|
  data = {
    id: row[:name_en].downcase.tr(' ','-'),
    name: row[:name_en].strip,
    name__ko: row[:name_kr],
    name__cn: row[:name_cn],
    birth_date: row[:birth],
    party: row[:party],
    area: row[:district],
    phone: row[:off_phone],
    homepage: row[:homepage],
    email: row[:email],
    photo: row[:photo],
    term: 20,
    source: 'https://github.com/teampopong/data-assembly',
  }

  ScraperWiki.save_sqlite([:id, :name, :term], data)
end
