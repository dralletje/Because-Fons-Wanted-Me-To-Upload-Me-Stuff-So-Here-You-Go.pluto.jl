### A Pluto.jl notebook ###
# v0.12.14

using Markdown
using InteractiveUtils

# ╔═╡ 7f06346e-2b56-11eb-1cf2-47e7429512ed
HTML{String}

# ╔═╡ 14bec8b8-13b2-11eb-2a31-5f0544ad5b56
function displayonly(m::Module)
	if isdefined(m, :PlutoForceDisplay)
		return m.PlutoForceDisplay
	else
		isdefined(m, :PlutoRunner) && parentmodule(m) == Main
	end
end

# ╔═╡ c70c68d2-1300-11eb-1628-9b8b38294867
"""
	@displayonly expression

Marks a expression as Pluto-only,
this won't be executed when running outside Pluto.
"""
macro displayonly(ex) displayonly(__module__) ? esc(ex) : nothing end

# ╔═╡ 1aec630c-12f8-11eb-0e28-9d3c9e54c177
module Startup include("./Base.jl") end

# ╔═╡ 80f585c2-13fa-11eb-1420-bb447ffa7b86
import .Startup: Inspect, @add, @identity

# ╔═╡ 0bfd6e84-12f8-11eb-2591-17ea18055c4b
@displayonly @add using Hyperscript v"0.0.3"

# ╔═╡ 9b354d80-13b9-11eb-2efa-ffd84ab4ba5a
md"## Examples"

# ╔═╡ 18de363a-13c0-11eb-0031-79878171f846
md"#### Interpolate a dict of styles"

# ╔═╡ e2753d84-1304-11eb-19af-4186896ccb45
@displayonly header_styles = Dict("font-size" => 25px, "padding-left" => 10px)

# ╔═╡ 9966edc0-1304-11eb-3316-5f95504aa597
@displayonly html_in_string = "<script>alert('Suckers!!!')</div>"

# ╔═╡ 5ca527d0-13bf-11eb-3001-71c88c91f01b
md"#### Interpolate an html compatible value as html"

# ╔═╡ 32fcd720-13bf-11eb-3c3b-955848d68b60
md"#### Interpolate a dict of attributes"

# ╔═╡ 72fcfbce-12ee-11eb-15b0-67a7b29ae044
@displayonly xxx = Dict(
	"class" => "blue light",
	"style" => Dict("padding-left" => 50px + 1em),
)

# ╔═╡ 47cd213a-13b7-11eb-309c-893e7469adbf
md"## Julia interpolation parser"

# ╔═╡ 69890450-12f5-11eb-3917-9d663c615c4e
struct Escaped value end

# ╔═╡ fa2528e5-7cc2-4cc8-9583-1c11405ed801
function to_expr(x::Union{String,Symbol,Bool,Number})
	x
end

# ╔═╡ fccf16f8-2f49-415f-9a54-5e9583206944
function to_expr(x::Expr)
	if x.head == :...
		to_expr(x.args[1])
	else
		x
	end
end

# ╔═╡ 22bab624-13b6-11eb-182e-c136d825c2ff
md"## Interpolatable types"

# ╔═╡ ff833662-13bb-11eb-14c8-8b2aae2ef7db
md"###### Example helpers"

# ╔═╡ 12cc356c-13bb-11eb-2bc9-975719034118
@displayonly const INTERPOLATE_ME = "INTERPOLATE_ME"

# ╔═╡ 09e5ab8c-13bf-11eb-04dc-d3e4b982057e
md"#### Base type, nothing special"

# ╔═╡ 43baade0-13b6-11eb-013c-7f0863f3c190
abstract type InterpolatedValue end

# ╔═╡ 99d61060-13bd-11eb-2470-b35e3f5f86b1
function Base.show(io::IO, mime::MIME"text/html", x::InterpolatedValue)
	throw("""
		show text/html should be override for InterpolatedValue.
		Got a $(typeof(x)) without html show overload.
	""")
end

# ╔═╡ 7d18c9d2-13be-11eb-1652-51d07e7d1b16
md"#### interpolation is attribute"

# ╔═╡ 9bb8f20e-1283-11eb-3e92-57505be107dd
Base.@kwdef struct AttributeValue <: InterpolatedValue
	name::String
	value
end

