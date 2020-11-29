### A Pluto.jl notebook ###
# v0.12.9

using Markdown
using InteractiveUtils

# ╔═╡ d948dc6e-2de1-11eb-19e7-cb3bb66353b6
md"## Immer"

# ╔═╡ d9634d9c-2de1-11eb-1fc6-037489c3a4fb
Base.@kwdef struct Cell
	id
	code::String
	folded::Bool
end

# ╔═╡ d9781358-2de1-11eb-2590-fd8bd91f8a10
Base.@kwdef struct Notebook
	id
	path::String
	cells::Dict{Any, Cell}
end

# ╔═╡ d98c520a-2de1-11eb-3ec4-e53c8fb0ae4f
function Base.:(==)(a::Notebook, b::Notebook)
	a.id == b.id && a.path == b.path && a.cells == b.cells
end

# ╔═╡ d9a22c06-2de1-11eb-2a9f-6fb5a5b8badf
setdiff(Dict(:x => 1), Dict(:x => 1))

# ╔═╡ d9b68804-2de1-11eb-00cd-113a17cbff74
values(Dict(:x => 1))

# ╔═╡ d9ce3580-2de1-11eb-25d0-b7cf9af1fcaa
notebook1 = Notebook(
	id = 1,
	path = "/app",
	cells = Dict(
		1 => Cell(
			id = 1,
			code = "x = 1",
			folded = false
		),
		2 => Cell(
			id = 2,
			code = "x = 1",
			folded = false
		),
		3 => Cell(
			id = 3,
			code = "x = 1",
			folded = false
		)
	)
)

# ╔═╡ d9e25a6a-2de1-11eb-2093-294134d73e3b
notebook2 = Notebook(
	id = 1,
	path = "/app",
	cells = Dict(
		1 => Cell(
			id = 1,
			code = "x = 2",
			folded = true
		),
		2 => Cell(
			id = 2,
			code = "x = 1",
			folded = false
		),
		3 => Cell(
			id = 3,
			code = "x = 1",
			folded = false
		)
	)
)

# ╔═╡ da4d4028-2de1-11eb-32ee-2b036fc04dfa
md"### AtPath"

# ╔═╡ da6343e4-2de1-11eb-26b4-733c5e4f29e8
Base.@kwdef struct AtPath{T}
	path::AbstractArray
	value::T
end

# ╔═╡ da775e10-2de1-11eb-2dfe-410470cf9ed3
Base.:(==)(a::AtPath, b::AtPath) = a.path == b.path && a.value == b.value

# ╔═╡ da8bb786-2de1-11eb-1e75-a3aac0d369cf
const Path = AbstractArray

# ╔═╡ daa028b0-2de1-11eb-087f-ff7ef5f3da2b
atpath(path::Path, value) = isempty(path) ? value : AtPath(path=path, value=value)

# ╔═╡ dab468fc-2de1-11eb-32b5-7d90db553189
atpath(path::Path, ::Nothing) = nothing

# ╔═╡ daca9af0-2de1-11eb-24f8-630215821fbf
function atpath(path::Path, values::AbstractArray)
	paths = filter(!isnothing, [
		atpath(path, value)
		for (index, value)
		in pairs(values)
	])
	if length(paths) == 0
		nothing
	elseif length(paths) == 1
		paths[begin]
	else
		paths
	end
end

# ╔═╡ dade8bb4-2de1-11eb-0b3f-852feb7c086c
function atpath(path::Path, value::AtPath)
	atpath([path..., value.path...], value.value)
end

# ╔═╡ daf9ec12-2de1-11eb-3a8d-59d9c2753134
md"## Diff"

# ╔═╡ db116c0a-2de1-11eb-2a56-872af797c547
abstract type Change end

# ╔═╡ db2d8a3e-2de1-11eb-02b8-9ffbfaeff61c
struct UpdateChange <: Change
	changes
end

# ╔═╡ db49d59a-2de1-11eb-2a6b-49399b175a9b
Base.:(==)(a::UpdateChange, b::UpdateChange) = a.changes == b.changes

# ╔═╡ db5df660-2de1-11eb-2aa2-c785aab9c00a
Base.@kwdef struct SetChange <: Change
	from
	to
end

