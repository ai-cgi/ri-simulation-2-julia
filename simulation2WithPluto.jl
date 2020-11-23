### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 66f2f870-108b-11eb-0ce6-1f6e07b93a46
# Setting up the libraries
begin
	# THIS LINE MUST BE CONFIGURED, it must be an existing dir, to write
	# some dependency information to (Manifest.toml, Project.toml)
	dir = "C:/projects/plutoJL/computationalthinking/"
	if !endswith(pwd(), dir)
	    cd(dir)
	end
    import Pkg
	# Activation means, that packages we installed are valid locally,
	# and don't interfer with other projects.
    Pkg.activate(".")
	# Pkg.installed() is deprecated and doesn't check for version.
	# (Yet the API of Pkg.dependencies() isn't exactly comfortable.)
	if !haskey(Pkg.installed(), "PlutoUI")
		Pkg.add("PlutoUI")
	end
	if !haskey(Pkg.installed(), "Colors")
		Pkg.add("Colors")
	end
	using PlutoUI # enables the Sliders
	using Colors  # Gray, RGB
end

# ╔═╡ 873e67a0-114d-11eb-0e58-17a0964b9172
md""" 

NOTE:

This is a Pluto notebook. So, to get it running, please 

1. Install Julia. [julialang.org](http://julialang.org)
2. In Julia, install Pluto, by hitting ] to enter the package mode, and then type

    add Pluto <ENTER>

3. I usually put my Pluto notebooks in a subdirectory of the Pluto directory. When you    start Pluto (see below), you then can select it in the "Open from file" field.
4. The code block marked with "Setting up the libraries" needs some attention:
   You should replace the path containing "computationalthinking" with the 
   path of your subdirectory. (In Windows, use / instead of backslash.)
5. Start Julia, then start Pluto with: 

    `using Pluto; Pluto.run()`

"""

# ╔═╡ 708af13e-114d-11eb-387c-436d11865e42
md"# Let's make a Labyrinth"

# ╔═╡ e479b78e-10b1-11eb-0d37-fbdd2869eef7
"""
Function so short, we could have omitted it. Creates a random nxm array of 0 and 1.
The array given as first argument to the rand(...) in the code will decide the
probability.
e.g.
[0.0, 1.0] gives 50% each
[0.0, 1.0, 1.0] gives 1/3 walls
"""
function makeRandomLabyrinth(n, m)
	arr = rand([0.0, 1.0, 1.0], n, m)
end

# ╔═╡ 5d1e20e0-2837-11eb-1fad-d70c35b9f138
md"""
The flood function 'pours' into start, and fills every white space that is reachable. This way we can see, whether there is a path from start to goal.
"""

# ╔═╡ e63a8f80-10b3-11eb-2838-b1948ba267b8
begin
	function flood(mx, x, y, oldVal, newVal)
		if mx[x,y] == oldVal
			mx[x,y] = newVal
			if x > 1
				flood(mx, x-1, y, oldVal, newVal)
			end
			if x < size(mx)[1]
				flood(mx, x+1, y, oldVal, newVal)
			end
			if y > 1
				flood(mx, x, y-1, oldVal, newVal)
			end
			if y < size(mx)[2]
				flood(mx, x, y+1, oldVal, newVal)
			end
		end
		mx
	end
end

# ╔═╡ 9f8d9320-2837-11eb-06a8-c1a84f786de8
md"A labyrinth has a path iff when pouring into start, goal will be coloured too"

# ╔═╡ 74d89c8e-10b5-11eb-08dc-89bcdfc5030c
function makeRandomLabyrinthWithPath(n, m, p1, p2)
	floodVal = 0.9
	r = makeRandomLabyrinth(n, m)
	generateCounter = 1
	# entrance and exit must be free, of course
	while r[p1.x, p1.y] != 1.0 || r[p2.x, p2.y] != 1.0
		r = makeRandomLabyrinth(n, m)
		generateCounter += 1
	end
	rf = flood(copy(r), p1.x, p1.y, 1.0, floodVal)
	while rf[p2.x, p2.y] != floodVal
		r = makeRandomLabyrinth(n, m)
		generateCounter += 1
		rf = flood(copy(r), p1.x, p1.y, 1.0, floodVal)
	end
	println("Valid labyrinth after $generateCounter tries.")
	r
