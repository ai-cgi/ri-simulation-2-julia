### A Pluto.jl notebook ###
# v0.12.11

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
	dir = "./computationalthinking/"
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
	if !haskey(Pkg.installed(), "Random")
		Pkg.add("Random")
	end
	using PlutoUI # enables the Sliders
	using Colors  # Gray, RGB
	using Random
end

# ╔═╡ 873e67a0-114d-11eb-0e58-17a0964b9172
md""" 

NOTE:

This is a Pluto notebook. So, to get it running, please 

1. Install Julia. [julialang.org](http://julialang.org)
2. In Julia, install Pluto, by hitting ] to enter the package mode, and then type

    add Julia <ENTER>

3. I usually put my Pluto notebooks in a subdirectory of the Pluto directory.
4. When you start Pluto (see below), you then can select it in the "Open from file" field.
5. The code block marked with "Setting up the libraries" needs some attention:
   You should replace "computationalthinking" with the name of your subdirectory.
6. Start Julia, then start Pluto with: 

    `using Pluto; Pluto.run()`

"""

# ╔═╡ 708af13e-114d-11eb-387c-436d11865e42
md"# Let's make a Labyrinth"

# ╔═╡ 5d1e20e0-2837-11eb-1fad-d70c35b9f138
md"The flood function 'pours' into start, and fills every white space that is reachable"

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

# ╔═╡ 83602dc0-1126-11eb-3632-e7de171beefd
# The with_terminal() makes the output visible. Otherwise, Pluto will only show the
# result of the computation.
#with_terminal() do
#	n = mazeHeight # danger of loop. with 50% walls 15x20 needs already ~ 1..5k tries to find maze with path
#	m = mazeWidth
#	global start = Pos(1,1)
#	global goal  = Pos(n,m)
#	global environment = makeRandomLabyrinthWithPath(n, m, start, goal)
#	:ok
#end

# ╔═╡ 6308cb50-109e-11eb-20d8-3999269f6b41
md"The first index counts from top down, the second left to right. Starts with one."

# ╔═╡ 0c84c5ee-109d-11eb-298f-d938ebce3865
vis(mx) = let normalizer = maximum(mx)
	map(n -> RGB(n/normalizer, n/normalizer, n/normalizer), mx)
end

# ╔═╡ 3e51e86e-109c-11eb-3c8a-f9f613e454d7
# adds a border
function enclose(mx, what)
	(n, m) = size(mx)
	sides = fill(what, n+2)
	updwn = fill(what, 1, m)
	hcat(sides, vcat(updwn, mx, updwn), sides)
end

# ╔═╡ d5990fa0-109d-11eb-1e3a-31f426f6600d
struct Pos
	x
	y
end

# ╔═╡ 9eb7d610-109d-11eb-3b7e-09ec7b457e39
begin
	inc(x)   = x + one(x)
	dec(x)   = x - one(x)
	left(p)  = Pos(p.x, dec(p.y))
	right(p) = Pos(p.x, inc(p.y))
	up(p)    = Pos(dec(p.x), p.y)
	down(p)  = Pos(inc(p.x), p.y)
end

# ╔═╡ 6c19af50-109b-11eb-0925-a1468e9692a2
actions = [up, down, left, right]

# ╔═╡ 8d3976d0-109f-11eb-39e5-3164b85a0502
#allowedPosition(start)

# ╔═╡ 60493b8e-2d59-11eb-2a1c-f5c9016ef152
md"## a branching labyrinth"

# ╔═╡ e326a362-2d58-11eb-0a7c-d5105081b4a4
struct Branch
	cells
	heads
	touchesWall
end

# ╔═╡ 0a371f6c-2d6e-11eb-0b6a-63d85a1928a0
# return a square around the current position minus border
#function around(pos, env, branch)
#	candidates = [up(pos), right(up(pos)), left(up(pos)), down(pos), left(down(pos)), #right(down(pos)), left(pos), right(pos)]
#	
#	(xMax, yMax) = size(env)
#	# && !(p ∈ branch.cells
#	filter!(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax ), candidates)
#end

