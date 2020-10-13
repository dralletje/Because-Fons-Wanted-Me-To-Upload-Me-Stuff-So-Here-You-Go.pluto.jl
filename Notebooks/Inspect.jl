### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ 8a199116-0be9-11eb-3928-9d270715ab91
download("https://raw.githubusercontent.com/fonsp/Pluto.jl/master/sample/Basic%20mathematics.jl")

# ╔═╡ c823f32a-0bcb-11eb-3b03-6f254957f1eb
struct Inspect
	value
end

# ╔═╡ 0fecfd3e-0bcf-11eb-1305-b1937e8b49ec
struct X
	x
	y
	z
end

# ╔═╡ 09b08b98-0bcf-11eb-19f2-9ff8b7af039d
sprint(show_struct, X(1,2,3))

# ╔═╡ 80edd01c-0bcf-11eb-1457-ddf7db1a1b82
Inspect(X(1,2,X(1,2,3)))

# ╔═╡ 692bf69c-0bd0-11eb-0a1e-df13a56a6d93
Inspect("Hey")

# ╔═╡ 75a805be-0bd0-11eb-1c0d-e7b32cf4f8e4
Inspect(:(1 + 1))

# ╔═╡ b11f7960-0bd0-11eb-356e-41e70d175ce7
Inspect([1,2,3,4])

# ╔═╡ 9b7e029a-0bd3-11eb-15e7-49e3eae7de79
tree_display_limit = 20

# ╔═╡ 62d91c7a-0bd2-11eb-2ab3-65cdfc639441
1 ≠ 2

# ╔═╡ 151555a0-0bd1-11eb-173f-69b267574cc6
[:(1 + 1)]

# ╔═╡ 20b02b58-0bd1-11eb-09cd-4d85ccbf2589
[Docs.doc(Base)]

# ╔═╡ 6e4e4f2a-0bd1-11eb-39ba-e3966462d7a1
Inspect(Docs.doc(Base))

# ╔═╡ 19f817be-0bd4-11eb-30ce-f9c1e1afd4af
typeof(:(1 + 1))

# ╔═╡ 1f2a6b2e-0bd4-11eb-1f8f-c1c8606c50c4
Meta.parse("'a'")

# ╔═╡ 6b9d3d52-0bd3-11eb-17d9-d339e5f636e9
function array_prefix(io, x::Array{<:Any, 1})
    print(io, eltype(x))
end

# ╔═╡ 6d68f680-0bd3-11eb-3b57-e5df8c2ef26d
function array_prefix(io, x)
    original = sprint(Base.showarg, x, false)
    print(io, lstrip(original, ':'))
    print(io, ": ")
end

# ╔═╡ 30c9e924-0bcd-11eb-3201-0f0758b02076
# Based on Julia source code, but HTML-ified
function inspect(io::IO, @nospecialize(x))
    t = typeof(x)
    field_count = nfields(x)
    nb = sizeof(x)
    if field_count != 0 || nb == 0
        print(io, """<jltree class="collapsed" onclick="onjltreeclick(this, event)">""")
        show(io, t)
        print(io, "<jlstruct>")
        
        if !Base.show_circular(io, x)
            recur_io = IOContext(io, Pair{Symbol,Any}(:SHOWN_SET, x),
                                 Pair{Symbol,Any}(:typeinfo, Any))
            for i in 1:field_count
                f = fieldname(t, i)
                if !isdefined(x, f)
                    print(io, "<r>", Base.undef_ref_str, "</r>")
                else
                    PlutoRunner.show_array_row(recur_io, (f, getfield(x, i)))
                end
            end
        end

        print(io, "</jlstruct>")
        print(io, "</jltree>")
    else
        Base.show_default(io, x)
    end
end


# ╔═╡ 212b6c6a-0bd0-11eb-154c-01cafaf243e1
1

# ╔═╡ d9042390-0bcb-11eb-2ac8-097fde2b2a8d
function Base.show(io::IO, mime::MIME"application/vnd.pluto.tree+xml", value::Inspect)
	inspect(io, value.value)
