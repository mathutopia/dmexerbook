### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 349bbd34-b34e-46c3-8c47-8bb415d497c8
using PlutoUI, ARules,CSV, DataFrames

# ╔═╡ 768ce87f-a710-47b3-8a7e-9d81a2a0510a
#=
下面的包Box并没有在Julia的通用注册中心注册。主要用于排版。如果要使用该包， 需要首先安装一个非通用的注册中心， 即在RPEL中执行如下代码即可。
```julia
begin
using Pkg
Pkg.Registry.add(RegistrySpec(url = "https://github.com/mathutopia/Wlreg.git"))
end
```
=#
using Box

# ╔═╡ 552abfd5-a12c-46a4-8754-bf6c38e465bf
PlutoUI.TableOfContents(title = "目录", depth = 3, aside = true)

# ╔═╡ 43f9a5aa-1649-4c82-ab8a-605e1da8b61a
html"""
<p style="font-size: 50px; text-align: center;">实验七 关联规则挖掘 </p>
"""

# ╔═╡ 00488270-759d-11ec-12fe-cb07b9231320
md"""
!!! green ""
	# 实验目的
	1. 理解关联规则的相关概念和挖掘算法的基本思想。
	2. 会利用工具包相关数据进行关联规则挖掘。
	3. 能对不同领域的问题， 通过恰当的方式， 将其转换为关联规则挖掘的问题， 并通过编码实现挖掘。

"""

# ╔═╡ 075edf0d-3b6a-4bba-986f-71687365b0b9
md"""
# 实验过程
"""

# ╔═╡ 356c9ecf-648b-488a-a9dd-69d2a7ced9f3
md"""
## 任务1： 数据准备
本实验使用移动业务数据集， 通过关联规则挖掘用户移动业务订购之间的关系。 该数据集包含19个经过处理的字段，各字段的具体含义如下表所示。 

"""

# ╔═╡ 735979ca-1278-4bc5-8917-3ff0d4fd738c
md"""
| 字段名                    | 字段名称     | 说明           |
|------------------------|----------|--------------|
| Khbm                   | 客户编码     |              |
| Fetion\_flag            | 飞信       | 1表示开通，0表示未开通 |
| mms\_flag               | 彩信       | 1表示开通，0表示未开通 |
| mobmail\_flag           | 139邮箱    | 1表示开通，0表示未开通 |
| pim\_flag               | 号薄管家     | 1表示开通，0表示未开通 |
| smsrtn\_flag            | 短信回执     | 1表示开通，0表示未开通 |
| gprs\_pkg               | GRPS     | 1表示开通，0表示未开通 |
| mobnews\_flag           | 手机报      | 1表示开通，0表示未开通 |
| timenews\_flag          | 新闻早晚报    | 1表示开通，0表示未开通 |
| cr\_flag                | 彩铃       | 1表示开通，0表示未开通 |
| wireless\_adv\_usr\_flag  | 无线音乐高级会员 | 1表示开通，0表示未开通 |
| wireless\_mus\_flag      | 无线音乐俱乐部  | 1表示开通，0表示未开通 |
| cr\_box\_flag            | 铃音盒      | 1表示开通，0表示未开通 |
| quanqu\_down            | 全曲下载     | 1表示开通，0表示未开通 |
| hotel\_preord\_call\_flag | 酒店预定     | 1表示开通，0表示未开通 |
| aer\_preord\_flag        | 机票预定     | 1表示开通，0表示未开通 |
| mo\_call\_12580\_flag     | 百科业务     | 1表示开通，0表示未开通 |
| mobpay\_flag            | 手机支付     | 1表示开通，0表示未开通 |
| mobgame\_flag           | 手机游戏     | 1表示开通，0表示未开通 |

"""

# ╔═╡ 412f7a9d-4731-4a69-a942-74fe0de10d6a
md"""
下面首先读取数据集。 数据集中每一个行代表一个客户， 每一列代表一项移动业务。如果用户订购了该业务， 则对应的位置值为1， 否则为0.
"""

