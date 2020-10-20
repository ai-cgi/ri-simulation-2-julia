### A Pluto.jl notebook ###
# v0.12.4

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
	if !endswith(pwd(), "computationalthinking")
	    cd("computationalthinking")
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

    add Julia <ENTER>

3. I usually put my Pluto notebooks in a subdirectory of the Pluto directory.
4. When you start Pluto (see below), you then can select it in the "Open from file" field.
5. The code block marked with "Setting up the libraries" needs some attention:
   You should replace "computationalthinking" with the name of your subdirectory (twice).

"""

# ╔═╡ 708af13e-114d-11eb-387c-436d11865e42
md"# Let's make a Labyrinth"

# ╔═╡ e479b78e-10b1-11eb-0d37-fbdd2869eef7
"Function so short, we could have omitted it. Creates a random nxm array of 0 and 1."
function makeRandomLabyrinth(n, m)
	arr = rand([0.0, 1.0], n, m)
end

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

# ╔═╡ 041d3050-115b-11eb-1792-13f40e80ec8d
md" Now we have a labyrinth with a possible path from start to goal."

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

# ╔═╡ d5990fa0-109d-11eb-1e3a-31f426f6600d
struct Pos
	x
	y
end

# ╔═╡ 83602dc0-1126-11eb-3632-e7de171beefd
begin
	n = 10
	m = 17
	start = Pos(1,1)
	goal  = Pos(n,m)
	environment = makeRandomLabyrinthWithPath(n, m, start, goal)
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

# ╔═╡ 65b5aca0-122f-11eb-2589-0f42d5b6200b
#with_terminal() do
begin
	plop = rand(3,3)
	pppp = one(plop)
	pppp * plop - plop
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

# ╔═╡ 245ac230-1230-11eb-0d47-4dff5b33feb0
left(Pos(3,4))

# ╔═╡ 6c19af50-109b-11eb-0925-a1468e9692a2
actions = [up, down, left, right]

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

# ╔═╡ 8d3976d0-109f-11eb-39e5-3164b85a0502
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

# ╔═╡ 27a00cd0-10a9-11eb-2f12-abb2475ba54d
function run()
	limit = 5000
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
r = run();

# ╔═╡ a141de80-10ac-11eb-3922-e3f4f0a071f6
md"Run $(r[end]==goal ? \"successful\" : \"gave up\") after $(length(r)) steps."

# ╔═╡ 7f2b0e90-1131-11eb-1cd0-e178e8d1c29a
md"## Hint: Select the slider, and then use cursor left / right keys."

# ╔═╡ 61f04e10-10ac-11eb-18b1-ab2d0f9958c4
@bind step Slider(1:length(r), default = 1, show_value=true)

# ╔═╡ 8289cb60-10ac-11eb-1a06-0de38c71a4fc
showPos(r[step])

# ╔═╡ 55233a80-10b1-11eb-2b60-2dd005c9f975
function mc(n)
	r = run()
	for i in 2:n
		r2 = run()
		if length(r2) < length(r)
			r = r2
		end
	end
	r
end

# ╔═╡ 7bb391b0-114a-11eb-01b4-6b160f733e0b
with_terminal() do
    global ro = @time mc(100_000)
end

# ╔═╡ 0da83940-114b-11eb-3fe7-154d0376336f
@bind stepo Slider(1:length(ro), default = 1, show_value=true)

# ╔═╡ 9ea00a40-114b-11eb-2c07-2b490e8f9460
showPos(ro[stepo])

# ╔═╡ ec8d3a6e-114b-11eb-1959-9136912de031
md"Best run in $(length(ro)) steps."

# ╔═╡ 2b67f280-1223-11eb-1adf-bb43c135e27c
[Gray(0.5) Gray(0.9) RGB(0.9,0.0,0.0)] 

# ╔═╡ 3b11e970-122d-11eb-2ca5-8364b8e87f47
a = 24

# ╔═╡ 3edecff2-122d-11eb-280a-79af4ba54967
b = 112 * a

# ╔═╡ 5250d6f0-122d-11eb-1fe8-59441130ce59
c = inc(b)

# ╔═╡ Cell order:
# ╟─873e67a0-114d-11eb-0e58-17a0964b9172
# ╠═66f2f870-108b-11eb-0ce6-1f6e07b93a46
# ╟─708af13e-114d-11eb-387c-436d11865e42
# ╠═e479b78e-10b1-11eb-0d37-fbdd2869eef7
# ╠═2e0d2a90-10b2-11eb-0c7a-eb5318672ebe
# ╠═e63a8f80-10b3-11eb-2838-b1948ba267b8
# ╠═74d89c8e-10b5-11eb-08dc-89bcdfc5030c
# ╠═83602dc0-1126-11eb-3632-e7de171beefd
# ╟─041d3050-115b-11eb-1792-13f40e80ec8d
# ╠═93f69d70-10b5-11eb-214d-951a0c4cf443
# ╠═7ead0960-108b-11eb-16fd-fdb97b1d32f2
# ╠═6308cb50-109e-11eb-20d8-3999269f6b41
# ╠═0c84c5ee-109d-11eb-298f-d938ebce3865
# ╠═9a05b1d0-1220-11eb-36c3-073f6da8f29d
# ╠═3e51e86e-109c-11eb-3c8a-f9f613e454d7
# ╠═2d2fe160-109b-11eb-359a-f77ff97f44f8
# ╠═d5990fa0-109d-11eb-1e3a-31f426f6600d
# ╠═65b5aca0-122f-11eb-2589-0f42d5b6200b
# ╠═9eb7d610-109d-11eb-3b7e-09ec7b457e39
# ╠═245ac230-1230-11eb-0d47-4dff5b33feb0
# ╠═6c19af50-109b-11eb-0925-a1468e9692a2
# ╠═1b8f6940-109f-11eb-21b1-2f315e51268b
# ╠═8d3976d0-109f-11eb-39e5-3164b85a0502
# ╠═a107e3c0-10a1-11eb-2d51-79e604b51e0b
# ╠═34449bb0-10a2-11eb-361d-df29435cc335
# ╠═b240f540-10a2-11eb-37f6-dbe5571bd876
# ╠═eb2c2fa0-10a2-11eb-0858-8f74d1315800
# ╠═27a00cd0-10a9-11eb-2f12-abb2475ba54d
# ╠═7b189c60-10a9-11eb-3495-e3b92b38c968
# ╟─a141de80-10ac-11eb-3922-e3f4f0a071f6
# ╟─7f2b0e90-1131-11eb-1cd0-e178e8d1c29a
# ╟─61f04e10-10ac-11eb-18b1-ab2d0f9958c4
# ╠═8289cb60-10ac-11eb-1a06-0de38c71a4fc
# ╠═55233a80-10b1-11eb-2b60-2dd005c9f975
# ╠═7bb391b0-114a-11eb-01b4-6b160f733e0b
# ╟─0da83940-114b-11eb-3fe7-154d0376336f
# ╠═9ea00a40-114b-11eb-2c07-2b490e8f9460
# ╟─ec8d3a6e-114b-11eb-1959-9136912de031
# ╠═2b67f280-1223-11eb-1adf-bb43c135e27c
# ╠═5250d6f0-122d-11eb-1fe8-59441130ce59
# ╠═3b11e970-122d-11eb-2ca5-8364b8e87f47
# ╠═3edecff2-122d-11eb-280a-79af4ba54967
