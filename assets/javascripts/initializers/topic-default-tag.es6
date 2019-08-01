import { withPluginApi } from "discourse/lib/plugin-api";

function initializeTopicDefaultTag(api) {
  
  // see app/assets/javascripts/discourse/lib/plugin-api
  // for the functions available via the api object
  
}

export default {
  name: "topic-default-tag",

  initialize() {
    withPluginApi("0.8.24", initializeTopicDefaultTag);
  }
};
