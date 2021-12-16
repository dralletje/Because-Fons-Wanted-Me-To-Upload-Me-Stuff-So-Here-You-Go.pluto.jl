### A Pluto.jl notebook ###
# v0.12.6

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

# ╔═╡ a701ac8a-1609-11eb-09f8-8df45cc83879
module DralCore include("./Base.jl") end

# ╔═╡ 2f2b1280-160b-11eb-3edc-57dd9566c448
import .DralCore: @add, Inspect, @identity, ForceMime

# ╔═╡ 06e81ba8-1627-11eb-1a18-ad4c9eb136fa
@add using DataFrames

# ╔═╡ aa7e64fc-1726-11eb-086f-531c28f1ac4e
@add using CSV

# ╔═╡ f7406f40-164e-11eb-2900-ff912ef83f0c
@add using Hyperscript v"0.0.3"

# ╔═╡ 00c86330-1632-11eb-30f5-472bb0d86180
@add using JSON3

# ╔═╡ acff09ca-1726-11eb-3c0f-a99ed5eb7332
from_csv = CSV.read("./10000-entries.csv");

# ╔═╡ a8661cbe-1dca-11eb-3304-e5217c8432cc


# ╔═╡ 9577e642-1716-11eb-1ff7-273a099de056
abstract type CsvParserState end

# ╔═╡ 508826bc-1718-11eb-18f2-87fd5a9189e5
struct BEFORE_COMMA <: CsvParserState end

# ╔═╡ 632f536c-1718-11eb-0647-9f8a8bfe52aa
struct AFTER_COMMA <: CsvParserState end

# ╔═╡ 19835574-1718-11eb-32a1-b343c769892c
Base.@kwdef struct IN_STRING <: CsvParserState
	start::Int
end

# ╔═╡ 78dfaa7c-1718-11eb-14b3-412a3c9a8c09
Base.@kwdef struct CsvParsedValue
	start::UInt32
	length::UInt32
end

# ╔═╡ a4de8654-171b-11eb-0595-b55ef15dc401
md"### Csv test with quotes"

# ╔═╡ ec265f34-1719-11eb-3575-e13a9de0466e
csv_line = """ "First", "second", "Third" """

# ╔═╡ abf95f86-171b-11eb-1e11-ef354453a963
md"### Csv test no quotes"

# ╔═╡ 8fb6be68-171b-11eb-1e4b-ff3f1b07a928
nowrap_csv_line = "First,Second,Third"

# ╔═╡ 7a949eb2-171b-11eb-29cf-fbca671a246f
parsed_nowrap = get_csv_value_positions_no_wrap(nowrap_csv_line)

# ╔═╡ 8c5a424e-171b-11eb-16a4-6199526d4852
map(parsed_nowrap) do value
	nowrap_csv_line[value.start:(value.start + value.length)]
end

# ╔═╡ 0b257588-171e-11eb-037a-73f723dc139f
md"### Get CSV positions"

# ╔═╡ f015d74a-171a-11eb-0c5f-e9c574be1c59
function csv_parse_positions(str; delimiter=',')
	values = CsvParsedValue[]
	state::CsvParserState = IN_STRING(start=1)
	for i in 1:length(str)
		char = str[i]

		if state isa IN_STRING
			if char == delimiter
				push!(values, CsvParsedValue(
					start=state.start,
					length=(i - 1) - state.start,
				))
				state = IN_STRING(start=i+1)
			else
				nothing
			end
		end
	end
	
	push!(values, CsvParsedValue(
		start=state.start,
		length=length(str) - state.start,
	))

	
	return values
end

# ╔═╡ 67f246e0-1716-11eb-2a04-fb022547237d
function get_csv_value_positions(str; delimiter=',', pre='"', post='"')
	values = CsvParsedValue[]
	state::CsvParserState = AFTER_COMMA()
	for i in 1:length(str)
		char = str[i]
		if state isa BEFORE_COMMA
			if char == delimiter
				state = AFTER_COMMA()
			elseif char == ' '
				nothing
			else
				throw("Expected comma or whitespace, got '$(char)'")
			end
		elseif state isa AFTER_COMMA
			if char == pre
				state = IN_STRING(start=i + 1)
			elseif char == ' '
				nothing
			else
				throw("Expected quote or whitespace, got '$(char)'")
			end
		elseif state isa IN_STRING
			if char == post
				push!(values, CsvParsedValue(
					start=state.start,
					length=(i - 1) - state.start,
				))
				state = BEFORE_COMMA()
			else
				nothing
			end
		end
	end
	
	@assert state isa BEFORE_COMMA
	return values