end

# ╔═╡ 8f1016ae-2979-11eb-33b7-8bcf1fd823a3
md"""
## We are ready to build the labyrinth, 
### and declare two positions as entrance and exit (goal)
"""

# ╔═╡ 041d3050-115b-11eb-1792-13f40e80ec8d
md" Now we have a labyrinth with a possible path from start (green) to goal (yellow)."

# ╔═╡ 46b128e0-2975-11eb-104f-a726af61b463
md"### For nostalgic reasons, we keep our original maze."

# ╔═╡ 7ead0960-108b-11eb-16fd-fdb97b1d32f2
environment0 = [[1 1 1 1 1 1 1 1 1 1]
              [0 1 0 1 0 1 0 1 0 1]
              [1 1 1 1 1 1 1 1 1 1]
              [1 0 1 0 0 0 0 0 1 0]
              [1 1 1 0 1 1 1 0 1 0]
              [1 0 1 0 1 0 1 0 1 1]
              [1 1 1 0 1 0 1 0 0 1]
              [0 0 1 0 1 0 1 0 1 1]
              [0 0 1 0 1 0 1 1 1 1]
              [0 0 1 0 1 0 0 0 0 0]];

# ╔═╡ 6308cb50-109e-11eb-20d8-3999269f6b41
md"The first index counts from top down, the second left to right. Starts with one."

# ╔═╡ 0c84c5ee-109d-11eb-298f-d938ebce3865
"Vizualist a maze."
vis(mx) = let normalizer = maximum(mx)
	map(n -> RGB(n/normalizer, n/normalizer, n/normalizer), mx)
end

# ╔═╡ 2e0d2a90-10b2-11eb-0c7a-eb5318672ebe
vis(flood(makeRandomLabyrinth(10, 17), 1, 1, 1.0, 0.5))#, 0.7))

# ╔═╡ 3e51e86e-109c-11eb-3c8a-f9f613e454d7
# adds a border
function enclose(mx, what)
	(n, m) = size(mx)
	sides = fill(what, n+2)
	updwn = fill(what, 1, m)
	hcat(sides, vcat(updwn, mx, updwn), sides)
end

# ╔═╡ 9a05b1d0-1220-11eb-36c3-073f6da8f29d
enclose(vis(environment0), Gray(0.7))

# ╔═╡ 8894d5e0-2975-11eb-37f6-7bc7537e9152
md"""## Finding our way
First, we define a struct for positions, and the possible actions.
"""

# ╔═╡ d5990fa0-109d-11eb-1e3a-31f426f6600d
struct Pos
	x
	y
end

# ╔═╡ 83602dc0-1126-11eb-3632-e7de171beefd
# The with_terminal() makes the output visible. Otherwise, Pluto will only show the
# result of the computation.
with_terminal() do
	n = 30 # danger of loop. with 50% walls 15x20 needs already ~ 1..5k tries to find maze with path
	m = 40
	global start = Pos(1,1)
	global goal  = Pos(n,m)
	global environment = makeRandomLabyrinthWithPath(n, m, start, goal)
	:ok
end

# ╔═╡ 93f69d70-10b5-11eb-214d-951a0c4cf443
let vlab = vis(enclose(flood(copy(environment), 1,1, 1.0, 0.9), 0.7))
	# +1 needed, because we edit the visualization not the labyrinth, and that has an added border
	vlab[start.x+1, start.y+1] = RGB(0.0, 1.0, 0.0)
	vlab[goal.x+1, goal.y+1] = RGB(1.0, 1.0, 0.0)
	vlab
