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
final_state = State(Offset(10,3))
initial_state = State(Offset(10,5)

"Collect rewards based on action"
reward_action_dict = Dict("left" => ActionValue(0,0), "right" => ActionValue(0,0), "up" => ActionValue(0,0), "down" => ActionValue(0,0))

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
number_of_steps = 0

# create agent
agent_x = Agent(Offset(5,10),0)
env_offsets = initialize_gui(reward_list, agent_x)

# select row
# environment[1,:]

# select column
# environment[:,1]

function get_state_for_agent(agent)
         string("S_",agent.pos.x,"_",agent.pos.y)
end


function get_possible_actions(agent)
  possible_actions = []

  if ((agent.pos.x > 1) && (env_matrix[agent.pos.x-1, agent.pos.y] == 1))
    push!(possible_actions,"up")
  end
  if ((agent.pos.x < 10) && (env_matrix[agent.pos.x+1, agent.pos.y] == 1))
    push!(possible_actions,"down")
  end
  if ((agent.pos.y > 1) && (env_matrix[agent.pos.x, agent.pos.y-1] == 1))
    push!(possible_actions,"left")
  end
  if ((agent.pos.y < 10) && (env_matrix[agent.pos.x, agent.pos.y+1] == 1))
    push!(possible_actions,"right")
  end
  return possible_actions
end

# implement agent movement
function move_agent_up(agent)
  agent.sim_offset.y = agent_x.sim_offset.y - 1
  agent
end

function move_agent_down(agent)
  agent.sim_offset.y = agent_x.sim_offset.y + 1
  agent
end

function move_agent_right(agent)
  agent.sim_offset.x = agent_x.sim_offset.x + 1
  agent
end

function move_agent_left(agent)
  agent.sim_offset.x = agent_x.sim_offset.x - 1
  agent
end

function get_random_action()
 pos_actions = get_possible_actions()
 pos_actions[rand(1:length(pos_actions))]
end

"check if agent is in final state"
function is_final_state(state)
  equal_offset(state.pos,final_state)
end

"check if state is final state"
function is_in_final_atate(agent)
  equal_offset(agent.pos,final_state)
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

"building a monte carlo search tree"
function build_tree(tree, agt)
  tree_key = get_state_for_agent(agt)
  println(tree_key)
  if is_final_state()
    tree    
  else 
    if !haskey(tree, tree_key)
      pos_actions = get_possible_actions()
      sub_tree = Dict()
      for act in pos_actions
        sub_tree[act] = get_state_for_agent(eval(Meta.parse(string("move_agent_", last_action, "(",agt,")"))))
      end
      tree[tree_key] = sub_tree      
    end
  end
end
