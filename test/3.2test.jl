### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ f2136390-0ca2-4c3f-9c5c-7eb7c78a3da8
using Box

# ╔═╡ e1704820-411c-4ddf-a100-72f8ca952941
using HypertextLiteral

# ╔═╡ 648664de-fb5b-4e74-a09c-fab401cc4ddc
ss = md"""
## 士大_夫sdf撒发 
asdf
"""  

# ╔═╡ b19a277f-ecc2-4505-b154-7429e8bfdcf5
a = match(r"#.*\n",string(ss)).match

# ╔═╡ ca4564c4-4a5f-4475-860a-fcd6fc8fc3e3
rootpath = split(dirname(@__FILE__),"\\")[end]

# ╔═╡ 92f8e369-e0fe-4994-83de-e89954faffbc
function maketoc(git="https://mathutopia.github.io")
	toc = read("toc.txt",String)
	toc = unique(split(strip(toc,'\n'), "\n"))
	pkgn = split(dirname(@__FILE__),"\\")[end]
	toc = [split(t,',') for t in toc]

	

	render_url(c) = join([git, pkgn, c[4] ],"/")

	render_row(c) = @htl("""
	
      <li> <a href=$(render_url(c))> $(c[3]) </a> </li>
    """)

    render_table(list) = @htl("""
    <div id="toc">
        <!-- 目录代码 -->
        <div style="text-align:center;"> <h3> 目录 <h3></div>
            
        <ul>
        $((render_row(b) for b in list))
        </ul>
    </div>
    <style>
        .toc {        
                margin-bottom: 10px;
                padding: 8px;
                background-color: #CCF;
                border: 1px solid #ddd;
                border-radius: 4px;      
        }
	</style>
  """)
	render_table(toc)
end

# ╔═╡ 5b568ad7-1e66-4736-84de-7152624b9859
maketoc()

# ╔═╡ 6b19c8cc-ce70-42f1-847c-3ce89299ac30
"""
    get_current_file_name -> nothing or filename 

用于返回当前运行的jl文件的文件名
```julia

```
"""   
function get_current_file_name()
	pathn = @__FILE__
	try m = match(r"\\.*\.jl",@__FILE__)
		m = split(m.match, "\\")
		return m[end]
	catch e
		println(e)
		return nothing
	end
end

# ╔═╡ 11493585-9ac9-4cf9-9f62-aee04ba305d5
function biaoti(str::Markdown.MD)
	bt = match(r"#.*\n",string(ss)).match
	bt = strip(bt, ['\n','#',' '])
	bt = replace(bt, [' ', ':','_'] => '-')

	fn = get_current_file_name()
	if occursin("backup", fn)
		return str
	end
	
	fnv = split(fn, ['.', '-'])
	@assert fnv[4] == "jl" "这个文件名有问题 $fnv"
	chapter, section, filename = fnv[1:3]

	open("toc.txt","a") do f
           write(f,  chapter, ',',section, ',',bt,',',filename,'\n')
    end
	return str
end

# ╔═╡ 06efd6c0-4b8f-42d1-aad5-3840c63ff4a0
ss |> biaoti

# ╔═╡ e222512d-90f1-4d60-9eb5-3e70655f9e84
hline("")

# ╔═╡ 5cb57a91-c318-4be1-a3bb-c01a60d51eb5
md"""
s撒懂法守法
""" |> box()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Box = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"

[compat]
Box = "~1.0.2"
HypertextLiteral = "~0.9.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "0ddcdac345900f1836b5593647a23f16358257a1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Box]]
deps = ["HypertextLiteral", "Markdown"]
git-tree-sha1 = "2d9ed49b39bb23bb7bdd80d77cf61f97e88ad3d2"
uuid = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
version = "1.0.2"

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
# ╠═f2136390-0ca2-4c3f-9c5c-7eb7c78a3da8
# ╠═648664de-fb5b-4e74-a09c-fab401cc4ddc
# ╠═b19a277f-ecc2-4505-b154-7429e8bfdcf5
# ╠═06efd6c0-4b8f-42d1-aad5-3840c63ff4a0
# ╠═ca4564c4-4a5f-4475-860a-fcd6fc8fc3e3
# ╠═e1704820-411c-4ddf-a100-72f8ca952941
# ╠═11493585-9ac9-4cf9-9f62-aee04ba305d5
# ╠═92f8e369-e0fe-4994-83de-e89954faffbc
# ╠═5b568ad7-1e66-4736-84de-7152624b9859
# ╠═6b19c8cc-ce70-42f1-847c-3ce89299ac30
# ╠═e222512d-90f1-4d60-9eb5-3e70655f9e84
# ╠═5cb57a91-c318-4be1-a3bb-c01a60d51eb5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
