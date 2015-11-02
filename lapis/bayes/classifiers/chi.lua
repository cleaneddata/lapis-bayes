local inv_chi2
inv_chi2 = function(chi, df)
  assert(df % 2 == 0, "df must be even")
  local m = chi / 2.0
  local sum = math.exp(-m)
  local term = sum
  for i = 1, math.floor(df / 2) do
    term = term * (m / i)
    sum = sum + term
  end
  return math.min(sum, 1)
end
local ChiClassifier
do
  local _parent_0 = require("lapis.bayes.classifiers.base")
  local _base_0 = {
    word_probabilities = function(self, categories, available_words)
      if not (#categories == 2) then
        return nil, "only two categories supported at once"
      end
      local a, b
      a, b = categories[1], categories[2]
      local s = 1
      local x = 0.5
      local mul = nil
      for _index_0 = 1, #available_words do
        local word = available_words[_index_0]
        local a_count = a.word_counts and a.word_counts[word] or 0
        local b_count = b.word_counts and b.word_counts[word] or 0
        local p = a_count / (a_count + b_count)
        local n = a_count + b_count
        local val = ((s * x) + (n * p)) / (s + n)
        if mul then
          mul = mul * val
        else
          mul = val
        end
      end
      local ph = inv_chi2(-2 * math.log(mul), 2 * (a.total_count + b.total_count))
      local tuples = {
        {
          a.name,
          ph
        },
        {
          b.name,
          1 - ph
        }
      }
      table.sort(tuples, function(a, b)
        return a[2] > b[2]
      end)
      return tuples
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "ChiClassifier",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ChiClassifier = _class_0
  return _class_0
end