# ╔═╡ 47f540ba-2dcb-11eb-37c0-d5eb23030583
#function validSize(pos, env, branch)
#	aroundCells = filter(p->env[p.x, p.y] == 1.0, around(pos, env, branch))
#	size(aroundCells, 1)	
#end

# ╔═╡ 9f570da0-2dc8-11eb-122f-9992dc9b56c9
begin
	
	# return a square around the current position minus border
	function around(pos, env, branch)
		candidates = [up(pos), right(up(pos)), left(up(pos)), down(pos), left(down(pos)), right(down(pos)), left(pos), right(pos)]
	
		(xMax, yMax) = size(env)
		# && !(p ∈ branch.cells
		filter!(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax  && env[p.x, p.y] == 0), candidates)
	end
	
	function validSize(pos, env, branch)
		aroundCells = filter(p->env[p.x, p.y] == 1.0, around(pos, env, branch))
		size(aroundCells, 1)	
	end
	
	function validNeighbors(pos, env, branch)
		candidates = [up(pos), down(pos), left(pos), right(pos)]
		(xMax, yMax) = size(env)
		filter!(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax && env[p.x, p.y] == 1), candidates)
		#println(   size(around(candidates[1],env, branch),1))
		#println(   validSize(candidates[1], env, branch))
		filter!(p->(size(around(p, env, branch), 1) - (validSize(p, env, branch)) <= 2 ), candidates)
		#filter(p->( 8 >= (validSize(p, env, branch)) ), candidates)
		if branch.touchesWall[1]
			(xMax, yMax) = size(env)
			filter!(!(r->r.x<=1 || r.y<=1 || r.x>=xMax || r.y>=yMax), candidates)
		end
		candidates
	end
end

# ╔═╡ 81404b50-2de2-11eb-1ec2-03ef8452a484
function leftOrRight(pos, env, branch)
	candidates = [left(pos), right(pos)]
	(xMax, yMax) = size(env)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	size(blank, 1)>=1
end

# ╔═╡ a8d1d1ac-2ddd-11eb-3bdf-b3b0810a6f90
function validUp(pos, env, branch)
	candidates = [pos, up(pos), left(up(pos)), right(up(pos)), left(pos), right(pos)]
	(xMax, yMax) = size(env)
	#filter!(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax && env[p.x, p.y] == 1), candidates)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	(size(blank, 1)==size(field, 1)) && leftOrRight(down(pos), env, branch)
end

# ╔═╡ 107abaf8-2de0-11eb-3569-0307ade15455
function validDown(pos, env, branch)
	candidates = [pos, down(pos), left(down(pos)), right(down(pos)), left(pos), right(pos)]
	(xMax, yMax) = size(env)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	(size(blank, 1)==size(field, 1)) && leftOrRight(up(pos), env, branch)
end

# ╔═╡ 00e87274-2de3-11eb-0894-51974bf1539b
function upOrDown(pos, env, branch)
	candidates = [up(pos), down(pos)]
	(xMax, yMax) = size(env)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	size(blank, 1)>=1
end

# ╔═╡ 2d4fafe8-2ddf-11eb-10ba-0140f68f427f
function validRight(pos, env, branch)
	candidates = [pos, right(pos), right(up(pos)), right(down(pos)), up(pos), down(pos)]
	(xMax, yMax) = size(env)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	(size(blank, 1)==size(field, 1)) && upOrDown(left(pos), env, branch)
end

# ╔═╡ edff6e04-2ddf-11eb-3620-b3498e82f553
function validLeft(pos, env, branch)
	candidates = [pos, left(pos), left(up(pos)), left(down(pos)), up(pos), down(pos)]
	(xMax, yMax) = size(env)
	field = filter(p -> (0 < p.x && 0 < p.y && p.x <= xMax && p.y <= yMax), candidates)
	blank = filter(p->  env[p.x, p.y] == 1, field)
	(size(blank, 1)==size(field, 1)) && upOrDown(right(pos), env, branch)