# ╔═╡ a434bbbd-000a-483b-a406-fa3081368dd7
function to_expr(x::AttributeValue)
	:($(AttributeValue)($(to_expr(x.name)), $(to_expr(x.value))))
end

# ╔═╡ 0c27f654-dbff-4266-9c70-f0ae3f584c8c
AttributeValue("myattribute", "otherthing")

# ╔═╡ 465a158c-1651-11eb-04bb-99ad4e4d311f
struct Javascript
	content
end

# ╔═╡ 4bab6b12-1651-11eb-2841-332c94b5d4e2
Base.show(io::IO, mime::MIME"application/javascript", js::Javascript) = print(io, js.content)

# ╔═╡ 7aec637c-1651-11eb-2c95-07dd3cefff97
@displayonly onclickhandler = Javascript("""
	alert("You clicked???")
""")

# ╔═╡ 6f610e5c-13ba-11eb-3062-fd8663b82dd0
md"#### Any text in between tags"

# ╔═╡ ebdef998-1285-11eb-14cc-8b85678a72c0
struct StateData <: InterpolatedValue value end

# ╔═╡ 4bdf4504-13bd-11eb-1746-e5b81e9e6d35
md"#### Inside an attribute, but without any quotes?!"

# ╔═╡ 04e1943a-1286-11eb-25eb-99f38df6c66a
struct AttributeUnquoted <: InterpolatedValue value end

# ╔═╡ e19fd3b8-13ba-11eb-04e4-2dde02446652
md"""#### Inside double quotes"""

# ╔═╡ 1e23dc34-1286-11eb-2957-335d24349a4d
struct AttributeDoubleQuoted <: InterpolatedValue value end

# ╔═╡ c62301c8-13ba-11eb-23a0-6b05cfbeaddd
md"""#### Inside single quotes"""

# ╔═╡ 24bb615c-1286-11eb-1106-478fafe4371c
struct AttributeSingleQuoted <: InterpolatedValue value end

# ╔═╡ 8aa807f6-13ba-11eb-155c-2784a14edf60
md"#### Interpolation anywhere inside a tag"

# ╔═╡ 48f3d7a2-1286-11eb-3598-6deee29c753a
struct BeforeAttributeName <: InterpolatedValue value end

# ╔═╡ 8dcf6da4-b05c-4cb3-a566-0a03180d3554
function to_expr(x::T) where T <: Union{
		AttributeDoubleQuoted,
		AttributeSingleQuoted,
		AttributeUnquoted,
		BeforeAttributeName,
		StateData,
	}
	:($(T)($(to_expr(x.value))))
end

# ╔═╡ 3d1e8308-12d3-11eb-3bf1-67d55eae7f50
function Base.show(io::IO, mime::MIME"text/html", x::BeforeAttributeName)
	if x.value isa Dict
		for (key, value) in pairs(x.value)
			show(io, mime, AttributeValue(name=key, value=value))
			print(io, " ")
		end
	elseif x.value isa Pair
		show(io, mime, AttributeValue(name=x.value.first, value=x.value.second))
		print(io, " ")
	else
		throw("invalid binding #2 $(typeof(x.value)) $(x.value)")
	end
end

# ╔═╡ 7aabd782-13b6-11eb-38c0-89fda4e4513b
md"## The actual parser"

# ╔═╡ 93875e76-13b7-11eb-13c3-1d9acf4d6075
md"""
### InterpolateArray

An array that kinda tries to work as a string, but you can append `InterpolatedValue`s to it too.
"""

# ╔═╡ 2765fa4a-1281-11eb-18a4-f14999912807
struct InterpolateArray
	arr::Array
end

# ╔═╡ 20bb3eda-b9cd-4a61-aaa1-fe06a40fb4f6
function to_expr(x::InterpolateArray)
	quote
		$(InterpolateArray)([
			$(map(x.arr) do x
				esc(to_expr(x))
			end...)
		])
	end
end

# ╔═╡ 9229d198-13bb-11eb-096e-a17862e1e327
@displayonly function show_interpolation(arr::InterpolateArray)
	for value in arr.arr
		if value isa InterpolatedValue
			return Inspect(value)
		end
	end
end

# ╔═╡ 1dff8458-164e-11eb-0468-633ba40ee340
const HtlString = InterpolateArray

