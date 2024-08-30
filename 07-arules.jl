### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 349bbd34-b34e-46c3-8c47-8bb415d497c8
using  CSV, DataFrames, PlutoUI

# ╔═╡ 7a28964e-9e44-4429-a1af-e2a761d8534a
using RuleMiner

# ╔═╡ d24d3f2c-85c6-4912-928a-a2a585c11134
begin
	using PlutoTeachingTools
	Temp = @ingredients "chinese.jl" # provided by PlutoLinks.jl
	PlutoTeachingTools.register_language!("chinese", Temp.PTTChinese.China())
	set_language!( PlutoTeachingTools.get_language("chinese") )
end;

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

# ╔═╡ 552abfd5-a12c-46a4-8754-bf6c38e465bf
PlutoUI.TableOfContents(title = "目录", depth = 3, aside = true)

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
下面首先读取数据集。 数据集中每一个行代表一个客户， 每一列代表一项移动业务。如果用户订购了该业务， 则对应的位置值为1， 否则为0。最后一列khbm代表客户编码。
"""

# ╔═╡ 23cd0f0d-7775-40aa-8669-f605ad137ecf
ydyw = CSV.read("data/移动业务关联规则分析数据.csv", DataFrame)

# ╔═╡ b6dd9070-fb79-413c-9694-72d200df17c8
md"""
由于数据集中包含了部分缺失值， 下面首先使用`dropmissing!`函数将数据中包含缺失值的样本删除。
"""

# ╔═╡ 46fb9aaa-4bec-4df6-a484-eb99a6a2fbe8
dropmissing!(ydyw)

# ╔═╡ fa78943e-0876-494c-bffe-0a15caa6ccd9
md"""
接下来， 我们将使用RuleMiner.jl包做关联规则的挖掘。 在RuleMiner.jl中， 引入`Transactions` 结构表示交易数据的集合。 具体而言：

**Transactions**：一个结构体（struct），用于以稀疏矩阵格式表示交易集合。

#### 字段
- **matrix**：`SparseMatrixCSC{Bool,Int64}` 类型，一个稀疏布尔矩阵，表示交易。矩阵的行对应交易，列对应商品。位置 `(i,j)` 的 `true` 值表示商品 `j` 出现在交易 `i` 中。
- **colkeys**：`Dict{Int,String}` 类型，一个字典，将列索引映射到商品名称。这允许从矩阵列索引检索原始商品名称。
- **linekeys**：`Dict{Int,String}` 类型，一个字典，将行索引映射到交易标识符。这可以用来将矩阵行映射回它们的原始交易 ID 或行号。

#### 构造函数
- `Transactions(matrix::SparseMatrixCSC{Bool,Int64}, colkeys::Dict{Int,String}, linekeys::Dict{Int,String})`：直接使用稀疏矩阵、列键和行键字典来创建 `Transactions` 对象。
- `Transactions(df::DataFrame, indexcol::Union{Symbol,Nothing}=nothing)`：从一个 DataFrame 创建 `Transactions` 对象。DataFrame 的每一行是一个交易，每一列是一个商品。`indexcol` 是可选的，指定用作交易标识符的列。如果没有提供，将使用行号作为标识符。


#### 相关函数
- `load_transactions`：从文件加载交易数据并返回 `Transactions` 结构。
- `txns_to_df`：将 `Transactions` 对象转换为 DataFrame。

"""

# ╔═╡ 51dd934d-4224-481e-94ed-88f44cc267df
md"""
由于我们的数据已经整理成DataFrame的格式，可以直接使用基于DataFrame的构造函数构造事务数据集。
"""

# ╔═╡ ce3bba49-7479-4d43-88f1-95ea97ccedf1
txs = Transactions(ydyw, :khbm)

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
通过函数`eclat`可以实现频繁项集的计算。该函数调用方式如下： 
```
eclat(txns::Transactions, min_support::Union{Int,Float64})::DataFrame
```
其中， transactions是前面提到的交易集合，  min_support表示支持度阈值。
"""

# ╔═╡ a37edbcf-7f83-42f7-967c-a851ff562cd4
md"""
下面的代码返回的是支持为5， 最大长度不超过17的项集(itemset)及其支持度计数（supp）构成的数据框（dataframe）。
"""

# ╔═╡ 88e3e70b-efd0-47a6-bcf2-3c94d55a4f71
fres1 = eclat(txs, 5)

# ╔═╡ a7174b3e-fafe-442b-b341-942fa79e239a
md"""
为了更好的了解结果， 我们可以对它按Support列从大到小排序。
"""

# ╔═╡ 3ecbe4ff-0771-4a9c-b474-79404d91030f
sort!(fres1, :Support, rev = true)

# ╔═╡ e87e7eeb-5161-46ae-88b3-084f8ca42361
md"""
从排序结果看， GPRS业务是最频繁的项集。事实上，GPRS业务是几乎所有的用户都开通了。 排在第二位的是CR_FLAG，表示彩铃业务。这也是一项大部分用户都会开通的业务。
"""

