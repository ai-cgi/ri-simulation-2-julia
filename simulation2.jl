include("datatypes.jl")
include("gui.jl")

# Define an environment for the simulation

env_matrix = [[1 1 1 1 1 1 1 1 1 1]
              [0 1 0 1 0 1 0 1 0 1]
              [1 1 1 1 1 1 1 1 1 1]
              [1 0 1 0 0 0 0 0 1 0]
              [1 1 1 0 1 1 1 0 1 0]
              [1 0 1 0 1 0 1 0 1 1]
              [1 0 1 0 1 0 1 0 0 1]
              [0 0 1 0 1 0 1 0 1 1]
              [0 0 1 0 1 0 1 1 1 1]
              [0 0 1 0 1 0 0 0 0 0]]

possible_actions = []

final_state = Offset(3,10)

"Collect rewards based on action"
reward_action_dict = Dict("left" => 0, "right" => 0, "up" => 0, "down" => 0)

# defining all rewards
reward_1 = Reward(Offset(5,5), Offset(0,0),3)
reward_2 = Reward(Offset(7,5), Offset(0,0),3)
reward_3 = Reward(Offset(7,9), Offset(0,0),3)
reward_4 = Reward(Offset(10,9), Offset(0,0),3)
reward_5 = Reward(Offset(10,6), Offset(0,0),3)
reward_6 = Reward(Offset(9,3), Offset(0,0),3)
reward_7 = Reward(Offset(3,3), Offset(0,0),3)
reward_8 = Reward(Offset(3,10), Offset(0,0),100)

# create reward list
reward_list = [reward_1, reward_2, reward_3, reward_4, reward_5, reward_6, reward_7, reward_8]
last_reward = 0
last_action = "up"

# create agent
agent_x = Agent(Offset(5,10), Offset(0,0),0)
env_offsets = initialize_gui(reward_list, agent_x)

# select row
# environment[1,:]

# select column
# environment[:,1]

function get_possible_actions()
  possible_actions = []

  if ((agent_x.sim_offset.x > 1) && (env_matrix[agent_x.sim_offset.y, agent_x.sim_offset.x-1] == 1))
    push!(possible_actions,"left")
  end
  if ((agent_x.sim_offset.x < 10) && (env_matrix[agent_x.sim_offset.y, agent_x.sim_offset.x+1] == 1))
    push!(possible_actions,"right")
  end
  if ((agent_x.sim_offset.y > 1) && (env_matrix[agent_x.sim_offset.y-1, agent_x.sim_offset.x] == 1))
    push!(possible_actions,"up")
  end
  if ((agent_x.sim_offset.y < 10) && (env_matrix[agent_x.sim_offset.y+1, agent_x.sim_offset.x] == 1))
    push!(possible_actions,"down")
  end
  return possible_actions
end

# implement agent movement
function move_agent_up()
  agent_x.sim_offset.y = agent_x.sim_offset.y - 1
  agent_x.sim_offset
end

function move_agent_down()
  agent_x.sim_offset.y = agent_x.sim_offset.y + 1
  agent_x.sim_offset
end

function move_agent_right()
  agent_x.sim_offset.x = agent_x.sim_offset.x + 1
  agent_x.sim_offset
end

function move_agent_left()
  agent_x.sim_offset.x = agent_x.sim_offset.x - 1
  agent_x.sim_offset
end

function get_random_action()
 pos_actions = get_possible_actions()
 pos_actions[rand(1:length(pos_actions))]
end

"check if agent is in final state"
function is_final_state()
  equal_offset(agent_x.sim_offset,final_state)
end

"check if agent on current position get's a reward"
function get_reward()
  for i = 1:length(reward_list)
    if equal_offset(reward_list[i].sim_offset,agent_x.sim_offset)
      r = reward_list[i]
      deleteat!(reward_list, i)
      return r.value
    end
  end
  return 0
end

"Get best action policy."
function get_max_action()
  max_value = maximum(values(reward_action_dict))
  action_keys = collect(keys(filter(p -> p.second == 2, reward_action_dict)))
  action_keys[rand(1:length(action_keys))]
end

"Move with max action"
function move_max_action()
  global last_action = get_max_action()
  eval(Meta.parse(string("move_agent_", last_action, "()")))
end

"Check Constraints, like rewards."
function check_constraints()
  global last_reward = get_reward()
  global agent_x.sum_reward += last_reward
  if last_reward > 0
    global reward_action_dict[last_action] = reward_action_dict[last_action] + 1
  end
end

"Simple Random move policy."
function move_agent_random()
  global last_action = get_random_action()
  eval(Meta.parse(string("move_agent_", get_random_action(), "()")))
end

"Resets Agent to initial position"
function reset_agent()
  global agent_x = Agent(Offset(5,10), Offset(0,0),0)
  global reward_list = [reward_1, reward_2, reward_3, reward_4, reward_5, reward_6, reward_7, reward_8]
  global reward_action_dict = Dict("left" => 0, "right" => 0, "up" => 0, "down" => 0)

  env_offsets = initialize_gui(reward_list, agent_x)
  update_gui(env_offsets, reward_list, agent_x)
end

"Moves Agent for given policy"
function move_agent(policy)
  for x = 1:10
    sleep(0.5)
    policy()
    check_constraints()
    update_gui(env_offsets, reward_list, agent_x)
  end
end

"Moves Agent for given policy"
function move_agent()
  for x = 1:38
    sleep(0.1)
    move_agent_random()
    check_constraints()
    update_gui(env_offsets, reward_list, agent_x)
  end
end
