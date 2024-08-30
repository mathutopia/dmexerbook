### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ cac6a7cd-aade-4eea-b134-529bbc3fe179
using CSV,DataFrames,PlutoUI,StatsBase,FreqTables,CategoricalArrays,XLSX 

# ╔═╡ 6a3988fc-a255-435a-8ca5-907f8d17cafb
begin
	using PlutoTeachingTools
	Temp = @ingredients "chinese.jl" # provided by PlutoLinks.jl
	PlutoTeachingTools.register_language!("chinese", Temp.PTTChinese.China())
	set_language!( PlutoTeachingTools.get_language("chinese") )
end;

# ╔═╡ a922d17b-3d81-4a0b-993f-786f2fc922f0
html"""
<p style="font-size: 50px; text-align: center;">实验二 数据分析基础  </p>
"""

# ╔═╡ dac9f5fd-b531-41cc-bf24-de036de2631d
md"""
# 实验目的
1. 掌握常见格式的数据的读写（比如CSV，EXCEL）
2. 了解不同数据类型的表示形式（DataFrame）
3. 掌握不同数据类型的统计计算方法
4. 掌握常见的数据预处理操作实现
5. 掌握常见的相似度计算方法
"""

# ╔═╡ 59a77bad-9a83-4358-a946-cb477d3264c1
md"""
# 知识链接：
1. 数据与数据类型
2. 常见统计指标及含义
3. 缺失值处理方法
4. 数据泛化与规范化
5. 常见相似度
""" 

# ╔═╡ 0271d168-2d8c-4e7b-8111-f098d84bd68d
md"""
# 实验步骤
"""

# ╔═╡ 2a1b0aa3-6957-4435-8010-b568c8b64b5e
md"""
下面的代码用于加载实验用到的所有包。 
"""

# ╔═╡ b0d4887b-ec8c-4dd6-930d-50cb5cb7fe94
md"""
## 任务1：数据读写
"""

# ╔═╡ 59c49362-1a13-4c32-a3c3-55343e04fa13
md"""
### 数据读取
由于CSV和EXCEL是两种最常见的数据格式， 这里我们主要介绍这两个格式的数据读取。

CSV是逗号分隔的文本文件，在Julia中， 使用CSV包可以非常方便的读取CSV格式的文件。其通用的使用方法是：

```julia
ret = CSV.read(source, sink::T; kwargs...)
```
其中： 
- `source`是要读取的数据所在的文件名（带后缀）， 如果文件不在当前目录下， 需要同时给定文件的路径。 
- `sink` 表示数据要存储的类型， 通常情况下， 我们会将数据存储为数据框格式（`DataFrame`）， 此后再根据需要去转换。
- `kwargs...`是一系列控制读取的相关参数。可以参考[CSV手册获取更多细节](https://csv.juliadata.org/stable/)。 其中一个常见的参数设置是：`header=false`, 表示要读取的表格没有表头。默认情况下， 第一行数据就是表头。
- `ret`是一个变量名， 用于指向读取的数据。
"""

# ╔═╡ 97f3906e-fa48-4173-b6e3-6d6df054c6f6
md"""
下面的代码用于读取本书中将经常用到的一个数据集-银行信用风险评估数据集。其中的文件名`"data/GermanCredit.csv"`给出了数据文件（"`GermanCredit.csv`"）所在的相对路径（"data/"）。 
"""

# ╔═╡ 1925f8df-7464-4c4c-8dad-dace0d47fffb
ret = CSV.read("data/GermanCredit.csv", DataFrame)

