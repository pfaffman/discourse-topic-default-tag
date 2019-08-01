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
  Category.register_custom_field_type('default_tag', :list)

  module ::TopicDefaultTag
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace TopicDefaultTag
    end
  end

  require_dependency "application_controller"
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

  Site.preloaded_category_custom_fields << 'default_tag' if Site.respond_to? :preloaded_category_custom_fields
  add_to_serializer(:basic_category, :default_tag) { object.custom_fields["default_tag"] }

  class ::Topic
    def has_default_tag?
      :topic_default_tag_enabled && self.category && self.category.custom_fields["default_tag"]
    end

    def topic_tag_default_tags
      puts "Gonna do some tags from #{self.category.custom_fields}!"

      tags = []
      if :topic_default_tag_enabled && self.category
        self.category.custom_fields["default_tag"].split("|").each do |tag_name|
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
    before_update do
      puts "WTF: #{self.custom_fields}"
      self.custom_fields['default_tag'] = self.custom_fields['default_tag'].join('|')
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