# ╔═╡ db75df12-2de1-11eb-0726-d1995cebd382
function diff(old::T, new::T, comparedeep::Bool=false) where T
	if comparedeep == false
		old == new ? [] : [SetChange(from=old, to=new)]
	else
		changes = filter(!isnothing, [
			atpath(
				[property], 
				diff(getproperty(old, property), getproperty(new, property))
			)
			for property
			in fieldnames(T)
		])

		if (
			!isempty(changes) &&
			changes isa AbstractArray &&
			all(x ->
				x isa AtPath &&
				x.value isa Change &&
				length(x.path) == 1
			, changes)
		)
			UpdateChange(changes)
		else
			changes
		end
	end
end

# ╔═╡ db8ba47c-2de1-11eb-3775-c95eae15f759
diff(old::Cell, new::Cell) = diff(old, new, old.id == new.id)

# ╔═╡ dbb0ba44-2de1-11eb-1c0c-61c9d8b50fde
diff(old::Notebook, new::Notebook) = diff(old, new, old.id == new.id)

# ╔═╡ dbc7f97a-2de1-11eb-362f-055a734d1a9e
function diff(o1::AbstractDict, o2::AbstractDict)
	changes = []
	for key in keys(o1) ∪ keys(o2)
		push!(changes, atpath([key], diff(get(o1, key, nothing), get(o2, key, nothing))))
	end
	filter(!isnothing, changes)
end

# ╔═╡ 67ade214-2de3-11eb-291d-135a397d629b
function diff(o1, o2)
	[SetChange(from=o1, to=o2)]
end

# ╔═╡ dbdd1df0-2de1-11eb-152f-8d1af1ad02fe
notebook1_to_notebook2 = atpath([], diff(notebook1, notebook2))

# ╔═╡ dbf55672-2de1-11eb-09ce-d99958a23a92
diff(notebook1.cells[1], notebook2.cells[1])

# ╔═╡ dc0ab2b0-2de1-11eb-0597-1b595c1db8c5
flatten = let
	function flatten(path::AtPath)
		values = map(flatten(path.value)) do x
			atpath(path.path, x)
		end
		filter(!isnothing, values)
	end
	flatten(change::UpdateChange) = flatten(change.changes)
	flatten(changes::Array) = filter(!isnothing, vcat(map(flatten, changes)...))
	flatten(x) = [x]
	flatten(::Nothing) = []
end

# ╔═╡ dc202a02-2de1-11eb-36f7-5133c8998470
flatten(notebook1_to_notebook2)

# ╔═╡ dc3657bc-2de1-11eb-34ce-dd2fd5ce971d
md"## JSON Patch"

# ╔═╡ dc4dd374-2de1-11eb-2a2b-d30b2c5606cd
Base.@kwdef struct Patch
	op::Symbol
	value::Any
	path::Array{Any}
end

# ╔═╡ 01f06d42-2de4-11eb-21ae-5f12cdaa15a4
flatten(Patch(op=:add,path=[],value=nothing))

# ╔═╡ dc6e700c-2de1-11eb-00fe-fdbfbdc6c8f3
function Base.:(==)(a::Patch, b::Patch)
	a.op == b.op && a.value == b.value && a.path == b.path
end

# ╔═╡ dc857f4a-2de1-11eb-09b1-693d4971a084
function to_jsonpatch(changes::AbstractArray)::Vector{Patch}
	vcat(map(to_jsonpatch, changes)...)
end

# ╔═╡ dca0c44e-2de1-11eb-24a3-cbdb16cd6257
function to_jsonpatch(change::AtPath{SetChange})::Vector{Patch}
	[Patch(
		op = :replace,
		path = map(change.path) do pathsegment
			if pathsegment isa Symbol
				string(pathsegment)
			else
				pathsegment
			end
		end,
		value = change.value.to,
	)]
end

# ╔═╡ 66139678-2de2-11eb-0c69-5955397d33aa
function to_jsonpatch(change::SetChange)::Vector{Patch}
	[Patch(
		op = :replace,
		path = [],
		value = change.to,
	)]
end

# ╔═╡ dcbe0842-2de1-11eb-236d-b572ab3abf5c
function to_jsonpatch(change::AtPath{UpdateChange})::Vector{Patch}
	flat = flatten(change)
	map(flat) do change
		to_jsonpatch(change)
	end
