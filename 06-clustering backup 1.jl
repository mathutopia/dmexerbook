### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# ╔═╡ 3f847b82-2175-498a-9ef7-f85a50432733
begin
using PlutoUI, Distances,Clustering, CSV, DataFrames, Distances, DataFramesMeta,StatsBase,StatsPlots
end

# ╔═╡ c9ff268b-0c31-4cea-b690-cb55ad8b24fa
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

# ╔═╡ 70ec76d1-638c-4bb9-80ab-69bb33450baf
 html"<font size=\"80\">实验6 聚类分析</font>"

# ╔═╡ e4e623dc-0717-421a-9d38-111833ab5711
md"""
# **实验目的：**
1. 掌握常见的距离计算方法
2. 掌握kmeans聚类分析方法
3. 掌握DBSCAN分析方法
4. 掌握一趟聚类算法
""" |> box()

# ╔═╡ bf7e4c5a-4f7f-4a99-a6b0-6a225b5a43a3
md"""
# 知识链接：
1. 聚类问题简介
2. 常见距离计算
3. kmeans算法
4. BIRCH算法
5. DBSCAN算法
6. 一趟聚类算法
""" |> box()

# ╔═╡ 139f007f-31be-4ae6-9d67-c6917ea01f3d
md"""
# 实验步骤：


kmeans函数介绍
设定距离等参数
聚类结果查看与分析
任务3：层次聚类（Birch？）
层次聚类函数介绍
设定相关参数
聚类结果查看与分析
任务4：DBSCAN聚类
相关函数介绍
设定相关参数
聚类结果查看与分析
任务5：一趟聚类算法
算法实现
算法应用
"""

# ╔═╡ ea3e25cd-0744-4c03-b1c3-57031a98ba4f
ret = CSV.read("data/air_data.csv",DataFrame)

# ╔═╡ 864ee807-e20c-4fa6-bafc-22b629a9caf4
md"""
## 数据集介绍
本实验使用航空客户数据集做有关分析， 下面简要介绍一下数据集。该数据是某航空公司已积累的大量的会员档案信息和其乘坐航班记录，经加工后得到的部分数据信息。该数据集包含$(size(ret)[1]) 条记录， 共 $(size(ret)[2]) 个字段。

其中主要字段的含义如下表所示：

|        | 属性名称                    | 属性说明                                      |
|--------|-------------------------|-------------------------------------------|
| 客户基本信息 | MEMBER\_NO               | 会员卡号                                      |
|        | FFP\_DATE                | 入会时间                                      |
|        | FIRST\_FLIGHT\_DATE       | 第一次飞行日期                                   |
|        | GENDER                  | 性别                                        |
|        | FFP\_TIER                | 会员卡级别                                     |
|        | WORK\_CITY               | 工作地城市                                     |
|        | WORK\_PROVINCE           | 工作地所在省份                                   |
|        | WORK\_COUNTRY            | 工作地所在国家                                   |
|        | AGE                     | 年龄                                        |
|--------|-------------------------|-------------------------------------------|
| 乘机信息   | FLIGHT\_COUNT            | 观测窗口内飞行次数                                 |
|        | AVG\_FLIGHT\_COUNT        | 观测窗口内平均飞行次数（飞行次数/8）                       |
|        | P1Y\_Flight\_Count        | 观测窗口内第1年飞行次数                              |
|        | L1Y\_Flight\_Count        | 观测窗口内第2年飞行次数                              |
|        | Ration\_P1Y\_Flight\_Count | 观测窗口内第1年飞行次数占比                            |
|        | Ration\_L1Y\_Flight\_Count | 观测窗口内第2年飞行次数占比                            |
|        | SUM\_YR                  | 观测窗口的票价支出                                 |
|        | SUM\_YR\_1                | 第1年票价支出                                   |
|        | SUM\_YR\_2                | 第2年票价支出                                   |
|        | AVG\_DISCOUNT            | 平均值折扣率                                    |
|        | SEG\_KM\_SUM              | 观测窗口的总飞行公里数                               |
|        | WEIGHTED\_SEG\_KM         | (=SEG\_KM\_SUM*AVG\_DISCOUNT)                |
|        | LOAD\_TIME               | 观测窗口结束时间                                  |
|        | LAST\_FLIGHT\_DATE        | 末次飞行日期                                    |
|        | LAST\_TO\_END             | 最后一次乘机时间至观测窗口结束天数                         |
|        | BEGIN\_TO\_FIRST          | 第一次飞行时间距窗口起始期的天数                          |
|        | AVG\_INTERVAL            | 平均乘机时间间隔                                  |
|        | MAX\_INTERVAL            | 最大乘机时间间隔                                  |
|--------|-------------------------|-------------------------------------------|
| 积分信息   | EXCHANGE\_COUNT          | 积分兑换次数                                    |
|        | POINTS\_SUM              | 总累计积分(=EP\_SUM+BP\_SUM+ADD\_Point\_SUM)       |
|        | POINT\_NOTFLIGHT         | 非乘机积分变动次数                                 |
|        | BP\_SUM                  | 总基本积分                                     |
|        | P1Y\_BP\_SUM              | 第1年基本积分                                   |
|        | L1Y\_BP\_SUM              | 第2年基本积分                                   |
|        | Ration\_P1Y\_BPS          | 第1年基本积分占比                                 |
|        | Ration\_L1Y\_BPS          | 第2年基本积分占比                                 |
|        | AVG\_BP\_SUM              | 平均总基本积分(=总基本积分/8)                         |
|        | EP\_SUM                  | 总精英积分                                     |
|        | EP\_SUM\_YR\_1             | 第1年精英积分                                   |
|        | EP\_SUM\_YR\_2             | 第2年精英积分                                   |
|        | ADD\_Point\_SUM           | 附加积分                                      |
|        | ADD\_POINTS\_SUM\_YR\_1     | 第1年附加积分                                   |
|        | ADD\_POINTS\_SUM\_YR\_2     | 第2年附加积分                                   |
|        | Eli\_Add\_Point\_Sum       | (=ADD\_POINTS\_SUM\_YR\_1+L1Y\_ELi\_Add\_Points) |
|        | L1Y\_Eli\_Add\_Points      |                                           |
|        | L1Y\_Points\_Sum          |


注：观测窗口是指以过去某个时间点为结束时间，某一时间长度作为宽度，得到历史时间范围内的一个时间段。

下面首先读取该数据集。
"""

