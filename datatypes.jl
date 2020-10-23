"Helper Data Struct keeping positions (pixel)"
mutable struct Offset
  x::Int
  y::Int
end

"Data Struct for GUI Environment"
struct EnvironmentOffset
  pad_x::Int
  pad_y::Int
  step_x::Int
  step_y::Int
end

"Data Structure for Reward"
mutable struct Reward
  sim_offset::Offset
  gui_offset::Offset
  value::Int
end

"Data Structure for Agend"
mutable struct Agent
  sim_offset::Offset
  gui_offset::Offset
  sum_reward::Int
end