end

# ╔═╡ 070d10ce-2de3-11eb-1e92-63ac4c7da494
to_jsonpatch(flatten(nothing))

# ╔═╡ 218d5e90-2de3-11eb-1736-f11e02d4c4d7
dict_test = Dict(
	:cells => Dict(
		"something" => Dict(:x => 1, :y => 2),		
		"something2" => Dict(:x => 1, :y => 2),		
		"something3" => Dict(:x => 1, :y => 2),
	),
	:ordering => ["something", "something2", "something3"],
)

# ╔═╡ 46972d56-2de3-11eb-3a85-e16496abab03
dict_test2 = Dict(
	:cells => Dict(
		"something" => Dict(:z => 1, :y => 2),		
		"something2" => Dict(:x => 1, :y => 2),		
		"something3" => Dict(:x => 1, :y => 2),
	),
	:ordering => ["something", "something2", "something3"],
)

# ╔═╡ 4c3dfa0a-2de3-11eb-015a-e7f5b00b9ee6
diff(dict_test, dict_test2)

# ╔═╡ e90064e0-2de3-11eb-2716-9fd56296f7c8
flatten(diff(dict_test, dict_test2))

# ╔═╡ a6f03238-2de3-11eb-3452-b9e97dc4ac83
to_jsonpatch(flatten(diff(dict_test, dict_test2)))

# ╔═╡ dce80d4a-2de1-11eb-3a21-6becd6f75e97
test_jsonpatch = [
	Patch(:replace, "x = 2", ["cells", 1, "code"]),
	Patch(:replace, true, ["cells", 1, "folded"])
]

# ╔═╡ dd0941fe-2de1-11eb-1acf-414ec0ee9fb7
function from_jsonpatch(patches)
	map(patches) do patch
		path = map(patch.path) do pathsegment
			if pathsegment isa String
				Symbol(pathsegment)
			else
				pathsegment
			end
		end
		if patch.op == :replace
			AtPath(
				path = path,
				value = SetChange(from = nothing, to = patch.value),
			)
		else
			throw("Unknown operator :$(patch.op)")
		end
	end
end

# ╔═╡ dd312598-2de1-11eb-144c-f92ed6484f5d
md"## Update"

# ╔═╡ dd4fca34-2de1-11eb-1093-7911b7982b04
takefirst(p::AtPath) = (p.path[begin], atpath(p.path[begin+1:end], p.value))

# ╔═╡ dd87ca7e-2de1-11eb-2ec3-d5721c32f192
function update(value, change::SetChange)
	change.to
end

# ╔═╡ ddaf5b66-2de1-11eb-3348-b905b94a984b
function update(value, change::UpdateChange)
	reduce(change.changes, init=value) do newvalue, change
		update(newvalue, change)
	end
end

# ╔═╡ ddcea842-2de1-11eb-1933-236c2df00832
function update(value::AbstractDict, change::AtPath)
	currentpath, nextchange = takefirst(change)
	Dict(value..., currentpath => update(value[currentpath], nextchange))
end

# ╔═╡ ddf2fcc2-2de1-11eb-1522-3de0178bcaf2
function update(value::T, change::AtPath) where T
	currentpath, nextchange = takefirst(change)
	
	args = [
		if fieldname == currentpath
			update(getfield(value, fieldname), nextchange)
		else
			getfield(value, fieldname)
		end
		for fieldname
		in fieldnames(T)
	]
	T(args...)
end

# ╔═╡ de10449e-2de1-11eb-31e1-4b0fdd7a7d43
function update(value::Any, changes::Array)
	reduce(changes, init=value) do newvalue, change
		update(newvalue, change)
	end
end

# ╔═╡ de3eb3ce-2de1-11eb-0cba-e15c15013051
update(
	notebook1,
	atpath([:cells, 2, :code], SetChange(from=nothing, to="Hey"))
)

# ╔═╡ de5e55da-2de1-11eb-226d-99e9ea4daeec
import Pluto

# ╔═╡ de79598e-2de1-11eb-1647-2fa0c807e980
function get_id(cell::Pluto.Cell)
	cell.cell_id
end

# ╔═╡ de98da50-2de1-11eb-1f42-2bfb651601a3
# notebook1_to_notebook_with_new_cell = diff(notebook1, notebook_with_new_cell)

