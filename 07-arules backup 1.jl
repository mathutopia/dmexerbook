### A Pluto.jl notebook ###
# v0.19.41

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

# ╔═╡ 00488270-759d-11ec-12fe-cb07b9231320
md"""
# 关联规则
**学习目标**
1. 理解关联规则的相关概念和挖掘算法的基本思想。
2. 会利用工具包相关数据进行关联规则挖掘。
3. 能对不同领域的问题， 通过恰当的方式， 将其转换为关联规则挖掘的问题， 并通过编码实现挖掘。

"""

# ╔═╡ 356c9ecf-648b-488a-a9dd-69d2a7ced9f3
md"""
# 任务1： 数据准备
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
# 任务2：运用apriori算法
"""

# ╔═╡ f4bee84d-a0f2-4642-aedf-b6d365aa055b
md"""
## 频繁项集发现
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
## 产生关联规则
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

# ╔═╡ Cell order:
# ╠═552abfd5-a12c-46a4-8754-bf6c38e465bf
# ╟─00488270-759d-11ec-12fe-cb07b9231320
# ╠═349bbd34-b34e-46c3-8c47-8bb415d497c8
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
