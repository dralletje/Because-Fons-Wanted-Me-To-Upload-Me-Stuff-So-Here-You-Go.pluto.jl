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

# ╔═╡ fc7411f0-27a7-4464-821f-746f2f40ccda
123

# ╔═╡ d95a5cd2-779b-4889-87fe-811048c7ab49
begin
	10
	30
end 

# ╔═╡ aed53ac5-0565-41ff-9be5-1812b54816e6
something

# ╔═╡ 995eb0b0-712f-4e19-917c-a852a9481c9a
x = quote @Map({ Origin = key(), Count = length(_) }) end

# ╔═╡ 82262f12-1723-4999-b184-59dc033d262d
x.args[2].args[3].args[1]

# ╔═╡ 67f8d0cd-6403-4ced-861a-751cdf1e00d5
[Z(), Z()]

# ╔═╡ fe03463f-32ff-4ee7-947a-426a68775c72


# ╔═╡ 20aabb43-5b65-436f-bdc7-f19215af9ee1
mutable_thing = Ref(10)

# ╔═╡ 8f57284d-d275-4bd8-aae7-d9de6dd3a133


# ╔═╡ 73a1a07c-fbe1-4896-b8a6-5143caa0e6c2
mutable_thing[] = 20

# ╔═╡ 315b590f-3c21-4036-b2f5-7feb671c1bb4
z

# ╔═╡ 8fde6c66-e12b-4cb0-9ef0-6e65cec53d71
z

# ╔═╡ 4905891e-5e28-4b31-8a4b-eb37332179d8
@bind bonding html"""<input type=range />"""

# ╔═╡ 87f519d8-4e65-4232-a721-5c2507414b98
bonding

# ╔═╡ 3f3b0df9-212e-4825-adce-89ff9491668b
var"*" == *

# ╔═╡ d67aa8b1-24b1-4339-bf25-3d488e48535c
collect(zip([1,2,3, 4], [4,5,6,7]))

# ╔═╡ a5a81bdd-084c-4272-83e4-6004e94cbd1a
supertypes(Set)

# ╔═╡ 9d7c7fdd-bc54-477d-ba03-a8b511c5439b
true[begin:end]

# ╔═╡ 4e65ffce-7d42-44f9-9614-f5b00f26ffae
struct Gr end

# ╔═╡ bdb561db-497b-41ae-8ab1-c63b03a651db
Gr[end]

# ╔═╡ 85edf3a1-bc18-47f5-9db6-108664650064
function match_path(if_match_fn, template, path)	
	if length(template) > length(path)
		nothing
	else
		if template[end] == var"^"
			prefix_template = template[begin:end-1]
			prefix_path = path[begin:length(prefix_template)]
			suffix = path[length(prefix_template)+1:end]
			match_path(prefix_template, prefix_path) do matches
				(matches..., suffix)
			end
		else
			if length(template) == length(path)
				matches = []
				for (t, p) in zip(template, path)
					if t == var"*"
						push!(matches, p)
					elseif t == p
						continue
					else
						return nothing
					end
				end
				if_match_fn(Tuple(matches))
			else
				nothing
			end
		end
	end
end

# ╔═╡ b2bfe85d-416f-4ac6-b1c8-cdead70d9195
match_path(["cells", *], ["cells", 5]) do (id,)
		id * 2
end

# ╔═╡ ea71a5ee-fd55-491a-b83e-288f6041dfbb
match_path(["cells", *, ^], ["cells", 5, "x", "y", "z"]) do (id,)
		id * 5
end

# ╔═╡ 4d564fcd-4ef4-48ae-8211-b9a4229344d9
struct Wildcard end

# ╔═╡ d9ff196d-1bfb-4c8c-a9a0-ea3e66e363f0
function trigger_resolver(anything, path, values=[])
	(value=anything, matches=values, rest=path)
end

# ╔═╡ e5bc8dd1-d389-4e4e-9e0b-bd94d19818da
function trigger_resolver(resolvers::Dict, path, values=[])
	if length(path) == 0
		throw("No key matched")
	end
	
	segment = path[begin]
	rest = path[begin+1:end]
	for (key, resolver) in resolvers
		if key isa Wildcard
			continue
		end
		if key == segment
			return trigger_resolver(resolver, rest, values)
		end
	end
	
	if haskey(resolvers, Wildcard())
		return trigger_resolver(resolvers[Wildcard()], rest, (values..., segment))
	else
		throw("No key matched")
	end
end

# ╔═╡ 817e8a8c-840c-4da2-a4ce-dabd529c1e0f
resolvers = Dict( 
	"cells" => Dict(
		Wildcard() => function(cell_id, rest)
			"CELL HIT $(cell_id) rest $(rest)"
		end,
	), 
	"path" => function(rest)
		"PATH HIT"
	end,
)

# ╔═╡ 07e4e656-5dbf-43cb-970f-94bcc6e80017
trigger_resolver(resolvers, ["cells", 10, "thing"])

# ╔═╡ 7b3f80b2-4760-4c2c-a4fc-48ed223847fb
no_args = function(; request, _...)
	"No args"
end