# ╔═╡ 80f0356c-b2f4-46ab-858a-31338149cd0b
md"""
### 产生关联规则
接下来， 使用apriori算法挖掘关联规则。`apriori`函数相关信息如下：

**函数声明：**
```julia
apriori(txns::Transactions, min_support::Union{Int,Float64}, max_length::Int)::DataFrame
```

**参数：**
- `txns::Transactions`：包含待挖掘数据集的 `Transactions` 对象。
- `min_support::Union{Int,Float64}`：最小支持度阈值。如果为 `Int` 类型，表示绝对支持度；如果为 `Float64` 类型，表示相对支持度。
- `max_length::Int`：要生成规则的最大长度。

**返回值：**
返回一个 `DataFrame`，包含发现的关联规则，以及以下列：
- `LHS`：规则的左侧（前件）。
- `RHS`：规则的右侧（后件）。
- `Support`：规则的相对支持度。
- `Confidence`：规则的置信度。
- `Coverage`：规则的覆盖度（RHS支持度）。
- `Lift`：关联规则的提升度。
- `N`：关联规则的绝对支持度。
- `Length`：关联规则中项的数量。

**描述：**
Apriori 算法使用广度优先、逐层搜索策略来发现频繁项集。它首先识别频繁的单个项，然后通过组合较小的频繁项集迭代构建更大的项集。在每次迭代中，它从大小为 k-1 的项集中生成大小为 k 的候选项集，然后剪枝掉任何有不频繁子集的候选项。
"""

# ╔═╡ 6051f8d0-eb87-405d-b503-2dce080ac05a
md"""
下面的代码选择`Support=0.1`挖掘关联规则。
"""

# ╔═╡ dc7ce647-23e4-415c-ac9a-c5f5fa8a65d0
rules1 = apriori(txs, 0.1,5)

# ╔═╡ 080d50a2-1911-427c-94ba-cc840856b03d
txs

# ╔═╡ 224261cf-59e2-4e0c-a215-543cdb1ba8fe
md"""
注： 以上关联规则只挖掘出了单个右件的规则， 其原因是Arules.jl包没有实现多个右件的规则的函数。
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
RuleMiner = "26420b10-3f9f-4b54-bd85-e6b3d5a44d3c"

[compat]
CSV = "~0.10.14"
DataFrames = "~1.6.1"
PlutoTeachingTools = "~0.2.15"
PlutoUI = "~0.7.60"
RuleMiner = "~0.4.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "02047030c0beac35b85857b16ea6006d2b88984c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "7eee164f122511d3e4e1ebadb7956939ea7e1c77"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.6"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "4b415b6cccb9ab61fec78a621572c82ac7fa5776"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.35"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "1ce1834f9644a8f7c011eb0592b7fd6c42c90653"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.0.1"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

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

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "5d9ab1a4faf25a62bb9d07ef0003396ac258ef1c"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.15"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

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
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "7b7850bb94f75762d567834d7e9802fc22d62f9c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.18"

[[deps.RuleMiner]]
deps = ["Combinatorics", "DataFrames", "Mmap", "SparseArrays"]
git-tree-sha1 = "8ee17616307a2ea579c1c4d8d943b4d7170be6ca"
uuid = "26420b10-3f9f-4b54-bd85-e6b3d5a44d3c"
version = "0.4.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ff11acffdb082493657550959d4feb4b6149e73a"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.5"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

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
# ╟─43f9a5aa-1649-4c82-ab8a-605e1da8b61a
# ╟─00488270-759d-11ec-12fe-cb07b9231320
# ╠═349bbd34-b34e-46c3-8c47-8bb415d497c8
# ╠═7a28964e-9e44-4429-a1af-e2a761d8534a
# ╠═552abfd5-a12c-46a4-8754-bf6c38e465bf
# ╟─075edf0d-3b6a-4bba-986f-71687365b0b9
# ╟─356c9ecf-648b-488a-a9dd-69d2a7ced9f3
# ╟─735979ca-1278-4bc5-8917-3ff0d4fd738c
# ╟─412f7a9d-4731-4a69-a942-74fe0de10d6a
# ╠═23cd0f0d-7775-40aa-8669-f605ad137ecf
# ╟─b6dd9070-fb79-413c-9694-72d200df17c8
# ╠═46fb9aaa-4bec-4df6-a484-eb99a6a2fbe8
# ╟─fa78943e-0876-494c-bffe-0a15caa6ccd9
# ╟─51dd934d-4224-481e-94ed-88f44cc267df
# ╠═ce3bba49-7479-4d43-88f1-95ea97ccedf1
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
# ╠═080d50a2-1911-427c-94ba-cc840856b03d
# ╟─224261cf-59e2-4e0c-a215-543cdb1ba8fe
# ╠═d24d3f2c-85c6-4912-928a-a2a585c11134
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
