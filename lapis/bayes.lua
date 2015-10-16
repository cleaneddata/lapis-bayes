local db = require("lapis.db")
local Categories, WordClassifications
do
  local _obj_0 = require("lapis.bayes.models")
  Categories, WordClassifications = _obj_0.Categories, _obj_0.WordClassifications
end
local default_probabilities
default_probabilities = function(categories, available_words, words, opts)
  local assumed_prob = opts.assumed_prob or 0.1
  local sum_counts = 0
  for _index_0 = 1, #categories do
    local c = categories[_index_0]
    sum_counts = sum_counts + c.total_count
  end
  local tuples
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #categories do
      local c = categories[_index_0]
      local p = math.log(c.total_count / sum_counts)
      local word_counts = c.word_counts
      for _index_1 = 1, #available_words do
        local w = available_words[_index_1]
        local count = word_counts and word_counts[w] or 0
        local real_prob = count / c.total_count
        local adjusted_prob = (assumed_prob + sum_counts * real_prob) / sum_counts
        p = p + math.log(adjusted_prob)
      end
      local _value_0 = {
        c.name,
        p
      }
      _accum_0[_len_0] = _value_0
      _len_0 = _len_0 + 1
    end
    tuples = _accum_0
  end
  table.sort(tuples, function(a, b)
    return a[2] > b[2]
  end)
  return tuples, #available_words / #words
end
local p2
p2 = function(categories, available_words, words, opts)
  local assumed_prob = opts.assumed_prob or 0.1
  local total_words = { }
  for _index_0 = 1, #categories do
    local c = categories[_index_0]
    for word, count in pairs(c.word_counts) do
      total_count[word] = total_count[word] or 0
      total_count[word] = total_count[word] + count
    end
  end
  for _index_0 = 1, #categories do
    local c = categories[_index_0]
    local tuples
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_1 = 1, #available_words do
        local _continue_0 = false
        repeat
          local word = available_words[_index_1]
          local cat_count = c.word_counts[word]
          if not (cat_count) then
            _continue_0 = true
            break
          end
          local tot = total_words[available_words]
          local _value_0 = {
            word,
            cat_count / tot
          }
          _accum_0[_len_0] = _value_0
          _len_0 = _len_0 + 1
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      tuples = _accum_0
    end
    local by_importance
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_1 = 1, #tuples do
        local t = tuples[_index_1]
        _accum_0[_len_0] = {
          math.abs(t[2] - 0.5, t)
        }
        _len_0 = _len_0 + 1
      end
      by_importance = _accum_0
    end
    table.sort(by_importance, function(a, b)
      return a[1] > b[1]
    end)
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_1 = 1, #by_importance do
        local i = by_importance[_index_1]
        _accum_0[_len_0] = i[2]
        _len_0 = _len_0 + 1
      end
      tuples = _accum_0
    end
    require("moon").p(tuples)
    error("not yet")
  end
end
local text_probabilities
text_probabilities = function(categories, text, opts)
  if opts == nil then
    opts = { }
  end
  local num_categories = #categories
  categories = Categories:find_all(categories, "name")
  assert(num_categories == #categories, "failed to find all categories for classify")
  local tokenize_text
  tokenize_text = require("lapis.bayes.tokenizer").tokenize_text
  local words = tokenize_text(text, opts)
  if not (words and next(words)) then
    return nil, "failed to generate tokens"
  end
  local categories_by_id
  do
    local _tbl_0 = { }
    for _index_0 = 1, #categories do
      local c = categories[_index_0]
      _tbl_0[c.id] = c
    end
    categories_by_id = _tbl_0
  end
  local wcs = WordClassifications:find_all(words, {
    key = "word",
    where = {
      category_id = db.list((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #categories do
          local c = categories[_index_0]
          _accum_0[_len_0] = c.id
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)())
    }
  })
  local available_words
  do
    local _accum_0 = { }
    local _len_0 = 1
    for word in pairs((function()
      local _tbl_0 = { }
      for _index_0 = 1, #wcs do
        local wc = wcs[_index_0]
        _tbl_0[wc.word] = true
      end
      return _tbl_0
    end)()) do
      _accum_0[_len_0] = word
      _len_0 = _len_0 + 1
    end
    available_words = _accum_0
  end
  if #available_words == 0 then
    return nil, "no words in text are classifyable"
  end
  for _index_0 = 1, #wcs do
    local wc = wcs[_index_0]
    local category = categories_by_id[wc.category_id]
    category.word_counts = category.word_counts or { }
    category.word_counts[wc.word] = wc.count
  end
  return default_probabilities(categories, available_words, words, opts)
end
local classify_text
classify_text = function(categories, text, ...)
  local counts, word_rate_or_err = text_probabilities(categories, text, ...)
  if not (counts) then
    return nil, word_rate_or_err
  end
  return counts[1][1], counts[1][2], word_rate_or_err
end
local train_text
train_text = function(category, text, opts)
  category = Categories:find_or_create(category)
  return category:increment_text(text, opts)
end
return {
  classify_text = classify_text,
  train_text = train_text,
  text_probabilities = text_probabilities
}
