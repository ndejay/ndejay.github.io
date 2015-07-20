module Jekyll

  module Filters

    def tags(obj)
      tag_links = obj['tags'].map do |tag|
        "<a href=\"/tag/#{tag}/\">##{tag}</a>"
      end
      tag_links.join(' ')
    end

  end

end
