### A Pluto.jl notebook ###
# v0.12.14

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

# ╔═╡ 121eea6c-31d7-11eb-2017-e91ef98fef6f
using Profile

# ╔═╡ 3a814d80-cd00-4455-a9e5-6264fdc11b91
import PlutoUI

# ╔═╡ 21631f7d-389b-41f1-ae59-5afe6f7c7382
clock = @bind raw_from_clock PlutoUI.Clock(0.0001, false)

# ╔═╡ a3150473-36c2-42f1-94f8-7b2733b562db
value = raw_from_clock

# ╔═╡ 98359ebb-4389-4634-b482-91b116e979a7
clock; begin ref = Ref(0) end

# ╔═╡ 940deb57-c5f1-4a66-bf44-a032358274e0
counter_value = begin
	if value == 1
		ref[] = 1
	else
		ref[] = ref[] + 1
	end
end

# ╔═╡ be3cb130-323b-11eb-1182-27ed7112453a
module Dralbase include("./Base.jl") end

# ╔═╡ dc510504-323b-11eb-0224-e3cf48e10311
import .Dralbase: @add

# ╔═╡ a9dd181e-323c-11eb-0ba2-ef8042f7e839
@add using ProfileVega

# ╔═╡ 35e0b39c-323e-11eb-39dc-81f37d5e2904
profileresult = ProfileVega.@profview PlutoRunner.format_output(Dict())

# ╔═╡ 581f850a-323e-11eb-3904-074f9fdf7125
struct WrapHtml{T}
	wrap::T
	as
end

# ╔═╡ 87202314-323e-11eb-174b-efb82bac1a0c
function Base.show(io::IO, ::MIME"text/html", x::WrapHtml)
	show(io, x.as, x.wrap)
end

# ╔═╡ 6befa630-323e-11eb-3162-f38cf928ef1c
# WrapHtml(profileresult, MIME"application/prs.juno.plotpane+html"())

# ╔═╡ 7c595ef4-323f-11eb-107c-9593afa7466a
struct VegaLiteView
	toshow
end

# ╔═╡ 0a25841c-323e-11eb-062d-594f35961851
VegaLiteView(ProfileVega.@profview PlutoRunner.format_output([[[]]]))

# ╔═╡ fa54210e-323f-11eb-0c3e-bf8bcadd839f
VegaLiteView(ProfileVega.@profview PlutoRunner.format_output([[[[[]]]]]))

# ╔═╡ 8bf9de10-323f-11eb-0862-a17eac43a375
VegaLiteView(profileresult)

# ╔═╡ d8ad490a-323e-11eb-01cc-17d1dc6cdf9d
function Base.show(io::IO, ::MIME"text/html", showvega::VegaLiteView)
	json = sprint(show, MIME"application/vnd.vega.v5+json"(), showvega.toshow)
	print(io, """
		<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
		
		<script id="pluto">
		let element = DOM.element('div')
		let view = new vega.View(vega.parse($(json)), {
			renderer:  'canvas',  // renderer (canvas or svg)
			container: element,   // parent DOM container
			hover:     true       // enable hover processing
		});
		await view.runAsync();
		return element
		</script>
	""")
end

# ╔═╡ ab96afa8-31cc-11eb-1922-9d23596a847d
md"---"

# ╔═╡ be36ff7a-31cc-11eb-23ad-07c8588ad4c3
struct StacktraceShower end

# ╔═╡ 1958921e-31d1-11eb-325d-4f25a7348c9a
function as_dict(dictlike)
	Dict(field => getproperty(dictlike, field) for field in propertynames(dictlike))
end

# ╔═╡ 047b131e-31d1-11eb-03ff-a9002a9b8e08
as_dict(stacktrace()[1])

# ╔═╡ 4686d2b2-31d5-11eb-2f05-d12f0761d2e4
_0 = begin
	_pluto_set
	PlutoUI.with_terminal() do
		# PlutoRunner.format_output([ [ [ ]]])
		PlutoRunner.format_output(Dict())

	end
end

# ╔═╡ bf9bbff0-31d5-11eb-20bc-6b3854511d98
Ref(nothing)

# ╔═╡ ccd0510e-31d5-11eb-0994-918a3c730794
x1 = @code_typed PlutoRunner.format_output([ [ [ ]]]);

# ╔═╡ 61da55a4-31d6-11eb-28b0-497042fd0212
x1.first.code