# ╔═╡ 83e580e9-a37a-4e6d-8619-7cd4742f541b
md"""
EXCEL是一个常见的办公软件， 下面介绍XLSX格式的数据读写。 通常， 如果是XLXS格式的数据， 建议使用`XLSX.jl`包读取。其基本用法是：

```julia
xf = XLSX.readxlsx(source)
xf["Sheetname"]
```
其中:
- source: 用于指定文件名， 跟`CSV.read`函数类似。
- xf是返回的结果。
由于EXCEL文件可以包含多个工作簿(`Sheet`), 当我们需要某个工作簿的数据时， 可以通过返回结果用中括号获得(`xf["Sheetname"]`)。剩下的操作， 有点像矩阵提取运算。具体可参考[XLXS.jl包的文档](https://felipenoris.github.io/XLSX.jl/stable/)。

XLXS.jl包只能读取XLSX格式的文件。 如果我们要读取老式的xls格式的文件， 需要用到`ExcelReaders.jl`包。 该包读取xls格式数据的通用方法是：
```julia
data = readxl(file, range)
```
其中： 
- `file`用于指定数据文件（跟前述函数的source参数相同）。
- `range`用于指定要读取的数据的位置。

比如， 下面的代码可以读取data文件夹下， GermanCredit.xls文件中， Data工作簿里， `A1:AF1001`区域的数据。
```julia
julia> using ExcelReaders

julia> ret2 = readxl("data/GermanCredit.xls", "Data!A1:AF1001") 
```
"""

# ╔═╡ 0584a94b-acbf-4280-8d16-501fe2a5f7ac
md"""
由于现在XLXS格式的数据更常见， 下面演示XLXS数据的读取。 下面的返回结果表明， 读取的XLSX文件有两个工作簿， 分别为`Data`和`Codelist`。
"""

# ╔═╡ 57dab2ac-5bcf-44d4-9c56-1d9a32e837d9
ret2 = XLSX.readxlsx("data/GermanCredit.xlsx")

# ╔═╡ 74572507-6434-41cf-b438-c2cac06561a3
md"""
我们可以使用工作簿名字读取相应的工作簿， 然后就可以像处理矩阵一样处理工作簿中的数据。这里不再继续演示， 项进一步了解可以参考包的官方文档。
"""

# ╔═╡ 25867f8e-807d-4fbd-bf45-1edc32d239a3
ret2["Data"][1:3, 5:7]

# ╔═╡ 1d170b7c-1d7a-4afd-91f4-8f77808d8f82
md"""
### 数据写入CSV
如果我们有一份表格数据（DataFrame）， 需要将其存入CSV文件中。可以简单的使用如下函数完成： 
```julia
CSV.write(file, table; kwargs...) => file
```
其中， 
- `file`用于指定存储数据的文件名， 类似在读取时的source参数。
- `table`要写入csv文件的表格型数据， 通常为DataFrame。
- `kwargs...`是跟写入有关的参数， 大部分情况下不用管。可以在官方文档中了解更多。

函数执行成功， 会在相应文件夹下创建名为file的文件。并返回文件名作为函数执行结果。下面的代码演示了将前面读取的数据`ret`写入同一个文件夹下的`test.csv`文件中。
```julia
julia> CSV.write("data/test.csv", ret)
"data/test.csv"
```

"""

# ╔═╡ add0096e-5c35-4ee7-9084-378e96649129
CSV.write("data/test.csv", ret)

# ╔═╡ a2069fd7-a40c-4121-91b6-36460fa20f5e
yuce = rand(300)

# ╔═╡ bd433586-1228-4871-9494-1edb6a25d963
md"""
## 任务2：数据的统计性分析
"""

# ╔═╡ 76eec074-8cfe-4130-98e1-8b9779c1e123
md"""
### 常见统计函数
数据探索分为统计分析和数据可视化两部分。 在Julia中， 统计相关的包有不少， 可参考[JuliaStats](https://juliastats.org/)了解统计有关的包。 本教程使用的基本统计工具主要来自于[StatsBase.jl](https://juliastats.org/StatsBase.jl/stable/)包。    


下表列出了常见的统计量名称、作用和相应的Julia函数。这里对统计量作用的描述并非严谨的数学定义， 只是为了方便理解和记忆而粗略的给出， 严谨的定义请参考有关书籍。

|统计量名称| 作用 | Julia函数 |
|----|---|---|
|计数 |统计给定的区间中（默认为：min~max）某个值出现的次数  | countmap|
|众数 |出现次数最多的数 | mode|
|最大值|向量元素的最大值| maximum|
|最小值|向量元素的最小值| minimum|
|p-分位数|p%的观测的最小上界；使用最多的是四分位数（p=.25, .5, .75）|quantile|
|均值|平均值|mean|
|中值|近似0.5分位数|median|
|极值|计算极大值、极小值|extrema|
|方差|计算方差， 默认是修正的| var|
|标准差|标准差|std|
|偏度|统计数据分布偏斜方向和程度|skewness|
|峰度|分布的尖锐程度， 正态分布，峰度为0|kurtosis|
|截断|去掉最大、最小的部分值（基于截断后的数据做统计被称为截断统计或鲁棒统计）|trim|

"""

