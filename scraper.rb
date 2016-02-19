#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'csv'
require 'json'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def json_from(url)
  JSON.parse(open(url).read, symbolize_names: true)
end

@POPONG_API = 'http://api.popong.com/v0.1/person/search?q=%s&api_key=test'

def find_popong(row)
  search = json_from(@POPONG_API % URI::encode(row[:name_kr])) 
  return {} if search[:items].count.zero?
  return search[:items].first if search[:items].count == 1

  if (addressed = search[:items].find_all { |i| i[:address] }).size == 1
    # warn "Found by address".cyan
    return addressed.first
  end

  first_unique = ->(json_sym, csv_sym) { 
    filtered = search[:items].find_all { |s| s[json_sym] = row[csv_sym] }
    return filtered.first if filtered.size == 1
  }

  return first_unique.(:name_en, :name_en) || first_unique.(:name_cn, :name_cn) || first_unique.(:birthday, :birth) 
  # || search[:items].sort_by { |i| i.reject { |k,v| v.to_s.empty? }.keys.count }.last
end


file = 'https://raw.githubusercontent.com/teampopong/data-assembly/master/assembly.csv'
raw = open(file).read

csv = CSV.parse(raw, headers: true, header_converters: :symbol)
csv.each do |row|
  json = find_popong(row) || begin
    warn "No match for #{row[:name_en]}".red
    {}
  end

  data = { 
    id: json[:id] || row[:name_en].downcase.tr(' ','-'),
    identifier__popong: json[:id],
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
    term: 19,
    source: "github.com/teampopong/data-for-rnd",

    wikipedia: json[:wiki],
    twitter: json[:twitter],
    facebook: json[:facebook],
  }

  ScraperWiki.save_sqlite([:id, :name, :term], data)
end