# ╔═╡ 2d83c766-1281-11eb-04aa-25be5611842a
function Base.:*(arr::InterpolateArray, string::String)
	if isempty(arr.arr)
		InterpolateArray([string])
	elseif typeof(last(arr.arr)) == String
		InterpolateArray([
			arr.arr[begin:end-1]...,
			last(arr.arr) * string
		])
	else
		InterpolateArray([arr.arr..., string])
	end
end

# ╔═╡ 09cee43a-1282-11eb-0a46-c18ecd9625ce
function Base.:*(arr::InterpolateArray, something::InterpolatedValue)
	InterpolateArray([arr.arr..., something])
end

# ╔═╡ 270fc9b6-12e5-11eb-2521-e5d37de17cce
function Base.length(arr::InterpolateArray)
	sum(map(arr.arr) do x
		if x isa AbstractString
			length(x)
		else
			1
		end
	end)
end

# ╔═╡ 03487786-12e9-11eb-14db-4d97ecf364dc
function Base.getindex(arr::InterpolateArray, range::UnitRange)
	InterpolateArray([
		arr.arr[begin:end-1]...,
		arr.arr[end][range]
	])
end

# ╔═╡ 841f6af8-1286-11eb-2840-f509d5f19d52
function Base.show(io::IO, mime::MIME"text/html", array::InterpolateArray)
	for item in array.arr
		if item isa AbstractString
			print(io, item)
		else
			show(io, mime, item)
		end
	end
end

# ╔═╡ 859f52b0-13b6-11eb-1845-612e0e717630
md"### Parser utils"

# ╔═╡ 7d7ecade-1274-11eb-1412-a78c710091d5
begin
	const CODE_TAB = 9
	const CODE_LF = 10
	const CODE_FF = 12
	const CODE_CR = 13
	const CODE_SPACE = 32
	const CODE_UPPER_A = 65
	const CODE_UPPER_Z = 90
	const CODE_LOWER_A = 97
	const CODE_LOWER_Z = 122
	const CODE_LT = 60
	const CODE_GT = 62
	const CODE_SLASH = 47
	const CODE_DASH = 45
	const CODE_BANG = 33
	const CODE_EQ = 61
	const CODE_DQUOTE = 34
	const CODE_SQUOTE = 39
	const CODE_QUESTION = 63
	
	Text("> CharCode Constants")
end

# ╔═╡ 320ecfcc-12d8-11eb-3b17-4d428df9c64c
@enum HtlParserState STATE_DATA STATE_TAG_OPEN STATE_END_TAG_OPEN STATE_TAG_NAME STATE_BOGUS_COMMENT STATE_BEFORE_ATTRIBUTE_NAME STATE_AFTER_ATTRIBUTE_NAME STATE_ATTRIBUTE_NAME STATE_BEFORE_ATTRIBUTE_VALUE STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED  STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED  STATE_ATTRIBUTE_VALUE_UNQUOTED  STATE_AFTER_ATTRIBUTE_VALUE_QUOTED  STATE_SELF_CLOSING_START_TAG  STATE_COMMENT_START  STATE_COMMENT_START_DASH  STATE_COMMENT  STATE_COMMENT_LESS_THAN_SIGN  STATE_COMMENT_LESS_THAN_SIGN_BANG  STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH  STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH_DASH  STATE_COMMENT_END_DASH  STATE_COMMENT_END  STATE_COMMENT_END_BANG  STATE_MARKUP_DECLARATION_OPEN

# ╔═╡ 401507ca-127a-11eb-0110-517057d53125
function entity(str::AbstractString)
	@assert length(str) == 1
	entity(str[1])
end

# ╔═╡ 8aa89fa0-1274-11eb-05a7-dfd699933cbe
entity(character::Char) = "&#$(Int(character));"

# ╔═╡ 829b96c6-1287-11eb-20cb-f3096f0b0703
function Base.show(io::IO, mime::MIME"text/html", child::StateData)
	if showable(MIME("text/html"), child.value)
		show(io, mime, child.value)
	elseif child.value isa AbstractArray{HtlString}
		for subchild in child.value
			show(io, mime, subchild)
		end
	else
		print(io, replace(string(child.value), r"[<&]" => entity))
	end
end

# ╔═╡ d4a0546c-12cf-11eb-1d03-cd395f63f993
function Base.show(io::IO, ::MIME"text/html", x::AttributeUnquoted)
	print(io, replace(value, r"[\s>&]" => entity))
