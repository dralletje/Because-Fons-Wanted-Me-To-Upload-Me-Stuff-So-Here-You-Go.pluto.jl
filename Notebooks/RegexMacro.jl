### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ e55ea6f0-4323-11ec-1084-1d4d52a1a43d
"""
    regex_escape(s::AbstractString)
Sanitize a string to make it safe for use in regular expression pattern construction. Any
regular expression metacharacters are escaped along with whitespace.
# Examples
```jldoctest
julia> regex_escape("Bang!")
"Bang\\!"
julia> regex_escape("  ( [ { . ? *")
"\\ \\ \\(\\ \\[\\ \\{\\ \\.\\ \\?\\ \\*"
julia> regex_escape("/^[a-z0-9_-]{3,16}\$/")
"/\\^\\[a\\-z0\\-9_\\-\\]\\{3,16\\}\\\$/"
```
"""
function regex_escape(s::AbstractString)
    res = replace(s, r"([()[\]{}?*+\-|^\$\\.&~#\s=!<>|:])" => s"\\\1")
    replace(res, "\0" => "\\0")
end

# ╔═╡ de84fde6-d96d-46b0-9bb0-d757ee3801a2
function interpolate_regex(str::AbstractString)
	regex_escape(str)
end

# ╔═╡ f745d6e8-777b-445b-9eb6-0e96d63b6256
function interpolate_regex(regex::Regex)
	regex.pattern
end

# ╔═╡ 5dbe703b-edd8-44e8-9f7c-7420f631a5f0
macro regex(str)
	if str isa String
		return var"@regex"(Expr(:string, str))
	end

	parts = []
	for part in str.args
		if part isa String
			push!(parts, part)
		else
			push!(parts, :(interpolate_regex($(esc(part)))))
		end
	end
	:(Regex($(Expr(:string, parts...))))
end

# ╔═╡ e0b844d7-de3e-4027-8622-3a7e2a0ecf9a
bb = "asd"

# ╔═╡ cace33e5-7d9b-4508-9df5-aa415524cf22
@regex "aa$(bb)c\\wc"

# ╔═╡ cd52f2cf-3f42-4d1e-80a7-575dadaa0453
sprint(dump, :("aa$(bb)cc")) |> Text

# ╔═╡ Cell order:
# ╟─e55ea6f0-4323-11ec-1084-1d4d52a1a43d
# ╠═de84fde6-d96d-46b0-9bb0-d757ee3801a2
# ╠═f745d6e8-777b-445b-9eb6-0e96d63b6256
# ╠═5dbe703b-edd8-44e8-9f7c-7420f631a5f0
# ╠═e0b844d7-de3e-4027-8622-3a7e2a0ecf9a
# ╠═cace33e5-7d9b-4508-9df5-aa415524cf22
# ╠═cd52f2cf-3f42-4d1e-80a7-575dadaa0453