end

# ╔═╡ 44c52d94-2ddd-11eb-0881-b9fc6253847c
function validNeighbors2(pos, env, branch)
	result = []
	if validUp(up(pos), env, branch) push!(result, up(pos)) end
	if validDown(down(pos), env, branch) push!(result, down(pos)) end
	if validRight(right(pos), env, branch) push!(result, right(pos)) end
	if validLeft(left(pos), env, branch) push!(result, left(pos)) end
	if branch.touchWall[1]
		(xMax, yMax) = size(env)
		filter!(r->r.x==0 || r.y==0 || r.x==xMax || r.y==yMax, result)
	end
	result
end

# ╔═╡ d5f06ab2-2d6e-11eb-2966-21146aba3ebf
#around(Pos(1,1))

# ╔═╡ 43e3f470-2d59-11eb-1e79-2ff78cadc866
function grow(branch, env)
	# TODO use for branching
	headCandidates = filter(h -> ! (h ∈ branch.heads), branch.cells)
	
	if size(branch.heads,1)>0
		activeHead = rand(branch.heads)
		println(activeHead)
		vn = validNeighbors(activeHead, env, branch)
		println(vn)
		if(size(vn,1)>0)
			nextPos = rand(vn) 
			push!(branch.cells, nextPos)
			push!(branch.heads, nextPos)
			env[nextPos.x, nextPos.y] = 0.0
			filter!(h->h != activeHead, branch.heads)
			println(branch)
			r = nextPos
			(xMax, yMax) = size(env)
			if r.x<=1 || r.y<=1 || r.x>=xMax || r.y>=yMax
				branch.touchesWall[1] = true
			end
		else
			filter!(h->h != activeHead, branch.heads)
		end
	end
	branch
end

# ╔═╡ 2a1ebbfc-2d96-11eb-00e5-2588060691c8
#with_terminal() do
begin
	e = [[1.0 1.0 1.0]
		[1.0 0.0 1.0]
		[1.0 1.0 1.0]
		[1.0 1.0 1.0]
		[1.0 1.0 1.0]]
	println(size(e))
	grow(Branch([Pos(2,2)],[Pos(2,2)], [false]), copy(e))
end

# ╔═╡ 86475416-2d85-11eb-0391-3576c0f73fc6
function makeEmptyLabyrinthWithPath(n, m)
	rand([1.0], n, m) 
end

# ╔═╡ bc4a3044-2dc4-11eb-06cc-1ff253a196be
function placeSeed(s, start, goal, env)
	(width, height) = size(env)
	Pos(rand(2:width-1), rand(2:height-1))
end

# ╔═╡ 1f8d50d0-2d86-11eb-30d0-7f9de19e8a30
function buildEmptyMaze(mazeHeight, mazeWidth)
	n = mazeHeight # danger of loop. with 50% walls 15x20 needs already ~ 1..5k tries to find maze with path
		m = mazeWidth
		start = Pos(1,1)
		goal  = Pos(n,m)
		env = makeEmptyLabyrinthWithPath(n, m)
	
	(env, start, goal)
end

# ╔═╡ bd7d4a90-28a2-11eb-29a8-6977d054b789
md"""## A slime mold.
This simulates the simple organism Physarum polycephalum, that is capable to find it's way through mazes.
Quite aMazeIng!

See on [YouTube](https://www.youtube.com/watch?v=HyzT5b0tNtk)
"""

# ╔═╡ 42253b24-2c2a-11eb-2be3-03ea0f2f5c73
struct FuligoState
	visited
	heads
	paths
end

# ╔═╡ 358d8b62-2dda-11eb-28ed-b973a68b4297
building = false

