### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ 17dc0323-5aa5-42d6-a316-b349c06933ba
using HypertextLiteral 

# ╔═╡ 1aa0a37f-69a9-40cd-acfd-c7f7b522d072
@htl("""
<p style="align：center； color:green; font-size:40px;" > 基于julia的数据挖掘实验教材  </p>
""")

# ╔═╡ b479ffc8-f9bc-45b4-a105-70234cc39ff6
md"""
这是一个简单的基于Julia的数据挖掘实验教程
"""

# ╔═╡ 52e62656-9402-45b9-9c35-7e870b044e49
rootpath = "https://mathutopia.github.io/dmexerbook/" ;

# ╔═╡ cdd355bf-0ddd-4c8e-af98-4c1def522af5
begin
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
end;

# ╔═╡ 48a37b8f-13e2-4374-ad29-8276e08bf34d
    render_table(jlfl)

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
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
HypertextLiteral = "~0.9.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "5b37abdf7398dc5da4cd347d0609990238d895bb"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"
"""

# ╔═╡ Cell order:
# ╟─1aa0a37f-69a9-40cd-acfd-c7f7b522d072
# ╟─b479ffc8-f9bc-45b4-a105-70234cc39ff6
# ╟─48a37b8f-13e2-4374-ad29-8276e08bf34d
# ╟─52e62656-9402-45b9-9c35-7e870b044e49
# ╟─17dc0323-5aa5-42d6-a316-b349c06933ba
# ╟─cdd355bf-0ddd-4c8e-af98-4c1def522af5
# ╟─e53e8558-b018-4f2f-a3b4-4df62952912a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