# ╔═╡ deccd3ca-2de1-11eb-3beb-e794bdcbdc95
# to_jsonpatch(notebook1_to_notebook_with_new_cell)

# ╔═╡ dee4aec8-2de1-11eb-07d1-a37b35c7f45f
# flatten(atpath([], diff(notebook1, notebook_with_new_cell)))

# ╔═╡ defa0900-2de1-11eb-3ae5-7df5163da1be
import UUIDs: UUID, uuid1

# ╔═╡ e1c0e148-2de1-11eb-08fe-a7634f98db8a
function Base.convert(::Type{Cell}, cell::Dict)
	Cell(;cell...)
end

# ╔═╡ e1df94c6-2de1-11eb-05c9-9fe03989454f
d = Dict(:id => 4, :code => "z = x + 1", :folded => false)

# ╔═╡ e20cf22a-2de1-11eb-1487-3f10462b08e3
Base.convert(Cell, d)

# ╔═╡ e2340bb4-2de1-11eb-02c2-63e115d8bd9b
update(
	notebook1,
	from_jsonpatch([
		Patch(
				op=:replace,
				value=Dict(:id => 4, :code => "z = x + 1", :folded => false),
				path=["cells", 3]
		)
	])
)

# ╔═╡ e25a45e0-2de1-11eb-31ee-db4e81ad7ec6
md"## Diff arrays"

# ╔═╡ e288699a-2de1-11eb-386a-bd2b11286514
struct ExampleWithKey
	key
	value
end

# ╔═╡ e2ae8ace-2de1-11eb-18e8-1bfde2676467
example_array = [
	ExampleWithKey(1, "One"),
	ExampleWithKey(2, "Two"),
	ExampleWithKey(3, "Three"),
]

# ╔═╡ e2d572b0-2de1-11eb-09f5-3b6d7c176133
example_array_simple_changed_value = [
	ExampleWithKey(1, "first"),
	ExampleWithKey(2, "Two"),
	ExampleWithKey(3, "Three"),
]

# ╔═╡ e30c29fe-2de1-11eb-3ecf-bdfd26016125
example_array_moved_entry = [
	ExampleWithKey(2, "Two"),
	ExampleWithKey(1, "One"),
	ExampleWithKey(3, "Three"),
]

# ╔═╡ e3374ef2-2de1-11eb-1319-1508ffc7ba6d
function diffkey(a::ExampleWithKey)
	a.key
end

# ╔═╡ e36ca81a-2de1-11eb-1bf0-290a00d48eff
function diff_array_with_keys(old::AbstractArray, new::AbstractArray)
	bykey = Dict(map(unique(keys(old) ∪ keys(new))) do key
		key => (get(old, key, nothing), get(new, key, nothing))
	end)
end

# ╔═╡ e39da820-2de1-11eb-0d4a-6bfc562ba990
diff_array_with_keys(example_array, example_array_simple_changed_value)

# ╔═╡ e3d486ba-2de1-11eb-27d2-ff3c13750b30
function getarraymoves(old::AbstractArray, new::AbstractArray)
	old_key_to_index = Dict(map(reverse, collect(pairs(old))))
	new_key_to_index = Dict(map(reverse, collect(pairs(new))))
	
	index_shifts = Dict()
	for key in keys(old_key_to_index) ∪ keys(new_key_to_index)
		index_shifts[key] = (get(old_key_to_index, key, nothing) => get(new_key_to_index, key, nothing))
	end
	
	changes_only = []
	for (key, indexes) in index_shifts
		if indexes.first ≠ indexes.second
			push!(changes_only, indexes)
		end
	end
	changes_only
end

# ╔═╡ e40c208e-2de1-11eb-0364-f517174a16bc
getarraymoves([4,3,2,1], [4,3,1,2])

# ╔═╡ e43cf574-2de1-11eb-018b-9bde2b3205ab
md"## Filter diff"

# ╔═╡ e46bdd58-2de1-11eb-1424-39ea8fcb6d9b
function startswith(xs::AbstractArray, prefix::AbstractArray)
	if length(prefix) > length(xs)
		return false
	else
		for index in 1:length(prefix)
			if xs[index] ≠ prefix[index]
				return false
			end
		end
		return true
	end
end