# ╔═╡ 23cd0f0d-7775-40aa-8669-f605ad137ecf
ydyw = CSV.read("data/移动业务关联规则分析数据.csv", DataFrame)

# ╔═╡ b6dd9070-fb79-413c-9694-72d200df17c8
md"""
由于数据集中包含了部分缺失值， 下面首先使用`dropmissing!`函数将数据中包含缺失值的样本删除。
"""

# ╔═╡ 46fb9aaa-4bec-4df6-a484-eb99a6a2fbe8
dropmissing!(ydyw)

# ╔═╡ 9f4d0b06-b7af-4879-adbf-a71251aa5676
md"""
接下来， 我们将使用Arules.jl包做关联规则的挖掘。 在Arules.jl中， 一个项集用一个向量表示， 所有项集用向量的向量表示。 为此， 我们将移动业务的每一项赋予一个编号，再将每个用户订购业务转化为一个向量。由于在数据集中， 最后一列代表的是客户编码。这不是一项业务。在分析中需要剔除。因此， 后面的分析， 只需要考虑18种业务。

下面构建的字典`id2name`用于将业务的编号转化为业务的名称。 其中`names(ydyw)`可以获得数据中的字段名，Dict用于将构成pair的多个项转化为一个字典。

"""

# ╔═╡ 81dc1a3d-f407-42b7-8c73-9c2af8dc907c
id2name = Dict(1:18 .=> names(ydyw)[1:18])

# ╔═╡ 03ab5928-973c-4024-993b-76d78af98bc5
md"""
下面的代码将数据集转换为一个项集的集合（向量的向量）。 这是采用向量推导的方式构建的。 其中`eachrow(ydyw)`会将数据集`ydyw`按行构成一个可迭代对象。`for row in eachrow(ydyw)` 用于遍历每一行。`[j for j in 1:(length(row)-1) if row[j]==1]`的作用是构建一个向量， 向量的元素是每一行中值为1的元素的下标。
"""

# ╔═╡ e687f5de-a445-4c2e-874c-d4bd1119f11a
txs = [[j for j in 1:(length(row)-1) if row[j]==1]	for row in eachrow(ydyw)]

# ╔═╡ 106c0603-9780-481a-a9a9-51c219bd45f5
md"""
至此， 我们将数据整理成了相关函数可以使用的样子。
"""

# ╔═╡ bab54374-5dbf-4a79-bb17-a04f788b9454
md"""
## 任务2：运用apriori算法
"""

# ╔═╡ f4bee84d-a0f2-4642-aedf-b6d365aa055b
md"""
### 频繁项集发现
"""

# ╔═╡ 80ec4ff9-5337-4631-b40b-ff6a2c6dbedf
md"""
通过函数`frequent`可以实现频繁项集的计算。该函数调用方式如下： 
```
frequent(transactions::Vector{Vector{S}}, minsupp::T, maxdepth) where {T <: Real, S}
```
其中， transactions是用向量的向量表示的所有项集，  minsupp表示支持度阈值， maxdepth表示支持的最大的项集宽度。项集的类型是S， S可以代表任何类型，而支持度的类型是实数的子类型都行（T <: Real）
"""

# ╔═╡ a37edbcf-7f83-42f7-967c-a851ff562cd4
md"""
下面的代码返回的是支持为5， 最大长度不超过17的项集(itemset)及其支持度计数（supp）构成的数据框（dataframe）。
"""

# ╔═╡ 88e3e70b-efd0-47a6-bcf2-3c94d55a4f71
fres1 = frequent(txs, 5, 17)

# ╔═╡ a7174b3e-fafe-442b-b341-942fa79e239a
md"""
为了更好的了解结果， 我们可以对它按supp列从大到小排序。
"""

