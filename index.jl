### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ 17dc0323-5aa5-42d6-a316-b349c06933ba
using HypertextLiteral 

# ╔═╡ 5e5b8716-480a-4570-9991-8573b244c78a
using Box

# ╔═╡ 1aa0a37f-69a9-40cd-acfd-c7f7b522d072
@htl("""
<p style="align：center； color:green; font-size:30px;" > 基于julia的数据挖掘实验教材  </p>
""")

# ╔═╡ b479ffc8-f9bc-45b4-a105-70234cc39ff6
md"""
这是一个简单的基于Julia的数据挖掘实验教程
"""

# ╔═╡ 52e62656-9402-45b9-9c35-7e870b044e49
rootpath = "https://mathutopia.github.io/dmexerbook/" ;

# ╔═╡ 54c07a7c-3dd9-4379-b85a-92df29846144
function maketoc()
	fs = readdir(".")
	jlfl = [ (name=nm[1:end-3] , url = rootpath*nm[1:end-3]) for nm in fs if 		(endswith( nm, ".jl") && nm != "index.jl")]

	render_row(file) = @htl("""
	
      <li> <a href=$(file.url)> $(file.name) </a> </li>
    """)

    render_table(list) = @htl("""
      <div id="toc">
    <!-- 目录代码 -->
	<div style="text-align:center;"> <h3> 目录 <h3></div>
	
    <ul>
      $((render_row(b) for b in list))
	 </ul>
  </div>""")

	render_table(jlfl)
end

# ╔═╡ 70071301-a573-49fe-af8a-07b9fb05f41f
maketoc()

# ╔═╡ e53e8558-b018-4f2f-a3b4-4df62952912a
html"""
<style>

#toc {
  font-family: Arial, sans-serif;
  background-color: #f2f2f2;
  padding: 10px;
}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Box = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
Box = "~1.0.3"
HypertextLiteral = "~0.9.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "50c77d89d3404b24f255fef026b0ae84a1156282"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Box]]
deps = ["HypertextLiteral", "Markdown"]
git-tree-sha1 = "6f8813909ef1623648a3e6ed2d07a8924e86f64e"
uuid = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
version = "1.0.3"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"
"""

# ╔═╡ Cell order:
# ╠═17dc0323-5aa5-42d6-a316-b349c06933ba
# ╠═5e5b8716-480a-4570-9991-8573b244c78a
# ╟─1aa0a37f-69a9-40cd-acfd-c7f7b522d072
# ╟─b479ffc8-f9bc-45b4-a105-70234cc39ff6
# ╟─52e62656-9402-45b9-9c35-7e870b044e49
# ╠═54c07a7c-3dd9-4379-b85a-92df29846144
# ╠═70071301-a573-49fe-af8a-07b9fb05f41f
# ╟─e53e8558-b018-4f2f-a3b4-4df62952912a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