# ╔═╡ e4902cb2-2de1-11eb-15e4-f1ff074acae7
function filter_by_path(value::AtPath, path::Path)
	if isempty(path)
		value
	else
		if startswith(path, value.path)
			filter_by_path(value.value, path[length(value.path)+1:end])
		elseif startswith(value.path, path)
			filter_by_path(AtPath(
				path=value.path[length(path)+1:end],
				value=value.value
			), [])
		else
			nothing
		end
	end
		
end

# ╔═╡ e4c54ae6-2de1-11eb-3392-9f5040455827
function filter_by_path(value::Array, path::Path)
	if isempty(path)
		value
	else
		filter(!isnothing, [filter_by_path(item, path) for item in value])
	end
end

# ╔═╡ e50395da-2de1-11eb-0d79-030f536e4c49
function filter_by_path(value, path::Path)
	if isempty(path)
		value
	else
		nothing
	end
end

# ╔═╡ e53832cc-2de1-11eb-13da-f30ab48fe2e5
function filter_by_path(value::UpdateChange, path::Path)
	UpdateChange(filter_by_path(value.changes, path))
end

# ╔═╡ e55d1cea-2de1-11eb-0d0e-c95009eedc34
md"## Testing"

# ╔═╡ e598832a-2de1-11eb-3831-371aa2e54828
abstract type TestResult end

# ╔═╡ e5b46afe-2de1-11eb-0de5-6d571c0fbbcf
const Code = Any

# ╔═╡ e5dbaf38-2de1-11eb-13a9-a994ac40bf9f
struct Pass <: TestResult
	expr::Code
end

# ╔═╡ e616c708-2de1-11eb-2e66-f972030a7ec5
abstract type Fail <: TestResult end

# ╔═╡ e6501fda-2de1-11eb-33ba-4bb34dc13d00
struct Wrong <: Fail
	expr::Code
	result
end

# ╔═╡ e66c8454-2de1-11eb-1d79-499e6873d0d2
struct Error <: Fail
	expr::Code
	error
end

# ╔═╡ e699ae9a-2de1-11eb-3ff0-c31222ac399e
function Base.show(io::IO, mime::MIME"text/html", value::Pass)
	show(io, mime, HTML("""
		<div
			style="
				display: flex;
				flex-direction: row;
				align-items: center;
				/*background-color: rgb(208, 255, 209)*/
			"
		>
			<div
				style="
					width: 12px;
					height: 12px;
					border-radius: 50%;
					background-color: green;
				"
			></div>
			<div style="min-width: 12px"></div>
			<code
				class="language-julia"
				style="
					flex: 1;
					background-color: transparent;
					filter: grayscale(1) brightness(0.8);
				"
			>$(value.expr)</code>
		</div>
	"""))
end

# ╔═╡ e6c17fae-2de1-11eb-1397-1b1cdfcc387c
function Base.show(io::IO, mime::MIME"text/html", value::Wrong)
	show(io, mime, HTML("""
		<div
			style="
				display: flex;
				flex-direction: row;
				align-items: center;
				/*background-color: rgb(208, 255, 209)*/
			"
		>
			<div
				style="
					width: 12px;
					height: 12px;
					border-radius: 50%;
					background-color: red;
				"
			></div>
			<div style="min-width: 12px"></div>
			<code
				class="language-julia"
				style="
					flex: 1;
					background-color: transparent;
					filter: grayscale(1) brightness(0.8);
				"
			>$(value.expr)</code>
		</div>
	"""))
end

# ╔═╡ e705bd90-2de1-11eb-3759-3d59a90e6e44
function Base.show(io::IO, mime::MIME"text/html", value::Error)
	show(io, mime, HTML("""
		<div
			style="
				display: flex;
				flex-direction: row;
				align-items: center;
				/*background-color: rgb(208, 255, 209)*/
			"
		>
			<div
				style="
					width: 12px;
					height: 12px;
					border-radius: 50%;
					background-color: red;
				"
			></div>
			<div style="width: 12px"></div>
			<div>
				<code
					class="language-julia"
					style="
						background-color: transparent;
						filter: grayscale(1) brightness(0.8);
					"
				>$(value.expr)</code>
				<div style="
					font-family: monospace;
					font-size: 12px;
					color: red;
					padding-left: 8px;
				">Error: $(value.error)</div>
			</div>
			
		</div>
	"""))