end

# ╔═╡ 2d2fe160-109b-11eb-359a-f77ff97f44f8
vis(enclose(environment, 0.7))

# ╔═╡ 9eb7d610-109d-11eb-3b7e-09ec7b457e39
begin
	inc(x)   = x + one(x)
	dec(x)   = x - one(x)
	left(p)  = Pos(p.x, dec(p.y))
	right(p) = Pos(p.x, inc(p.y))
	up(p)    = Pos(dec(p.x), p.y)
	down(p)  = Pos(inc(p.x), p.y)
end

# ╔═╡ 245ac230-1230-11eb-0d47-4dff5b33feb0
left(Pos(3,4))

# ╔═╡ 6c19af50-109b-11eb-0925-a1468e9692a2
actions = [up, down, left, right]

# ╔═╡ 1b8f6940-109f-11eb-21b1-2f315e51268b
"Criterion to filter for actions that don't lead into a wall."
function allowedPosition(p)
	let (xMax, yMax) = size(environment)
		0 < p.x &&
		0 < p.y &&
		p.x <= xMax &&
		p.y <= yMax &&
		environment[p.x, p.y] == 1
	end
end

# ╔═╡ 8d3976d0-109f-11eb-39e5-3164b85a0502
# this better be true (by choice of the maze)
allowedPosition(start)

# ╔═╡ a107e3c0-10a1-11eb-2d51-79e604b51e0b
allowedActions(currentPos) = filter(f -> allowedPosition(f(currentPos)), actions)

# ╔═╡ 34449bb0-10a2-11eb-361d-df29435cc335
allowedActions(start)

# ╔═╡ b240f540-10a2-11eb-37f6-dbe5571bd876
function showPos(p)
    v = vis(enclose(environment, 0.7))
	v[p.x+1, p.y+1] = RGB(1.0,0.0,0.0)
	actions = allowedActions(p)
	for a in actions
		nextP = a(p)
		v[nextP.x+1, nextP.y+1] = RGB(0.0,1.0,1.0)
	end
	v
end

# ╔═╡ eb2c2fa0-10a2-11eb-0858-8f74d1315800
showPos(start)

# ╔═╡ bd7d4a90-28a2-11eb-29a8-6977d054b789
md"## A completely random walk."

# ╔═╡ 27a00cd0-10a9-11eb-2f12-abb2475ba54d
function randomWalk()
	limit = 50000
	r = [start]
	count = 0
	while count < limit && r[end] != goal
        count += 1
		currentPosition = r[end]
		actions = allowedActions(currentPosition)
		if length(actions) < 1
			println("strange things happen at the $currentPosition point")
		end
		action = rand(actions)
		push!(r, action(currentPosition))
	end
	r
end

# ╔═╡ 7b189c60-10a9-11eb-3495-e3b92b38c968
r = randomWalk();

# ╔═╡ a141de80-10ac-11eb-3922-e3f4f0a071f6
md"The run $(r[end]==goal ? \"ended successfully\" : \"didn' find the goal\") after $(length(r)) steps."

# ╔═╡ 7f2b0e90-1131-11eb-1cd0-e178e8d1c29a
md"## Hint: Select the slider, and then use cursor left / right keys."

# ╔═╡ 61f04e10-10ac-11eb-18b1-ab2d0f9958c4
@bind step Slider(1:length(r), default = 1, show_value=true)

# ╔═╡ 8289cb60-10ac-11eb-1a06-0de38c71a4fc
showPos(r[step])

# ╔═╡ f2021d90-28a2-11eb-1a83-e5d7932f9761
md"""
## Monte Carlo
Monte Carlo seems to mean: Roll the dice often enoug, and something will come up that is acceptable. For efficiency, add secret souce.

This is MC *without* secret souce. We run randomly n times and keep the fastest, i.e. shortest run.
"""

