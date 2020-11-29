### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 7d7ecade-1274-11eb-1412-a78c710091d5
begin
	CODE_TAB = 9
	CODE_LF = 10
	CODE_FF = 12
	CODE_CR = 13
	CODE_SPACE = 32
	CODE_UPPER_A = 65
	CODE_UPPER_Z = 90
	CODE_LOWER_A = 97
	CODE_LOWER_Z = 122
	CODE_LT = 60
	CODE_GT = 62
	CODE_SLASH = 47
	CODE_DASH = 45
	CODE_BANG = 33
	CODE_EQ = 61
	CODE_DQUOTE = 34
	CODE_SQUOTE = 39
	CODE_QUESTION = 63
	
	Text("> Constants")
end

# ╔═╡ 320ecfcc-12d8-11eb-3b17-4d428df9c64c
@enum STATE_DATA STATE_TAG_OPEN STATE_END_TAG_OPEN STATE_TAG_NAME STATE_BOGUS_COMMENT STATE_BEFORE_ATTRIBUTE_NAME STATE_AFTER_ATTRIBUTE_NAME STATE_ATTRIBUTE_NAME STATE_BEFORE_ATTRIBUTE_VALUE STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED  STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED  STATE_ATTRIBUTE_VALUE_UNQUOTED  STATE_AFTER_ATTRIBUTE_VALUE_QUOTED  STATE_SELF_CLOSING_START_TAG  STATE_COMMENT_START  STATE_COMMENT_START_DASH  STATE_COMMENT  STATE_COMMENT_LESS_THAN_SIGN  STATE_COMMENT_LESS_THAN_SIGN_BANG  STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH  STATE_COMMENT_LESS_THAN_SIGN_BANG_DASH_DASH  STATE_COMMENT_END_DASH  STATE_COMMENT_END  STATE_COMMENT_END_BANG  STATE_MARKUP_DECLARATION_OPEN

# ╔═╡ 72fcfbce-12ee-11eb-15b0-67a7b29ae044
xxx = Dict(
	"class" => "blue light",
	"style" => Dict("padding-left" => 50),
)

# ╔═╡ 57f74f28-128a-11eb-1efa-132082acc59b
function Dump(value)
	sprint(dump, value) |> Text
end

# ╔═╡ 2765fa4a-1281-11eb-18a4-f14999912807
struct InterpolateArray
	arr::Array
end

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
function Base.:*(arr::InterpolateArray, something)
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

# ╔═╡ 5e9ff658-12ef-11eb-1725-bd2616fe3463
css_value(key, value::AbstractString) = value

# ╔═╡ 6d464c46-12ef-11eb-3ccd-375549d552ab
css_value(key, value::Real) = "$(value)px"

# ╔═╡ 2789a164-12ef-11eb-0363-cf772908ce7a
function render_inline_css(styles::Dict)
	result = ""
	for (key, value) in pairs(styles)
		result *= "$(string(key)): $(css_value(key, value));"
	end
	result
end

# ╔═╡ dccd80a4-12ef-11eb-3347-59a44dc4e4c3
string("Hey")

# ╔═╡ 9bb8f20e-1283-11eb-3e92-57505be107dd
Base.@kwdef struct AttributeValue
	name::String
	value
end

# ╔═╡ 3ad52dfc-12d7-11eb-150d-ab55f1099fd5
do_you_even_html_bro(bro) = !isempty(methods(show, Tuple{IO,MIME"text/html", typeof(bro)}))

# ╔═╡ ebdef998-1285-11eb-14cc-8b85678a72c0
struct StateData value end

# ╔═╡ 04e1943a-1286-11eb-25eb-99f38df6c66a
struct AttributeUnquoted value end

# ╔═╡ 1e23dc34-1286-11eb-2957-335d24349a4d
struct AttributeDoubleQuoted value end

# ╔═╡ 24bb615c-1286-11eb-1106-478fafe4371c
struct AttributeSingleQuoted value end

# ╔═╡ 48f3d7a2-1286-11eb-3598-6deee29c753a
struct BeforeAttributeName value end

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

# ╔═╡ f222324a-127c-11eb-0f20-49189a060eb1
const animals = ["ant", "bison", "camel", "duck", "elephant"];

# ╔═╡ ffd98b56-127c-11eb-3a7b-cf4afa5630b7
# console.log(animals.slice(2));
# // expected output: Array ["camel", "duck", "elephant"]
animals[3:end]

# ╔═╡ 1e29b2fc-127d-11eb-05b4-83874bad781c
# console.log(animals.slice(2, 4));
# // expected output: Array ["camel", "duck"]
animals[3:5]

