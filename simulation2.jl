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

function move_agent_random()
  eval(Meta.parse(string("move_agent_", get_random_action(), "()")))
end


function reset_agent()
  agent_x = Agent(Offset(5,10), Offset(0,0),0)
  env_offsets = initialize_gui(reward_list, agent_x)
  update_gui(env_offsets, reward_list, agent_x)
end

function move_agent()
  for x = 1:100
    sleep(0.5)
    move_agent_random()
    update_gui(env_offsets, reward_list, agent_x)
  end
end