# ╔═╡ 55233a80-10b1-11eb-2b60-2dd005c9f975
function mc(n)
	r = randomWalk()
	for i in 2:n
		r2 = randomWalk()
		if length(r2) < length(r)
			r = r2
		end
	end
	r
end

# ╔═╡ 4f680c60-297a-11eb-1471-2d80b59a15fb
md"You have to change n to do sth interesting. Remember to change it back, otherwise loading this notebook will take a long time."

# ╔═╡ 7bb391b0-114a-11eb-01b4-6b160f733e0b
with_terminal() do
	n = 1
    global ro = @time mc(n)
	println("Found a run of length $(length(ro)) after $n runs.")
end

# ╔═╡ 0da83940-114b-11eb-3fe7-154d0376336f
@bind stepo Slider(1:length(ro), default = 1, show_value=true)

# ╔═╡ 9ea00a40-114b-11eb-2c07-2b490e8f9460
showPos(ro[stepo])

# ╔═╡ ec8d3a6e-114b-11eb-1959-9136912de031
md"Best of the (random) runs found the exit in $(length(ro)) steps."

# ╔═╡ 332902e0-28a6-11eb-2b7c-b38ecfeff63b
md"""
## Towards Reinforcement Learning

We start with a single run, to find the exit. For that we can use the randomWalk,
or some heuristics.

(Right-hand-on-the-wall and its left hand equivalent should work fine here, as the exit is at the limits of the labyrinth.)
"""

# ╔═╡ cbcd3e80-28a6-11eb-2c9b-7b6e83510cd0
function rightHandOnTheWall()
	limit = 50000
	r = [start]
	actions = allowedActions(start)
	#here I use the information, that I start at 1,1. Should be done better
	lastAction = actions[1]
	if length(actions) == 2
		lastAction = down
	end
	push!(r, lastAction(start))
	count = 1
	while count < limit && r[end] != goal
        count += 1
		currentPosition = r[end]
		actions = Set(allowedActions(currentPosition))
		if length(actions) < 1
			println("strange things happen at the $currentPosition point")
		end
		
		orderedActions = [right, up, left, down]
		idx = indexin([lastAction], orderedActions)[1]-1
		if idx < 1
			idx = 4
		end
		orderedActionsDirected = vcat(orderedActions[idx:end], 
			                          orderedActions[1:idx-1])

		suggestedActions = filter(a -> a ∈ actions, orderedActionsDirected)
		action = suggestedActions[1]
		#println("From $((currentPosition.x,currentPosition.y)), after $lastAction we go $action, suggested: $(map(Symbol,suggestedActions))")
			
		# action = rand(actions)
		
		push!(r, action(currentPosition))
		lastAction = action
	end
	r
end

# ╔═╡ 5ee3d0d0-28a7-11eb-0c91-f1ef4e8c8d25
@bind startHeuristics Select(["randomWalk" => "random", "rightHandOnTheWall" => "right hand on the wall"], default="randomWalk")

# ╔═╡ 6110c2f0-28a7-11eb-25f5-15f394f9ac44
md"$startHeuristics is used as start heuristics"

# ╔═╡ 009256b0-2766-11eb-3208-21824dedb58f
with_terminal() do
	a = Dict()
	println("First walk uses the heuristics $startHeuristics")		
	firstWalk = eval(Symbol(startHeuristics))() #randomWalk()
	println("Found a path of length $(length(firstWalk))")	
	currentValue = 0
	# start at end == goal
	for i in length(firstWalk):-1:1
		# if not in a, then this it the nearest to goal
		if !haskey(a, firstWalk[i])
			a[firstWalk[i]] = currentValue
			currentValue -= 1
			println(currentValue)
		else # state already in a, so we found a shortcut
			currentValue = a[firstWalk[i]] - 1
			println("shortcut to $currentValue")
		end
	end
	global a0 = a
end