# ╔═╡ 88ad4fa2-2d86-11eb-1619-59ec21e70a82
@bind mazeType Select(["random" , "empty", "branching"], default="random")

# ╔═╡ d9b1930c-2ca2-11eb-08ef-316ff1de6859
md"density: $(@bind mazeDensity Slider(10:45, default = 30, show_value=true))"

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
	ratio = mazeDensity
	randomData = push!(vec(fill(1.0, (100-ratio,1))), vec(fill(0.0, (ratio,1)))...)
	arr = rand(randomData, n, m) #[0.0,1.0,1.0]
end

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
	while rf[p2.x, p2.y] != floodVal && generateCounter < 10
		r = makeRandomLabyrinth(n, m)
		generateCounter += 1
		rf = flood(copy(r), p1.x, p1.y, 1.0, floodVal)
	end
	println("Valid labyrinth after $generateCounter tries.")
	r
end

# ╔═╡ f62e6a68-2c9e-11eb-0882-49b61e6864e3
md"maze height: $(@bind mazeHeight Slider(1:200, default = 60, show_value=true))"

# ╔═╡ 9b5f5a4c-2c9f-11eb-1859-dd4a15669a17
md"maze width: $(@bind mazeWidth Slider(1:300, default = 80, show_value=true))"

# ╔═╡ bbadf27a-2d82-11eb-0145-537378cddfde
function buildRandomMaze()
	# The with_terminal() makes the output visible. Otherwise, Pluto will only show the
	# result of the computation.
	
		n = mazeHeight # danger of loop. with 50% walls 15x20 needs already ~ 1..5k tries to find maze with path
		m = mazeWidth
		start = Pos(1,1)
		goal  = Pos(n,m)
		env = makeRandomLabyrinthWithPath(n, m, start, goal)
	
	(env, start, goal)
end

# ╔═╡ 6735d49a-2d98-11eb-1f5b-f9a7bb1a13e9
md"branch cycles: $(@bind branchCycles Slider(1:100, default = 2, show_value=true))"

# ╔═╡ 5ac695ca-2dc3-11eb-0c4e-61152a2cf867
md"seed count: $(@bind seedCount Slider(1:100, default = 1, show_value=true))"

# ╔═╡ ebe9cbfe-2d83-11eb-3376-c3b1dd0cf3c7
function buildBranchingMaze(mazeHeight, mazeWidth, env)
	start = Pos(1,1)
	goal  = Pos(mazeHeight,mazeWidth)
	env = makeEmptyLabyrinthWithPath(mazeHeight,mazeWidth)

	
	heads = map(s-> placeSeed(s, start, goal, env) ,(1 : seedCount))
	branches = copy(map(h -> Branch([h],[h, h], [false]), heads))
	# ewolveBranches
	for i in 1:branchCycles
		for branch in branches
		 grow(branch, env)
		end
	end
	
	# write to maze
	for branch in branches
		for cell in branch.cells
			env[cell.x, cell.y] = 0.0
		end
	end
	(env, start, goal)
end

# ╔═╡ 1467e648-2d86-11eb-1343-cdf9827acb86
if mazeType == "random"
	global(environment, start, goal) = buildRandomMaze()
elseif mazeType == "branching"
	env = makeEmptyLabyrinthWithPath(mazeHeight, mazeWidth)
	global(environment, start, goal) = buildBranchingMaze(mazeHeight, mazeWidth, env)
else
	global(environment, start, goal) = buildEmptyMaze(mazeHeight, mazeWidth)
end


# ╔═╡ 1b8f6940-109f-11eb-21b1-2f315e51268b
function allowedPosition(p)
	let (xMax, yMax) = size(environment)
		0 < p.x &&
		0 < p.y &&
		p.x <= xMax &&
		p.y <= yMax &&
		environment[p.x, p.y] == 1
	end
end

