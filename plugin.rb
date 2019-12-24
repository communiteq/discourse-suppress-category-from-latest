# name: discourse-suppress-categories-from-latest
# about: Discourse Suppress Categories From Latest
# authors: richard@discoursehosting.com
# version: 1.0
# url: https://github.com/discoursehosting/discourse-suppress-categories-from-latest

enabled_site_setting :suppress_categories_from_latest_enabled

after_initialize do
  Category.register_custom_field_type('suppress_category_from_latest', :boolean)
  Site.preloaded_category_custom_fields << 'suppress_category_from_latest' if Site.respond_to? :preloaded_category_custom_fields
  
  class ::Category
    @@suppressed_ids = DistributedCache.new("suppressed_categories")
    
    after_save :reset_suppressed_categories_cache

    def self.suppressed_ids
      if @@suppressed_ids['suppressed'].nil?
        @@suppressed_ids['suppressed'] = CategoryCustomField
          .where(name: "suppress_category_from_latest", value: "true")
          .pluck(:category_id)
      end
      @@suppressed_ids['suppressed']
    end
    
    protected
    def reset_suppressed_categories_cache
      @@suppressed_ids['suppressed'] = CategoryCustomField
        .where(name: "suppress_category_from_latest", value: "true")
        .pluck(:category_id)
    end
  end

  
  if TopicQuery.respond_to?(:results_filter_callbacks)
    suppress_categories_from_latest = Proc.new do |list_type, result, user, options|

      if !SiteSetting.suppress_categories_from_latest_enabled || options[:category] || options[:tags]
        result
      else
        suppressed_ids = Category.suppressed_ids.join(',')
        if suppressed_ids.empty?
          result
        else
          result.where("topics.category_id not in (#{suppressed_ids})")
        end
      end
    end
    TopicQuery.results_filter_callbacks << suppress_categories_from_latest
  end
end

