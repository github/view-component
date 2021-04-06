# frozen_string_literal: true

require "test_helper"
require "view_component/css_module"

class CSSModuleTest < Minitest::Test
  def test_it_returns_mappings
    mappings =
      ViewComponent::CSSModule.rewrite(
        "item",
        ".title { color: red; }"
      )[:mappings]

    assert_equal mappings, { "title" => "item_447b7_title" }
  end

  def test_it_autoprefixes
    before_css = ".title { display: flex; }"
    after_css = ".item_447b7_title {\n display: -webkit-box;\n display: -webkit-flex;\n display: -ms-flexbox;\n display: flex }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_class_selectors
    before_css = ".title { color: red; }"
    after_css = ".item_447b7_title {\n  color: red; }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_id_selectors
    before_css = "#container {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "#item_447b7_container {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_nested_selectors
    before_css = "#container .title {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "#item_447b7_container .item_447b7_title {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_comma_selectors
    before_css = "#container .title, #container .subtitle {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "#item_447b7_container .item_447b7_title, #item_447b7_container .item_447b7_subtitle {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end


  def test_it_doesnt_rewrite_bare_element_selectors
    before_css = "span {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "span {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_nested_bare_element_selectors
    before_css = "#container h1 {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "#item_447b7_container h1 {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)

    before_css = "h1#container {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = "h1#item_447b7_container {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_immediate_child_selectors
    before_css = ".parent > .child {\n  background: rbga(255, 255, 255, 0.8);\n}"
    after_css = ".item_447b7_parent > .item_447b7_child {\n  background: rbga(255, 255, 255, 0.8); }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_pseudo_selectors
    before_css = ".clearfix:after {\n content: \" \";\n}"
    after_css = ".item_447b7_clearfix:after {\n  content: \" \"; }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def test_it_rewrites_media_queries
    before_css = "@media (max-width: 767px) { .mobile-topbar { display: block; } }"
    after_css = "@media (max-width: 767px) {\n  .item_447b7_mobile-topbar {\n    display: block; } }\n"
    assert_rewrite("item", before_css, after_css)
  end

  def assert_rewrite(module_name, original_css, expected_rewritten_css)
    assert_equal(
      expected_rewritten_css,
      ViewComponent::CSSModule.rewrite(module_name, original_css)[:css]
    )
  end
end