end

# ╔═╡ 1edafc64-12d1-11eb-1a14-2f2e86cf7e94
function Base.show(io::IO, ::MIME"text/html", x::AttributeDoubleQuoted)
	print(io, replace(x.value, r"[\"&]" => entity))
end

# ╔═╡ 42d2a93e-12d1-11eb-1816-e994ba4b209e
function Base.show(io::IO, ::MIME"text/html", x::AttributeSingleQuoted)
	print(io, replace(x.value, r"['&]" => entity))
end

# ╔═╡ 8d20f660-1274-11eb-2bc8-95c2558b7f4b
function isAsciiAlphaCode(code::Int)::Bool
  return (
		CODE_UPPER_A <= code
		&& code <= CODE_UPPER_Z
	) || (
		CODE_LOWER_A <= code
		&& code <= CODE_LOWER_Z
	)
end

# ╔═╡ a62252c6-1274-11eb-0605-45db63c8abfb
function isSpaceCode(code) 
  return ( code === CODE_TAB
		|| code === CODE_LF
		|| code === CODE_FF
		|| code === CODE_SPACE
		|| code === CODE_CR
	) # normalize newlines
end

# ╔═╡ d97167b4-1273-11eb-2be4-ad073ff79006
function hypertext(args)
	state = STATE_DATA
	string = InterpolateArray([])
	nameStart = 0
	nameEnd = 0

	for j in 1:length(args)
		if args[j] isa Escaped
			value = args[j].value
			
			if state == STATE_DATA
				string *= StateData(value)
				
			elseif state == STATE_BEFORE_ATTRIBUTE_VALUE
				state = STATE_ATTRIBUTE_VALUE_UNQUOTED

				name = args[j - 1][nameStart:nameEnd]
				prefixlength = length(string) - nameStart 

				string = InterpolateArray([
					string.arr[begin:end-1]...,
					string.arr[end][begin:nameStart - 1]
				])


				# string = string[1:(nameStart - length(strings[j - 1]))]
				string *= AttributeValue(name, value)
				
			elseif state == STATE_ATTRIBUTE_VALUE_UNQUOTED
				string *= AttributeUnquoted(value)
				
			elseif state == STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED
				string *= AttributeSingleQuoted(value)
				
			elseif state == STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED
				string *= AttributeDoubleQuoted(value)
				
			elseif state == STATE_BEFORE_ATTRIBUTE_NAME
				string *= BeforeAttributeName(value)

			elseif state == STATE_COMMENT || true
				throw("invalid binding #1 $(state)")
			end
		else
			input = args[j]
			inputlength = length(input)
			i = 1
			while i <= inputlength		
				code = Int(input[i])

				if state == STATE_DATA
					if code === CODE_LT
						state = STATE_TAG_OPEN
					end

				elseif state == STATE_TAG_OPEN
					if code === CODE_BANG
						state = STATE_MARKUP_DECLARATION_OPEN
					elseif code === CODE_SLASH
						state = STATE_END_TAG_OPEN
					elseif isAsciiAlphaCode(code)
						state = STATE_TAG_NAME
						i -= 1
					elseif code === CODE_QUESTION
						state = STATE_BOGUS_COMMENT
						i -= 1
					else
						state = STATE_DATA
						i -= 1
					end

				elseif state == STATE_END_TAG_OPEN
					if isAsciiAlphaCode(code)
						state = STATE_TAG_NAME
						i -= 1
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_BOGUS_COMMENT
						i -= 1
					end

				elseif state == STATE_TAG_NAME
					if isSpaceCode(code)
						state = STATE_BEFORE_ATTRIBUTE_NAME
					elseif code === CODE_SLASH
						state = STATE_SELF_CLOSING_START_TAG
					elseif code === CODE_GT
						state = STATE_DATA
					end

				elseif state == STATE_BEFORE_ATTRIBUTE_NAME
					if isSpaceCode(code)
						nothing
					elseif code === CODE_SLASH || code === CODE_GT
						state = STATE_AFTER_ATTRIBUTE_NAME
						i -= 1
					elseif code === CODE_EQ
						state = STATE_ATTRIBUTE_NAME
						nameStart = i + 1
						nameEnd = nothing
					else
						state = STATE_ATTRIBUTE_NAME
						i -= 1
						nameStart = i + 1
						nameEnd = nothing
					end

				elseif state == STATE_ATTRIBUTE_NAME
					if isSpaceCode(code) || code === CODE_SLASH || code === CODE_GT
						state = STATE_AFTER_ATTRIBUTE_NAME
						nameEnd = i - 1
						i -= 1
					elseif code === CODE_EQ
						state = STATE_BEFORE_ATTRIBUTE_VALUE
						nameEnd = i - 1
					end

				elseif state == STATE_AFTER_ATTRIBUTE_NAME
					if isSpaceCode(code)
						# ignore
					elseif code === CODE_SLASH
						state = STATE_SELF_CLOSING_START_TAG
					elseif code === CODE_EQ
						state = STATE_BEFORE_ATTRIBUTE_VALUE
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_ATTRIBUTE_NAME
						i -= 1
						nameStart = i + 1
						nameEnd = nothing
					end

				elseif state == STATE_BEFORE_ATTRIBUTE_VALUE
					if isSpaceCode(code)
						# continue
					elseif code === CODE_DQUOTE
						state = STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED
					elseif code === CODE_SQUOTE
						state = STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_ATTRIBUTE_VALUE_UNQUOTED
						i -= 1
					end

				elseif state == STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED
					if code === CODE_DQUOTE
						state = STATE_AFTER_ATTRIBUTE_VALUE_QUOTED
					end

				elseif state == STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED
					if code === CODE_SQUOTE
						state = STATE_AFTER_ATTRIBUTE_VALUE_QUOTED
					end

				elseif state == STATE_ATTRIBUTE_VALUE_UNQUOTED
					if isSpaceCode(code)
						state = STATE_BEFORE_ATTRIBUTE_NAME
					elseif code === CODE_GT
						state = STATE_DATA
					end

				elseif state == STATE_AFTER_ATTRIBUTE_VALUE_QUOTED
					if isSpaceCode(code)
						state = STATE_BEFORE_ATTRIBUTE_NAME
					elseif code === CODE_SLASH
						state = STATE_SELF_CLOSING_START_TAG
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_BEFORE_ATTRIBUTE_NAME
						i -= 1
					end

				elseif state == STATE_SELF_CLOSING_START_TAG
					if code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_BEFORE_ATTRIBUTE_NAME
						i -= 1
					end

				elseif state == STATE_BOGUS_COMMENT
					if code === CODE_GT
						state = STATE_DATA
					end

				elseif state == STATE_COMMENT_START
					if code === CODE_DASH
						state = STATE_COMMENT_START_DASH
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT_START_DASH
					if code === CODE_DASH
						state = STATE_COMMENT_END
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT
					if code === CODE_LT
						state = STATE_COMMENT_LESS_THAN_SIGN
					elseif code === CODE_DASH
						state = STATE_COMMENT_END_DASH
					end

				elseif state == STATE_COMMENT_LESS_THAN_SIGN
					if code === CODE_BANG
						state = STATE_COMMENT_LESS_THAN_SIGN_BANG
					elseif code !== CODE_LT
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT_LESS_THAN_SIGN_BANG
					if code === CODE_DASH
						state = STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH
					else
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH
					if code === CODE_DASH
						state = STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH_DASH
					else
						state = STATE_COMMENT_END
						i -= 1
					end

				elseif state == STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH_DASH
					state = STATE_COMMENT_END
						i -= 1

				elseif state == STATE_COMMENT_END_DASH
					if code === CODE_DASH
						state = STATE_COMMENT_END
					else
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT_END
					if code === CODE_GT
						state = STATE_DATA
					elseif code === CODE_BANG
						state = STATE_COMMENT_END_BANG
					elseif code !== CODE_DASH
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_COMMENT_END_BANG
					if code === CODE_DASH
						state = STATE_COMMENT_END_DASH
					elseif code === CODE_GT
						state = STATE_DATA
					else
						state = STATE_COMMENT
						i -= 1
					end

				elseif state == STATE_MARKUP_DECLARATION_OPEN
					if code === CODE_DASH && Int(input[i + 1]) == CODE_DASH
						state = STATE_COMMENT_START
						i += 1
					else # Note: CDATA and DOCTYPE unsupported!
						state = STATE_BOGUS_COMMENT
						i -= 1
					end
				else
					state = nothing
				end

				i = i + 1
			end
		string *= input
		end

	end

	return string
