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
local FisherClassifier
do
  local _class_0
  local _parent_0 = require("lapis.bayes.classifiers.base")
  local _base_0 = {
    word_probabilities = function(self, categories, available_words)
      if not (#categories == 2) then
        return nil, "only two categories supported at once"
      end
      local a, b
      a, b = categories[1], categories[2]
      local s = self.opts.robs
      local x = self.opts.robx
      local min_dev = self.opts.min_dev
      local mul_a = 0
      local mul_b = 0
      local kept_tokens = 0
      for _index_0 = 1, #available_words do
        local word = available_words[_index_0]
        local a_count = a.word_counts and a.word_counts[word] or 0
        local b_count = b.word_counts and b.word_counts[word] or 0
        local p = a_count / (a_count + b_count)
        local n = a_count + b_count
        local val = ((s * x) + (n * p)) / (s + n)
        if not min_dev or math.abs(val - 0.5) > min_dev then
          mul_a = mul_a + math.log(val)
          mul_b = mul_b + math.log(1 - val)
          kept_tokens = kept_tokens + 1
        end
      end
      if kept_tokens == 0 then
        return nil, "not enough strong signals to decide"
      end
      local pa = inv_chi2(-2 * mul_a, 2 * kept_tokens)
      local pb = inv_chi2(-2 * mul_b, 2 * kept_tokens)
      local p = (1 + pa - pb) / 2
      local tuples = {
        {
          a.name,
          p
        },
        {
          b.name,
          1 - p
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
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "FisherClassifier",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
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
  local self = _class_0
  self.default_options = {
    robs = 1,
    robx = 0.5,
    min_dev = 0.3
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  FisherClassifier = _class_0
  return _class_0
end
