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

    response.map { |attributes| build_quote(attributes) }
  end

  def find(id)
    response = @db.execute <<~SQL, id
      SELECT id, title, body FROM quotes WHERE id = ? LIMIT 1;
    SQL

    build_quote(response.first)
  end

  def create(**params)
    response = @db.execute <<~SQL, params[:title], params[:body]
      INSERT INTO quotes (title, body)
      VALUES(?, ?)
      RETURNING id, title, body;
    SQL

    build_quote(response.first)
  end

  def update(id, **params)
    response = @db.execute <<~SQL, params[:title], params[:body], id
      UPDATE quotes
      SET title = ?, body = ?
      WHERE id = ?
      RETURNING id, title, body;
    SQL

    build_quote(response.first)
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

  private

  def build_quote(attr_ary)
    Quote.new %i[id title body].zip(attr_ary).to_h
  end
end