# ╔═╡ f773a1d1-d284-4464-9d49-941ff8041c7c
md"""
### 连续变量统计分析
下面的统计分析基于前述的银行信用风险评估数据集（假定数据集保存在`ret`变量中）, 以下若没有特别声明， 提到的数据集时都表示该数据集。

数据集中， AMOUNT字段存储的是每一个客户的贷款金额， 是一个典型的连续变量。 可以简单的通过`变量名.属性名`或`变量名[:, :属性名]`的方式获取相应的属性列。 只要将获取的相应字段放入相应统计函数中，就可得得到统计量的值, 下面的代码是计算所有用户贷款金额的均值（`mean`）、方差(`var`)、偏度(`skewness`)和峰度(`kurtosis`)。

```julia
julia> mean(ret.AMOUNT)
3271.258

julia> var(ret.AMOUNT)
7.967843470906908e6

julia> skewness(ret[:,:AMOUNT])
1.946702018941925

julia> kurtosis(ret[:,:AMOUNT])
4.265163377213499
```
如果要计算其他统计量的值， 可以参考相应统计量的帮助文档。
"""

# ╔═╡ 2e0cc942-9ea0-451c-85f2-02af5e738314
md"""
### 类别变量统计分析
对于类别变量， 一个常见的统计任务是了解变量在各个水平上的取值分布情况（取不同值的样本的数量）。 这可以通过`FreqTables.jl`包中的`freqtable`函数得到。 [这里可以看到更多的细节](https://github.com/nalimilan/FreqTables.jl)

`freqtable`函数有两种使用方式: ：1）提供1个或多个（...）向量（AbstractVector）；2）提供一个表格型数据t（比如， DataFrame），然后可以提供一个或多个(...)以字符串（AbstractString）或符号（Symbol）形式给出的列名（cols）。
```julia
freqtable(x::AbstractVector...)

freqtable(t, cols::Union{Symbol, AbstractString}...)
```

下面的代码统计客户当前工作持续的年限（EMPLOYMENT）的分布情况（`0：失业; 1： <1 年； 2： 1<=... <4年； 3： 4<=...<7年； 4：>=7年`）。 
```julia
julia> ft = freqtable(ret, :EMPLOYMENT);
NamedArrays.NamedVector{Int64, Vector{Int64}, Tuple{OrderedCollections.OrderedDict{Int64, Int64}}}: 
62
172
339
174
253
```
由于EMPLOYMENT的取值是整数，如果我们想获得某个取值的数量， 需要使用`Name()`对象获取。

```julia
julia>  ft[Name(0)]
62
```

类似的， 我们也可以同时获取多个字段的列联表, 下面同时分析当前工作持续的年限（EMPLOYMENT）和贷款历史（HISTORY）字段。
```julia
julia> ft= freqtable(ret, :EMPLOYMENT, :HISTORY)
5×5 Named Matrix{Int64}
EMPLOYMENT ╲ HISTORY │   0    1    2    3    4
─────────────────────┼────────────────────────
0                    │   1    5   31    6   19
1                    │   9    9  111   12   31
2                    │  18   15  189   33   84
3                    │   3   10   89   17   55
4                    │   9   10  110   20  104
```

如果我们需要的是比例，可以在结果上调用`prop`函数。 其使用方法如下：
```julia
prop(tbl::AbstractArray{<:Number}; margins = nothing)
```
其中， tbl是一个数组，`freqtable`函数返回的结果就是一个数组。 `margins`参数不指定时， 比例是全局去求的。如果要按行、按列求比例， 可以设定margins=1或2。 下面的代码演示的是对行求比例的结果。
```julia
julia> t = prop(ft1, margins=1)

5×5 Named Matrix{Float64}
EMPLOYMENT ╲ HISTORY │         0          1          2          3          4
─────────────────────┼──────────────────────────────────────────────────────
0                    │  0.016129  0.0806452        0.5  0.0967742   0.306452
1                    │ 0.0523256  0.0523256   0.645349  0.0697674   0.180233
2                    │ 0.0530973  0.0442478   0.557522  0.0973451   0.247788
3                    │ 0.0172414  0.0574713   0.511494  0.0977011   0.316092
4                    │ 0.0355731  0.0395257   0.434783  0.0790514   0.411067

julia> sum(t,dims=2)
5×1 Named Matrix{Float64}
EMPLOYMENT ╲ HISTORY │ sum(HISTORY)
─────────────────────┼─────────────
0                    │          1.0
1                    │          1.0
2                    │          1.0
3                    │          1.0
4                    │          1.0
```
"""

