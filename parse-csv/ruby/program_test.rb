require "debug"
require "minitest/autorun"
require_relative "program"

class TestProgram < Minitest::Test
  def setup
    @csv = CSV.read('products.csv', headers: true)
  end

  def test_sales_parsing
    expected = {
      'Store A' => {
        'top_product' => 'Product 3',
        'quantity'    => 7,
        'price'       => 20.0,
        'total_sales' => 140.0,
      },
      'Store B' => {
        'top_product' => 'Product 3',
        'quantity'    => 9,
        'price'       => 20.0,
        'total_sales' => 180.0,
      },
    }
    assert_equal expected, Program.new(sales: @csv).tally
  end

  def test_store_summary
    assert_equal [
      { 'product' => 'Product 1', 'quantity' => 12, 'price' => 10.0 },
      { 'product' => 'Product 2', 'quantity' => 5,  'price' => 15.0 },
      { 'product' => 'Product 3', 'quantity' => 7,  'price' => 20.0 },
    ], Program.new(sales: @csv).store_summary('Store A')

    assert_equal [
      { 'product' => 'Product 1', 'quantity' => 12, 'price' => 10.0 },
      { 'product' => 'Product 2', 'quantity' => 11, 'price' => 15.0 },
      { 'product' => 'Product 3', 'quantity' => 9,  'price' => 20.0 },
    ], Program.new(sales: @csv).store_summary('Store B')
  end
end