# ╔═╡ eb6f9c9a-31d6-11eb-19a2-8541790df6a3


# ╔═╡ e354dfd0-31d5-11eb-1521-e7c4f350c847
x2 = @code_typed PlutoRunner.format_output([ [ [ []]]]);

# ╔═╡ 639c3650-31d6-11eb-36a1-f97e45eb4dd6
x2.first.code

# ╔═╡ 70f2ac0a-31d6-11eb-3192-591601f37b9b
z =x2.first.code[7]

# ╔═╡ c758f6c6-31d6-11eb-1623-25bf4a0ac4e4
typeof(z.values[1])

# ╔═╡ dc77c564-31d6-11eb-3933-af4cef3691aa
x2.first.code[7] == x1.first.code[7]

# ╔═╡ c21a9bec-31dd-11eb-231a-995f472d621d
PlutoRunner.eval(quote
	pluto_showable(m::MIME, @nospecialize(x::Any)) = Base.invokelatest(showable, m, x)
end)

# ╔═╡ 8ed75934-31de-11eb-076f-cb41a125749f
PlutoRunner.eval(quote
	# function get_showable(x)
	# 	PlutoRunner.Iterators.filter(m -> PlutoRunner.pluto_showable(m ,x), PlutoRunner.allmimes) |> first
	# end
	function get_showable(@nospecialize(x))
		for mime in PlutoRunner.allmimes
			if PlutoRunner.pluto_showable(mime, x)
				return mime
			end
		end
	end
end)

# ╔═╡ 0f661936-31de-11eb-1b43-fb51d0ced33e
PlutoRunner.eval(quote
	function show_richest(io::IO, @nospecialize(x))::Tuple{<:Any,MIME}
		mime = PlutoRunner.get_showable(x)

		if mime isa MIME"text/plain" && use_tree_viewer_for_struct(x)
			tree_data(x, io), MIME"application/vnd.pluto.tree+object"()
		elseif mime isa MIME"application/vnd.pluto.tree+object"
			tree_data(x, IOContext(io, :compact => true)), mime
		elseif mime isa MIME"application/vnd.pluto.table+object"
			table_data(x, IOContext(io, :compact => true)), mime
		elseif mime ∈ imagemimes
			show(io, mime, x)
			nothing, mime
		elseif mime isa MIME"text/latex"
			# Wrapping with `\text{}` allows for LaTeXStrings with mixed text/math
			texed = repr(mime, x)
			html(io, Markdown.LaTeX("\\text{$texed}"))
			nothing, MIME"text/html"()
		else
			# the classic:
			show(io, mime, x)
			nothing, mime
		end
	end
end)

# ╔═╡ 34cad802-31df-11eb-03c3-93fa3c3b6bc4


# ╔═╡ 3aa92cb0-31df-11eb-20d1-9338bed640e0
let
	value = [[[[Ref([Ref([[[[]]]])])]]]]
	PlutoRunner.tree_data(value, IOContext(IOBuffer()))
end;

# ╔═╡ 4b78d3c0-31de-11eb-0f91-57f141ea381a
let
	value = Ref(Ref([[[[]]]]))
	PlutoRunner.show_richest(IOContext(IOBuffer()), value)
end

# ╔═╡ 24646240-31de-11eb-14f1-0773b9ceaac2
f(x) = PlutoRunner.Iterators.filter(m -> PlutoRunner.pluto_showable(m ,x), PlutoRunner.allmimes) |> first

# ╔═╡ 3588b776-31de-11eb-037b-cd2d241c2e6a
f([[[[[]]]]])

# ╔═╡ b1e8cf58-31db-11eb-3799-71d1d72b8130
PlutoRunner.show_richest(stdout, [Ref([ [Ref( [ ])]])])

# ╔═╡ d066e2a0-31db-11eb-3c54-e948d96ad682
@which PlutoRunner.tree_data([Ref([ [Ref( [ []])]])], IOContext(IOBuffer()))

# ╔═╡ 4a1be92c-31d4-11eb-155b-6fb713b7b6ec
# PlutoUI.with_terminal() do
# 	@code_warntype PlutoRunner.format_output([[[[[[Ref(nothing)]]]]]])
# end

# ╔═╡ 8ab7df20-31db-11eb-0d2a-b3ba464dc30b
PlutoRunner.Iterators.filter(m -> PlutoRunner.pluto_showable(m ,[[[Ref(nothing)]]]), PlutoRunner.allmimes) |> first

