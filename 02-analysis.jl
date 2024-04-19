### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ fbf0f37a-4f39-4faf-a1fb-51311baca882
begin
using Pkg
Pkg.Registry.add(RegistrySpec(url = "https://github.com/mathutopia/Wlreg.git"))
using Box
end

# ╔═╡ cac6a7cd-aade-4eea-b134-529bbc3fe179
begin
using CSV,DataFrames,PlutoUI,StatsBase,FreqTables,CategoricalArrays 
end

# ╔═╡ 8dfc4b4b-9092-4f4c-83fb-8ea93602174c
using ExcelReaders

# ╔═╡ d81022aa-1c73-4a5c-b312-3b3979bbbd7d
PlutoUI.TableOfContents(title = "目录")

# ╔═╡ 6dc4358c-bbf7-41e5-a54a-0b04efcafd7b
md"""
实验二：数据分析基础 
""" |> extitle

# ╔═╡ 1649bd60-465c-443c-b2be-61e8f7b6465b


# ╔═╡ dac9f5fd-b531-41cc-bf24-de036de2631d
md"""
# **实验目的：**
1. 掌握常见格式的数据的读写（比如CSV，EXCEL）
2. 了解不同数据类型的表示形式（DataFrame）
3. 掌握不同数据类型的统计计算方法
4. 掌握常见的数据预处理操作实现
5. 掌握常见的相似度计算方法
""" >>> box()

# ╔═╡ 59a77bad-9a83-4358-a946-cb477d3264c1
md"""
# **知识链接：**
1. 数据与数据类型
2. 常见统计指标及含义
3. 缺失值处理方法
4. 数据泛化与规范化
5. 常见相似度
""" |> box()

# ╔═╡ 0271d168-2d8c-4e7b-8111-f098d84bd68d
md"""
# 实验步骤：
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

# ╔═╡ bf47215a-d0e9-4fb7-982f-7669e56cd037
ret2 = readxl("data/GermanCredit.xls", "Data!A1:AF1001")

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
""" |> box()

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



# ╔═╡ Cell order:
# ╠═fbf0f37a-4f39-4faf-a1fb-51311baca882
# ╠═cac6a7cd-aade-4eea-b134-529bbc3fe179
# ╠═d81022aa-1c73-4a5c-b312-3b3979bbbd7d
# ╟─6dc4358c-bbf7-41e5-a54a-0b04efcafd7b
# ╠═1649bd60-465c-443c-b2be-61e8f7b6465b
# ╠═dac9f5fd-b531-41cc-bf24-de036de2631d
# ╟─59a77bad-9a83-4358-a946-cb477d3264c1
# ╟─0271d168-2d8c-4e7b-8111-f098d84bd68d
# ╟─b0d4887b-ec8c-4dd6-930d-50cb5cb7fe94
# ╟─59c49362-1a13-4c32-a3c3-55343e04fa13
# ╟─97f3906e-fa48-4173-b6e3-6d6df054c6f6
# ╠═1925f8df-7464-4c4c-8dad-dace0d47fffb
# ╟─83e580e9-a37a-4e6d-8619-7cd4742f541b
# ╠═8dfc4b4b-9092-4f4c-83fb-8ea93602174c
# ╠═bf47215a-d0e9-4fb7-982f-7669e56cd037
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