# ╔═╡ 28a1cb52-127d-11eb-10d5-a531650667c1
# console.log(animals.slice(1, 5));
# // expected output: Array ["bison", "camel", "duck", "elephant"]
animals[2:6]

# ╔═╡ 401507ca-127a-11eb-0110-517057d53125
entity(character::AbstractString) = entity(character[1])

# ╔═╡ 8aa89fa0-1274-11eb-05a7-dfd699933cbe
entity(character::Char) = "&#$(Int(character));"

# ╔═╡ 3b5caba2-1287-11eb-193c-5bee1ef582c5
function Base.show(io::IO, mime::MIME"text/html", attribute::AttributeValue)
	value = attribute.value
	result = if value === nothing || value == false
		""
	else
		righthandside = if value === true
			"\"\""
		elseif attribute.name === "style" && attribute.value isa Dict
			render_inline_css(attribute.value)
		else
			string(attribute.value)
		end
		escaped = replace(righthandside, r"^['\"]|[\s>&]" => entity)
		"$(attribute.name)=$(escaped)"
	end

	print(io, result)
end

# ╔═╡ 829b96c6-1287-11eb-20cb-f3096f0b0703
function Base.show(io::IO, mime::MIME"text/html", child::StateData)
	if do_you_even_html_bro(child.value)
		show(io, mime, child.value)
	else
		print(io, replace(string(child.value), r"[<&]" => entity))
		# print(io, htmlencode(child.value))
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
function isAsciiAlphaCode(code)
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
function hypertext(strings, arguments)
	state = STATE_DATA
	string = InterpolateArray([])
	nameStart = 0
	nameEnd = 0

	for j in 1:length(strings)
		input = strings[j]

		if j > 1
			value = arguments[j]
			
			if state == STATE_DATA
				string *= StateData(value)
				
			elseif state == STATE_BEFORE_ATTRIBUTE_VALUE
				state = STATE_ATTRIBUTE_VALUE_UNQUOTED
								
				@debug strings
				@debug nameStart:nameEnd
				name = strings[j - 1][nameStart:nameEnd]
				prefixlength = length(string) - nameStart 

				string = InterpolateArray([
					string.arr[begin:end-1]...,
					string.arr[end][begin:nameStart - 1]
				])


				# string = string[1:(nameStart - length(strings[j - 1]))]
				string *= AttributeValue(name, value)

				# if match(r"^[\s>]", input) !== nothing
				# 	if value === nothing || value == false
				# 		string = 
				# 	elseif value === true
				# 		string *= "''"
				# 	else
				# 		if (name === "style" && isObjectLiteral(value)) # || typeof value === "function"
				# 			throw("Something here")
				# 			string *= "::" * j
				# 			nodeFilter |= SHOW_ELEMENT
				# 		else
				# 			string *= replace(value, r"^['\"]|[\s>&]" => entity)
				# 		end
				# 	end
				# else
				# 	string *= replace(value, r"^['\"]|[\s>&]" => entity)
				# end
				
			elseif state == STATE_ATTRIBUTE_VALUE_UNQUOTED
				string *= AttributeUnquoted(value)
				
			elseif state == STATE_ATTRIBUTE_VALUE_SINGLE_QUOTED
				string *= AttributeSingleQuoted(value)
				
			elseif state == STATE_ATTRIBUTE_VALUE_DOUBLE_QUOTED
				string *= AttributeDoubleQuoted(value)
				
			elseif state == STATE_BEFORE_ATTRIBUTE_NAME
				string *= BeforeAttributeName(value)
				# if isObjectLiteral(value)
				# 	string *= "::" * j * "=''"
				# 	nodeFilter |= SHOW_ELEMENT
				# else
				# 	throw("invalid binding #2")
				# end
			elseif state == STATE_COMMENT || true
				throw("invalid binding #1 $(state)")
			end
		end

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
					@debug "ALL THE OTHERS"
					state = STATE_AFTER_ATTRIBUTE_NAME
					nameEnd = i - 1
					i -= 1
				elseif code === CODE_EQ
					state = STATE_BEFORE_ATTRIBUTE_VALUE
					@debug "CODE_EQ"
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

	return string
end

# ╔═╡ 50b261ae-1284-11eb-1496-d300a0e1d2a0
macro htl(expr)
	if expr isa String
		return hypertext([expr], [nothing])
	end
	
	@assert expr.head == :string
	
	strings = []
	arguments = []
	for i in (1:2:length(expr.args))
		push!(strings, expr.args[i])
		try
			push!(arguments, expr.args[i+1])
		catch; end
	end


	
	quote
		strings = $(strings)
		arguments = [$(map(esc, arguments)...)]

		missing_args = (length(arguments) - length(strings)) + 1
		size_fix = [strings..., repeat([""], missing_args)...]
		
		hypertext(size_fix, [nothing, arguments...])
	end