end

# ╔═╡ 50b261ae-1284-11eb-1496-d300a0e1d2a0
macro htl(expr)
	if expr isa String
		return hypertext([expr])
	end
	
	@assert expr.head == :string
	segments_escaped = map(expr.args) do segment
		if segment isa String
			segment
		else
			Escaped(segment)
		end
	end
	result = hypertext(segments_escaped)
	return to_expr(result)
end

# ╔═╡ c4e9901e-12d5-11eb-1c3c-f7a267c38b06
@displayonly @htl """<style class="showthestyles">
.red {
	background-color: red;
}

.blue {
	background-color: blue;
}

.light {
	color: white;
	font-weight: bold;
}
"""

# ╔═╡ 6a44eea0-13b7-11eb-2ad5-4b6caa17b60b
@displayonly @htl("""
	<div
		class=$("blue" * " " * "light")
		style=$(header_styles)
	>
		$(html"<div>Big Font</div>")
		<div style=$(:fontSize => 12px)>
			$(html_in_string)
		</div>
	</div>
""")

# ╔═╡ f8f20860-12ea-11eb-2ae2-a108ae05e1a1
@displayonly @htl("""
	<div class=$("blue" * " " * "light")>
		$(html"<div>WOW</div>")
	</div>
""")

# ╔═╡ 47a8de5c-12ee-11eb-15a5-97783fdea760
@displayonly @htl("""
	<div $(xxx...)>
		Class: $(xxx["class"])
	</div>
""")