# ╔═╡ a1417f09-52e3-4228-8b1e-dca19a74079e
md"""
如果只是单纯统计某一个字段中，各个取值出现的次数， 使用`countmap`函数可能更方便。其返回结果是一个由`水平=>出现次数`构成的字典。读者可自行实验下述代码查看效果。
```julia
julia> ft = countmap(ret.EMPLOYMENT);
```
""" |> tip

# ╔═╡ dccdfcc0-8490-4f50-9739-3811362c7d70
md"""
## 任务3：数据预处理
"""

# ╔═╡ 54d4eedb-281a-4f17-8934-8216354677c7
md"""
### 数据离散化
有时候， 我们希望将数值泛化为一个类别变量， 这可以用`CategoricalArrays.jl`包中的`cut`函数实现, 其使用方典型法如下：

```julia  
cut(x::AbstractArray, breaks::AbstractVector; labels::Union{AbstractVector,Function})

cut(x::AbstractArray, ngroups::Integer; labels::Union{AbstractVector,Function})
```
简单来说， 在对一个数据进行划分时， 我们可以通过向量指定划分区间（breaks）， 也可以直接指定要划分的类别（ngroups）的数量。 与此同时， 我们可以指定每一个类别的标签(labels)。

下面我们将年龄:AGE字段, 划分为三个类别，并通过`levels`函数查看每一个3个水平的标签值。
```julia
julia> age = cut(ret.AGE, 3);

julia> levels(age);
String[
"Q1: [19.0, 28.0)"
"Q2: [28.0, 38.0)"
"Q3: [38.0, 75.0]"]
```
可以看到自动划分时， 函数在28和38岁两个年龄做出了划分。 如果你认为这种划分方式不够合理， 可以自己指定划分标准。 假设我们希望在30岁和50岁作为划分点。 这时候可以这么做：
```julia
julia> age2 = cut(ret.AGE, [0,30,50,100]);
```
注意， 上面的参数`[0,30,50,100]`设定的是数据取值的3个区间， 因此会有4个值。最左端不能大于最小值， 最右端不能小于最大值。

如果想自己给每个区间重新设置标签， 下面的例子把将三个区间分别设置为三个不同的字符串：
```julia
julia> age3 = cut(ret.AGE, [0,30,50,100], labels=["青","中","老"]);
```

请读着通过`countmap`函数自行查看两种划分下， 样本的分布情况。
"""

