module CachesAsIs

  module ClassMethods
    def caches_page_as_is(*actions)
      return unless perform_caching
      options = actions.extract_options!
      after_filter({:only => actions}.merge(options)) { |c| c.cache_page_as_is }
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def as_is_cache_path(path)
    ext = File.extname(path)
    if ext.blank?
      "#{path}.asis"
    else
      path.gsub(/\.#{ext}$/, '.asis')
    end
  end
  
  def cached_page_headers
    response.headers.map { |k,v| "#{k}: #{v}"}
  end
  
  def cache_page_as_is(content = nil, options = nil)
    return unless perform_caching && caching_allowed
    
    path = case options
    when Hash
      url_for(options.merge(:only_path => true, :skip_relative_url_root => true, :format => 'asis'))
    when String
      as_is_cache_path(options)
    else
      as_is_cache_path(request.path)
    end
    
    cache_page(cached_page_headers.join("\n") + "\n\n#{content || response.body}", path)
  end  
end

ActionController::Base.send(:include, CachesAsIs)