# ╔═╡ a107e3c0-10a1-11eb-2d51-79e604b51e0b
allowedActions(currentPos) = filter(f -> allowedPosition(f(currentPos)), actions)

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

# ╔═╡ 070353b2-2c22-11eb-223e-9f39e48bede6
function expand()
	
	limit = if building 1 else 1000 end
	states = [FuligoState([start], [start], Dict(start => [start]))]
	
	count = 0
	while count < limit && !(goal ∈ states[end].heads)
        count += 1
		currentHeads = copy(states[end].heads)
		visited = copy(states[end].visited)
		paths = deepcopy(states[end].paths)
		
		posNextPos = vcat(
			map(p -> 
				map(a-> (p, a(p)), allowedActions(p)),
				currentHeads
			)...
		)
		
		newHeads = []
		newPaths = Dict()
		for (pos, nextPos) in shuffle!(posNextPos) # shuffling makes it natural
			if !(nextPos ∈ visited)
				push!(newHeads, nextPos)
				push!(visited, nextPos)
				newPaths[nextPos] = push!(copy(paths[pos]), nextPos)		
			end
		end
		push!(states, FuligoState(visited, newHeads, newPaths))
	end
	states
	
end

# ╔═╡ 303cc1bc-2da2-11eb-2737-852198e8a6fd
@bind enablePath CheckBox(default=true)

# ╔═╡ 6ba2c8d4-2c2f-11eb-1643-41763d6c4706
function showFuligo(f)
	# TODO show labyrinth heads
	
	
	
    v = vis(enclose(environment, 0.7))
	
	visited = f.visited
	for vis in visited
		v[vis.x+1, vis.y+1] = RGB(1.0,1.0,0.6)
	end
	
	if enablePath
		paths = f.paths
		for (_, ps) in paths
			for p in ps
				v[p.x+1, p.y+1] = RGB(0.6,0.7,0.6)
			end
		end
	end
		
	heads = f.heads
	for h in heads
		v[h.x+1, h.y+1] = RGB(1.0,0.8,0.0)
	end
	
	v[start.x+1, start.y+1] = RGB(1.0,0.0,0.0)
	v[goal.x+1, goal.y+1] = RGB(0.0,1.0,0.0)
	v
end

# ╔═╡ bbb98ffc-2c30-11eb-13d2-bd43c7ef0560
#with_terminal() do 
	fuligo = expand()
#end

# ╔═╡ 7a2390c4-2c30-11eb-3ecc-cb0817f36cb0
md"step: $(@bind fStep Slider(1:length(fuligo), default = 1, show_value=true))"

# ╔═╡ 0b590ab2-2cc0-11eb-03a9-b54366a73e12
md"one minimal path is $(length(fuligo[end].paths[goal])) steps long"