end

# ╔═╡ b2d9969c-1719-11eb-229e-875c982909ad
parsed_values = get_csv_value_positions(csv_line)

# ╔═╡ f38e22d4-1719-11eb-172c-ef75cd3d4af0
map(parsed_values) do value
	csv_line[value.start:(value.start + value.length)]
end

# ╔═╡ a279eaea-171c-11eb-0712-13cc5930cbb4
function Base.:+(value::CsvParsedValue, n::Number)
	CsvParsedValue(
		start=value.start + n,
		length=value.length
	)
end

# ╔═╡ 14db541c-171e-11eb-2ea3-390648613723
md"### Test CSV positions on 1000-entries.csv"

# ╔═╡ b52eb98a-171a-11eb-0999-4dcac8b2ab49
file_line = readline("./1000-entries.csv")

# ╔═╡ bd87cf44-171b-11eb-077d-610887f5cd07
file_values = csv_parse_positions(file_line)

# ╔═╡ c8d2d7ae-171b-11eb-0c3e-559fb17734db
map(file_values) do value
	file_line[value.start:(value.start + value.length)]
end

# ╔═╡ 208cd132-171e-11eb-08ba-a9f790f93c93
md"## Parse file"

# ╔═╡ 7eeda7c0-172f-11eb-1c72-4f61305cf66c
struct CsvLinePositions
	positions::Array{CsvParsedValue}
end

# ╔═╡ 29ec3662-172f-11eb-2e64-b18fab6bb01c
Base.@kwdef struct CsvFile
	path
	headers::Array{String}
	lines::Array{CsvLinePositions}
end

# ╔═╡ c7e23c80-1726-11eb-0683-0f09fcf13716
function read_csv(path)::CsvFile
	open(path) do file
		header_line = readline(file)
		columns_positions = 
		columns = map(csv_parse_positions(header_line)) do value
			header_line[value.start:(value.start + value.length)]
		end

		lines = []
		for line in eachline(file)
			pos = position(file) - length(line) - 2
			push!(lines, CsvLinePositions(csv_parse_positions(line) .+ pos))
		end

		CsvFile(
			path=path,
			headers=columns,
			lines=lines
		)
	end
end

# ╔═╡ 15a828da-1722-11eb-1744-9d083d37f7d7
function read_csv_value(file, position)
	seek(file, position.start - 1)
	return String(read(file, position.length + 1, all=true))
end

# ╔═╡ f0f3c8ac-1733-11eb-1b58-f97bbfd79ea1
md"### getindex to retrieve values"

# ╔═╡ ab082efc-1713-11eb-3304-e958c91a5554
csvfile = read_csv("./10000-entries.csv");

# ╔═╡ 514b979c-1dd2-11eb-35fe-5b4dcf9dadef


# ╔═╡ e01399a8-172f-11eb-00e7-336bd50c252a
"Get the values of a line"
function Base.getindex(csvfile::CsvFile, ::typeof(:), linenumber::Number)
	open(csvfile.path) do file
		line = csvfile.lines[linenumber]
		values = []
		for position in line.positions
			# seek(file, position.start - 1)
			# value = String(read(file, position.length + 1))
			value = read_csv_value(file, position)
			push!(values, value)
		end
		Dict(zip(csvfile.headers, values))
	end
end

# ╔═╡ 43a7efa0-1730-11eb-2f46-6f62a57edbc9
csvfile["Order ID",:][1:10]

# ╔═╡ fc0d4072-1730-11eb-2139-0f2b0f999091
"Get all values of a column in all lines"
function Base.getindex(csvfile::CsvFile, column::String, ::typeof(:))
	index = findfirst(==(column), csvfile.headers)
	open(csvfile.path) do file
		values = []
		for line in csvfile.lines
			push!(values, read_csv_value(file, line.positions[index]))
		end
		return values
	end
end

# ╔═╡ c18a5a76-1731-11eb-2a16-61e3fd622a75
csvfile[:,1]

# ╔═╡ f63ea704-1731-11eb-145d-71a3440c50ad
"Get all values of a column in all lines"
function Base.getindex(csvfile::CsvFile, column::String, linenumber::Number)
	index = findfirst(==(column), csvfile.headers)
	open(csvfile.path) do file
		read_csv_value(file, csvfile.lines[linenumber].positions[index])
	end
