module Jekyll

  class ArchiveIndexGenerator < Generator


    def generate(site)
      if site.layouts.key? site.config['archive_layout']
        site.pages << ArchiveIndex.new(site,
                                       site.source,
                                       './',
                                       site.config['archive_target'],
                                       { 'layout' => site.config['archive_layout'] })
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

      @data['title'] = 'Archive'
      @data['archive_tags'] = generate_archive_tags
      @data['archive_date'] = generate_archive_for_years
    end

    def generate_archive_tags
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

    def generate_archive_for_years
      years = site.posts.map { |p| p.url_placeholders[:year] }
      return [] unless years
      years.uniq.sort.map do |year|
        {
          'url'        => "/#{year}",
          'name'       => year,
          'months'     => generate_archive_for_months_in_year(year),
          'post_count' => site.posts.select { |p| p.url_placeholders[:year] == year }.length,
        }
      end
    end

    def generate_archive_for_months_in_year(year)
      posts_in_year = site.posts.select { |p| p.url_placeholders[:year] == year }
      months = posts_in_year.map { |p| p.url_placeholders[:month] }
      return [] unless months
      months.uniq.sort.map do |month|
        {
          'url'        => "/#{year}/#{month}",
          'name'       => Time.new(0, month).strftime("%B"),
          'post_count' => posts_in_year.select { |p| p.url_placeholders[:month] == month }.length,
        }
      end
    end

    def read_yaml(*) ; end

  end

end
