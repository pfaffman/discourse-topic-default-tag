import { acceptance } from "helpers/qunit-helpers";

acceptance("TopicDefaultTag", { loggedIn: true });

test("TopicDefaultTag works", async assert => {
  await visit("/admin/plugins/topic-default-tag");

  assert.ok(false, "it shows the TopicDefaultTag button");
});