end

# ╔═╡ a7312cae-1731-11eb-0cd7-df9193e0c171
csvfile["Order ID", 1]

# ╔═╡ 28634556-1734-11eb-1161-cb1d522ecc2a
md"### Compare size"

# ╔═╡ 4658c5a0-1733-11eb-14d5-231c0436eaa3
whole_thing = map(csvfile.headers) do header
	csvfile[header,:]
end;

# ╔═╡ 54dc13ce-16d5-11eb-0511-8321d9123bc8
md"# Display Tabs"

# ╔═╡ 27e2f910-162f-11eb-2dc0-1d686a9b6391
dataframe = DataFrame([
		Dict(:x => 1, :y => 2),
				Dict(:x => 3, :y => 4),
				Dict(:x => 5, :y => 6)

		])

# ╔═╡ a47c6cf8-1630-11eb-0d13-cbe6e8f303e2
is_specific_show(method::Method) = method.sig.types[4] != Any

# ╔═╡ c4d6753e-164e-11eb-1fb8-6fab217ef869
macro methods(expr::Expr)
	@assert Meta.isexpr(expr, :call)
	λfn = expr.args[1]
	λarguments_types = map(expr.args[2:end]) do argument
		if Meta.isexpr(argument, Symbol("::"), 1)
			esc(argument.args[1])
		else
			quote typeof($(esc(argument))) end
		end
	end
	
	quote
		methods($(λfn), Tuple{$(λarguments_types...)})
	end
end

# ╔═╡ ddf85fd8-1648-11eb-3ef0-fbd18d3544c0
module HTL include("./htl-but-more-flex.jl") end

# ╔═╡ 3ccccd9a-164a-11eb-35dc-3ff2a543cb88
import .HTL: @htl

# ╔═╡ 6657750e-1661-11eb-3459-f5052415456a
function Base.convert(::Type{HTML}, htl::HTL.HtlString)
	HTML() do io
		show(io, MIME("text/html"), htl)
	end
end

# ╔═╡ 1928a70e-164f-11eb-3cbd-5bc7a989fc6c
container = Dict(
	"style" => Dict(
		:display => :flex,
		:flexDirection => :row,
	)
)

# ╔═╡ 810bf634-164f-11eb-3bb0-b1c00850784c
element_style = Dict(
	:padding => "$(5px) $(5px)",
	:marginRight => 5px,
	:cursor => "pointer",
	:overflow => :hidden,
	:textOverflow => :ellipsis,
	:fontFamily => "'JuliaMono'",
	:whiteSpace => :nowrap,
	:direction => :rtl,
	:fontSize => 12px,
)

# ╔═╡ ce29f512-16cf-11eb-01e4-2b0d57a505c6
md"---"

# ╔═╡ 41f1bc1e-1662-11eb-3816-29a7e6e762ec
value_to_show = HTML("<div>Hey</div>");

# ╔═╡ af697fe6-16d4-11eb-265a-0dee80345227
md"## ForceMime"

# ╔═╡ 4fa9fa7c-16cd-11eb-3dea-1b914bdb1ccd
PlutoTree = MIME"application/vnd.pluto.tree+xml"

# ╔═╡ 8efc2428-162f-11eb-0c33-d1c55efdd707
display_types = let
	all_methods = methods(show, Tuple{IO, MIME, typeof(value_to_show)})
	only_specific = filter(is_specific_show, collect(all_methods))
	mimes = map(only_specific) do method
		method.sig.parameters[3]
	end
	unique([
		MIME"text/plain",
		mimes...,
		PlutoTree,
	])
end

# ╔═╡ 92ae541e-1662-11eb-39a8-e58fe0fc0568
# struct ForceMime{T_MIME <: MIME}
# 	mime::T_MIME
# 	value
# end

# ╔═╡ 9c898894-1662-11eb-3279-1bc25f755a50
# function Base.show(io::IO, ::T, forced::ForceMime{T}) where T
# 	show(io, T(), forced.value)
# end

# ╔═╡ 57cec0ba-16ce-11eb-123f-39012b39e631
# function Base.show(io::IO, ::T, forced::ForceMime{T}) where T <: PlutoTree
# 	if showable(T(), forced.value)
# 		show(io, T(), forced.value)
# 	else
# 		PlutoRunner.show_struct(io, forced.value)
# 	end
# end