# ╔═╡ 52275bf8-330a-46c5-b6d8-4137ce1031d8
md"""
由于数据中包含多个字段， 我们选择部分字段做下列实验演示。 主要选择的字段是： 平均飞行次数（AVG\_FLIGHT\_COUNT）， 最近消费间隔时间（LAST\_TO\_END）， 加权里程数（WEIGHTED\_SEG\_KM）和平均基本积分（AVG\_BP\_SUM）。

由于各个字段在量纲上存在显著差异， 我们将每个字段做最大最小规范化， 并分别重命名为cnt,time,km, bp。
"""

# ╔═╡ 2d63e2c5-44e9-4d54-b199-f3a3c8013048
maxmin(x) = (x .- minimum(x))./(maximum(x) - minimum(x))

# ╔═╡ 62957610-c7f8-4e43-9ce3-a5372432ecb1
data = @select ret :cnt= maxmin(:AVG_FLIGHT_COUNT) :time = maxmin(:LAST_TO_END) :km = maxmin(:WEIGHTED_SEG_KM) :bp = maxmin(:AVG_BP_SUM)

# ╔═╡ 7d874820-7e3f-11ec-1087-dd819d253f23
md"""
## 任务1： 距离计算
做聚类分析以及各种数据挖掘， 距离都是很重要的一个概念， 这里以以及相关的julia包[**Distances.jl**](https://github.com/JuliaStats/Distances.jl)总结一下有关的距离的计算。 

"""

# ╔═╡ 41eb25f8-8a10-4f78-9373-dd79f95c87f2
md"""
### 计算方式
"""

# ╔═╡ 3012af0f-f52d-4212-a5a7-c8f97485ea5c
md"""
最常见的计算距离的方式是： 用某种距离函数， 去计算两个向量的距离。 假定`x,y`是两个需要计算距离的向量， 距离计算的基本方法是：
```julia
r = distfun(x,y)
```
其中， `distfun`表示某种距离计算函数，是Distances.jl提供的一种简便调用方式， 比如欧式距离函数是：`euclidean`。 因此， 可以这样计算两个向量的距离：
```julia
r = euclidean(x,y)
```

更通用的距离计算方式是：
```
r = evaluate(dist, x, y)
r = dist(x, y)
```
其中`dist`是某种距离类型的实例， 比如欧式距离对应的类型是`Euclidean.`, 欧式距离可计算如下：
```julia
r = evaluate(Euclidean(), x, y)
r = Euclidean()(x, y)
```



"""

