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

Q = Array{Dict}(undef, 10, 10)

"initialize Q array"
function initialize_q_table()
  for i = 1:10
      for j = 1:10
        Q[i,j] = Dict("up" => 0, "down" => 0, "left" => 0, "right" => 0)         
      end
    end
end

final_state = Offset(3,10)

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
agent_x = Agent(Offset(5,10), Offset(0,0),0)
env_offsets = initialize_gui(reward_list, agent_x)

# select row
# environment[1,:]

# select column
# environment[:,1]

function get_state_for_agent(agent)
         string("S_",agent.sim_offset.x,"_",agent.sim_offset.y)
end

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
  pos_actions = get_possible_actions()
  possible_reward_action_dict = Dict()
  for pos_act in pos_actions
         possible_reward_action_dict[pos_act] = reward_action_dict[pos_act]
  end

  max_value = maximum(map(v -> v.average_reward, values(possible_reward_action_dict)))
  action_keys = collect(keys(filter(p -> p.second.average_reward == max_value, possible_reward_action_dict)))
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
    # we have to use the correct formular
    global reward_action_dict[last_action].number_consumed = reward_action_dict[last_action].number_consumed + 1
    global reward_action_dict[last_action].average_reward =
      reward_action_dict[last_action].average_reward +
         ((1 / reward_action_dict[last_action].number_consumed) * (last_reward - reward_action_dict[last_action].average_reward))
  end
end

"Simple Random move policy."
function move_agent_random()
  global last_action = get_random_action()
  eval(Meta.parse(string("move_agent_", get_random_action(), "()")))
end

"Simple implementation of the ϵ-greedy function"
function ϵ_greedy(ϵ)
    if rand() <= ϵ
      move_agent_random()
    else
      move_max_action()
    end
end


"Resets Agent to initial position"
function reset_agent()
  global agent_x = Agent(Offset(5,10), Offset(0,0),0)
  global reward_list = [reward_1, reward_2, reward_3, reward_4, reward_5, reward_6, reward_7, reward_8]
  # global reward_action_dict = Dict("left" => 0, "right" => 0, "up" => 0, "down" => 0)
  global reward_action_dict = Dict("left" => ActionValue(0,0), "right" => ActionValue(0,0), "up" => ActionValue(0,0), "down" => ActionValue(0,0))

  env_offsets = initialize_gui(reward_list, agent_x)
  update_gui(env_offsets, reward_list, agent_x)
end

"Moves Agent for given policy"
function move_agent(policy, iterations)
  for x = 1:iterations
    sleep(0.05)
    policy()
    check_constraints()
    update_gui(env_offsets, reward_list, agent_x)
  end
end

"Moves Agent for given policy"
function move_agent_epsilon(policy, ϵ, iterations)
  x = 0
  while (x < iterations) && !is_final_state()
    sleep(0.001)
    policy(ϵ)
    check_constraints()
    update_gui(env_offsets, reward_list, agent_x)
    x = x + 1
  end
  if x < iterations
    println(string("Final state reached after ", x, " iterations."))
  else   
    println("Final state could not be reached....")
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