# ╔═╡ 76a922be-1665-11eb-2a7c-934912daa9fd
# function Base.show(io::IO, ::MIME"text/plain", forced::ForceMime)
# 	show(io, forced.mime, forced.value)
# end

# ╔═╡ 7578d97e-1666-11eb-3889-ddf0e18940f8
# function Base.showable(mime::MIME"text/plain", forced::ForceMime)
# 	true
# end

# ╔═╡ a4249e9c-1662-11eb-0fe9-47660abdf219
# function Base.showable(mime::MIME, forced::ForceMime)
# 	forced.mime == mime
# end

# ╔═╡ 86ddfbcc-1648-11eb-3f9e-8b4e20652525
md"## PlutoWidget"

# ╔═╡ e9fa1488-1630-11eb-01c9-55855d3636cf
# Base.@kwdef struct PlutoWidget
# 	html::HTML
# 	default::Any
# end

# ╔═╡ e9fb2364-1630-11eb-23ca-cb566efde6d8
# function Base.show(io::IO, mime::MIME"text/html", widget::PlutoWidget)
# 	show(io, mime, widget.html)
# end

# ╔═╡ e9fc4170-1630-11eb-2d17-818f5bca25e7
# Base.get(widget::PlutoWidget) = widget.default

# ╔═╡ 2d367b78-1648-11eb-2930-c1d52d3154f0
md"## JS String"

# ╔═╡ 00b45dd6-1650-11eb-1cd9-eb24a003c261
struct Javascript
	content::Union{String,Function}
end

# ╔═╡ 6a0df1ae-1653-11eb-2e81-45a60c72147b
function Base.show(io::IO, js::Javascript)
	if js.content isa Function
		js.content(io)
	else
		print(io, js.content)
	end
end

# ╔═╡ 6001129a-1653-11eb-0237-e581b9ae8ccd
function Base.show(io::IO, ::MIME"application/javascript", js::Javascript)
	print(io, js)
end

# ╔═╡ 44a02d1a-1653-11eb-2f66-810e0dbf7beb
function Base.show(io::IO, ::MIME"text/html", js::Javascript)
	print(io, """<pre class="language-javascript">""")
	print(io, js)
	print(io, "</pre>")
end

# ╔═╡ 8c193c86-1658-11eb-076b-9b70e647ca8c
interpolate_variable = "NOTEBOOK SCOPE"

# ╔═╡ 8e7b49c6-1660-11eb-3ee9-912fee2214bf
struct Something
	x
	y
end

# ╔═╡ 46790f1a-165f-11eb-30d3-9bb0bfc03bf2
function interpolate_json(expr::Expr)
	jsonargs = map(expr.args) do arg
		if typeof(arg) == Symbol || typeof(arg) == Expr
			:(JSON3.write($(arg)))
		else
			arg
		end
	end
	result_expr = Expr(:string, jsonargs...)
	
    quote
		Javascript($(esc(result_expr)))
	end

end

# ╔═╡ 4da8b5ce-1632-11eb-3dec-9344ab4de82c
macro js_str(str::Expr)
	interpolate_json(str)
end

# ╔═╡ 80851158-1645-11eb-3fa5-1f9ae7ad2cc7
macro js_str(str::String)
    try		
		expr = Meta.parse("\"\"\"$(str)\"\"\"")
		if expr isa String
			interpolate_json(Expr(:string, expr))
		else
			interpolate_json(expr)
		end
    catch exception
        error(string("syntax: ", exception.msg))
    end
end

# ╔═╡ 4ed5612a-1657-11eb-10ab-bd7091e24be4
function onclick(value)
	@js_str """
		let buttons = this.closest('.buttons')
		buttons.value = $(value)
		buttons.dispatchEvent(new CustomEvent("input"))
	"""
end

# ╔═╡ 4705e2a6-164a-11eb-1720-67d21325ba09
@bind selected_mime PlutoWidget(
	html=@htl("""
		<div class=buttons $(container)>$(
			map(display_types) do display
				@htl """
					<div
						style=$(element_style)
						onclick=$(onclick(display.parameters[1]))
					>
						$(display.parameters[1])
					</div>
				"""
			end
		)</div>
	"""),
	default=display_types[1].parameters[1]
)

# ╔═╡ 019b9762-1657-11eb-3eea-170e8e9036b4
ForceMime(MIME(selected_mime), value_to_show)