# ╔═╡ 9bbfccaa-13be-11eb-0f5a-ab652326e658
@displayonly show_interpolation(
	@htl """<div myattribute=$(INTERPOLATE_ME) />"""
)

# ╔═╡ 0ff6dba5-0971-44af-b5ef-415c32c16477
@htl """<div myattribute=$(false)>Hey</div>"""

# ╔═╡ 456689da-1651-11eb-2ea8-67c3eb7fd87e
@displayonly @htl """<div onclick=$(onclickhandler)>Click me</div>"""

# ╔═╡ 6413c7b2-13bd-11eb-399f-5df29575805e
@displayonly show_interpolation(
	@htl """<div>$(INTERPOLATE_ME)</div>"""
)

# ╔═╡ 579e4f34-13bd-11eb-34d5-d5e71a889500
@displayonly show_interpolation(
	@htl """<div style=font-size:$(INTERPOLATE_ME) />"""
)

# ╔═╡ 3a5eca5e-13bb-11eb-0722-ad238adcae34
@displayonly show_interpolation(
	@htl """<div style="font-size: $(INTERPOLATE_ME)" />"""
)

# ╔═╡ ddc3d9a4-13bc-11eb-0b32-2f75c621cb29
@displayonly show_interpolation(
	@htl """<div style='font-size: $(INTERPOLATE_ME)' />"""
)

# ╔═╡ 302d77d6-13bd-11eb-343b-91f686ef5ad8
@displayonly show_interpolation(
	@htl """<div tagbefore="" $(INTERPOLATE_ME) tagafter='' />"""
)

# ╔═╡ a622b5cc-1274-11eb-164d-0b63d950630a
function isObjectLiteral(value) 
	typeof(value) == Dict
  # return value && value.toString === Object.prototype.toString
end

# ╔═╡ e0a16876-13b7-11eb-3b44-297b398657d0
md"## Simple CSS formatter"

# ╔═╡ f7ed3046-1303-11eb-2174-b5995b50ed27
function camelcase_to_dashes(str::String)
	replace(str, r"[A-Z]" => (x -> "-$(lowercase(x))"))
end

# ╔═╡ 6b87ab40-12f9-11eb-2656-796e5ace3f7d
css_value(key, value) = string(value)

# ╔═╡ 6d464c46-12ef-11eb-3ccd-375549d552ab
"Convert numbers into pixel values"
css_value(key, value::Real) = "$(value)px"

# ╔═╡ 5e9ff658-12ef-11eb-1725-bd2616fe3463
css_value(key, value::AbstractString) = value

# ╔═╡ d3807cae-1303-11eb-0813-d909f52fdfcb
"""Un-camelcase symbols if used as keys (eg :fontSize => "font-size")"""
css_key(key::Symbol) = camelcase_to_dashes(string(key))

# ╔═╡ 0082c536-13bd-11eb-0852-8f42e5e9a36a
css_key(key::String) = key

