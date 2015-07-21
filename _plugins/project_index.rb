module Jekyll

  class ProjectIndexGenerator < Generator

    priority :high

    def generate(site)
      config = site.config['project_index'] || {}

      project_index = ProjectIndex.new(site, site.source, './', config['target'])

      site.pages << project_index
    end

  end

  class ProjectIndex < Page

    def initialize(site, base, dir, name)
      @site   = site
      @base   = base
      @dir    = dir
      @config = site.config['project_index'] || {}
      @name   = "#{name.to_s.gsub(/[:\s]+/, '_')}.html"

      process(@name)
      read_yaml(File.join(base, '_layouts'), "#{@config['layout']}.html")

      @data['projects'] = projects
    end

    def projects
      YAML.load_file(@config['source'])['projects']
    end

  end

end

