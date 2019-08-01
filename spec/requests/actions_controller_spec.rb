require 'rails_helper'

describe TopicDefaultTag::ActionsController do
  before do
    Jobs.run_immediately!
  end

  it 'can list' do
    sign_in(Fabricate(:user))
    get "/topic-default-tag/list.json"
    expect(response.status).to eq(200)
  end
end
