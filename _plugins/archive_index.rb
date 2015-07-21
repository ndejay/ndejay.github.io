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
      @posts  = site.posts

      process(@name)
      read_yaml(File.join(base, '_layouts'), "#{@config['layout']}.html")

      @data['archives_by_tag']  = archives_by_tag
      @data['archives_by_date'] = archives_by_year
    end

    # Construct a Hash of Posts indexed by the specified Post attribute.
    #
    # post_attr - The String name of the Post attribute.
    #
    # Examples
    #
    #   post_attr_hash('categories')
    #   # => { 'tech' => [<Post A>, <Post B>],
    #   #      'ruby' => [<Post B>] }
    #
    # Returns the Hash: { attr => posts } where
    #   attr  - One of the values for the requested attribute.
    #   posts - The Array of Posts with the given attr value.
    #
    # Taken from jekyll/jekyll (Copyright (c) 2014 Tom Preston-Werner under the MIT).
    def post_attr_hash(post_attr)
      # Build a hash map based on the specified post attribute ( post attr =>
      # array of posts ) then sort each array in reverse order.
      hash = Hash.new { |h, key| h[key] = [] }
      @posts.each { |p| p.send(post_attr.to_sym).each { |t| hash[t] << p } }
      hash.values.each { |posts| posts.sort!.reverse! }
      hash
    end

    def post_date_attr_hash(post_date_attr, posts = {})
      posts = @posts if posts.empty?
      hash = Hash.new { |h, key| h[key] = [] }
      posts.each { |p| hash[p.date.strftime(post_date_attr)] << p }
      hash.values.each { |ps| ps.sort!.reverse! }
      hash
    end

    def tags
      post_attr_hash('tags')
    end

    def years
      # Create entries only for months with posts.
      post_date_attr_hash("%Y")
    end

    def months(year)
      # Create entries only for days with months.
      post_date_attr_hash("%m", years[year])
    end

    def months_filled(year)
      # Create entries even for postless months.
      hash = Hash.new { |h, key| h[key] = [] }
      (1..12).map { |m| hash["%02d" % m] }
      hash.merge(months(year))
    end

    def days(year, month)
      # Create entries only for days with posts.
      post_date_attr_hash("%d", months(year)[month])
    end

    def archives_by_tag
      tags.map do |tag, ps|
        {
          'url'        => "/tag/#{tag}",
          'name'       => tag,
          'post_count' => ps.length,
        }
      end
    end

    def archives_by_year
      years.map do |year, ps|
        {
          'url'        => "/#{year}",
          'name'       => year,
          'months'     => archives_by_months_in_year(year),
          'post_count' => ps.length,
        }
      end
    end

    def archives_by_months_in_year(year)
      months = if @config['fill']['months']
                 method(:months_filled)
               else
                 method(:months)
               end

      months.call(year).map do |month, ps|
        filled_only = {
          'url'        => "/#{year}/#{month}",
          'days'       => archives_by_days_in_month(year, month),
        }

        hash = {
          'name'       => Time.new(0, month).strftime("%B"),
          'post_count' => ps.length,
        }

        hash.merge!(filled_only) if ps.length > 0
        hash
      end
    end

    def archives_by_days_in_month(year, month)
      days(year, month).map do |day, ps|
        {
          'url'        => "/#{year}/#{month}/#{day}",
          'name'       => day,
          'posts'      => ps,
          'post_count' => ps.length,
        }
      end
    end

  end

end