# ╔═╡ 1bd83605-0cbe-4908-8044-15ee8470c321
md"""
上面的计算方式每次只能计算两个向量的距离。如果同时要计算多个向量的距离，有下面两种方式。下面假定`X`和`Y`分别是具有`m`列和`n`列的两个具有行数相同矩阵。下面的代码可以实现对两个矩阵的每一对配对求距离`dist`。
返回结果R是大小为（m,n）的矩阵，使得`R[i,j]`是`X[:,i]`和`Y[:,j]`之间的距离。使用成对函数计算所有对的距离通常比单独计算每对的距离快得多。
```julia
R = pairwise(dist, X, Y, dims=2)
```

如果`X`和`Y`是具有 $m\times n$ 列的两个同尺寸矩阵,下面的代码可以计算两个矩阵对应列的距离`dist`
```julia
r = colwise(dist, X, Y)
```
返回结果r是一个向量。`r[i]`是`X[:,i]`与`Y[:,i]`的距离。
"""

# ╔═╡ 319acc7d-b5ac-421a-b3ea-98d6cd3701de
md"""
### 距离类型与函数
每个距离对应一个距离类型， 有一个相应的方便调用的函数。 下表列出了距离的类型名、相应函数及对应的距离计算数学表达式。 当然，这里的数学表达式只是说明距离是如何被计算的，并不意味着系统是这么实现的。事实上， 包中实现的距离计算效率要比这里的函数实现高。

| type name            |  convenient syntax                | math definition     |
| -------------------- | --------------------------------- | --------------------|
|  Euclidean           |  `euclidean(x, y)`                | `sqrt(sum((x - y) .^ 2))` |
|  SqEuclidean         |  `sqeuclidean(x, y)`              | `sum((x - y).^2)` |
|  PeriodicEuclidean   |  `peuclidean(x, y, w)`            | `sqrt(sum(min(mod(abs(x - y), w), w - mod(abs(x - y), w)).^2))`  |
|  Cityblock           |  `cityblock(x, y)`                | `sum(abs(x - y))` |
|  TotalVariation      |  `totalvariation(x, y)`           | `sum(abs(x - y)) / 2` |
|  Chebyshev           |  `chebyshev(x, y)`                | `max(abs(x - y))` |
|  Minkowski           |  `minkowski(x, y, p)`             | `sum(abs(x - y).^p) ^ (1/p)` |
|  Hamming             |  `hamming(k, l)`                  | `sum(k .!= l)` |
|  RogersTanimoto      |  `rogerstanimoto(a, b)`           | `2(sum(a&!b) + sum(!a&b)) / (2(sum(a&!b) + sum(!a&b)) + sum(a&b) + sum(!a&!b))` |
|  Jaccard             |  `jaccard(x, y)`                  | `1 - sum(min(x, y)) / sum(max(x, y))` |
|  BrayCurtis          |  `braycurtis(x, y)`               | `sum(abs(x - y)) / sum(abs(x + y))`  |
|  CosineDist          |  `cosine_dist(x, y)`              | `1 - dot(x, y) / (norm(x) * norm(y))` |
|  CorrDist            |  `corr_dist(x, y)`                | `cosine_dist(x - mean(x), y - mean(y))` |
|  ChiSqDist           |  `chisq_dist(x, y)`               | `sum((x - y).^2 / (x + y))` |
|  KLDivergence        |  `kl_divergence(p, q)`            | `sum(p .* log(p ./ q))` |
|  GenKLDivergence     |  `gkl_divergence(x, y)`           | `sum(p .* log(p ./ q) - p + q)` |
|  RenyiDivergence     |  `renyi_divergence(p, q, k)`      | `log(sum( p .* (p ./ q) .^ (k - 1))) / (k - 1)` |
|  JSDivergence        |  `js_divergence(p, q)`            | `KL(p, m) / 2 + KL(q, m) / 2 with m = (p + q) / 2` |
|  SpanNormDist        |  `spannorm_dist(x, y)`            | `max(x - y) - min(x - y)` |
|  BhattacharyyaDist   |  `bhattacharyya(x, y)`            | `-log(sum(sqrt(x .* y) / sqrt(sum(x) * sum(y)))` |
|  HellingerDist       |  `hellinger(x, y)`                | `sqrt(1 - sum(sqrt(x .* y) / sqrt(sum(x) * sum(y))))` |
|  Haversine           |  `haversine(x, y, r = 6_371_000)` | [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula) |
|  SphericalAngle      |  `spherical_angle(x, y)`          | [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula) |
|  Mahalanobis         |  `mahalanobis(x, y, Q)`           | `sqrt((x - y)' * Q * (x - y))` |
|  SqMahalanobis       |  `sqmahalanobis(x, y, Q)`         | `(x - y)' * Q * (x - y)` |
|  MeanAbsDeviation    |  `meanad(x, y)`                   | `mean(abs.(x - y))` |
|  MeanSqDeviation     |  `msd(x, y)`                      | `mean(abs2.(x - y))` |
|  RMSDeviation        |  `rmsd(x, y)`                     | `sqrt(msd(x, y))` |
|  NormRMSDeviation    |  `nrmsd(x, y)`                    | `rmsd(x, y) / (maximum(x) - minimum(x))` |
|  WeightedEuclidean   |  `weuclidean(x, y, w)`            | `sqrt(sum((x - y).^2 .* w))`  |
|  WeightedSqEuclidean |  `wsqeuclidean(x, y, w)`          | `sum((x - y).^2 .* w)`  |
|  WeightedCityblock   |  `wcityblock(x, y, w)`            | `sum(abs(x - y) .* w)`  |
|  WeightedMinkowski   |  `wminkowski(x, y, w, p)`         | `sum(abs(x - y).^p .* w) ^ (1/p)` |
|  WeightedHamming     |  `whamming(x, y, w)`              | `sum((x .!= y) .* w)`  |
|  Bregman             |  `bregman(F, ∇, x, y; inner=dot)` | `F(x) - F(y) - inner(∇(y), x - y)` |
"""

