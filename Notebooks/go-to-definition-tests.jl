### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ c8457138-a45f-430d-bf41-4bacbe1779de
y1 = 10

# ╔═╡ c461953d-fe7d-4dbc-8677-f886d81fe5ab
abstract type y3 end

# ╔═╡ 87a5b8ea-c6f2-4bf5-b8bd-0d8dbf27f467
struct y2 <: y3 end

# ╔═╡ 9cf5e608-d9e2-4ec7-b140-cb5748072fcd
macro y4() end

# ╔═╡ ec48fd24-1e5c-429d-b1b8-d5e6218930d4


# ╔═╡ ec478346-0e53-4850-94db-36ea84ed2477
LLL.@macro X+λ/2

# ╔═╡ a6f0e836-fa7a-4a34-a87c-51db806f7154
MIME"text/html"

# ╔═╡ 9f4cbf9b-ae9f-472b-a0d2-bd72c5b12f60
"asd"

# ╔═╡ ff1654da-7007-4064-8f96-c64ce9a43d6e


# ╔═╡ 2ce62c6d-bb35-459b-b3da-26154e0631c2
"\\" # hi"

# ╔═╡ 2215479b-502b-40c9-97cc-23d8b5910727
x + :begin

# ╔═╡ 0408990e-cda6-4ebc-bb0c-a14fac4962df
:begin + 1 asd()

# ╔═╡ 46939f80-d683-400b-a5b9-9e460c205874


# ╔═╡ f9351399-f3ee-4665-b3a6-967b692bc132
LLL = 10

# ╔═╡ b9330c5f-741d-460d-a2a4-d1d353786eff
H= 10

# ╔═╡ 563e15ad-50d2-4b35-8ef3-c776b8c99831
y = 10

# ╔═╡ 7f6731a5-029f-4b7a-bf2b-5c55d784bcad
(LLL = 10,)

# ╔═╡ 86a67548-96bf-4dd9-9b50-73af8f4a7979
:if

# ╔═╡ 7f91c428-0fe9-4288-8a57-a3d5e1957e0f
:(mod.$(hi)"# Hi")

# ╔═╡ 9757f6a0-ca5b-4afd-a19f-b8a5df3e78aa
10units().x

# ╔═╡ 95ab1795-d6a1-4bd8-8a38-5bc09b354b1d
l.a""

# ╔═╡ 782c7574-8b78-4ad2-921f-2554752a6e3f
a""

# ╔═╡ 261f94c1-e938-46fd-915f-b17c1de4a54a
"""$(
begin
	init = A'[I]
	# broken:
	1 + two + "3"
end
)"""

# ╔═╡ 5c1c8856-5650-4943-979d-ba42eaa34a91
@Test.test 1 == 1

# ╔═╡ 41e589f2-ad62-4814-9a02-5fdab26ff335
let 
	"hello # world"
end

# ╔═╡ 224faf90-58ec-492d-a6b5-ab6505d20cb8
10u"mg"

# ╔═╡ a6693ac5-46a5-4d3c-a9ad-34e9aa8b2c46
let
	sum(
		sum(
			x for x in g
		)
		for x in g
	)
end

# ╔═╡ d722de9f-dd8e-416a-a310-59e3e6320839
"""
$(any(x>0 for x in 1:10 if x isa Number))
"""

# ╔═╡ 173d58e8-4963-4a09-9c53-7610da7738a4
5y1()

# ╔═╡ 6ad83a71-f9a9-488d-a85c-d8eb41d09ba3
@asdasd() do y1, y2
	y1, y2, y3
end

# ╔═╡ 897a841f-0dd7-4649-bfff-5bed1c3f6993
html"""
<div>x</div>
"""

# ╔═╡ 632cc25a-f8e6-4377-8caf-87b34e213435
module y5
	macro y() end
end

# ╔═╡ 49e6558e-1af5-4be7-9d5d-d8b759004f51
function y6(y1, y2::y2, y3 = y3)
	y1, y2, y3, y5
end

# ╔═╡ 7fd1d2ed-f243-4156-b63c-2bbd632a2d8d
export y1, y2, y3, @y4, y5, y6

# ╔═╡ b71f55a3-8265-4fb3-bae7-132f8a486bc1
y5.@y

# ╔═╡ 35792efd-e9aa-40b6-8263-c4e8210afbe9
@y5.y

# ╔═╡ 486cc66f-aeeb-46e3-b453-47cf69bebd2f
[y1 for y1 in y1:y1]

# ╔═╡ a574018a-8b73-454d-b06d-05372589a9e2
x.d

# ╔═╡ 4f09c6fc-0627-4a25-a510-46fee8b6eccc
x.g.l = 10

# ╔═╡ 650ff4da-2293-4714-b8ce-06d9270aba5b
asd = 10

# ╔═╡ 6191d789-c6b1-4d52-9002-b81d8bac41de
asd.:(hi)