end

# ╔═╡ 2d96e9e8-0bcd-11eb-2e25-8f8c06a2bab9
@which Base.show_default(IOBuffer(), "x")

# ╔═╡ 2d5cd59e-0bcd-11eb-3b65-71067978da01


# ╔═╡ 0ba097da-0bd0-11eb-1360-f3bee7c9a97e
function show_array_row(io::IO, pair::Tuple)
    i, element = pair
    print(io, "<r><k>", i, "</k><v>")
    # show_richest(io, element; onlyhtml=true)
	inspect(io, element)
    print(io, "</v></r>")
end

# ╔═╡ a5532bf6-0bd3-11eb-3ad9-45535d8d091b
function show_array_elements(io::IO, indices::AbstractVector{<:Integer}, x::AbstractArray{<:Any, 1})
    for i in indices
        if isassigned(x, i)
            show_array_row(io, (i, x[i]))
        else
            show_array_row(io, (i, Text(Base.undef_ref_str)))
        end
    end
end

# ╔═╡ 07b86458-0bd1-11eb-0e79-616c2cb33e6c
function inspect(io::IO, x::AbstractArray{<:Any, 1})
    print(io, """<jltree class="collapsed" onclick="onjltreeclick(this, event)">""")
    array_prefix(io, x)
    print(io, "<jlarray>")
    indices = eachindex(x)

    if length(x) <= tree_display_limit
        show_array_elements(io, indices, x)
    else
        firsti = firstindex(x)
        from_end = tree_display_limit > 20 ? 10 : 1

        show_array_elements(io, indices[firsti:firsti-1+tree_display_limit-from_end], x)
        
        print(io, "<r><more></more></r>")
        
        show_array_elements(io, indices[end+1-from_end:end], x)
    end
    
    print(io, "</jlarray>")
    print(io, "</jltree>")
end

# ╔═╡ Cell order:
# ╠═8a199116-0be9-11eb-3928-9d270715ab91
# ╠═c823f32a-0bcb-11eb-3b03-6f254957f1eb
# ╠═d9042390-0bcb-11eb-2ac8-097fde2b2a8d
# ╠═0fecfd3e-0bcf-11eb-1305-b1937e8b49ec
# ╠═09b08b98-0bcf-11eb-19f2-9ff8b7af039d
# ╠═80edd01c-0bcf-11eb-1457-ddf7db1a1b82
# ╠═692bf69c-0bd0-11eb-0a1e-df13a56a6d93
# ╠═75a805be-0bd0-11eb-1c0d-e7b32cf4f8e4
# ╠═b11f7960-0bd0-11eb-356e-41e70d175ce7
# ╟─9b7e029a-0bd3-11eb-15e7-49e3eae7de79
# ╠═62d91c7a-0bd2-11eb-2ab3-65cdfc639441
# ╠═151555a0-0bd1-11eb-173f-69b267574cc6
# ╠═20b02b58-0bd1-11eb-09cd-4d85ccbf2589
# ╠═a5532bf6-0bd3-11eb-3ad9-45535d8d091b
# ╠═6e4e4f2a-0bd1-11eb-39ba-e3966462d7a1
# ╠═19f817be-0bd4-11eb-30ce-f9c1e1afd4af
# ╠═1f2a6b2e-0bd4-11eb-1f8f-c1c8606c50c4
# ╠═6b9d3d52-0bd3-11eb-17d9-d339e5f636e9
# ╠═6d68f680-0bd3-11eb-3b57-e5df8c2ef26d
# ╠═07b86458-0bd1-11eb-0e79-616c2cb33e6c
# ╠═30c9e924-0bcd-11eb-3201-0f0758b02076
# ╠═212b6c6a-0bd0-11eb-154c-01cafaf243e1
# ╠═0ba097da-0bd0-11eb-1360-f3bee7c9a97e
# ╠═2d96e9e8-0bcd-11eb-2e25-8f8c06a2bab9
# ╠═2d5cd59e-0bcd-11eb-3b65-71067978da01