# ╔═╡ 06143c00-276d-11eb-066b-bdc66ae718bc
function showA(a)
    v = vis(enclose(environment, 0.7))
	v[1, 1] = RGB(1.0,0.0,0.0) # assumes start at 1 1
	scale = minimum(values(a))
	for p in keys(a)
		v[p.x+1, p.y+1] = RGB(0.0,a[p]/scale,0.8)
	end
	v
end

# ╔═╡ a0057490-276e-11eb-24df-dd4df346d183
showA(a0)

# ╔═╡ 832cced0-2779-11eb-317a-51f6a7dc2a98
function greedy(a, p)
	actions = allowedActions(p)
	# I use get, not a[ax(p)], so I can give a low default value to unknown places
	actionValues = map(ax -> get(a,ax(p),-100000), actions)
	v, i = findmax(actionValues)
	actions[i]
end

# ╔═╡ 58b5b230-277d-11eb-0fa7-0d098f4ab70d
function runWithPolicy(policy, a)
	r = [start]
	while r[end] != goal
		currentPosition = r[end]
		action = policy(a, currentPosition)
		push!(r, action(currentPosition))
	end
	r
end

# ╔═╡ 1b9077a0-277d-11eb-0da4-8d6cdd1d9a4a
with_terminal() do
	# I had a case where the firstWalk didn't find the exit in 5000 steps
	# sending runWithPolicy(greedy, a0) into an infinite loop.
	if get(a0, goal, -10000) != -10000
		@time global firstPolicedWalk = runWithPolicy(greedy, a0)
	else
		println("Can't run yet")
	end
end

# ╔═╡ 33cbad30-2782-11eb-14c5-35599512657d
md"This took $(length(firstPolicedWalk)) steps."

# ╔═╡ b12a6400-277e-11eb-155d-8b9b9cf56177
@bind step1 Slider(1:length(firstPolicedWalk), default = 1, show_value=true)

# ╔═╡ c19fa5c0-277e-11eb-1640-559e9143177a
showPos(firstPolicedWalk[step1])

# ╔═╡ 107337d0-28ff-11eb-2f23-933d94f9d8df
ϵ = 0.3

# ╔═╡ 17160fc0-2901-11eb-0e1c-9be562177705
episodeLength = 20

# ╔═╡ 2bc0819e-28ff-11eb-04e1-75d13c28ab89
function mcRC(n)
	a = copy(a0)
	for i in 1:n
		pos = rand(keys(a)) #start from a known position
		action = rand(allowedActions(pos)) # perform a random action
		r = [pos, action(pos)]
		for k in 1:episodeLength
			currentPosition = r[end]
			if rand() > ϵ
				action = greedy(a, currentPosition)
			else
				action = rand(allowedActions(currentPosition))
			end
			push!(r, action(currentPosition))
		end
		#println("i=$i")
		currentValue = a[r[1]]
		# start at end == goal
		for i in 1:length(r)
			# if not in a, then this it the nearest to goal
			if !haskey(a, r[i])
				a[r[i]] = currentValue
				currentValue -= 1
				#println(currentValue)
			else # state already in a, so we found a shortcut
				currentValue = a[r[i]] - 1
				#println("shortcut to $currentValue")
			end
		end

	end
	a
end

# ╔═╡ b8572580-297a-11eb-36d0-1b752484dfe4
md"You have to change n to do sth interesting. Remember to change it back, otherwise loading this notebook will take a long time."

# ╔═╡ dda73b90-2902-11eb-0eaf-d9d79fde7518
 with_terminal() do
	n = 1_000
	@time global a1 = mcRC(n)
end

# ╔═╡ ff11fd80-2900-11eb-179e-19b3f2682029
if get(a0, goal, -10000) != -10000
	rMC = runWithPolicy(greedy, a1)
else
	println("Can't run yet")
end

# ╔═╡ a147f6d0-2907-11eb-12f7-ffb4409424be
md"This took $(length(rMC)) steps."