# ╔═╡ 0412619f-4412-448e-ac7c-b9bf0f95cd34
[x for x in 1:14]

# ╔═╡ add99dfe-4701-4031-9adb-e5976c2b132b
"h $(x)i"

# ╔═╡ 96a24996-bf60-4341-80d2-1f35a3faccff
asd`open`

# ╔═╡ 0e581941-5b9d-40f7-8d71-783470fed6b9
struct X end

# ╔═╡ 399d2d0c-6407-4bdb-b7ea-5ab9d2539654
X{LLL}

# ╔═╡ 10567ba0-3c96-4283-90d6-d9a0cfe64823
function G(; y = y)::LLL{X}
	t = y
	t = 2
end

# ╔═╡ f505b2aa-e0cd-49da-b9d9-bf085c48b90d
G(LLL=LLL)

# ╔═╡ fd80a205-578c-41c4-ae2c-e2c4283e78b3
X::Y

# ╔═╡ Cell order:
# ╠═c8457138-a45f-430d-bf41-4bacbe1779de
# ╠═c461953d-fe7d-4dbc-8677-f886d81fe5ab
# ╠═87a5b8ea-c6f2-4bf5-b8bd-0d8dbf27f467
# ╠═9cf5e608-d9e2-4ec7-b140-cb5748072fcd
# ╠═ec48fd24-1e5c-429d-b1b8-d5e6218930d4
# ╠═ec478346-0e53-4850-94db-36ea84ed2477
# ╠═399d2d0c-6407-4bdb-b7ea-5ab9d2539654
# ╠═a6f0e836-fa7a-4a34-a87c-51db806f7154
# ╠═9f4cbf9b-ae9f-472b-a0d2-bd72c5b12f60
# ╠═ff1654da-7007-4064-8f96-c64ce9a43d6e
# ╠═2ce62c6d-bb35-459b-b3da-26154e0631c2
# ╠═2215479b-502b-40c9-97cc-23d8b5910727
# ╠═0408990e-cda6-4ebc-bb0c-a14fac4962df
# ╠═46939f80-d683-400b-a5b9-9e460c205874
# ╠═f9351399-f3ee-4665-b3a6-967b692bc132
# ╠═b9330c5f-741d-460d-a2a4-d1d353786eff
# ╠═563e15ad-50d2-4b35-8ef3-c776b8c99831
# ╠═10567ba0-3c96-4283-90d6-d9a0cfe64823
# ╠═7f6731a5-029f-4b7a-bf2b-5c55d784bcad
# ╠═f505b2aa-e0cd-49da-b9d9-bf085c48b90d
# ╠═86a67548-96bf-4dd9-9b50-73af8f4a7979
# ╠═fd80a205-578c-41c4-ae2c-e2c4283e78b3
# ╠═7f91c428-0fe9-4288-8a57-a3d5e1957e0f
# ╠═9757f6a0-ca5b-4afd-a19f-b8a5df3e78aa
# ╠═6191d789-c6b1-4d52-9002-b81d8bac41de
# ╠═95ab1795-d6a1-4bd8-8a38-5bc09b354b1d
# ╠═782c7574-8b78-4ad2-921f-2554752a6e3f
# ╠═261f94c1-e938-46fd-915f-b17c1de4a54a
# ╠═5c1c8856-5650-4943-979d-ba42eaa34a91
# ╠═41e589f2-ad62-4814-9a02-5fdab26ff335
# ╠═224faf90-58ec-492d-a6b5-ab6505d20cb8
# ╠═a6693ac5-46a5-4d3c-a9ad-34e9aa8b2c46
# ╠═d722de9f-dd8e-416a-a310-59e3e6320839
# ╠═173d58e8-4963-4a09-9c53-7610da7738a4
# ╠═6ad83a71-f9a9-488d-a85c-d8eb41d09ba3
# ╠═897a841f-0dd7-4649-bfff-5bed1c3f6993
# ╠═632cc25a-f8e6-4377-8caf-87b34e213435
# ╠═49e6558e-1af5-4be7-9d5d-d8b759004f51
# ╠═7fd1d2ed-f243-4156-b63c-2bbd632a2d8d
# ╠═b71f55a3-8265-4fb3-bae7-132f8a486bc1
# ╠═35792efd-e9aa-40b6-8263-c4e8210afbe9
# ╠═486cc66f-aeeb-46e3-b453-47cf69bebd2f
# ╠═a574018a-8b73-454d-b06d-05372589a9e2
# ╠═4f09c6fc-0627-4a25-a510-46fee8b6eccc
# ╠═650ff4da-2293-4714-b8ce-06d9270aba5b
# ╠═0412619f-4412-448e-ac7c-b9bf0f95cd34
# ╠═add99dfe-4701-4031-9adb-e5976c2b132b
# ╠═96a24996-bf60-4341-80d2-1f35a3faccff
# ╠═0e581941-5b9d-40f7-8d71-783470fed6b9