end

# ╔═╡ e748600a-2de1-11eb-24be-d5f0ecab8fa4
macro test(expr)	
	quote				
		expr_raw = $(expr |> QuoteNode)
		try
			result = $(esc(expr))
			if result == true
				Pass(expr_raw)
			else
				Wrong(expr_raw, result)
			end
		catch e
			Error(expr_raw, e)
		end
		
		# Base.@locals()
	end
end

# ╔═╡ e78b7408-2de1-11eb-2f1a-3f0783049c7d
@test to_jsonpatch(flatten(notebook1_to_notebook2)) == test_jsonpatch

# ╔═╡ e7c85c1c-2de1-11eb-1a2a-65f8f21e4a05
@test update(notebook1, from_jsonpatch(to_jsonpatch(notebook1_to_notebook2))) == notebook2

# ╔═╡ e7e8d076-2de1-11eb-0214-8160bb81370a
@test notebook1 == deepcopy(notebook1)

# ╔═╡ e8170bee-2de1-11eb-34ce-59bda29af907
@test filter_by_path(notebook1_to_notebook2, []) == notebook1_to_notebook2

# ╔═╡ e839d76e-2de1-11eb-3226-b9e01e4d2a92
@test filter_by_path(notebook1_to_notebook2, [:cells]) == AtPath(
	path=[1],
	value=UpdateChange([
		AtPath(path=[:code], value=SetChange("x = 1", "x = 2"))
		AtPath(path=[:folded], value=SetChange(false, true))
	])	
)

# ╔═╡ e87c1d2c-2de1-11eb-1929-294031c5ff95
@test filter_by_path(notebook1_to_notebook2, [:cells, 1]) == notebook1_to_notebook2.value

# ╔═╡ e8d0c98a-2de1-11eb-37b9-e1df3f5cfa25
md"## DisplayOnly"

# ╔═╡ e907d862-2de1-11eb-11a9-4b3ac37cb0f3
function displayonly(m::Module)
	if isdefined(m, :PlutoForceDisplay)
		return m.PlutoForceDisplay
	else
		isdefined(m, :PlutoRunner) && parentmodule(m) == Main
	end
end

# ╔═╡ e924a0be-2de1-11eb-2170-71d56e117af2
"""
	@displayonly expression

Marks a expression as Pluto-only,
this won't be executed when running outside Pluto.
"""
macro displayonly(ex) displayonly(__module__) ? esc(ex) : nothing end

# ╔═╡ e94f9cc4-2de1-11eb-0cba-29f84d00374b
@displayonly @test update(
	notebook1,
	notebook1_to_notebook2
) == notebook2

# ╔═╡ e98deac4-2de1-11eb-2fb6-49c5008c09ff
# @displayonly @test update(
# 	notebook1,
# 	notebook1_to_notebook_with_new_cell
# ) == notebook_with_new_cell

# ╔═╡ e9d2eba8-2de1-11eb-16bf-bd2a16537a97
@displayonly x = 2

# ╔═╡ ea45104e-2de1-11eb-3248-5dd833d350e4
@displayonly @test 1 + 1 == x

# ╔═╡ ea6650bc-2de1-11eb-3016-4542c5c333a5
@displayonly @test 1 + 1 + 1 == x

# ╔═╡ ea934d9c-2de1-11eb-3f1d-3b60465decde
@displayonly @test throw("Oh my god") == x

# ╔═╡ ead002dc-2de1-11eb-0e8a-313ef430af41
notebook_with_new_cell = Notebook(
	id = 1,
	path = "/app",
	cells = Dict(
		1 => Cell(
			id = 1,
			code = "x = 2",
			folded = true
		),
		2 => Cell(
			id = 2,
			code = "x = 1",
			folded = false
		),
		3 => Cell(
			id = 3,
			code = "x = 1",
			folded = false
		),
		3 => Cell(
			id = 4,
			code = "z = x + 1",
			folded = false
		)
	)
)