# ╔═╡ b9084950-2907-11eb-3f4d-9bce686f420b
@bind stepMCRC Slider(1:length(rMC), default = 1, show_value=true)

# ╔═╡ cc18cf60-2907-11eb-3739-f5ec56fcff4f
showPos(rMC[stepMCRC])

# ╔═╡ 5369ec60-2908-11eb-0a00-bd170c3142e1
showA(a1)

# ╔═╡ 1df51b90-277d-11eb-3df1-b5f6c4a123fb
md"# Misc Tests & Experiments"

# ╔═╡ 2b67f280-1223-11eb-1adf-bb43c135e27c
[Gray(0.5) Gray(0.9) RGB(0.9,0.0,0.0)] 

# ╔═╡ e4303e90-2451-11eb-264f-6dfad8939bbb
@bind testBox CheckBox(default=false)

# ╔═╡ ea11d440-2451-11eb-2b3a-6dc972a6e57f
begin
	if(testBox)
		md"Yes"
	else
		md"No"
	end
end

# ╔═╡ f26bee92-2452-11eb-1417-91ab179d2c01
mutable struct Counter
	n
end

# ╔═╡ 342e7470-2452-11eb-14ed-9d98d89a2b07
runCounter = Counter(0)

# ╔═╡ 3b089af0-2452-11eb-3bed-45ab89873ce9
@bind doRun Button("Run!")

# ╔═╡ 38905280-2453-11eb-0c85-5f7897bd6a79
doRun

# ╔═╡ 43bed470-2452-11eb-0392-eb8049029f12
begin
	doRun
	runCounter.n += 1
	md"I run $(runCounter.n) times."
end

