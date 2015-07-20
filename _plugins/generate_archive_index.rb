module Jekyll

  class ArchiveIndexGenerator < Generator

    safe true

    def generate(site)
      if site.layouts.key? 'archive_index'
        site.pages << ArchiveIndex.new(site,
                                       site.source,
                                       './',
                                       'archive.html',
                                       { 'layout' => 'archive_index' })
      end
    end

  end

  class ArchiveIndex < Page

    def initialize(site, base, dir, name, data)
      @site = site
      @base = base
      @dir  = dir
      @name = name
      @data = data

      process(@name)

      @data['archive_tags'] = generate_archive_tags
      @data['archive_date'] = generate_archive_for_years
    end

    def generate_archive_tags
      tags = site.posts.map { |p| p.tags }.inject(&:+).uniq
      tags.map do |t| 
        {
          'url'  => "/tag/#{t}",
          'name' => t,
        }
      end
    end

    def generate_archive_for_years
      years = site.posts.map { |p| p.url_placeholders[:year] }.uniq.sort
      years.map do |y|
        {
          'url'    => "/#{y}",
          'name'   => y,
          'months' => generate_archive_for_months_in_year(y),
        }
      end
    end

    def generate_archive_for_months_in_year(year)
      posts_in_year = site.posts.select { |p| p.url_placeholders[:year] == year }
      months = posts_in_year.map { |p| p.url_placeholders[:month] }.uniq.sort
      months = months.map do |m|
        {
          'url'  => "/#{year}/#{m}",
          'name' => Time.new(0, m).strftime("%B"),
        }
      end
    end

    def read_yaml(*) ; end

  end

end
