require "csv"

class Program
  HEADER  = [
    "Store",
    "Product",
    "Quantity",
    "Price",
    "Total Sales"
  ]

  def initialize(sales:)
    @sales = sales
  end

  def print
    result = [HEADER]
    tally.each do |store, top|
      result << [
        store,
        top['top_product'],
        top['quantity'],
        top['price'],
        top['total_sales'],
      ]
    end

    template = formatting_template(result)
    result.each do |line|
      puts (template % line).strip
    end
  end

  def store_summary(store)
    store_sales(store)
      .group_by { |sale| sale['Product'] }
      .map do |product, sales|
        {
          'product' => product,
          'price' => sales.first['Price'].to_f,
          'quantity' => sales.sum { |sale| sale['Quantity'].to_i }
        }
      end
  end

  def tally
    result = {}
    @sales
      .group_by { |sale| sale['Store'] }
      .each do |store, sales|
        top = store_summary(store).max_by { |attr| attr['quantity'] * attr['price'] }
        result[store] = {
          'top_product' => top['product'],
          'quantity'    => top['quantity'],
          'price'       => top['price'],
          'total_sales' => top['quantity'] * top['price'],
        }
      end
    result
  end

  private

  def store_sales(store)
    @sales.select { |sale| sale['Store'] == store }
  end

  def formatting_template(lines)
    lines.transpose
      .map { |line| line.map(&:to_s).max_by(&:length).length }
      .map { |space| "%-#{space}s" }.join(" ")
  end
end