# ╔═╡ 3ecbe4ff-0771-4a9c-b474-79404d91030f
sort!(fres1, :supp, rev = true)

# ╔═╡ e87e7eeb-5161-46ae-88b3-084f8ca42361
md"""
从排序结果看， 空的项集是最多的。当然， 这个项集没有意义。 其次是单项集{17}， 这个项对应的是$(id2name[17])， 即GPRS业务。从结果可见， GPRS业务是几乎所有的用户都开通了。 可以通过前面构建的编号到名字的字典`id2name`获得每个项目的名字。
"""

# ╔═╡ 80f0356c-b2f4-46ab-858a-31338149cd0b
md"""
### 产生关联规则
接下来， 使用apriori算法挖掘关联规则。`apriori`函数的签名如下：
```
apriori(transactions; supp = 0.01, conf = 0.8, maxlen = 5)
```
其中， `transactions`含义与`frequent`函数中一致。 `supp`表示规则的支持度， `conf`表示规则的置信度， `maxlen`是规则的长度（前件和后件的长度和）。 注意，  后三个参数是关键字参数， 都有默认值。
"""

# ╔═╡ 6051f8d0-eb87-405d-b503-2dce080ac05a
md"""
下面的代码选择`supp=0.1`挖掘关联规则。返回结果仍然是d`ataframe`， 每一行代表一条规则。 其中`lhs`表示规则的前件（左手边）, `rhs`是规则的右件（右手边）, `supp、conf、lift`分别表示规则的支持度，置信度和提升度。
"""

# ╔═╡ dc7ce647-23e4-415c-ac9a-c5f5fa8a65d0
rules1 = apriori(txs, supp=0.1)

# ╔═╡ d3041d44-81da-4bf6-85df-deb2b091be8d
md"""
比如第二条规则， `"{2 | 17}"	=> "5"`， 它表示的是{ $(id2name[2]) | $(id2name[17])} => { $(id2name[5]) }, 即{139邮箱, GPRS业务} => {彩铃}
"""

# ╔═╡ fb6fdb58-e3db-4d4f-92b4-5e35b0b9451c
md"""
apriori算法还有另外一种用法， 其输入参数可以是共现矩阵。即一个逻辑矩阵， 列表示项， 行表示交易， 元素为true表示行对应的交易中存在列对应的项。 这种格式的数据，只需要将原始数据转化为一个逻辑矩阵即可。 可以先试用Matrix将数据转化为矩阵， 进而使用BitMatrix将矩阵进一步转化为逻辑矩阵。 其它的参数是相同的。 不过该函数返回的结果是由规则构成的向量， 显示上稍差一点。
"""

# ╔═╡ 9c781d6e-dc50-4c43-aba3-5b30df5bfcff
occurrence = Matrix(ydyw[:, 1:end-1])

# ╔═╡ de95546c-d9b6-4436-89a4-78a68998dec0
apriori(BitMatrix(occurrence), supp=0.1)