# ╔═╡ 459ef124-9e1d-4a32-b9df-dbc650b793cf
struct X
	a
	b
	c
end

# ╔═╡ e3edae68-35f2-40a7-b724-9b4bacd6499c
"$(X(10, 20, 30))"

# ╔═╡ 634f6c3f-fe34-4df0-9519-1fbf44072071
_no_args(request=10, things=10)

# ╔═╡ 1ffbe3b3-06f6-41b0-9df9-990632a920a4
things = function()
	"No args"
end

# ╔═╡ ec2d2812-d7fa-4ddb-a607-82aad9ff20cd
things1 = function(rest)
	"No args"
end

# ╔═╡ 0078e49e-0ae9-48c4-a0a7-03fbde301273
[nothing...]

# ╔═╡ 02e6edb9-7ac2-4c81-9ba7-82a8f6f96498
let
	import DataFrames
end

# ╔═╡ b6a62c6f-538a-4e8f-a5e8-ba9ab41713c3


# ╔═╡ 1d81272b-2ba7-457b-9346-24b91d609a42


# ╔═╡ 78f241d3-466a-4d0b-acfc-35b10b080a4a
begin
	import DataFrames
end

# ╔═╡ 1f1efcfa-879c-48e8-9c61-bfcedae02a78
DataFrames

# ╔═╡ 589e934a-7d2b-4429-8634-1ae99009dec0
function P()
	import DataFrames
end

# ╔═╡ d23868ea-17c3-4602-8307-21b12d1a3015
10

# ╔═╡ 82230462-9521-4486-9050-a39765d59f7b
"Hey"

# ╔═╡ Cell order:
# ╠═fc7411f0-27a7-4464-821f-746f2f40ccda
# ╠═d95a5cd2-779b-4889-87fe-811048c7ab49
# ╠═aed53ac5-0565-41ff-9be5-1812b54816e6
# ╠═995eb0b0-712f-4e19-917c-a852a9481c9a
# ╠═82262f12-1723-4999-b184-59dc033d262d
# ╠═67f8d0cd-6403-4ced-861a-751cdf1e00d5
# ╠═fe03463f-32ff-4ee7-947a-426a68775c72
# ╠═20aabb43-5b65-436f-bdc7-f19215af9ee1
# ╠═8f57284d-d275-4bd8-aae7-d9de6dd3a133
# ╠═73a1a07c-fbe1-4896-b8a6-5143caa0e6c2
# ╠═315b590f-3c21-4036-b2f5-7feb671c1bb4
# ╠═8fde6c66-e12b-4cb0-9ef0-6e65cec53d71
# ╠═4905891e-5e28-4b31-8a4b-eb37332179d8
# ╠═87f519d8-4e65-4232-a721-5c2507414b98
# ╠═3f3b0df9-212e-4825-adce-89ff9491668b
# ╠═d67aa8b1-24b1-4339-bf25-3d488e48535c
# ╠═b2bfe85d-416f-4ac6-b1c8-cdead70d9195
# ╠═a5a81bdd-084c-4272-83e4-6004e94cbd1a
# ╠═ea71a5ee-fd55-491a-b83e-288f6041dfbb
# ╠═9d7c7fdd-bc54-477d-ba03-a8b511c5439b
# ╠═4e65ffce-7d42-44f9-9614-f5b00f26ffae
# ╠═bdb561db-497b-41ae-8ab1-c63b03a651db
# ╠═85edf3a1-bc18-47f5-9db6-108664650064
# ╠═4d564fcd-4ef4-48ae-8211-b9a4229344d9
# ╠═d9ff196d-1bfb-4c8c-a9a0-ea3e66e363f0
# ╠═e5bc8dd1-d389-4e4e-9e0b-bd94d19818da
# ╠═07e4e656-5dbf-43cb-970f-94bcc6e80017
# ╠═817e8a8c-840c-4da2-a4ce-dabd529c1e0f
# ╠═7b3f80b2-4760-4c2c-a4fc-48ed223847fb
# ╠═e3edae68-35f2-40a7-b724-9b4bacd6499c
# ╠═459ef124-9e1d-4a32-b9df-dbc650b793cf
# ╠═634f6c3f-fe34-4df0-9519-1fbf44072071
# ╠═1ffbe3b3-06f6-41b0-9df9-990632a920a4
# ╠═ec2d2812-d7fa-4ddb-a607-82aad9ff20cd
# ╠═0078e49e-0ae9-48c4-a0a7-03fbde301273
# ╠═02e6edb9-7ac2-4c81-9ba7-82a8f6f96498
# ╠═b6a62c6f-538a-4e8f-a5e8-ba9ab41713c3
# ╠═1d81272b-2ba7-457b-9346-24b91d609a42
# ╠═1f1efcfa-879c-48e8-9c61-bfcedae02a78
# ╠═78f241d3-466a-4d0b-acfc-35b10b080a4a
# ╠═589e934a-7d2b-4429-8634-1ae99009dec0
# ╠═d23868ea-17c3-4602-8307-21b12d1a3015
# ╠═82230462-9521-4486-9050-a39765d59f7b
