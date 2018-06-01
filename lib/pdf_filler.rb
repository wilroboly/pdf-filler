require 'open-uri'
require 'pdf_forms'
require 'json'
require 'uri'

PATH_TO_PDFTK = ENV['PATH_TO_PDFTK'] || (File.exist?('/usr/local/bin/pdftk') ? '/usr/local/bin/pdftk' : '/usr/bin/pdftk')

class PdfFiller
  attr_reader :options
  #path to the pdftk binary
  #http://www.pdflabs.com/docs/install-pdftk/

  # regular expression to determine if fillable or non-fillable field
  # validates 1,2 and 1,2,3
  KEY_REGEX = /^(?<x>[0-9]+),(?<y>[0-9]+)(,(?<page>[0-9]+))?$/

  def initialize (options = {})
    @pdftk = PdfForms.new(PATH_TO_PDFTK, options)
  end

  def urldecode_keys hash
    output = Hash.new
    hash.each do |key, value|
      output[ URI.unescape( key ) ] = value
    end
    output
  end

  # Given a PDF an array of fields -> values
  # return a PDF with the given fields filled out
  def fill( url, data )
    source_pdf = open( URI.escape( url ) )
    filled_pdf = Tempfile.new( ['pdf', '.pdf'] )
    
    data = urldecode_keys data
    @pdftk.fill_form source_pdf.path, filled_pdf.path, data.find_all{ |key, value| !key[KEY_REGEX] }

    filled_pdf
  end
  
  # Given a PDF an array of fields -> values
  # return a PDF with the given fields filled out
  # TODO: This function is shit -- blast it away
  def fill_old( url, data )
    source_pdf = open( URI.escape( url ) )
    step_1_result = Tempfile.new( ['pdf', '.pdf'] )
    filled_pdf = Tempfile.new( ['pdf', '.pdf'] )

    data = urldecode_keys data
    #Fill fillable fields (step 1)
    @pdftk.fill_form source_pdf.path, step_1_result.path, data.find_all{ |key, value| !key[KEY_REGEX] }

    #Fill non-fillable fields (returning filled pdf)
    Prawn::Document.generate filled_pdf.path, :template => step_1_result.path do |pdf|
      pdf.font("Helvetica", :size=> 10)
      fields = data.find_all { |key, value| key[KEY_REGEX] }
      fields.each do |key, value|
        at = key.match(KEY_REGEX)
        pdf.go_to_page at[:page].to_i || 1
        pdf.draw_text value, :at => [ at[ :x ].to_i, at[:y].to_i ]
      end
    end

    filled_pdf
  end

  # Return a hash of all fields in a given PDF
  def get_fields(url)
    source_pdf = open( URI.escape( url ) )

    fields = @pdftk.get_fields(source_pdf.path).map do |field|
      result = {}
      result[:pdf_name] = field.name
      # result[:api_name] = field.name.downcase.gsub(' ', '').gsub('.', '')
      result[:type] = field.type.downcase
      result[:flags] = field.flags
      result[:justification] = field.justification
      if field.respond_to?(:options) && !field.options.nil?
        result[:options] = field.options
      end

      result
    end
    @output = fields
  end

end
