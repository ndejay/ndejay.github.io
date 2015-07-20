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

    def initialize(site, base, dir, name, data = {})
      self.content = data.delete('content') || ''
      self.data    = data

      super(site, base, dir[-1, 1] == '/' ? dir : '/' + dir, name)
    end

    def read_yaml(*) ; end

  end

end