# ╔═╡ d79fd59e-ef0b-4b12-b4cf-6526020b8167
md"""
### 典型距离计算
下面几个距离是常见的

| type name            |  convenient syntax                | math definition     |
| -------------------- | --------------------------------- | --------------------|
|  Euclidean           |  `euclidean(x, y)`                | `sqrt(sum((x - y) .^ 2))` |
|  SqEuclidean         |  `sqeuclidean(x, y)`              | `sum((x - y).^2)` |
|  Cityblock           |  `cityblock(x, y)`                | `sum(abs(x - y))` |
|  TotalVariation      |  `totalvariation(x, y)`           | `sum(abs(x - y)) / 2` |
|  Chebyshev           |  `chebyshev(x, y)`                | `max(abs(x - y))` |
|  Minkowski           |  `minkowski(x, y, p)`             | `sum(abs(x - y).^p) ^ (1/p)` |
|  Jaccard             |  `jaccard(x, y)`                  | `1 - sum(min(x, y)) / sum(max(x, y))` |
|  CosineDist          |  `cosine_dist(x, y)`              | `1 - dot(x, y)` / (norm(x) * norm(y))` |
|  CorrDist            |  `corr_dist(x, y)`                | `cosine_dist(x - mean(x), y - mean(y))` |
|  ChiSqDist           |  `chisq_dist(x, y)`               | `sum((x - y).^2 / (x + y))` |
|  KLDivergence        |  `kl_divergence(p, q)`            | `sum(p .* log(p ./ q))` |



"""

# ╔═╡ be29c6d4-8d37-439b-9111-9adcbda40582
md"""
注意区分距离和相似度。比如， 我们有余弦相似度， 余弦距离是`1-余弦相似度`。类似的， 我们有相关系数（用于表示线性相关性），其值通常在[-1,1]中，而相关性距离CorrDist， 则只能为正数，因此范围是[0,2]
""" |> box(:yellow, :注意)

# ╔═╡ deb39e3e-139a-4d1f-8b56-4fb888060018
md"""
下面的代码演示计算第1、2号样本的欧式距离的计算。
"""

# ╔═╡ 130bc63c-90ad-4076-bf55-e16f92ee6520
euclidean(data[1,:], data[2,:])

# ╔═╡ a57b8a91-44d9-48ce-be6a-005b645f57a5
md"""
如果想要一次性多计算几个样本， 需要首先将样本的特征表示为矩阵形式。这可以通过将样本对应的数据框放入矩阵类型（Matrix）的构造函数去构造。 此外， 计算距离时，通常将矩阵的列视为样本。 因此， 转换后的特征矩阵，需要做一个转置操作。

下面计算1~10号样本与11~20号样本的欧式距离。
"""

# ╔═╡ 9e354aa0-5092-4fda-8919-84b9c6618e00
colwise(euclidean, Matrix(data[1:10,:])',Matrix(data[11:20,:])')

