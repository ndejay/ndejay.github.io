module Jekyll

  class ArchiveIndexGenerator < Generator

    priority :high

    def generate(site)
      config = site.config['archive_index'] || {}

      archive_index = ArchiveIndex.new(site, site.source, './', config['target'])

      site.pages << archive_index
    end

  end

  class ArchiveIndex < Page

    def initialize(site, base, dir, name)
      @site   = site
      @base   = base
      @dir    = dir
      @config = site.config['archive_index'] || {}
      @name   = "#{name.to_s.gsub(/[:\s]+/, '_')}.html"

      process(@name)
      read_yaml(File.join(base, '_layouts'), "#{@config['layout']}.html")

      @data['archives_by_tag']  = generate_archives_by_tag
      @data['archives_by_date'] = generate_archives_by_year
    end

    def generate_archives_by_tag
      tags = site.posts.map { |p| p.tags }.inject(&:+)
      return [] unless tags

      tags.uniq.map do |tag|
        {
          'url'        => "/tag/#{tag}",
          'name'       => tag,
          'post_count' => site.posts.select { |p| p.tags.include? tag }.length,
        }
      end
    end

    def generate_archives_by_year
      years = site.posts.map { |p| p.url_placeholders[:year] }
      return [] unless years

      years.uniq.sort.map do |year|
        {
          'url'        => "/#{year}",
          'name'       => year,
          'months'     => generate_archives_by_months_in_year(year),
          'post_count' => site.posts.select { |p| p.url_placeholders[:year] == year }.length,
        }
      end
    end

    def generate_archives_by_months_in_year(year)
      posts_in_year = site.posts.select { |p| p.url_placeholders[:year] == year }
      months        = (1..12).map { |m| "%02d" % m }

      months.map do |month|
        post_count = posts_in_year.select { |p| p.url_placeholders[:month] == month }.length
        {
          'url'        => post_count > 0 ? "/#{year}/#{month}" : nil,
          'name'       => Time.new(0, month).strftime("%B"),
          'post_count' => post_count,
        }
      end
    end

  end

end