# ╔═╡ 6d118cc6-31d3-11eb-3d19-d7e81bf906a7
# _pluto_set = begin
# 	PlutoRunner.eval(quote
# 		function sprint_withreturned(f::Function, args...; context=nothing, sizehint::Integer=0)
# 			@nospecialize
# 			x = @time begin
# 				@time buffer = IOBuffer(sizehint=sizehint)
# 				@info "  ^^^ BUFFER"
# 				@time val = f(IOContext(buffer, context), args...)
# 				@info "  ^^^ VAL"
# 				stuff = @time resize!(buffer.data, buffer.size), val
# 				@info "  ^^^ RESIZE"
# 				stuff
# 			end
# 			@info "^^^ WHOLE THING"
# 			x
# 		end
# 	end)
# 	nothing
# end

# ╔═╡ 12abc072-31cd-11eb-22c3-5d34782a365c
[[StacktraceShower()]]

# ╔═╡ 126e18b6-31d3-11eb-0495-871c572da231
PlutoRunner.format_output([[]])

# ╔═╡ cebeddf4-31cc-11eb-3293-b397a292be77
function Base.show(io::IO, mime::MIME"text/html", ::StacktraceShower)
	show(io, mime, HTML("""
	<b>Stacktrace:</b>
		
	<ul>
		$(join(map(stacktrace()) do x
			"""<li style="color: $(x.inlined ? "green" : "red")">$(x)</li>"""
		end, "\n"))
	</ul>
	"""))
end

# ╔═╡ 2d9c903b-a06e-4e09-b73d-b214a3630d1d
methods(PlutoUI.Clock)

# ╔═╡ a4212fa8-3103-11eb-32e3-29c15db48366
Tuple{fill(Any, 10)...}

# ╔═╡ 5bb1c3b4-da0e-42ae-8350-0858b1edbf13
Tuple{(Any for _ in 1:10)...}

# ╔═╡ 711219a6-ab8a-48a6-9bec-193bf6071292
@bind x html"""
	<input type=range />
"""

# ╔═╡ f0b7e4b8-31d5-11eb-2961-655947eee1a3
PlutoUI.with_terminal() do
	# Profile.clear()
	value = Ref(Ref([[ [Ref( [ []])]]]))
	# @profile PlutoRunner.format_output(value)
	# @profile PlutoRunner.sprint_withreturned(PlutoRunner.show_richest, value, context=IOContext(IOBuffer()))
	# @profile PlutoRunner.show_richest(stdout, value)
	PlutoRunner.Iterators.filter(m -> PlutoRunner.pluto_showable(m ,x), PlutoRunner.allmimes) |> first
	# Profile.print()
end

# ╔═╡ 47e1325a-59dd-4020-97f7-e2a8149cdd7e
# x

# ╔═╡ e6eaf080-4aa1-4c92-87a8-816d3d6ebc9d
# factorial(big(x) - 1)

# ╔═╡ c7b6cf40-ecce-425d-8f7d-caa7511499f3
# factorial(big(x))

# ╔═╡ a4b7cdb5-5853-4c68-8937-59e1b56c170d
# factorial(big(x) + 1)

# ╔═╡ a2d98f18-0f0a-48c9-8359-dae4825550bc
function with_kwargs(x; something, somethingelse)
	
end

# ╔═╡ 722a5398-804b-447f-9e06-d2a563dd4f0f
applicable(with_kwargs, 1)

# ╔═╡ fe6cc8e9-73c8-4307-b85b-1bbc98798d84


# ╔═╡ 96c1c59a-b108-4316-9911-47f0c6f7e44d
Base.@kwdef struct X
	a
	b
	c=nothing
end

# ╔═╡ dd197a5e-8397-45c7-8f2c-7fa7183690ce
X(1,2)

