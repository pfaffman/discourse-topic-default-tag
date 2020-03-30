# frozen_string_literal: true
require 'rails_helper'

describe TopicCreator do
  fab!(:newuser)      { Fabricate(:user, trust_level: TrustLevel[0]) }
  fab!(:user)      { Fabricate(:user, trust_level: TrustLevel[2]) }
  fab!(:user2)      { Fabricate(:user, trust_level: TrustLevel[2]) }
  fab!(:admin)     { Fabricate(:admin) }
  fab!(:moderator)     { Fabricate(:moderator) }

  let(:valid_attrs) { Fabricate.attributes_for(:topic) }
  let(:pm_valid_attrs)  { { raw: 'this is a new post', title: 'this is a new title', archetype: Archetype.private_message, target_usernames: moderator.username } }

    context 'tags' do
      fab!(:tag1) { Fabricate(:tag, name: "fun") }
      fab!(:tag2) { Fabricate(:tag, name: "fun2") }

      before do
        SiteSetting.tagging_enabled = true
      end

      it "can create a topic in a category with a default tag" do
        create_staff_tags(['alpha'])
        category = Fabricate(:category, name: "Neil's Blog loves tags")
        CategoryCustomField.create(category_id: category.id, name: 'default_tags', value: 'alpha')
        topic = TopicCreator.create(user, Guardian.new(user), valid_attrs.merge(category: category.id))
        expect(topic).to be_valid
        expect(topic.category).to eq(category)
        expect(topic.tags.first.name).to eq('alpha')
      end

      it "can create a topic in a category without a default tag" do
        create_staff_tags(['alpha'])
        category = Fabricate(:category, name: "Neil's Blog hates tags")
        topic = TopicCreator.create(user, Guardian.new(user), valid_attrs.merge(category: category.id))
        expect(topic).to be_valid
        expect(topic.category).to eq(category)
        expect(topic.tags.length).to eq(0)
      end
    end

  context 'personal message' do
    it "should be possible for a trusted user to send private message" do
      SiteSetting.min_trust_to_send_messages = TrustLevel[2]
      SiteSetting.enable_personal_messages = true
      expect(TopicCreator.create(user2, Guardian.new(user2), pm_valid_attrs)).to be_valid
    end

  end
end