# ╔═╡ 0d73c688-f2db-43b0-8ead-1dd8ea8cb5b0
md"""
### 数据连续化
有时候， 一个文本类型的数据， 我们希望将其转换为数值类型进行处理。 这可以通过简单的将文本替换为数值(文本重新编码）实现。 `CategoricalArrays.jl`包中的函数是`recode`函数实现了这一功能。

其基本的用法是:
```julia
recode(a::AbstractArray, pairs::Pair...)
```
其中， a是一个待替换处理的数组， pairs是 `old => new`形式构成对。函数会将数组a中， 值为old的对象替换为new对象。 这里old可以是一个容器， 只要a中的元素在容器old中， 就会被new替换掉。

假设，我们要将上面离散化为3个年龄段的结果`age3`， 重新编码。分别用数值1,2,3来表示“青”、“中”、“老”。这可以通过如下方式实现：
```julia
julia> recode(age3, "青"=>1, "中"=>2, "老"=>3)
```

"""

# ╔═╡ 747cf576-292f-4d5d-8fab-0ddea0f30610
md"""
### 缺失值填充
如果数据中存在缺失值， 在Julia中， 通常用missing来表示。 我们可以通过上述recode函数， 将缺失值重新编码为某一个值。 下面用一个构造的小例子演示如何将缺失值替换为均值。 
```julia
julia> vec = [1,2,3,missing,5];

julia > m = mean(skipmissing(vec)) 
2.75
julia> recode(vec, missing => m)
[1.0,2.0,3.0,2.75,5.0]
```
注意， 求向量的均值要求不能包含确实值， 如果数据中包含缺失值， 可以将其包裹在`skipmissing`函数的返回结果中， 这会自动过滤掉缺失值。
"""

# ╔═╡ e170243f-805a-4be3-904e-8f59eaa80a48
md"""
### 数据泛化
数据的泛化在本质上还是用新的值代替旧的值， 因此， 还是可以用`recode`函数实现。 由于年龄字段是一个整数。我们可以将年龄按照如下方式泛化为不同的值：
```julia
julia> age4 = recode(ret.AGE, 0:29=>"青", 30:49 => "中", 50:100 => "老");
```
这里泛化的结果，应该跟前面离散化的结果是一致的。
```julia
julia> age3 = cut(ret.AGE, [0,30,50,100], labels=["青","中","老"]);

julia> all(age3 .== age4)
true
```

"""

# ╔═╡ 069a7724-aa8e-4d52-ad4a-c9173448096e
md"""
### 数据的规范化
由于规范化是一个非常简单的操作， 这里我们以最大最小规范化为例， 自己写一个函数`norm`.
```julia
julia> function normalize(x)     
	smx = skipmissing(x)
    m,M = extrema(smx)
    Mm = M-m
	y = similar(x, Float32)
    for i in CartesianIndices(x)
        y[i] = (x[i] - m) / Mm
    end
	return y;
end
```
这里考虑到规范化会涉及除法， 所以返回结果的类型被硬编码为`Float32`。 更好的做法是用`Base.promote_op`推断。 这里为了简单起见， 就直接编码了。 

接下来可以直接用于对数据的min-max规范化
```julia
julia> normalize(ret.AGE);
```
对于z-score规范化， 读者可以按类似方式去写一个。
"""

# ╔═╡ 3ff487e9-3b5a-4e98-990f-d6de25b06177
md"""
## 任务4：相似度计算
### 相关系数
使用`cor`函数可以方便的计算Pearson相关系数：
```julia
cor(x::AbstractVector, y::AbstractVector)
```
其中， xiaxixx，y都是向量。
下面的代码计算年龄AGE和贷款金额AMOUNT的相关系数
```julia
julia> cor(ret.AGE, ret.AMOUNT)
0.03271641666544819
```
从结果看， 年龄AGE和贷款金额AMOUNT的相关系数非常小。

### 余弦相似度
在Julia中， 可以直接通过`cos`函数计算一个弧度的余弦值， 该函数不能直接求两个向量的余弦相似度。 我们可以简单编写一个可以直接求两个向量的夹角的余弦值的函数。
```julia
julia> cos(x::AbstractVector, y::AbstractVector) = sum(x.*y)/sqrt(sum(x.*x)*sum(y.*y))
```
利用该函数求年龄AGE和贷款金额AMOUNT的余弦相似度如下：

```julia
julia> cos(ret.AGE, ret.AMOUNT)
0.727775270342379
```
"""