# ╔═╡ 98f1647e-2c30-11eb-3f17-a92df4c7e9be
showFuligo(fuligo[fStep])

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
# ╠═5d1e20e0-2837-11eb-1fad-d70c35b9f138
# ╠═e63a8f80-10b3-11eb-2838-b1948ba267b8
# ╠═9f8d9320-2837-11eb-06a8-c1a84f786de8
# ╠═74d89c8e-10b5-11eb-08dc-89bcdfc5030c
# ╠═83602dc0-1126-11eb-3632-e7de171beefd
# ╠═bbadf27a-2d82-11eb-0145-537378cddfde
# ╠═6308cb50-109e-11eb-20d8-3999269f6b41
# ╠═0c84c5ee-109d-11eb-298f-d938ebce3865
# ╠═3e51e86e-109c-11eb-3c8a-f9f613e454d7
# ╠═d5990fa0-109d-11eb-1e3a-31f426f6600d
# ╠═9eb7d610-109d-11eb-3b7e-09ec7b457e39
# ╠═6c19af50-109b-11eb-0925-a1468e9692a2
# ╠═1b8f6940-109f-11eb-21b1-2f315e51268b
# ╠═8d3976d0-109f-11eb-39e5-3164b85a0502
# ╠═a107e3c0-10a1-11eb-2d51-79e604b51e0b
# ╠═b240f540-10a2-11eb-37f6-dbe5571bd876
# ╟─60493b8e-2d59-11eb-2a1c-f5c9016ef152
# ╠═e326a362-2d58-11eb-0a7c-d5105081b4a4
# ╠═0a371f6c-2d6e-11eb-0b6a-63d85a1928a0
# ╠═47f540ba-2dcb-11eb-37c0-d5eb23030583
# ╠═9f570da0-2dc8-11eb-122f-9992dc9b56c9
# ╠═a8d1d1ac-2ddd-11eb-3bdf-b3b0810a6f90
# ╠═107abaf8-2de0-11eb-3569-0307ade15455
# ╠═2d4fafe8-2ddf-11eb-10ba-0140f68f427f
# ╠═edff6e04-2ddf-11eb-3620-b3498e82f553
# ╠═81404b50-2de2-11eb-1ec2-03ef8452a484
# ╠═00e87274-2de3-11eb-0894-51974bf1539b
# ╠═44c52d94-2ddd-11eb-0881-b9fc6253847c
# ╠═d5f06ab2-2d6e-11eb-2966-21146aba3ebf
# ╠═43e3f470-2d59-11eb-1e79-2ff78cadc866
# ╠═2a1ebbfc-2d96-11eb-00e5-2588060691c8
# ╠═86475416-2d85-11eb-0391-3576c0f73fc6
# ╠═bc4a3044-2dc4-11eb-06cc-1ff253a196be
# ╠═ebe9cbfe-2d83-11eb-3376-c3b1dd0cf3c7
# ╠═1f8d50d0-2d86-11eb-30d0-7f9de19e8a30
# ╠═1467e648-2d86-11eb-1343-cdf9827acb86
# ╟─bd7d4a90-28a2-11eb-29a8-6977d054b789
# ╠═42253b24-2c2a-11eb-2be3-03ea0f2f5c73
# ╠═358d8b62-2dda-11eb-28ed-b973a68b4297
# ╠═070353b2-2c22-11eb-223e-9f39e48bede6
# ╠═6ba2c8d4-2c2f-11eb-1643-41763d6c4706
# ╠═88ad4fa2-2d86-11eb-1619-59ec21e70a82
# ╟─d9b1930c-2ca2-11eb-08ef-316ff1de6859
# ╟─f62e6a68-2c9e-11eb-0882-49b61e6864e3
# ╟─9b5f5a4c-2c9f-11eb-1859-dd4a15669a17
# ╟─6735d49a-2d98-11eb-1f5b-f9a7bb1a13e9
# ╟─5ac695ca-2dc3-11eb-0c4e-61152a2cf867
# ╟─303cc1bc-2da2-11eb-2737-852198e8a6fd
# ╟─7a2390c4-2c30-11eb-3ecc-cb0817f36cb0
# ╟─0b590ab2-2cc0-11eb-03a9-b54366a73e12
# ╠═98f1647e-2c30-11eb-3f17-a92df4c7e9be
# ╠═bbb98ffc-2c30-11eb-13d2-bd43c7ef0560
# ╠═1df51b90-277d-11eb-3df1-b5f6c4a123fb
# ╠═2b67f280-1223-11eb-1adf-bb43c135e27c
# ╠═e4303e90-2451-11eb-264f-6dfad8939bbb
# ╠═ea11d440-2451-11eb-2b3a-6dc972a6e57f
# ╠═f26bee92-2452-11eb-1417-91ab179d2c01
# ╠═342e7470-2452-11eb-14ed-9d98d89a2b07
# ╠═3b089af0-2452-11eb-3bed-45ab89873ce9
# ╠═38905280-2453-11eb-0c85-5f7897bd6a79
# ╠═43bed470-2452-11eb-0392-eb8049029f12
