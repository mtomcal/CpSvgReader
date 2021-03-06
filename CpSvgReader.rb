#!/usr/bin/env ruby

require 'bio'
require 'thor'
require 'json'
require 'rasem'

class SvgInterface
  def output
    raise 'Output method not implemented'
  end
  def gene_line
    raise 'gene_line not implemented'
  end
  def format_range
    raise 'format_range not implemented'
  end
  def sequence
    raise 'sequence not implemented'
  end
  def join_gene
    raise 'join_gene not implemented'
  end
  def gene
    raise 'gene not implemented'
  end
end

class SvgRender < SvgInterface
  attr_accessor :scale
  attr_reader :img
  def initialize(scale=1)
    @scale = scale
    @img = Rasem::SVGImage.new(scale(140500), 2000)
  end
  def output
    @img.close
    File.open("chloroplast.svg", "w") do |f|
      f << @img.output
    end
  end
  def scale(value)
    return value.to_i/@scale
  end
  def gene_line
    @img.line scale(150), 1000, scale(140384), 1000 
  end
  def format_range(range)
    if (range.match(/^\d+\.\.\d+$/)) 
      return :complement => false, :join => false, :range => range.split(/\.\./)
    elsif (range.match(/complement\(\d/))
      matches = range.match(/\((\d+\.\.\d+)\)/).to_a
      return :complement => true, :join => false, :range => matches[1].split(/\.\./)
    elsif (range.match(/complement\(join\(\d/))
      matches = range.scan(/(\d+\.\.\d+)/)
      matches.flatten!
      ranges = []
      puts range + " " + matches.inspect
      matches.each do |m|
        m.split(/\.\./).each do |n|
          ranges << n
        end
      end
      return :complement => true, :join => true, :range => ranges
    elsif (range.match(/join\(\d/))
      matches = range.scan(/(\d+\.\.\d+)+/).to_a
      matches.flatten!
      ranges = []
      puts matches.inspect
      matches.each do |m|
        m.split(/\.\./).each do |n|
          ranges << n
        end
      end
      return :complement => false, :join => true, :range => ranges
    else
      return false
    end
  end
  def sequence(seq)
    @img.text scale(150), 1000, seq
  end

  def join_gene(range, name)
    complement = range[:complement]
    gene_y = 600 
    text_y = 550 
    if complement
      gene_y= 1000
      text_y= 1450
    end
    colors = [
      "red",
      "orange",
      "yellow",
      "green",
    ]
    rand = Random.rand(4) - 1
    length = range[:range].last.to_i - range[:range][0].to_i
    text_start = 150+range[:range][0].to_i + length/2
    index = 0
    while index < range[:range].size - 1
      start = range[:range][index].to_i
      stop = range[:range][index + 1].to_i
      exon_length = stop - start
      @img.rectangle scale(150+start), gene_y, scale(stop-start), 400, :stroke_width=>2, :fill=>colors[rand], :stroke=>"black"
      if complement
        @img.line scale(text_start), text_y, scale(range[:range][index].to_i+150+exon_length/2), text_y - 50
      else
        @img.line scale(range[:range][index].to_i+150+exon_length/2), text_y + 50, scale(text_start), text_y
      end
      index = index + 2 
    end
    @img.text scale(text_start), text_y, name
  end
  def gene(range, name)
    range = format_range(range)
    if not range
      return
    end
    if range[:join]
      join_gene(range, name)
      return
    end
    complement = range[:complement]
    start = range[:range][0].to_i
    stop = range[:range][1].to_i
    gene_y = 600 
    text_y = 550 
    if complement
      gene_y= 1000
      text_y= 1450
    end
    colors = [
      "red",
      "orange",
      "yellow",
      "green",
    ]
    @img.rectangle scale(150+start), gene_y, scale(stop-start), 400, :stroke_width=>2, :fill=>colors[Random.rand(4) - 1], :stroke=>"black"
    length = stop-start
    text_start = 150+start + length / 2
    @img.text scale(text_start), text_y, name
  end
end

class SvgJsonRender < SvgRender 
  attr_reader :svg_json
  def initialize(scale=1)
    @svg_json = {:elements => []}
  end
  def output
    File.open("chloroplast.json", "w") do |f|
      f << @svg_json.to_json
    end
  end
  def gene_line
    @svg_json[:elements] << {
      :line => {
        :x1 => 150,
        :y1 => 1000,
        :x2 => 140384,
        :y2 => 1000,
      }
    }
  end
  def sequence(seq)
    @svg_json[:elements] << {
      :text => {
        :x => 150,
        :y => 1000,
        :seq => seq,
      }
    }
  end
  def join_gene(range, name)
    complement = range[:complement]
    gene_y = 600 
    text_y = 550 
    if complement
      gene_y= 1000
      text_y= 1450
    end
    length = range[:range].last.to_i - range[:range][0].to_i
    text_start = 150+range[:range][0].to_i + length/2
    index = 0
    while index < range[:range].size - 1
      start = range[:range][index].to_i
      stop = range[:range][index + 1].to_i
      exon_length = stop - start
      @svg_json[:elements] << {
        :rectangle => {
          :x => 150+start,
          :y => gene_y,
          :width => stop-start,
          :height => 400
        }
      }
      if complement
        @svg_json[:elements] << {
          :line => {
            :x1 => text_start,
            :y1 => text_y,
            :x2 => range[:range][index].to_i+150+exon_length/2,
            :y2 => text_y - 50
          }
        }

      else
        @svg_json[:elements] << {
          :line => {
            :x1 => range[:range][index].to_i+150+exon_length/2,
            :y1 => text_y + 50,
            :x2 => text_start,
            :y2 => text_y
          }
        }
      end
      index = index + 2 
    end
    @svg_json[:elements] << {
      :text => {
        :x => text_start,
        :y => text_y,
        :seq => name,
      }
    }
  end
  def gene(range, name)
    range = format_range(range)
    if not range
      return
    end
    if range[:join]
      join_gene(range, name)
      return
    end
    complement = range[:complement]
    start = range[:range][0].to_i
    stop = range[:range][1].to_i
    gene_y = 600 
    text_y = 550 
    if complement
      gene_y= 1000
      text_y= 1450
    end
    @svg_json[:elements] << {
      :rectangle => {
        :x => 150+start,
        :y => gene_y,
        :width => stop-start,
        :height => 400
      }
    }
    length = stop-start
    text_start = 150+start + length / 2
    @svg_json[:elements] << {
      :text => {
        :x => text_start,
        :y => text_y,
        :seq => name,
      }
    }
  end
end



class CpSvgReader < Thor
  desc "query FILE", "Query Genbank Sequence Features"
  def query(file)
    #seq = IO.readlines("cp_dna.fasta")[1..-1].join("\n")
    #seq = seq.gsub(/\n/,"")
    ff = Bio::FlatFile.open(Bio::GenBank, file)
    svg = SvgJsonRender.new(40)
    svg.gene_line
    ff.each_entry do |gb|
      gb.features.each do |feature|
        hash = feature.assoc
        position = feature.position
        next unless hash['translation'] and hash['gene']
        #puts position + " " + hash['gene']
        svg.gene(position, hash['gene'])
      end
    end
    #svg.sequence(seq)
    svg.output
  end

  desc "svg", "render svg"
  def svg()
    svg = SvgRender.new
    svg.gene_line
    svg.output
  end
end

CpSvgReader.start(ARGV)
