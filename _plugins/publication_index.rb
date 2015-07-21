require 'bibtex'
require 'citeproc'
require 'csl/styles'

module Jekyll

  class PublicationIndexGenerator < Generator

    priority :high

    def generate(site)
      config = site.config['publication_index'] || {}

      publication_index = PublicationIndex.new(site, site.source, './', config['target'])

      site.pages << publication_index
    end

  end

  class PublicationIndex < Page

    def initialize(site, base, dir, name)
      @site   = site
      @base   = base
      @dir    = dir
      @config = site.config['publication_index'] || {}
      @name   = "#{name.to_s.gsub(/[:\s]+/, '_')}.html"

      process(@name)
      read_yaml(File.join(base, '_layouts'), "#{@config['layout']}.html")

      @cp = CiteProc::Processor.new style: 'apa', format: 'html'
      @cp.import BibTeX.open(@config['source']).to_citeproc

      @data['publications_by_year'] = publications_by_year
    end

    def years
      hash = Hash.new { |h, key| h[key] = [] }
      @cp.items.values.each do |e|
        hash[e.issued.year.to_s] << @cp.render(:bibliography, id: e.id)
      end
      hash.values.each { |ps| ps.sort!.reverse! }
      hash
    end

    def publications_by_year
      years.map do |year, pubs|
        {
          'name'              => year,
          'publications'      => pubs,
          'publication_count' => pubs.length,
        }
      end
    end

  end

end