# ╔═╡ 1e8f0683-a779-4b73-89b2-d8759335935f
PlutoUI.TableOfContents(title = "目录")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
CSV = "~0.10.14"
CategoricalArrays = "~0.10.8"
DataFrames = "~1.6.1"
FreqTables = "~0.4.6"
PlutoTeachingTools = "~0.2.15"
PlutoUI = "~0.7.60"
StatsBase = "~0.34.3"
XLSX = "~0.10.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "7fd2a5ea909808ca56b76a5cdbec602c9b911da0"

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

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

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

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "380053d61bb9064d6aa4a9777413b40429c79901"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.2.0"

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

[[deps.FreqTables]]
deps = ["CategoricalArrays", "Missings", "NamedArrays", "Tables"]
git-tree-sha1 = "4693424929b4ec7ad703d68912a6ad6eff103cfe"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "0.4.6"

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

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

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

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

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

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "58e317b3b956b8aaddfd33ff4c3e33199cd8efce"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.10.3"

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

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

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

[[deps.XLSX]]
deps = ["Artifacts", "Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "319b05e790046f18f12b8eae542546518ef1a88f"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.10.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "1165b0443d0eca63ac1e32b8c0eb69ed2f4f8127"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.3+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

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
# ╟─a922d17b-3d81-4a0b-993f-786f2fc922f0
# ╟─dac9f5fd-b531-41cc-bf24-de036de2631d
# ╟─59a77bad-9a83-4358-a946-cb477d3264c1
# ╟─0271d168-2d8c-4e7b-8111-f098d84bd68d
# ╟─2a1b0aa3-6957-4435-8010-b568c8b64b5e
# ╠═cac6a7cd-aade-4eea-b134-529bbc3fe179
# ╟─b0d4887b-ec8c-4dd6-930d-50cb5cb7fe94
# ╟─59c49362-1a13-4c32-a3c3-55343e04fa13
# ╟─97f3906e-fa48-4173-b6e3-6d6df054c6f6
# ╠═1925f8df-7464-4c4c-8dad-dace0d47fffb
# ╟─83e580e9-a37a-4e6d-8619-7cd4742f541b
# ╟─0584a94b-acbf-4280-8d16-501fe2a5f7ac
# ╟─57dab2ac-5bcf-44d4-9c56-1d9a32e837d9
# ╟─74572507-6434-41cf-b438-c2cac06561a3
# ╠═25867f8e-807d-4fbd-bf45-1edc32d239a3
# ╟─1d170b7c-1d7a-4afd-91f4-8f77808d8f82
# ╠═add0096e-5c35-4ee7-9084-378e96649129
# ╠═a2069fd7-a40c-4121-91b6-36460fa20f5e
# ╟─bd433586-1228-4871-9494-1edb6a25d963
# ╟─76eec074-8cfe-4130-98e1-8b9779c1e123
# ╟─f773a1d1-d284-4464-9d49-941ff8041c7c
# ╟─2e0cc942-9ea0-451c-85f2-02af5e738314
# ╟─a1417f09-52e3-4228-8b1e-dca19a74079e
# ╟─dccdfcc0-8490-4f50-9739-3811362c7d70
# ╟─54d4eedb-281a-4f17-8934-8216354677c7
# ╟─0d73c688-f2db-43b0-8ead-1dd8ea8cb5b0
# ╟─747cf576-292f-4d5d-8fab-0ddea0f30610
# ╟─e170243f-805a-4be3-904e-8f59eaa80a48
# ╟─069a7724-aa8e-4d52-ad4a-c9173448096e
# ╟─3ff487e9-3b5a-4e98-990f-d6de25b06177
# ╟─1e8f0683-a779-4b73-89b2-d8759335935f
# ╠═6a3988fc-a255-435a-8ca5-907f8d17cafb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
