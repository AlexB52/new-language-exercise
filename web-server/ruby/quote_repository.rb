Quote = Struct.new(:id, :title, :body, keyword_init: true) do
  require 'json'

  def to_json
    to_h.to_json
  end
end

class QuoteRepository
  attr_accessor :db
  def initialize(db:)
    @db = db
    @db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS quotes (
        id INTEGER PRIMARY KEY,
        title TEXT,
        body TEXT
      );
    SQL
  end

  def list
    response = @db.execute <<~SQL
      SELECT id, title, body FROM quotes;
    SQL

    response.map do |attributes|
      Quote.new %i[id title body].zip(attributes).to_h
    end
  end

  def create(**params)
    response = @db.execute <<~SQL, params[:title], params[:body]
      INSERT INTO quotes (title, body)
      VALUES(?, ?)
      RETURNING id, title, body;
    SQL
    attributes = %i[id title body].zip(response.first).to_h
    Quote.new(attributes)
  end

  def delete(*ids)
    @db.execute <<~SQL, ids.join(",")
      DELETE FROM quotes WHERE id IN (?);
    SQL
  end

  def delete_all
    @db.execute <<~SQL
      DELETE FROM quotes;
    SQL
  end

  def count
    response = @db.execute <<~SQL
      SELECT COUNT(id) FROM quotes;
    SQL
    response.first.first
  end
end
