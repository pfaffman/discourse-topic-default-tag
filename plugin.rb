# name: TopicDefaultTag
# about:
# version: 0.1
# authors: pfaffman
# url: https://github.com/pfaffman


register_asset "stylesheets/common/topic-default-tag.scss"

enabled_site_setting :topic_default_tag_enabled

PLUGIN_NAME ||= "TopicDefaultTag".freeze

after_initialize do
  # see lib/plugin/instance.rb for the methods available in this context
  Category.register_custom_field_type('default_tags', :list)

  module ::TopicDefaultTag
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace TopicDefaultTag
    end
  end

  require_dependency "application_controller"
  class ::ApplicationController
  end
  require 'categories_controller'

  class ::CategoriesController
    before_action :default_tag_to_string, only: [:create, :update]

    # converts the Ember array into the string that Rails needs
    def default_tag_to_string
      puts "CDT: #{params}"

      return unless :topic_default_tag_enabled
      #Just check whether the field exists to avoid running into errors
      if request.params["custom_fields"]["default_tags"].is_a?(Array)
        request.params["custom_fields"]["default_tags"] = request.params["custom_fields"]["default_tags"].join('|')end
    end

  end

  class TopicDefaultTag::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def list
      render json: success_json
    end
  end

  TopicDefaultTag::Engine.routes.draw do
    get "/list" => "actions#list"
  end

  Discourse::Application.routes.append do
    mount ::TopicDefaultTag::Engine, at: "/topic-default-tag"
  end

  Site.preloaded_category_custom_fields << 'default_tags' if Site.respond_to? :preloaded_category_custom_fields
  add_to_serializer(:basic_category, :default_tags) { object.custom_fields["default_tags"] }


  class ::Topic
    def has_default_tags?
      :topic_default_tag_enabled && self.category && self.category.custom_fields["default_tags"]
    end

    def topic_tag_default_tags
      puts "Gonna do some tags from #{self.category.custom_fields}!"

      tags = []
      if :topic_default_tag_enabled && self.category && self.category.custom_fields["default_tags"]
        self.category.custom_fields["default_tags"].split("|").each do |tag_name|
          tags << Tag.find_by_name(tag_name)
        end
      end
      tags
    end

    after_create do
      self.topic_tag_default_tags.each do |tag|
        TopicTag.create(topic_id: self.id, tag_id: tag.id)
      end
    end
  end

  class ::Category
    before_commit do
      puts "WTF: #{self.custom_fields}"
      # if self.custom_fields['default_tags']
      #   self.custom_fields['default_tags'] = self.custom_fields['default_tags'].join('|')
      # end
      # self.custom_fields['default_tags'] += "|WTFINDEED"
    end
  end


  # DiscourseEvent.on(:post_created) do |post, opts, user|
  #   if post.post_number == 1
  #     topic = Topic.find(post.topic_id)
  #     # then add the tag
  #     topic.topic_tag_default_tags.each do |tag|
  #       TopicTag.create(topic_id: post.topic_id, tag_id: tag.id)
  #     end
  #   end
  # end


end