end

# ╔═╡ c4e9901e-12d5-11eb-1c3c-f7a267c38b06
@htl """<style>
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

# ╔═╡ 4107909e-12e8-11eb-231f-15111d759302
x = @htl("""<div class="$("hey XD")">Hey</div>$("Something")""")

# ╔═╡ f8f20860-12ea-11eb-2ae2-a108ae05e1a1
@htl("""
	<div class=$("blue" * " " * "light")>
		$(html"<div>WOW</div>")
	</div>
	$(10)
""")

# ╔═╡ 47a8de5c-12ee-11eb-15a5-97783fdea760
@htl("""
	<div $(xxx)>
		Blue
	</div>
""")

# ╔═╡ 38fce674-12ed-11eb-1b30-a32ed1d0bc58
@htl("""<div>$("Hey") - $(10)</div>""")

# ╔═╡ a622b5cc-1274-11eb-164d-0b63d950630a
function isObjectLiteral(value) 
	typeof(value) == Dict
  # return value && value.toString === Object.prototype.toString
end

# ╔═╡ Cell order:
# ╟─7d7ecade-1274-11eb-1412-a78c710091d5
# ╟─320ecfcc-12d8-11eb-3b17-4d428df9c64c
# ╠═c4e9901e-12d5-11eb-1c3c-f7a267c38b06
# ╠═4107909e-12e8-11eb-231f-15111d759302
# ╠═f8f20860-12ea-11eb-2ae2-a108ae05e1a1
# ╠═72fcfbce-12ee-11eb-15b0-67a7b29ae044
# ╠═47a8de5c-12ee-11eb-15a5-97783fdea760
# ╟─57f74f28-128a-11eb-1efa-132082acc59b
# ╟─2765fa4a-1281-11eb-18a4-f14999912807
# ╟─2d83c766-1281-11eb-04aa-25be5611842a
# ╟─09cee43a-1282-11eb-0a46-c18ecd9625ce
# ╟─270fc9b6-12e5-11eb-2521-e5d37de17cce
# ╟─03487786-12e9-11eb-14db-4d97ecf364dc
# ╟─841f6af8-1286-11eb-2840-f509d5f19d52
# ╠═3b5caba2-1287-11eb-193c-5bee1ef582c5
# ╠═5e9ff658-12ef-11eb-1725-bd2616fe3463
# ╠═6d464c46-12ef-11eb-3ccd-375549d552ab
# ╠═2789a164-12ef-11eb-0363-cf772908ce7a
# ╠═dccd80a4-12ef-11eb-3347-59a44dc4e4c3
# ╠═38fce674-12ed-11eb-1b30-a32ed1d0bc58
# ╟─50b261ae-1284-11eb-1496-d300a0e1d2a0
# ╟─9bb8f20e-1283-11eb-3e92-57505be107dd
# ╟─3ad52dfc-12d7-11eb-150d-ab55f1099fd5
# ╟─ebdef998-1285-11eb-14cc-8b85678a72c0
# ╟─829b96c6-1287-11eb-20cb-f3096f0b0703
# ╟─04e1943a-1286-11eb-25eb-99f38df6c66a
# ╟─d4a0546c-12cf-11eb-1d03-cd395f63f993
# ╟─1e23dc34-1286-11eb-2957-335d24349a4d
# ╟─1edafc64-12d1-11eb-1a14-2f2e86cf7e94
# ╟─24bb615c-1286-11eb-1106-478fafe4371c
# ╟─42d2a93e-12d1-11eb-1816-e994ba4b209e
# ╟─48f3d7a2-1286-11eb-3598-6deee29c753a
# ╠═3d1e8308-12d3-11eb-3bf1-67d55eae7f50
# ╠═d97167b4-1273-11eb-2be4-ad073ff79006
# ╠═f222324a-127c-11eb-0f20-49189a060eb1
# ╠═ffd98b56-127c-11eb-3a7b-cf4afa5630b7
# ╠═1e29b2fc-127d-11eb-05b4-83874bad781c
# ╠═28a1cb52-127d-11eb-10d5-a531650667c1
# ╠═401507ca-127a-11eb-0110-517057d53125
# ╠═8aa89fa0-1274-11eb-05a7-dfd699933cbe
# ╠═8d20f660-1274-11eb-2bc8-95c2558b7f4b
# ╠═a62252c6-1274-11eb-0605-45db63c8abfb
# ╠═a622b5cc-1274-11eb-164d-0b63d950630a
