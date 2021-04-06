# frozen_string_literal: true

require "test_helper"

class TranslatableTest < ViewComponent::TestCase
  def test_isolated_translations
    render_inline(TranslatableComponent.new)

    assert_selector("p.sidecar.shared-key", text: "Hello from sidecar translations!")
    assert_selector("p.sidecar.nested", text: "This is coming from the sidecar")
    assert_selector("p.sidecar.missing", text: "This is coming from Rails")

    assert_selector("p.helpers.shared-key", text: "Hello from Rails translations!")
    assert_selector("p.helpers.nested", text: "This is coming from Rails")

    assert_selector("p.global.shared-key", text: "Hello from Rails translations!")
    assert_selector("p.global.nested", text: "This is coming from Rails")
  end
end