# ╔═╡ b760559b-2335-4c23-99a1-82747d64914c
md"""
更常见的一个场景是， 计算所有样本两两之间的距离。这可以通过`pairwise`函数实现。 不过，这时候需要注意的一个问题是， $n$个样本会产生$n^2$个距离。如果样本数量太多， 很容易导致内存不足。下面的代码计算了前100个样本两两之间的欧式距离。
"""

# ╔═╡ 4cfe738b-1995-4233-8546-471e7195b03b
pairwise(euclidean, Matrix(data[1:100,:])')

# ╔═╡ 5f6f8819-8793-47bc-8037-872a6900ece0
size(data)

# ╔═╡ 88093475-0f2b-4120-9748-36f73ddc0b24
md"""
由于后面的任务都需要进行类似的操作， 下面我们首相将数据准备成矩阵的形式。
"""

# ╔═╡ 3e11f98b-373a-4186-a71b-54a042735f2a
X = Matrix(data)' # 注意这里的转换为矩阵并转置

# ╔═╡ bf19eb1c-5bc5-4c53-8561-3920cf788327
md"""
## 任务2 一趟聚类
一趟聚类的思想很简单， 下面的代码实现一个简单的一趟聚类算法。 首先定义了一个结构体Cluster， 用于表示一个簇。 结构体会记录该簇包含了哪些样本（用id向量表示）， 以及簇的中心（用center表示）。 簇的中心是所有样本的均值向量。
"""

# ╔═╡ bb5090de-0443-4a79-8dda-5a09a43c6eba
mutable struct Cluster
	id # 用于记录簇中有哪些样本。
	center# 用于记录簇的中心向量
end

# ╔═╡ 1be189bf-4a2f-4fcd-bb94-4a3297fb1e51
begin
# X是输入数据， 要求为k*n矩阵， k是特征维度，n为样本数量。r是构建簇的阈值。
function onepass(X,r; dist = SqEuclidean())
	ret = Cluster[]
	push!(ret, Cluster([1], X[:,1]))# 第一个样本先建立一个簇
	for (i,x) in enumerate(eachcol(X[:,2:end]))# 从第2个样本开始
		ds = [dist(x, c.center) for c in ret]#求每个样本跟已有簇之间的距离。
		(dm, k) = findmin(ds)# 求出最小距离簇的编号与对应最小距离
		if dm > r # 最小距离比阈值要大
			push!(ret, Cluster([i+1],x))# 新建一个簇， 
		else
			n = length(ret[k].id)
			push!(ret[k].id, i+1)
			ret[k].center = (n .* ret[k].center .+ x)./(n+1)
		end
	end
	return ret
end

end

# ╔═╡ 84735154-7ff5-4bb1-8d22-a4226e4c448b
md"""
下面的代码以阈值r=0.1构建簇，
"""

# ╔═╡ e6199349-13bf-4efe-af3c-01c6dccab74c
clu = onepass(X, 0.1)

# ╔═╡ 6208466b-d86d-4b0b-99b5-bfa2baabb3b9
md"""
由于返回结果是一个簇的向量， 可以通过这个向量方便的获得想要的结果。比如，可以通过`length`函数，获得最终生成的簇的数量。 下面的代码返回每个簇的样本个数。
"""

# ╔═╡ a10f2c4b-89ec-4175-a3a4-5ba273520f40
[length(c.id) for c in clu]

# ╔═╡ 3bf510ec-f3c9-4b3d-bac1-19a9ea386a54
md"""
## 任务3 kmeans聚类
K-Means聚类分析的目标是把数据集D中的样本聚成k个簇， 使得每个样本指派给距离最近的簇， 每个样本与簇之间的距离和（总损失）最小。K-Means聚类可以用kmeans函数实现。

"""

# ╔═╡ 8e085543-c0f3-45b8-9c09-de76e9069be2
md"""
### kmeans聚类函数
kmeans的函数签名如下：
```
kmeans(X::AbstractMatrix{<:Real},               
       k::Integer;                              
       weights::Union{Nothing, AbstractVector{<:Real}}=nothing, 
       init::Union{Symbol, SeedingAlgorithm, AbstractVector{<:Integer}}             
       maxiter::Integer=_kmeans_default_maxiter, 
       tol::Real=_kmeans_default_tol,            
       display::Symbol=_kmeans_default_display,  
       distance::SemiMetric=SqEuclidean()) 
```
其中， 
- X是d×n的特征矩阵， d是特征的维度，n是样本的个数。
- k是类的个数。
以上两个参数是位置参数， 必须给定，后面的参数是关键字参数， 都有默认值。

- init:初始类中心， 可以是Symbol,用于指定随机选取中心的方法; 或者长度为k的向量， 用于指定k个中心对应X中的下标。
- weights: n维向量， 用于指定每个元素的权重。
- maxiter: 整数， 用于指定最大的迭代次数
- tol:: 目标值变化的容忍程度， 目标变化小于这个值， 则认为算法收敛了。
- display: Symbol: 计算过程展示的信息量， 可取如下值： 
		- :none: 没有展示
		- :final: 部分信息
		- :iter: 每一轮迭代的进度信息
- distance: 计算点之间距离的函数， 默认是平方欧式距离， 表示节点位置差的平方和。

更多的细节请参考（[官方文档](https://juliastats.org/Clustering.jl/stable/kmeans.html)）。
"""

# ╔═╡ b9034943-31f9-49ab-8ae4-30f76cad2c43
md"""
上面的参数中，X是d×n的特征矩， 与数据挖掘的数据通常行为样本， 列为特征刚好相反， 需要对原始数据做一个转置变换。
""" |> box(:yellow, :注意)

# ╔═╡ a80a133b-88a0-4803-b5a7-e586440aca3c
md"""
###  计算案例
下面还是以上述构造的特征计算kmeans聚类。 前面已经构造了特征矩阵X。 假定我们要将样本聚为2个类， 下面的代码可以实现这一目标：
"""

# ╔═╡ 8ecc280e-0342-4100-af46-9b0723f1dfc0
c1 = kmeans(X, 2)

# ╔═╡ a09c4b87-7dda-4d07-9b9f-4b3514335ffd
md"""
#### 结果提取与分析
上面kmeans的结果保存在变量c1中。有几个重要的结果是需要关注的。
 - 中心(centers)
 - 簇结果计数（counts）
 - 样本分派的类别（assignments）

这些结果可以通过 **聚类结果.名字**的方式获取相应的字段。 其中计数和分派还可以counts、assignments两个函数在聚类结果上调用实现。
"""

# ╔═╡ 2bf3e51a-6a5e-4d22-b024-7d2bb5d48336
md"""
下面的结果说明， 聚类为两个簇后， 第一簇有 $((counts(c1)[1])) 个样本， 第二簇有 $((counts(c1)[2])) 个样本。
"""

# ╔═╡ e9fc11af-6da4-45d4-9679-cb963214edb6
counts(c1)

# ╔═╡ 1fc28df8-dbd8-44d4-9a82-7c95663c499c
md"""
下面的向量表示每个样本被分派到哪一个簇中。
"""

# ╔═╡ 595f9993-abeb-41ac-86b7-3508b6228f3d
assignments(c1)

# ╔═╡ 8dd22076-0400-4279-9eba-e75e829bcd58
md"""
下面给出的是每个簇的中心， 因为我们只使用了4个特征， 所以每个簇的中心是4维的向量。
"""

# ╔═╡ e2d34790-2576-49f6-b80e-b457a9aa44b9
c1.centers

# ╔═╡ 91c9e518-5f06-4435-b988-c268b991bc21
md"""
`assignments`函数可以返回所有样本被分配的簇的编号组成的向量。
"""

# ╔═╡ 735ada31-d603-4380-b34c-9fa1575b9478
assignments(c1)

# ╔═╡ d7deebc1-6e63-47e2-9572-bca890286a9c
c1.assignments

# ╔═╡ 0e0f504d-82f0-4051-b54b-301f170836fa
md"""
### 切换距离计算
在kmeans函数中， 默认的距离函数是平方欧式距离（distance::SemiMetric=SqEuclidean()）。如果想采用不同的距离函数， 可以指定不同的距离类型实例。 比如， 我们用城市块距离重新做聚类， 看一下效果是否会不一样。
"""

# ╔═╡ b236174b-f099-490a-8922-bd0ff4b8f2b2
c2 = kmeans(X, 2, distance = Cityblock(), display=:final)

# ╔═╡ f026189c-3266-4e31-b308-936ff02caa37
md"""
读者可以自行对比两种不同的距离返回的结果的差异。
"""

# ╔═╡ c19ef3e8-d2ae-4ae1-8f6c-88b2254c2b24
md"""
## 任务4 层次聚类
### 层次聚类函数
层次聚类使用的函数是hclust。其签名如下：
```
hclust(d::AbstractMatrix; [linkage], [uplo], [branchorder]) -> Hclust
```
其中， 
- d::AbstractMatrix: 是样本之间的距离矩阵， 其中d[i,j]表示第i个样本和第j个样本的距离。
- linkage::Symbol: 表示簇之间的距离计算方式。 本质上是簇的样本之间的聚类如何变成簇的簇的距离。其可选项包括：
	- :single (默认值): 簇的元素之间的最小距离当成是簇之间的聚类。
	- :average: 簇元素之间的平均距离当成是簇的距离。
	- :complete: 簇元素之间的最大距离当成是簇的距离。
	- :ward: 合并簇之后， 样本到簇中心的平方距离的增加量

由于层次聚类输入的是距离矩阵， 所以需要事先计算出距离矩阵来。更多的细节，可以参考[帮助文档](https://juliastats.org/Clustering.jl/stable/hclust.html)
"""

# ╔═╡ 9c9bf9ac-7767-4f1d-8575-9d6dc5d8b9f9
md"""
### 距离计算
由于我们的数据中包含很多样本， 直接计算所有样本之间的距离很容易导致内存不足。为此， 我们随机抽取1000个样本用于演示层次聚类过程。 下面的id用于存储我们从X的列中无放回的抽取1000个样本的编号。

"""

# ╔═╡ 1b08b323-7a1a-4f5c-a6ce-37ce24d91591
id = sample(1:size(X)[2], 1000, replace = false)

# ╔═╡ ae38b3e4-df08-4ebb-b49a-c301aadc4c37
md"""
接下来， 计算相应的距离。由于我们要的是样本之间两两的距离，因此，选用`pairwise`函数。 同时，因为X中列存储的是样本， 因此指定距离计算的维度`dims=2`。
"""

# ╔═╡ e418ceb6-41ee-4697-826b-fee80670e735
d = pairwise(Euclidean(), X[:, id], X[:, id],dims=2)

# ╔═╡ 0e58ba7f-9d14-4e22-9ed1-bf9b280906c1
md"""
### 层次聚类计算
"""

# ╔═╡ 468a299c-99e6-47ba-baa9-046c49cc7aca
h = hclust(d)

# ╔═╡ a6e1cf72-167c-449f-b853-f3924e285363
md"""
层次聚类是将所有的样本最终聚成了一个类。 可以使用`plot`函数（来自StatsPlots包）画出层次聚类的过程。
"""

# ╔═╡ c86d1fe0-ded7-405b-993a-cb3d121811fe
plot(h)

# ╔═╡ 08df9aff-dee7-4c9e-b1f9-fa34f7ef0eb8
md"""
上面将所有的样本画在一起， 可能看不清做种结果长啥样， 我们可以少画一点。 如下为 我们将前50个样本做层次聚类的结果。
"""

# ╔═╡ 13e28462-a217-4bbe-a9c8-4a2e427d7025
h1 = hclust(d[1:50, 1:50])

# ╔═╡ 061ee529-f032-4c8f-8613-01e72c5d6e69
plot(h1)

# ╔═╡ 75c784bb-3683-4a56-8c9c-bdd9be54ac61
md"""
为了实现按照不同的距离将其划分为不同的类， 需要使用`cutree`函数。 下面的代码是将样本划分为两个簇。不过请注意， 这里实现的是将随机挑选出的样本做的划分结果。
"""

# ╔═╡ 40286c18-78f1-4c2a-ba71-e95f62e0129d
cutree(h, k=2)

# ╔═╡ a738d4d5-f360-4f8b-96ca-b0a58e867dde
PlutoUI.TableOfContents(title = "目录", aside = true)

# ╔═╡ Cell order:
# ╠═70ec76d1-638c-4bb9-80ab-69bb33450baf
# ╟─e4e623dc-0717-421a-9d38-111833ab5711
# ╟─bf7e4c5a-4f7f-4a99-a6b0-6a225b5a43a3
# ╠═3f847b82-2175-498a-9ef7-f85a50432733
# ╟─139f007f-31be-4ae6-9d67-c6917ea01f3d
# ╟─864ee807-e20c-4fa6-bafc-22b629a9caf4
# ╠═ea3e25cd-0744-4c03-b1c3-57031a98ba4f
# ╟─52275bf8-330a-46c5-b6d8-4137ce1031d8
# ╠═2d63e2c5-44e9-4d54-b199-f3a3c8013048
# ╠═62957610-c7f8-4e43-9ce3-a5372432ecb1
# ╟─7d874820-7e3f-11ec-1087-dd819d253f23
# ╟─41eb25f8-8a10-4f78-9373-dd79f95c87f2
# ╟─3012af0f-f52d-4212-a5a7-c8f97485ea5c
# ╟─1bd83605-0cbe-4908-8044-15ee8470c321
# ╟─319acc7d-b5ac-421a-b3ea-98d6cd3701de
# ╟─d79fd59e-ef0b-4b12-b4cf-6526020b8167
# ╟─be29c6d4-8d37-439b-9111-9adcbda40582
# ╠═deb39e3e-139a-4d1f-8b56-4fb888060018
# ╠═130bc63c-90ad-4076-bf55-e16f92ee6520
# ╟─a57b8a91-44d9-48ce-be6a-005b645f57a5
# ╠═9e354aa0-5092-4fda-8919-84b9c6618e00
# ╟─b760559b-2335-4c23-99a1-82747d64914c
# ╠═4cfe738b-1995-4233-8546-471e7195b03b
# ╠═5f6f8819-8793-47bc-8037-872a6900ece0
# ╟─88093475-0f2b-4120-9748-36f73ddc0b24
# ╠═3e11f98b-373a-4186-a71b-54a042735f2a
# ╠═bf19eb1c-5bc5-4c53-8561-3920cf788327
# ╠═bb5090de-0443-4a79-8dda-5a09a43c6eba
# ╠═1be189bf-4a2f-4fcd-bb94-4a3297fb1e51
# ╠═84735154-7ff5-4bb1-8d22-a4226e4c448b
# ╠═e6199349-13bf-4efe-af3c-01c6dccab74c
# ╠═6208466b-d86d-4b0b-99b5-bfa2baabb3b9
# ╠═a10f2c4b-89ec-4175-a3a4-5ba273520f40
# ╟─3bf510ec-f3c9-4b3d-bac1-19a9ea386a54
# ╟─8e085543-c0f3-45b8-9c09-de76e9069be2
# ╟─b9034943-31f9-49ab-8ae4-30f76cad2c43
# ╟─a80a133b-88a0-4803-b5a7-e586440aca3c
# ╠═8ecc280e-0342-4100-af46-9b0723f1dfc0
# ╟─a09c4b87-7dda-4d07-9b9f-4b3514335ffd
# ╟─2bf3e51a-6a5e-4d22-b024-7d2bb5d48336
# ╠═e9fc11af-6da4-45d4-9679-cb963214edb6
# ╟─1fc28df8-dbd8-44d4-9a82-7c95663c499c
# ╠═595f9993-abeb-41ac-86b7-3508b6228f3d
# ╟─8dd22076-0400-4279-9eba-e75e829bcd58
# ╠═e2d34790-2576-49f6-b80e-b457a9aa44b9
# ╟─91c9e518-5f06-4435-b988-c268b991bc21
# ╠═735ada31-d603-4380-b34c-9fa1575b9478
# ╠═d7deebc1-6e63-47e2-9572-bca890286a9c
# ╟─0e0f504d-82f0-4051-b54b-301f170836fa
# ╠═b236174b-f099-490a-8922-bd0ff4b8f2b2
# ╟─f026189c-3266-4e31-b308-936ff02caa37
# ╟─c19ef3e8-d2ae-4ae1-8f6c-88b2254c2b24
# ╟─9c9bf9ac-7767-4f1d-8575-9d6dc5d8b9f9
# ╟─1b08b323-7a1a-4f5c-a6ce-37ce24d91591
# ╟─ae38b3e4-df08-4ebb-b49a-c301aadc4c37
# ╠═e418ceb6-41ee-4697-826b-fee80670e735
# ╟─0e58ba7f-9d14-4e22-9ed1-bf9b280906c1
# ╠═468a299c-99e6-47ba-baa9-046c49cc7aca
# ╟─a6e1cf72-167c-449f-b853-f3924e285363
# ╠═c86d1fe0-ded7-405b-993a-cb3d121811fe
# ╟─08df9aff-dee7-4c9e-b1f9-fa34f7ef0eb8
# ╠═13e28462-a217-4bbe-a9c8-4a2e427d7025
# ╠═061ee529-f032-4c8f-8613-01e72c5d6e69
# ╟─75c784bb-3683-4a56-8c9c-bdd9be54ac61
# ╠═40286c18-78f1-4c2a-ba71-e95f62e0129d
# ╟─a738d4d5-f360-4f8b-96ca-b0a58e867dde
# ╟─c9ff268b-0c31-4cea-b690-cb55ad8b24fa
