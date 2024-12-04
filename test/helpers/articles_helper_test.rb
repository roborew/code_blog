require "test_helper"

class ArticlesHelperTest < ActionView::TestCase
  include Pagy::Backend
  include Pagy::Frontend

  def setup
    @controller = ArticlesController.new
    # Setup Pagy variables that would normally be set by the controller
    @pagy_t_vars = Pagy::DEFAULT.merge({})
  end

  def pagy_array(array, vars={})
    vars[:items] ||= Pagy::DEFAULT[:items] # Default to Pagy's default items if not specified
    pagy = Pagy.new(count: array.size, page: vars[:page], items: vars[:items])
    return pagy, array[(pagy.offset)...(pagy.offset + vars[:items])] || []
  end

  test "pagy_nav renders pagination with previous and next links" do
    pagy, _records = pagy_array((1..100).to_a, items: 10, page: 5)
    result = pagy_nav(pagy)

    assert_match /Previous/, result
    assert_match /Next/, result
    assert_match /<span class='px-3 py-2 border text-sm font-medium text-white bg-blue-500'>5<\/span>/, result
    assert_match /<a.*?>6<\/a>/, result
  end

  test "pagy_nav renders pagination without previous link on first page" do
    pagy, _records = pagy_array((1..100).to_a, items: 10, page: 1)
    result = pagy_nav(pagy)

    assert_no_match /<a.*?>Previous<\/a>/, result
    assert_match /<span class="px-3 py-2 border text-sm font-medium text-gray-300">Previous<\/span>/, result
  end

  test "pagy_nav renders pagination without next link on last page" do
    pagy, _records = pagy_array((1..100).to_a, items: 10, page: 10)
    result = pagy_nav(pagy)

    assert_no_match /<a.*?>Next<\/a>/, result
    assert_match /<span class="px-3 py-2 border text-sm font-medium text-gray-300">Next<\/span>/, result
  end

  test "pagy_nav renders pagination with gap" do
    pagy, _records = pagy_array((1..100).to_a, items: 10, page: 5)
    result = pagy_nav(pagy)

    assert_match /<span class="px-3 py-2 border text-sm font-medium text-gray-500">...<\/span>/, result
  end
end