# ╔═╡ 2789a164-12ef-11eb-0363-cf772908ce7a
function render_inline_css(styles::Dict)
	result = ""
	for (key, value) in pairs(styles)
		result *= render_inline_css(key => value)
	end
	result
end

# ╔═╡ 5476cce0-1300-11eb-0de4-0bf07d830d30
function render_inline_css(style::Tuple{Pair})
	result = ""
	for (key, value) in styles
		result *= render_inline_css(key => value)
	end
	result
end

# ╔═╡ 6854c1f2-1300-11eb-0370-1dc63273e570
function render_inline_css((key, value)::Pair)
	"$(css_key(key)): $(css_value(key, value));"
end

# ╔═╡ 3b5caba2-1287-11eb-193c-5bee1ef582c5
function Base.show(io::IO, mime::MIME"text/html", attribute::AttributeValue)
	value = attribute.value
	result = if value === nothing || value == false
		""
	else
		righthandside = if value === true
			"\"\""
		elseif (
			attribute.name === "style" &&
			hasmethod(render_inline_css, Tuple{typeof(attribute.value)})
		)
			render_inline_css(attribute.value)
		elseif showable(MIME("application/javascript"), attribute.value)
			sprint(show, MIME("application/javascript"), attribute.value)
		else
			string(attribute.value)
		end
		escaped = replace(righthandside, r"^['\"]|[\s>&]" => entity)
		"$(attribute.name)=$(escaped)"
	end

	print(io, result)
end