# ╔═╡ Cell order:
# ╠═3a814d80-cd00-4455-a9e5-6264fdc11b91
# ╠═21631f7d-389b-41f1-ae59-5afe6f7c7382
# ╟─a3150473-36c2-42f1-94f8-7b2733b562db
# ╟─98359ebb-4389-4634-b482-91b116e979a7
# ╟─940deb57-c5f1-4a66-bf44-a032358274e0
# ╠═be3cb130-323b-11eb-1182-27ed7112453a
# ╠═dc510504-323b-11eb-0224-e3cf48e10311
# ╠═a9dd181e-323c-11eb-0ba2-ef8042f7e839
# ╠═0a25841c-323e-11eb-062d-594f35961851
# ╠═fa54210e-323f-11eb-0c3e-bf8bcadd839f
# ╠═35e0b39c-323e-11eb-39dc-81f37d5e2904
# ╠═581f850a-323e-11eb-3904-074f9fdf7125
# ╠═87202314-323e-11eb-174b-efb82bac1a0c
# ╠═6befa630-323e-11eb-3162-f38cf928ef1c
# ╠═8bf9de10-323f-11eb-0862-a17eac43a375
# ╠═7c595ef4-323f-11eb-107c-9593afa7466a
# ╠═d8ad490a-323e-11eb-01cc-17d1dc6cdf9d
# ╟─ab96afa8-31cc-11eb-1922-9d23596a847d
# ╠═be36ff7a-31cc-11eb-23ad-07c8588ad4c3
# ╠═1958921e-31d1-11eb-325d-4f25a7348c9a
# ╠═047b131e-31d1-11eb-03ff-a9002a9b8e08
# ╠═4686d2b2-31d5-11eb-2f05-d12f0761d2e4
# ╠═bf9bbff0-31d5-11eb-20bc-6b3854511d98
# ╠═61da55a4-31d6-11eb-28b0-497042fd0212
# ╠═ccd0510e-31d5-11eb-0994-918a3c730794
# ╠═639c3650-31d6-11eb-36a1-f97e45eb4dd6
# ╠═121eea6c-31d7-11eb-2017-e91ef98fef6f
# ╠═70f2ac0a-31d6-11eb-3192-591601f37b9b
# ╠═dc77c564-31d6-11eb-3933-af4cef3691aa
# ╠═eb6f9c9a-31d6-11eb-19a2-8541790df6a3
# ╠═c758f6c6-31d6-11eb-1623-25bf4a0ac4e4
# ╠═e354dfd0-31d5-11eb-1521-e7c4f350c847
# ╠═c21a9bec-31dd-11eb-231a-995f472d621d
# ╠═8ed75934-31de-11eb-076f-cb41a125749f
# ╠═0f661936-31de-11eb-1b43-fb51d0ced33e
# ╠═34cad802-31df-11eb-03c3-93fa3c3b6bc4
# ╠═3aa92cb0-31df-11eb-20d1-9338bed640e0
# ╠═4b78d3c0-31de-11eb-0f91-57f141ea381a
# ╠═24646240-31de-11eb-14f1-0773b9ceaac2
# ╠═3588b776-31de-11eb-037b-cd2d241c2e6a
# ╠═f0b7e4b8-31d5-11eb-2961-655947eee1a3
# ╠═b1e8cf58-31db-11eb-3799-71d1d72b8130
# ╠═d066e2a0-31db-11eb-3c54-e948d96ad682
# ╠═4a1be92c-31d4-11eb-155b-6fb713b7b6ec
# ╠═8ab7df20-31db-11eb-0d2a-b3ba464dc30b
# ╠═6d118cc6-31d3-11eb-3d19-d7e81bf906a7
# ╠═12abc072-31cd-11eb-22c3-5d34782a365c
# ╠═126e18b6-31d3-11eb-0495-871c572da231
# ╠═cebeddf4-31cc-11eb-3293-b397a292be77
# ╠═2d9c903b-a06e-4e09-b73d-b214a3630d1d
# ╠═a4212fa8-3103-11eb-32e3-29c15db48366
# ╠═5bb1c3b4-da0e-42ae-8350-0858b1edbf13
# ╠═711219a6-ab8a-48a6-9bec-193bf6071292
# ╠═47e1325a-59dd-4020-97f7-e2a8149cdd7e
# ╠═e6eaf080-4aa1-4c92-87a8-816d3d6ebc9d
# ╠═c7b6cf40-ecce-425d-8f7d-caa7511499f3
# ╠═a4b7cdb5-5853-4c68-8937-59e1b56c170d
# ╠═a2d98f18-0f0a-48c9-8359-dae4825550bc
# ╠═722a5398-804b-447f-9e06-d2a563dd4f0f
# ╠═fe6cc8e9-73c8-4307-b85b-1bbc98798d84
# ╠═96c1c59a-b108-4316-9911-47f0c6f7e44d
# ╠═dd197a5e-8397-45c7-8f2c-7fa7183690ce