# ╔═╡ Cell order:
# ╟─873e67a0-114d-11eb-0e58-17a0964b9172
# ╠═66f2f870-108b-11eb-0ce6-1f6e07b93a46
# ╟─708af13e-114d-11eb-387c-436d11865e42
# ╠═e479b78e-10b1-11eb-0d37-fbdd2869eef7
# ╠═2e0d2a90-10b2-11eb-0c7a-eb5318672ebe
# ╟─5d1e20e0-2837-11eb-1fad-d70c35b9f138
# ╠═e63a8f80-10b3-11eb-2838-b1948ba267b8
# ╟─9f8d9320-2837-11eb-06a8-c1a84f786de8
# ╠═74d89c8e-10b5-11eb-08dc-89bcdfc5030c
# ╟─8f1016ae-2979-11eb-33b7-8bcf1fd823a3
# ╠═83602dc0-1126-11eb-3632-e7de171beefd
# ╟─041d3050-115b-11eb-1792-13f40e80ec8d
# ╠═93f69d70-10b5-11eb-214d-951a0c4cf443
# ╟─46b128e0-2975-11eb-104f-a726af61b463
# ╠═7ead0960-108b-11eb-16fd-fdb97b1d32f2
# ╟─6308cb50-109e-11eb-20d8-3999269f6b41
# ╠═0c84c5ee-109d-11eb-298f-d938ebce3865
# ╠═9a05b1d0-1220-11eb-36c3-073f6da8f29d
# ╠═3e51e86e-109c-11eb-3c8a-f9f613e454d7
# ╠═2d2fe160-109b-11eb-359a-f77ff97f44f8
# ╟─8894d5e0-2975-11eb-37f6-7bc7537e9152
# ╠═d5990fa0-109d-11eb-1e3a-31f426f6600d
# ╠═9eb7d610-109d-11eb-3b7e-09ec7b457e39
# ╠═245ac230-1230-11eb-0d47-4dff5b33feb0
# ╠═6c19af50-109b-11eb-0925-a1468e9692a2
# ╠═1b8f6940-109f-11eb-21b1-2f315e51268b
# ╠═8d3976d0-109f-11eb-39e5-3164b85a0502
# ╠═a107e3c0-10a1-11eb-2d51-79e604b51e0b
# ╠═34449bb0-10a2-11eb-361d-df29435cc335
# ╠═b240f540-10a2-11eb-37f6-dbe5571bd876
# ╠═eb2c2fa0-10a2-11eb-0858-8f74d1315800
# ╠═bd7d4a90-28a2-11eb-29a8-6977d054b789
# ╠═27a00cd0-10a9-11eb-2f12-abb2475ba54d
# ╠═7b189c60-10a9-11eb-3495-e3b92b38c968
# ╟─a141de80-10ac-11eb-3922-e3f4f0a071f6
# ╟─7f2b0e90-1131-11eb-1cd0-e178e8d1c29a
# ╠═61f04e10-10ac-11eb-18b1-ab2d0f9958c4
# ╠═8289cb60-10ac-11eb-1a06-0de38c71a4fc
# ╟─f2021d90-28a2-11eb-1a83-e5d7932f9761
# ╠═55233a80-10b1-11eb-2b60-2dd005c9f975
# ╟─4f680c60-297a-11eb-1471-2d80b59a15fb
# ╠═7bb391b0-114a-11eb-01b4-6b160f733e0b
# ╠═0da83940-114b-11eb-3fe7-154d0376336f
# ╠═9ea00a40-114b-11eb-2c07-2b490e8f9460
# ╟─ec8d3a6e-114b-11eb-1959-9136912de031
# ╟─332902e0-28a6-11eb-2b7c-b38ecfeff63b
# ╠═cbcd3e80-28a6-11eb-2c9b-7b6e83510cd0
# ╟─5ee3d0d0-28a7-11eb-0c91-f1ef4e8c8d25
# ╟─6110c2f0-28a7-11eb-25f5-15f394f9ac44
# ╠═009256b0-2766-11eb-3208-21824dedb58f
# ╠═06143c00-276d-11eb-066b-bdc66ae718bc
# ╠═a0057490-276e-11eb-24df-dd4df346d183
# ╠═832cced0-2779-11eb-317a-51f6a7dc2a98
# ╠═58b5b230-277d-11eb-0fa7-0d098f4ab70d
# ╠═1b9077a0-277d-11eb-0da4-8d6cdd1d9a4a
# ╠═33cbad30-2782-11eb-14c5-35599512657d
# ╠═b12a6400-277e-11eb-155d-8b9b9cf56177
# ╠═c19fa5c0-277e-11eb-1640-559e9143177a
# ╠═107337d0-28ff-11eb-2f23-933d94f9d8df
# ╠═17160fc0-2901-11eb-0e1c-9be562177705
# ╠═2bc0819e-28ff-11eb-04e1-75d13c28ab89
# ╟─b8572580-297a-11eb-36d0-1b752484dfe4
# ╠═dda73b90-2902-11eb-0eaf-d9d79fde7518
# ╠═ff11fd80-2900-11eb-179e-19b3f2682029
# ╟─a147f6d0-2907-11eb-12f7-ffb4409424be
# ╟─b9084950-2907-11eb-3f4d-9bce686f420b
# ╠═cc18cf60-2907-11eb-3739-f5ec56fcff4f
# ╠═5369ec60-2908-11eb-0a00-bd170c3142e1
# ╠═1df51b90-277d-11eb-3df1-b5f6c4a123fb
# ╠═2b67f280-1223-11eb-1adf-bb43c135e27c
# ╠═e4303e90-2451-11eb-264f-6dfad8939bbb
# ╠═ea11d440-2451-11eb-2b3a-6dc972a6e57f
# ╠═f26bee92-2452-11eb-1417-91ab179d2c01
# ╠═342e7470-2452-11eb-14ed-9d98d89a2b07
# ╠═3b089af0-2452-11eb-3bed-45ab89873ce9
# ╠═38905280-2453-11eb-0c85-5f7897bd6a79
# ╠═43bed470-2452-11eb-0392-eb8049029f12