# ╔═╡ 224261cf-59e2-4e0c-a215-543cdb1ba8fe
md"""
注： 以上关联规则只挖掘出了单个右件的规则， 其原因是Arules.jl包没有实现多个右件的规则的函数。
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ARules = "7cbe2057-1070-5a1a-9a20-8e476bfa53e1"
Box = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
ARules = "~0.0.2"
Box = "~1.0.1"
CSV = "~0.10.14"
DataFrames = "~0.21.8"
PlutoUI = "~0.7.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.3"
manifest_format = "2.0"
project_hash = "558a27d38f313b85ee0348e93396bcb52fc636c5"

[[deps.ARules]]
deps = ["DataFrames", "StatsBase"]
git-tree-sha1 = "28d08a275d00e869550a41d4859b5fcbe1f2b7b6"
uuid = "7cbe2057-1070-5a1a-9a20-8e476bfa53e1"
version = "0.0.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Box]]
deps = ["HypertextLiteral", "Markdown"]
git-tree-sha1 = "c43838e1b85ae396b37551d2b48f71efdb1d4bbe"
uuid = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
version = "1.0.15"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "2ac27f59196a68070e132b25713f9a5bbc5fa0d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.8.3"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "d476eaeddfcdf0de15a67a948331c69a585495fa"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.47.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["CategoricalArrays", "Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "Missings", "PooledArrays", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ecd850f3d2b815431104252575e7307256121548"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "0.21.8"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "Logging", "Markdown", "Random", "Suppressor"]
git-tree-sha1 = "45ce174d36d3931cd4e37a47f93e07d1455f038d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.1"

[[deps.PooledArrays]]
deps = ["DataAPI"]
git-tree-sha1 = "b1333d4eced1826e15adbdf01a4ecaccca9d353c"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "0.5.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "90b4f68892337554d31cdcdbe19e48989f26c7e6"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.3"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "f6cb12bae7c2ecff6c4986f28defff8741747a9b"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "0.3.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.Suppressor]]
deps = ["Logging"]
git-tree-sha1 = "9143c41bd539a8885c79728b9dedb0ce47dc9819"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.7"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "5d54d076465da49d6746c647022f3b3674e64156"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.8"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═552abfd5-a12c-46a4-8754-bf6c38e465bf
# ╟─43f9a5aa-1649-4c82-ab8a-605e1da8b61a
# ╟─00488270-759d-11ec-12fe-cb07b9231320
# ╠═349bbd34-b34e-46c3-8c47-8bb415d497c8
# ╟─075edf0d-3b6a-4bba-986f-71687365b0b9
# ╟─356c9ecf-648b-488a-a9dd-69d2a7ced9f3
# ╟─735979ca-1278-4bc5-8917-3ff0d4fd738c
# ╟─412f7a9d-4731-4a69-a942-74fe0de10d6a
# ╠═23cd0f0d-7775-40aa-8669-f605ad137ecf
# ╟─b6dd9070-fb79-413c-9694-72d200df17c8
# ╠═46fb9aaa-4bec-4df6-a484-eb99a6a2fbe8
# ╟─9f4d0b06-b7af-4879-adbf-a71251aa5676
# ╠═81dc1a3d-f407-42b7-8c73-9c2af8dc907c
# ╟─03ab5928-973c-4024-993b-76d78af98bc5
# ╠═e687f5de-a445-4c2e-874c-d4bd1119f11a
# ╟─106c0603-9780-481a-a9a9-51c219bd45f5
# ╟─bab54374-5dbf-4a79-bb17-a04f788b9454
# ╟─f4bee84d-a0f2-4642-aedf-b6d365aa055b
# ╟─80ec4ff9-5337-4631-b40b-ff6a2c6dbedf
# ╟─a37edbcf-7f83-42f7-967c-a851ff562cd4
# ╠═88e3e70b-efd0-47a6-bcf2-3c94d55a4f71
# ╟─a7174b3e-fafe-442b-b341-942fa79e239a
# ╠═3ecbe4ff-0771-4a9c-b474-79404d91030f
# ╟─e87e7eeb-5161-46ae-88b3-084f8ca42361
# ╟─80f0356c-b2f4-46ab-858a-31338149cd0b
# ╟─6051f8d0-eb87-405d-b503-2dce080ac05a
# ╠═dc7ce647-23e4-415c-ac9a-c5f5fa8a65d0
# ╟─d3041d44-81da-4bf6-85df-deb2b091be8d
# ╟─fb6fdb58-e3db-4d4f-92b4-5e35b0b9451c
# ╠═9c781d6e-dc50-4c43-aba3-5b30df5bfcff
# ╠═de95546c-d9b6-4436-89a4-78a68998dec0
# ╟─224261cf-59e2-4e0c-a215-543cdb1ba8fe
# ╟─768ce87f-a710-47b3-8a7e-9d81a2a0510a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