# ╔═╡ c341af04-165f-11eb-3540-25200941ec50
js"""alert($(interpolate_variable))"""

# ╔═╡ 8a973d5e-1658-11eb-3888-9fd3f0c630ab
let
	interpolate_variable = "Inside let block"
	js"""alert($(interpolate_variable))"""
end

# ╔═╡ 8e4e4b52-165f-11eb-3e79-a91300020ca3
js_str_in_function(interpolate_variable) = js"""alert($(interpolate_variable))"""

# ╔═╡ 9dee345a-165f-11eb-3119-37fe66842cd3
js_str_in_function("Inside function")

# ╔═╡ 40f0c37a-1660-11eb-1da5-c3356b3011c4
expression_in_function(interpolate_variable) = js"""alert($(interpolate_variable.x))"""

# ╔═╡ 3ddd2e58-1660-11eb-2f96-d1e564afe081
expression_in_function(Something("xxx", "yyy"))

# ╔═╡ d0dc5678-1734-11eb-1671-f775af2fc554
md"## Unit"

# ╔═╡ d541388c-1734-11eb-0f38-2b5a796edb69
abstract type Unit <: Number end

# ╔═╡ df2e6e00-1734-11eb-3094-e5421fd7fb7a
Base.getindex(value::Unit) = value.value

# ╔═╡ 1e0f5e7c-1735-11eb-39ea-4d3ffa3aeec7
Base.:+(a::T, b::T) where {T <: Unit} = T(a[] + b[])

# ╔═╡ 3b2b47f0-1735-11eb-2a1b-a9492f05416d
Base.:-(a::T, b::T) where {T <: Unit} = T(a[] - b[])

# ╔═╡ 6b36212a-1735-11eb-1210-4390737a30b5
Base.:/(a::T, b::T) where {T <: Unit} = a[] / b[]

# ╔═╡ 7a276484-1735-11eb-3407-4db18cfc12a5
Base.:/(a::T, b::Number) where {T <: Unit} = T(a[] / b)

# ╔═╡ 8cb84ac8-1735-11eb-24ab-a1b20b77d7b1
Base.:*(a::T, b::Number) where {T <: Unit} = T(a[] * b)

# ╔═╡ 963c6110-1735-11eb-1fcd-119dccca8bb3
Base.:*(a::Number, b::T) where {T <: Unit} = T(a * b[])

# ╔═╡ 46f1c1c6-1781-11eb-3e7b-93cba1a5ed46
Base.convert(t::Type{Number}, u::Unit) = convert(t, u[])

# ╔═╡ 7f9eff52-1727-11eb-3c9a-a9976fbb8c74
md"## Bytes"

# ╔═╡ 4ee71d36-1722-11eb-2c7a-33243e14b60d
struct Bytes <: Unit
	value
end

# ╔═╡ 55e5ea40-1722-11eb-1e98-837b7ea479f1
function Base.show(io::IO, mime::MIME"text/plain", bytesobj::Bytes)
	bytes = bytesobj[]
	if bytes > 1e9
		print(io, string(round(bytes / 1e9, digits=2)))
		print(io, "gb")
	elseif bytes > 1e6
		print(io, string(round(bytes / 1e6, digits=2)))
		print(io, "mb")
	elseif bytes > 1e3
		print(io, string(round(bytes / 1e3, digits=2)))
		print(io, "kb")
	else
		print(io, string(round(bytes, digits=2)))
		print(io, " bytes")
	end
end

# ╔═╡ c1ba1f52-1722-11eb-19e1-53bbdc4d5a14
function bytesize(subject)
	Bytes(Base.summarysize(subject))
end

# ╔═╡ 05afcdfe-1728-11eb-2c18-3b21a30cefed
bytesize(from_csv)

# ╔═╡ 97ea65a0-1732-11eb-1e6e-0bc8efc38012
csvfile_full_size = bytesize(csvfile)

# ╔═╡ d5de9dfe-1732-11eb-22b1-7d2f9efa9d1d
single_column_size = bytesize(csvfile["Order ID",:])

# ╔═╡ a3438ab6-1733-11eb-379f-83d7b04e389d
all_columns_size = bytesize(whole_thing)

# ╔═╡ ae486b2a-1733-11eb-307b-f7197700a08c
size_increase = round(bytesize(whole_thing) / bytesize(csvfile), digits=2)

