include("datatypes_reworked.jl")

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
initial_state = State(Offset(10,5))

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
agent_x = Agent(Offset(10,5),0)

# select row
# environment[1,:]

# select column
# environment[:,1]

function get_state_for_agent(agent)
         string(agent.pos.x,".",agent.pos.y)
end
 
function set_state_for_agent(state)
  Agent(state.pos, 0)
end

function state_to_string(state)
  string(state.pos.x,".",state.pos.y)
end

function string_to_state(str)
  State(Offset(parse(Int, split(str, ".")[1]),parse(Int, split(str, ".")[2]))) 
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
  agent.pos.x = agent.pos.x - 1
  agent
end

function move_agent_down(agent)
  agent.pos.x = agent.pos.x + 1
  agent
end

function move_agent_right(agent)
  agent.pos.y = agent.pos.y + 1
  agent
end

function move_agent_left(agent)
  agent.pos.y = agent.pos.y - 1
  agent
end

function get_random_action()
 pos_actions = get_possible_actions()
 pos_actions[rand(1:length(pos_actions))]
end

"check if agent is in final state"
function is_final_state(state)
  equal_offset(state.pos,final_state.pos)
end

"check if state is final state"
function is_in_final_state(agent)
  equal_offset(agent.pos,final_state.pos)
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

"create search tree for searching"
function create_tree(tree, state_string)
  if is_in_final_state(set_state_for_agent(string_to_state(state_string))) 
    tree[state_string] = Dict()
    tree
  else
     if !haskey(tree, state_string)
      agt = set_state_for_agent(string_to_state(state_string))
      pos_actions = get_possible_actions(agt)
      sub_tree = Dict()
      for act in pos_actions
        target = get_state_for_agent(eval(Meta.parse(string("move_agent_", act, "(",agt,")"))))
        if !haskey(tree,target)
           sub_tree[act] = target
        end
           agt = set_state_for_agent(string_to_state(state_string))
      end
      tree[state_string] = sub_tree
      for s in values(sub_tree)
        create_tree(tree,s)     
      end       
    end 
  end
    tree
end

"function to visualize trees based on dictionary relations by given start_key"
function visualize_tree(tree_dict, key, dot_string)
   println("->", dot_string)
   edges = tree_dict[key]
    if length(edges) == 0
    else
       for ke in keys(edges)
           edge = edges[ke]
           dot_string = string(dot_string, key, " -> ", edge, " [label=",first(ke),"]\n")
           dot_string = visualize_tree(tree_dict, edge, dot_string)
      end     
   end
  dot_string 
end   

graphviz_start = """digraph {    
  node [shape="circle", style="filled", fillColor="#AAAAAA"]
  edge [color="#AAAAAA", fontcolor="#AAAAAA"]    
  10.3 [color="darkgreen", fontcolor="white"]
  10.5 [color="#AA0000", fontcolor="white"]"""