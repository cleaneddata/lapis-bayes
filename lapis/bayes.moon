db = require "lapis.db"

tokenize_text = (text) ->
  res = unpack db.query "select to_tsvector('english', ?)", text
  vector = res.to_tsvector
  [t for t in vector\gmatch "'(.-)'"]


check_text = (text, categories) ->

classify_text = (text, category) ->
  import Categories from require "lapis.bayes.models"
  category = Categories\find_or_create category

  for word in *tokenize_text text
    nil


{:check_text, :classify_text, :tokenize_text}