# ╔═╡ Cell order:
# ╠═7f06346e-2b56-11eb-1cf2-47e7429512ed
# ╠═c70c68d2-1300-11eb-1628-9b8b38294867
# ╠═14bec8b8-13b2-11eb-2a31-5f0544ad5b56
# ╠═1aec630c-12f8-11eb-0e28-9d3c9e54c177
# ╠═80f585c2-13fa-11eb-1420-bb447ffa7b86
# ╟─9b354d80-13b9-11eb-2efa-ffd84ab4ba5a
# ╠═0bfd6e84-12f8-11eb-2591-17ea18055c4b
# ╠═c4e9901e-12d5-11eb-1c3c-f7a267c38b06
# ╟─18de363a-13c0-11eb-0031-79878171f846
# ╠═e2753d84-1304-11eb-19af-4186896ccb45
# ╟─9966edc0-1304-11eb-3316-5f95504aa597
# ╠═6a44eea0-13b7-11eb-2ad5-4b6caa17b60b
# ╟─5ca527d0-13bf-11eb-3001-71c88c91f01b
# ╠═f8f20860-12ea-11eb-2ae2-a108ae05e1a1
# ╟─32fcd720-13bf-11eb-3c3b-955848d68b60
# ╟─72fcfbce-12ee-11eb-15b0-67a7b29ae044
# ╠═47a8de5c-12ee-11eb-15a5-97783fdea760
# ╟─47cd213a-13b7-11eb-309c-893e7469adbf
# ╠═69890450-12f5-11eb-3917-9d663c615c4e
# ╠═8dcf6da4-b05c-4cb3-a566-0a03180d3554
# ╠═a434bbbd-000a-483b-a406-fa3081368dd7
# ╠═fa2528e5-7cc2-4cc8-9583-1c11405ed801
# ╠═fccf16f8-2f49-415f-9a54-5e9583206944
# ╠═20bb3eda-b9cd-4a61-aaa1-fe06a40fb4f6
# ╠═50b261ae-1284-11eb-1496-d300a0e1d2a0
# ╟─22bab624-13b6-11eb-182e-c136d825c2ff
# ╟─ff833662-13bb-11eb-14c8-8b2aae2ef7db
# ╟─12cc356c-13bb-11eb-2bc9-975719034118
# ╟─9229d198-13bb-11eb-096e-a17862e1e327
# ╟─09e5ab8c-13bf-11eb-04dc-d3e4b982057e
# ╠═43baade0-13b6-11eb-013c-7f0863f3c190
# ╠═99d61060-13bd-11eb-2470-b35e3f5f86b1
# ╟─7d18c9d2-13be-11eb-1652-51d07e7d1b16
# ╠═9bbfccaa-13be-11eb-0f5a-ab652326e658
# ╠═0ff6dba5-0971-44af-b5ef-415c32c16477
# ╠═0c27f654-dbff-4266-9c70-f0ae3f584c8c
# ╟─9bb8f20e-1283-11eb-3e92-57505be107dd
# ╟─465a158c-1651-11eb-04bb-99ad4e4d311f
# ╟─4bab6b12-1651-11eb-2841-332c94b5d4e2
# ╠═7aec637c-1651-11eb-2c95-07dd3cefff97
# ╠═456689da-1651-11eb-2ea8-67c3eb7fd87e
# ╠═3b5caba2-1287-11eb-193c-5bee1ef582c5
# ╟─6f610e5c-13ba-11eb-3062-fd8663b82dd0
# ╠═6413c7b2-13bd-11eb-399f-5df29575805e
# ╟─ebdef998-1285-11eb-14cc-8b85678a72c0
# ╟─1dff8458-164e-11eb-0468-633ba40ee340
# ╠═829b96c6-1287-11eb-20cb-f3096f0b0703
# ╟─4bdf4504-13bd-11eb-1746-e5b81e9e6d35
# ╠═579e4f34-13bd-11eb-34d5-d5e71a889500
# ╟─04e1943a-1286-11eb-25eb-99f38df6c66a
# ╟─d4a0546c-12cf-11eb-1d03-cd395f63f993
# ╟─e19fd3b8-13ba-11eb-04e4-2dde02446652
# ╠═3a5eca5e-13bb-11eb-0722-ad238adcae34
# ╟─1e23dc34-1286-11eb-2957-335d24349a4d
# ╟─1edafc64-12d1-11eb-1a14-2f2e86cf7e94
# ╟─c62301c8-13ba-11eb-23a0-6b05cfbeaddd
# ╠═ddc3d9a4-13bc-11eb-0b32-2f75c621cb29
# ╟─24bb615c-1286-11eb-1106-478fafe4371c
# ╟─42d2a93e-12d1-11eb-1816-e994ba4b209e
# ╟─8aa807f6-13ba-11eb-155c-2784a14edf60
# ╠═302d77d6-13bd-11eb-343b-91f686ef5ad8
# ╟─48f3d7a2-1286-11eb-3598-6deee29c753a
# ╟─3d1e8308-12d3-11eb-3bf1-67d55eae7f50
# ╟─7aabd782-13b6-11eb-38c0-89fda4e4513b
# ╠═d97167b4-1273-11eb-2be4-ad073ff79006
# ╟─93875e76-13b7-11eb-13c3-1d9acf4d6075
# ╟─2765fa4a-1281-11eb-18a4-f14999912807
# ╟─2d83c766-1281-11eb-04aa-25be5611842a
# ╟─09cee43a-1282-11eb-0a46-c18ecd9625ce
# ╟─270fc9b6-12e5-11eb-2521-e5d37de17cce
# ╟─03487786-12e9-11eb-14db-4d97ecf364dc
# ╟─841f6af8-1286-11eb-2840-f509d5f19d52
# ╟─859f52b0-13b6-11eb-1845-612e0e717630
# ╟─7d7ecade-1274-11eb-1412-a78c710091d5
# ╟─320ecfcc-12d8-11eb-3b17-4d428df9c64c
# ╟─401507ca-127a-11eb-0110-517057d53125
# ╟─8aa89fa0-1274-11eb-05a7-dfd699933cbe
# ╟─8d20f660-1274-11eb-2bc8-95c2558b7f4b
# ╟─a62252c6-1274-11eb-0605-45db63c8abfb
# ╟─a622b5cc-1274-11eb-164d-0b63d950630a
# ╟─e0a16876-13b7-11eb-3b44-297b398657d0
# ╟─f7ed3046-1303-11eb-2174-b5995b50ed27
# ╟─6b87ab40-12f9-11eb-2656-796e5ace3f7d
# ╟─6d464c46-12ef-11eb-3ccd-375549d552ab
# ╟─5e9ff658-12ef-11eb-1725-bd2616fe3463
# ╟─d3807cae-1303-11eb-0813-d909f52fdfcb
# ╟─0082c536-13bd-11eb-0852-8f42e5e9a36a
# ╠═2789a164-12ef-11eb-0363-cf772908ce7a
# ╟─5476cce0-1300-11eb-0de4-0bf07d830d30
# ╟─6854c1f2-1300-11eb-0370-1dc63273e570