# ╔═╡ 9f94e846-1784-11eb-2d23-572bb240a14d
Inspect(:(Base.:*(a::Number, b::T) where {T <: Unit} = T(a * b[])))

# ╔═╡ Cell order:
# ╠═a701ac8a-1609-11eb-09f8-8df45cc83879
# ╠═2f2b1280-160b-11eb-3edc-57dd9566c448
# ╟─06e81ba8-1627-11eb-1a18-ad4c9eb136fa
# ╠═aa7e64fc-1726-11eb-086f-531c28f1ac4e
# ╠═acff09ca-1726-11eb-3c0f-a99ed5eb7332
# ╠═05afcdfe-1728-11eb-2c18-3b21a30cefed
# ╟─a8661cbe-1dca-11eb-3304-e5217c8432cc
# ╟─9577e642-1716-11eb-1ff7-273a099de056
# ╟─508826bc-1718-11eb-18f2-87fd5a9189e5
# ╟─632f536c-1718-11eb-0647-9f8a8bfe52aa
# ╟─19835574-1718-11eb-32a1-b343c769892c
# ╠═78dfaa7c-1718-11eb-14b3-412a3c9a8c09
# ╟─a4de8654-171b-11eb-0595-b55ef15dc401
# ╟─ec265f34-1719-11eb-3575-e13a9de0466e
# ╟─b2d9969c-1719-11eb-229e-875c982909ad
# ╟─f38e22d4-1719-11eb-172c-ef75cd3d4af0
# ╟─abf95f86-171b-11eb-1e11-ef354453a963
# ╟─8fb6be68-171b-11eb-1e4b-ff3f1b07a928
# ╟─7a949eb2-171b-11eb-29cf-fbca671a246f
# ╟─8c5a424e-171b-11eb-16a4-6199526d4852
# ╟─0b257588-171e-11eb-037a-73f723dc139f
# ╟─f015d74a-171a-11eb-0c5f-e9c574be1c59
# ╟─67f246e0-1716-11eb-2a04-fb022547237d
# ╟─a279eaea-171c-11eb-0712-13cc5930cbb4
# ╟─14db541c-171e-11eb-2ea3-390648613723
# ╟─b52eb98a-171a-11eb-0999-4dcac8b2ab49
# ╟─bd87cf44-171b-11eb-077d-610887f5cd07
# ╟─c8d2d7ae-171b-11eb-0c3e-559fb17734db
# ╟─208cd132-171e-11eb-08ba-a9f790f93c93
# ╟─7eeda7c0-172f-11eb-1c72-4f61305cf66c
# ╟─29ec3662-172f-11eb-2e64-b18fab6bb01c
# ╟─c7e23c80-1726-11eb-0683-0f09fcf13716
# ╟─15a828da-1722-11eb-1744-9d083d37f7d7
# ╟─f0f3c8ac-1733-11eb-1b58-f97bbfd79ea1
# ╠═ab082efc-1713-11eb-3304-e958c91a5554
# ╟─514b979c-1dd2-11eb-35fe-5b4dcf9dadef
# ╟─e01399a8-172f-11eb-00e7-336bd50c252a
# ╠═43a7efa0-1730-11eb-2f46-6f62a57edbc9
# ╟─fc0d4072-1730-11eb-2139-0f2b0f999091
# ╠═c18a5a76-1731-11eb-2a16-61e3fd622a75
# ╟─f63ea704-1731-11eb-145d-71a3440c50ad
# ╠═a7312cae-1731-11eb-0cd7-df9193e0c171
# ╟─28634556-1734-11eb-1161-cb1d522ecc2a
# ╠═97ea65a0-1732-11eb-1e6e-0bc8efc38012
# ╠═d5de9dfe-1732-11eb-22b1-7d2f9efa9d1d
# ╠═4658c5a0-1733-11eb-14d5-231c0436eaa3
# ╠═a3438ab6-1733-11eb-379f-83d7b04e389d
# ╠═ae486b2a-1733-11eb-307b-f7197700a08c
# ╟─54dc13ce-16d5-11eb-0511-8321d9123bc8
# ╠═27e2f910-162f-11eb-2dc0-1d686a9b6391
# ╟─a47c6cf8-1630-11eb-0d13-cbe6e8f303e2
# ╟─c4d6753e-164e-11eb-1fb8-6fab217ef869
# ╠═ddf85fd8-1648-11eb-3ef0-fbd18d3544c0
# ╠═3ccccd9a-164a-11eb-35dc-3ff2a543cb88
# ╟─f7406f40-164e-11eb-2900-ff912ef83f0c
# ╟─6657750e-1661-11eb-3459-f5052415456a
# ╟─8efc2428-162f-11eb-0c33-d1c55efdd707
# ╟─1928a70e-164f-11eb-3cbd-5bc7a989fc6c
# ╟─810bf634-164f-11eb-3bb0-b1c00850784c
# ╟─4ed5612a-1657-11eb-10ab-bd7091e24be4
# ╟─ce29f512-16cf-11eb-01e4-2b0d57a505c6
# ╠═41f1bc1e-1662-11eb-3816-29a7e6e762ec
# ╟─4705e2a6-164a-11eb-1720-67d21325ba09
# ╟─019b9762-1657-11eb-3eea-170e8e9036b4
# ╟─af697fe6-16d4-11eb-265a-0dee80345227
# ╠═4fa9fa7c-16cd-11eb-3dea-1b914bdb1ccd
# ╠═92ae541e-1662-11eb-39a8-e58fe0fc0568
# ╠═9c898894-1662-11eb-3279-1bc25f755a50
# ╠═57cec0ba-16ce-11eb-123f-39012b39e631
# ╠═76a922be-1665-11eb-2a7c-934912daa9fd
# ╠═7578d97e-1666-11eb-3889-ddf0e18940f8
# ╠═a4249e9c-1662-11eb-0fe9-47660abdf219
# ╟─86ddfbcc-1648-11eb-3f9e-8b4e20652525
# ╠═e9fa1488-1630-11eb-01c9-55855d3636cf
# ╠═e9fb2364-1630-11eb-23ca-cb566efde6d8
# ╠═e9fc4170-1630-11eb-2d17-818f5bca25e7
# ╟─2d367b78-1648-11eb-2930-c1d52d3154f0
# ╟─00c86330-1632-11eb-30f5-472bb0d86180
# ╟─00b45dd6-1650-11eb-1cd9-eb24a003c261
# ╟─4da8b5ce-1632-11eb-3dec-9344ab4de82c
# ╟─80851158-1645-11eb-3fa5-1f9ae7ad2cc7
# ╟─6a0df1ae-1653-11eb-2e81-45a60c72147b
# ╟─6001129a-1653-11eb-0237-e581b9ae8ccd
# ╟─44a02d1a-1653-11eb-2f66-810e0dbf7beb
# ╟─8c193c86-1658-11eb-076b-9b70e647ca8c
# ╟─c341af04-165f-11eb-3540-25200941ec50
# ╟─8a973d5e-1658-11eb-3888-9fd3f0c630ab
# ╟─8e4e4b52-165f-11eb-3e79-a91300020ca3
# ╟─9dee345a-165f-11eb-3119-37fe66842cd3
# ╟─40f0c37a-1660-11eb-1da5-c3356b3011c4
# ╟─8e7b49c6-1660-11eb-3ee9-912fee2214bf
# ╠═3ddd2e58-1660-11eb-2f96-d1e564afe081
# ╟─46790f1a-165f-11eb-30d3-9bb0bfc03bf2
# ╟─d0dc5678-1734-11eb-1671-f775af2fc554
# ╟─d541388c-1734-11eb-0f38-2b5a796edb69
# ╟─df2e6e00-1734-11eb-3094-e5421fd7fb7a
# ╠═1e0f5e7c-1735-11eb-39ea-4d3ffa3aeec7
# ╠═3b2b47f0-1735-11eb-2a1b-a9492f05416d
# ╠═6b36212a-1735-11eb-1210-4390737a30b5
# ╠═7a276484-1735-11eb-3407-4db18cfc12a5
# ╠═8cb84ac8-1735-11eb-24ab-a1b20b77d7b1
# ╠═963c6110-1735-11eb-1fcd-119dccca8bb3
# ╠═46f1c1c6-1781-11eb-3e7b-93cba1a5ed46
# ╟─7f9eff52-1727-11eb-3c9a-a9976fbb8c74
# ╟─4ee71d36-1722-11eb-2c7a-33243e14b60d
# ╟─55e5ea40-1722-11eb-1e98-837b7ea479f1
# ╟─c1ba1f52-1722-11eb-19e1-53bbdc4d5a14
# ╠═9f94e846-1784-11eb-2d23-572bb240a14d
