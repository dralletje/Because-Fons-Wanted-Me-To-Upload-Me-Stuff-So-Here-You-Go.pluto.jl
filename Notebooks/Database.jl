### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 06e81ba8-1627-11eb-1a18-ad4c9eb136fa
using DataFrames

# ╔═╡ aa7e64fc-1726-11eb-086f-531c28f1ac4e
using CSV

# ╔═╡ acff09ca-1726-11eb-3c0f-a99ed5eb7332
from_csv = CSV.read("./10000-entries.csv", DataFrame);

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

# ╔═╡ ec265f34-1719-11eb-3575-e13a9de0466e
csv_line = """ "First", "second", "Third" """

# ╔═╡ 8fb6be68-171b-11eb-1e4b-ff3f1b07a928
nowrap_csv_line = "First,Second,Third"

# ╔═╡ 7a949eb2-171b-11eb-29cf-fbca671a246f
parsed_nowrap = get_csv_value_positions_no_wrap(nowrap_csv_line)

# ╔═╡ a279eaea-171c-11eb-0712-13cc5930cbb4
function Base.:+(value::CsvParsedValue, n::Number)
	CsvParsedValue(
		start=value.start + n,
		length=value.length
	)
end

# ╔═╡ b52eb98a-171a-11eb-0999-4dcac8b2ab49
file_line = readline("./1000-entries.csv")

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

# ╔═╡ 514b979c-1dd2-11eb-35fe-5b4dcf9dadef


# ╔═╡ d541388c-1734-11eb-0f38-2b5a796edb69
abstract type Unit <: Number end

# ╔═╡ df2e6e00-1734-11eb-3094-e5421fd7fb7a
Base.getindex(value::Unit) = value.value

# ╔═╡ 1e0f5e7c-1735-11eb-39ea-4d3ffa3aeec7
Base.:+(a::T, b::T) where {T <: Unit} = T(a[] + b[])

# ╔═╡ 8c5a424e-171b-11eb-16a4-6199526d4852
map(parsed_nowrap) do value
	nowrap_csv_line[value.start:(value.start + value.length)]
end

# ╔═╡ 3b2b47f0-1735-11eb-2a1b-a9492f05416d
Base.:-(a::T, b::T) where {T <: Unit} = T(a[] - b[])

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

# ╔═╡ bd87cf44-171b-11eb-077d-610887f5cd07
file_values = csv_parse_positions(file_line)

# ╔═╡ c8d2d7ae-171b-11eb-0c3e-559fb17734db
map(file_values) do value
	file_line[value.start:(value.start + value.length)]
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

# ╔═╡ ab082efc-1713-11eb-3304-e958c91a5554
csvfile = read_csv("./10000-entries.csv");

# ╔═╡ 43a7efa0-1730-11eb-2f46-6f62a57edbc9
csvfile["Order ID",:][1:10]

# ╔═╡ c18a5a76-1731-11eb-2a16-61e3fd622a75
csvfile[:,1]

# ╔═╡ a7312cae-1731-11eb-0cd7-df9193e0c171
csvfile["Order ID", 1]

# ╔═╡ 4658c5a0-1733-11eb-14d5-231c0436eaa3
whole_thing = map(csvfile.headers) do header
	csvfile[header,:]
end;

# ╔═╡ 15a828da-1722-11eb-1744-9d083d37f7d7
function read_csv_value(file, position)
	seek(file, position.start - 1)
	return String(read(file, position.length + 1, all=true))
end

# ╔═╡ e01399a8-172f-11eb-00e7-336bd50c252a
# "Get the values of a line"
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

# ╔═╡ fc0d4072-1730-11eb-2139-0f2b0f999091
# "Get all values of a column in all lines"
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

# ╔═╡ f63ea704-1731-11eb-145d-71a3440c50ad
# "Get all values of a column in all lines"
function Base.getindex(csvfile::CsvFile, column::String, linenumber::Number)
	index = findfirst(==(column), csvfile.headers)
	open(csvfile.path) do file
		read_csv_value(file, csvfile.lines[linenumber].positions[index])
	end
end

# ╔═╡ a4de8654-171b-11eb-0595-b55ef15dc401
md"### Csv test with quotes"

# ╔═╡ abf95f86-171b-11eb-1e11-ef354453a963
md"### Csv test no quotes"

# ╔═╡ 0b257588-171e-11eb-037a-73f723dc139f
md"### Get CSV positions"

# ╔═╡ 14db541c-171e-11eb-2ea3-390648613723
md"### Test CSV positions on 1000-entries.csv"

# ╔═╡ 208cd132-171e-11eb-08ba-a9f790f93c93
md"## Parse file"

# ╔═╡ f0f3c8ac-1733-11eb-1b58-f97bbfd79ea1
md"### getindex to retrieve values"

# ╔═╡ 28634556-1734-11eb-1161-cb1d522ecc2a
md"### Compare size"

# ╔═╡ d0dc5678-1734-11eb-1671-f775af2fc554
md"## Unit"

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"

[compat]
CSV = "~0.9.11"
DataFrames = "~1.3.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "49f14b6c56a2da47608fe30aed711b5882264d7a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.11"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "cfdfef912b7f93e4b848e80b9befdf9e331bc05a"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.1"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "244586bc07462d22aed0113af9c731f2a518c93e"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.10"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═06e81ba8-1627-11eb-1a18-ad4c9eb136fa
# ╠═aa7e64fc-1726-11eb-086f-531c28f1ac4e
# ╠═acff09ca-1726-11eb-3c0f-a99ed5eb7332
# ╠═05afcdfe-1728-11eb-2c18-3b21a30cefed
# ╠═a8661cbe-1dca-11eb-3304-e5217c8432cc
# ╠═9577e642-1716-11eb-1ff7-273a099de056
# ╠═508826bc-1718-11eb-18f2-87fd5a9189e5
# ╠═632f536c-1718-11eb-0647-9f8a8bfe52aa
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
# ╠═e01399a8-172f-11eb-00e7-336bd50c252a
# ╠═43a7efa0-1730-11eb-2f46-6f62a57edbc9
# ╠═fc0d4072-1730-11eb-2139-0f2b0f999091
# ╠═c18a5a76-1731-11eb-2a16-61e3fd622a75
# ╠═f63ea704-1731-11eb-145d-71a3440c50ad
# ╠═a7312cae-1731-11eb-0cd7-df9193e0c171
# ╟─28634556-1734-11eb-1161-cb1d522ecc2a
# ╠═97ea65a0-1732-11eb-1e6e-0bc8efc38012
# ╠═d5de9dfe-1732-11eb-22b1-7d2f9efa9d1d
# ╠═4658c5a0-1733-11eb-14d5-231c0436eaa3
# ╠═a3438ab6-1733-11eb-379f-83d7b04e389d
# ╠═ae486b2a-1733-11eb-307b-f7197700a08c
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
