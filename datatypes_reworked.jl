"Helper Data Struct keeping positions (pixel)"
mutable struct Offset
  x::Int
  y::Int
end

struct State
  pos::Offset
end

mutable struct Edge
    visited::Bool
    target::String
end

mutable struct Leaf
    id::String
    visited::Bool
end

function equal_offset(offset1::Offset, offset2::Offset)
    (offset1.x == offset2.x) && (offset1.y == offset2.y)
end

"Data Structure for Reward"
mutable struct Reward
  sim_offset::Offset
  gui_offset::Offset
  value::Int
end

"Data Structure for Agend"
mutable struct Agent
  pos::Offset
  sum_reward::Int
end