# ╔═╡ Cell order:
# ╠═d948dc6e-2de1-11eb-19e7-cb3bb66353b6
# ╠═d9634d9c-2de1-11eb-1fc6-037489c3a4fb
# ╠═d9781358-2de1-11eb-2590-fd8bd91f8a10
# ╠═d98c520a-2de1-11eb-3ec4-e53c8fb0ae4f
# ╠═d9a22c06-2de1-11eb-2a9f-6fb5a5b8badf
# ╠═d9b68804-2de1-11eb-00cd-113a17cbff74
# ╠═d9ce3580-2de1-11eb-25d0-b7cf9af1fcaa
# ╠═d9e25a6a-2de1-11eb-2093-294134d73e3b
# ╠═da4d4028-2de1-11eb-32ee-2b036fc04dfa
# ╠═da6343e4-2de1-11eb-26b4-733c5e4f29e8
# ╠═da775e10-2de1-11eb-2dfe-410470cf9ed3
# ╠═da8bb786-2de1-11eb-1e75-a3aac0d369cf
# ╠═daa028b0-2de1-11eb-087f-ff7ef5f3da2b
# ╠═dab468fc-2de1-11eb-32b5-7d90db553189
# ╠═daca9af0-2de1-11eb-24f8-630215821fbf
# ╠═dade8bb4-2de1-11eb-0b3f-852feb7c086c
# ╟─daf9ec12-2de1-11eb-3a8d-59d9c2753134
# ╠═db116c0a-2de1-11eb-2a56-872af797c547
# ╠═db2d8a3e-2de1-11eb-02b8-9ffbfaeff61c
# ╠═db49d59a-2de1-11eb-2a6b-49399b175a9b
# ╠═db5df660-2de1-11eb-2aa2-c785aab9c00a
# ╠═db75df12-2de1-11eb-0726-d1995cebd382
# ╠═db8ba47c-2de1-11eb-3775-c95eae15f759
# ╠═dbb0ba44-2de1-11eb-1c0c-61c9d8b50fde
# ╠═dbc7f97a-2de1-11eb-362f-055a734d1a9e
# ╠═67ade214-2de3-11eb-291d-135a397d629b
# ╠═dbdd1df0-2de1-11eb-152f-8d1af1ad02fe
# ╠═dbf55672-2de1-11eb-09ce-d99958a23a92
# ╠═dc0ab2b0-2de1-11eb-0597-1b595c1db8c5
# ╠═dc202a02-2de1-11eb-36f7-5133c8998470
# ╠═01f06d42-2de4-11eb-21ae-5f12cdaa15a4
# ╟─dc3657bc-2de1-11eb-34ce-dd2fd5ce971d
# ╟─dc4dd374-2de1-11eb-2a2b-d30b2c5606cd
# ╠═dc6e700c-2de1-11eb-00fe-fdbfbdc6c8f3
# ╠═dc857f4a-2de1-11eb-09b1-693d4971a084
# ╠═dca0c44e-2de1-11eb-24a3-cbdb16cd6257
# ╠═66139678-2de2-11eb-0c69-5955397d33aa
# ╠═dcbe0842-2de1-11eb-236d-b572ab3abf5c
# ╠═070d10ce-2de3-11eb-1e92-63ac4c7da494
# ╠═218d5e90-2de3-11eb-1736-f11e02d4c4d7
# ╠═46972d56-2de3-11eb-3a85-e16496abab03
# ╠═4c3dfa0a-2de3-11eb-015a-e7f5b00b9ee6
# ╠═e90064e0-2de3-11eb-2716-9fd56296f7c8
# ╠═a6f03238-2de3-11eb-3452-b9e97dc4ac83
# ╠═dce80d4a-2de1-11eb-3a21-6becd6f75e97
# ╠═dd0941fe-2de1-11eb-1acf-414ec0ee9fb7
# ╠═dd312598-2de1-11eb-144c-f92ed6484f5d
# ╠═dd4fca34-2de1-11eb-1093-7911b7982b04
# ╠═dd87ca7e-2de1-11eb-2ec3-d5721c32f192
# ╠═ddaf5b66-2de1-11eb-3348-b905b94a984b
# ╠═ddcea842-2de1-11eb-1933-236c2df00832
# ╠═ddf2fcc2-2de1-11eb-1522-3de0178bcaf2
# ╠═de10449e-2de1-11eb-31e1-4b0fdd7a7d43
# ╠═de3eb3ce-2de1-11eb-0cba-e15c15013051
# ╠═de5e55da-2de1-11eb-226d-99e9ea4daeec
# ╠═de79598e-2de1-11eb-1647-2fa0c807e980
# ╠═de98da50-2de1-11eb-1f42-2bfb651601a3
# ╠═deccd3ca-2de1-11eb-3beb-e794bdcbdc95
# ╠═dee4aec8-2de1-11eb-07d1-a37b35c7f45f
# ╠═defa0900-2de1-11eb-3ae5-7df5163da1be
# ╠═e1c0e148-2de1-11eb-08fe-a7634f98db8a
# ╠═e1df94c6-2de1-11eb-05c9-9fe03989454f
# ╠═e20cf22a-2de1-11eb-1487-3f10462b08e3
# ╠═e2340bb4-2de1-11eb-02c2-63e115d8bd9b
# ╟─e25a45e0-2de1-11eb-31ee-db4e81ad7ec6
# ╠═e288699a-2de1-11eb-386a-bd2b11286514
# ╠═e2ae8ace-2de1-11eb-18e8-1bfde2676467
# ╠═e2d572b0-2de1-11eb-09f5-3b6d7c176133
# ╠═e30c29fe-2de1-11eb-3ecf-bdfd26016125
# ╠═e3374ef2-2de1-11eb-1319-1508ffc7ba6d
# ╠═e36ca81a-2de1-11eb-1bf0-290a00d48eff
# ╠═e39da820-2de1-11eb-0d4a-6bfc562ba990
# ╠═e3d486ba-2de1-11eb-27d2-ff3c13750b30
# ╠═e40c208e-2de1-11eb-0364-f517174a16bc
# ╟─e43cf574-2de1-11eb-018b-9bde2b3205ab
# ╠═e46bdd58-2de1-11eb-1424-39ea8fcb6d9b
# ╠═e4902cb2-2de1-11eb-15e4-f1ff074acae7
# ╠═e4c54ae6-2de1-11eb-3392-9f5040455827
# ╠═e50395da-2de1-11eb-0d79-030f536e4c49
# ╠═e53832cc-2de1-11eb-13da-f30ab48fe2e5
# ╟─e55d1cea-2de1-11eb-0d0e-c95009eedc34
# ╟─e598832a-2de1-11eb-3831-371aa2e54828
# ╟─e5b46afe-2de1-11eb-0de5-6d571c0fbbcf
# ╟─e5dbaf38-2de1-11eb-13a9-a994ac40bf9f
# ╟─e616c708-2de1-11eb-2e66-f972030a7ec5
# ╟─e6501fda-2de1-11eb-33ba-4bb34dc13d00
# ╟─e66c8454-2de1-11eb-1d79-499e6873d0d2
# ╟─e699ae9a-2de1-11eb-3ff0-c31222ac399e
# ╟─e6c17fae-2de1-11eb-1397-1b1cdfcc387c
# ╟─e705bd90-2de1-11eb-3759-3d59a90e6e44
# ╟─e748600a-2de1-11eb-24be-d5f0ecab8fa4
# ╟─e78b7408-2de1-11eb-2f1a-3f0783049c7d
# ╟─e7c85c1c-2de1-11eb-1a2a-65f8f21e4a05
# ╟─e7e8d076-2de1-11eb-0214-8160bb81370a
# ╟─e8170bee-2de1-11eb-34ce-59bda29af907
# ╟─e839d76e-2de1-11eb-3226-b9e01e4d2a92
# ╟─e87c1d2c-2de1-11eb-1929-294031c5ff95
# ╟─e8d0c98a-2de1-11eb-37b9-e1df3f5cfa25
# ╟─e907d862-2de1-11eb-11a9-4b3ac37cb0f3
# ╟─e924a0be-2de1-11eb-2170-71d56e117af2
# ╟─e94f9cc4-2de1-11eb-0cba-29f84d00374b
# ╟─e98deac4-2de1-11eb-2fb6-49c5008c09ff
# ╟─e9d2eba8-2de1-11eb-16bf-bd2a16537a97
# ╟─ea45104e-2de1-11eb-3248-5dd833d350e4
# ╟─ea6650bc-2de1-11eb-3016-4542c5c333a5
# ╟─ea934d9c-2de1-11eb-3f1d-3b60465decde
# ╟─ead002dc-2de1-11eb-0e8a-313ef430af41