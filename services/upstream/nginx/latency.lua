local _M = {}

local data = { [0] = 0 }

function _M.add(v)
  local n = data[0] + 1
  data[n] = v
  data[0] = n
end

function _M.reset()
  data = { [0] = 0 }
end

local function percentile(sorted, p)
  local n = #sorted
  if n == 0 then
    return nil
  end

  local idx = math.floor(p * n)
  if idx < 1 then
    idx = 1
  end

  return sorted[idx]
end

function _M.stats()
  local n = #data
  if n == 0 then
    return {}
  end

  local sorted = table.new(n, 0)
  local sum = 0
  for i = 1, n do
    sum = sum + data[i]
    sorted[i] = data[i]
  end
  table.sort(sorted)

  return {
    avg = sum / n,
    min = sorted[1],
    max = sorted[n],
    med = percentile(sorted, 0.5),
    p90 = percentile(sorted, 0.90),
    p95 = percentile(sorted, 0.95),
    p99 = percentile(sorted, 0.99),
    count = n
  }
end

return _M
