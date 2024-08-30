require "minitest/autorun"

class TestExecutable < Minitest::Test
  def test_executable
    out, _ = capture_subprocess_io do
      system "./product_summary products.csv"
    end

    assert_equal <<~EXPECTED, out
      Store   Product   Quantity Price Total Sales
      Store A Product 3 7        20.0  140.0
      Store B Product 3 9        20.0  180.0
    EXPECTED
  end
end
