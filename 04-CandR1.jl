### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ 169e578d-b1a6-43a3-8d4d-bd09e1beb989
begin
using Pkg
Pkg.Registry.add(RegistrySpec(url = "https://github.com/mathutopia/Wlreg.git"))
using Box
end

# ╔═╡ 474a99e2-9032-11ee-2d38-95a5b97c5516
begin
using MLJ, DataFrames, PlutoUI,CSV, Plots, TreeRecipe
end

# ╔═╡ 731c9424-4b31-4454-95d6-aad92b411975
using DecisionTree,MLJDecisionTreeInterface

# ╔═╡ 0649a662-1900-4bc9-bf8d-bbc01cd84ed6
using Random

# ╔═╡ c9a97f79-ce2c-4cdc-b765-0608162f7e8c
PlutoUI.TableOfContents(title = "目录", indent = true, depth = 4, aside = true)

# ╔═╡ 7a2fb632-ff40-41b7-bbd2-cc08cb3ed9a9
 html"<font size=\"80\">实验4 分类与回归（1）</font>"

# ╔═╡ 798913b3-a263-40e9-96df-35b1c5d68acf
md"""
# **实验目的：**
1. 掌握分类问题建模的基本流程
2. 掌握决策树分类模型（C4.5,CRAT）的应用

""" |> box()

# ╔═╡ 1c6dbcff-e276-40bf-a92a-e8fd867778b6
md"""
# 知识链接：
1. 分类问题基本流程（数据集划分、模型评估）
2. C4.5算法
3. CART算法
"""|> box()

# ╔═╡ b4c4a8b6-c535-465e-b204-279e6e1f1a54
md"""
# 实验步骤：
""" 

# ╔═╡ 8e1b157c-6587-4a1f-8ebc-bfe0a66ea0ce
md"""
# 任务1：建模流程搭建
"""

# ╔═╡ 0ee80ce8-a007-4e26-8dd4-dbf0938fd96a
md"""
下面介绍用[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)做数据挖掘建模的基本过程。
"""

# ╔═╡ 8344e755-ffc6-4bb3-ac3b-e2a737033030
md"""
## 1. 准备数据
首先，需要读取数据。然后按照算法的要求将数据转化为响应的形式。
"""

# ╔═╡ 6fc60358-3beb-481e-b0d7-e664ccd03bdb
ret = CSV.read("data/GermanCredit.csv", DataFrame);

# ╔═╡ 9f60ced4-f98a-4298-9da8-f062d6b7e842
ret

# ╔═╡ 1bfc9917-68ac-415a-aea3-336728d39b37
md"""
由于数据中包含多个字段。 为了简便起见， 我们仅选择3列作为特征， 构造预测变量X。 DataFrames.jl包提供了select函数用于数据框中字段的选择， 其基本用法如下：
```julia
select(df::AbstractDataFrame, args...)
```
其中`df`为一个数据框。`args...`是一些选择条件。 可以使用一个列名构成的向量表示要选择的列。返回结果是一个由选择结果构成的数据框。


目标变量y是数据中的`RESPONSE`列。由于这一列是整数， 需要用`categorical`函数将其转化为类别变量。
"""

# ╔═╡ 2118bc17-9972-4e70-b4ae-0cb8f493eb01
X = select(ret, [:AMOUNT,:EMPLOYMENT, :AGE])

# ╔═╡ 80493e58-24b8-4493-8cde-a7540767c41d
y = categorical(ret.RESPONSE)

# ╔═╡ 884ad14a-dd1a-419d-bec1-d4744d51d099
md"""
## 2. 准备模型
"""

# ╔═╡ 89154da7-bddb-472c-ab06-2832410e9939
md"""
首先， 可以用准备好的数据去**搜索合适的模型**。下面的代码会返回所有适合的模型信息。
```julia
models(matching(X, y))
```
其中： 
- `matching(X, y)`生成一个检查函数。该函数对可以用于输入数据X和目标y的模型将返回ture。
- `models`返回已经注册的检查结果为true的模型。

当然， 也可以通过`models`函数搜索跟决策树有关的模型。
```julia
models("DecisionTree")
```
`models`函数返回的结果是一个命名元组构成的向量。向量的每一个元素(元组)表示一个符合的模型元信息。模型的元信息包括很多模型相关的信息， 其中最重要的是模型的名字`name`和所在的包的名字`package_name`。这两个信息给出了模型的出处。 如果我们要使用这个模型， 需要确保相应的包已经安装。



接下来， 假定我们选择的是`DecisionTree`包中的`DecisionTreeClassifier`分类模型。可以使用如下方法查看该模型的元信息。
```julia
julia> info("DecisionTreeClassifier", pkg="DecisionTree")
```
或者用doc函数查看该模型的帮助文档。
```julia
julia> doc("DecisionTreeClassifier", pkg="DecisionTree")
```

"""

# ╔═╡ 8ea9afae-7cc2-44ea-8606-daca1dba25dd
info("DecisionTreeClassifier", pkg="DecisionTree")

# ╔═╡ 441adb16-78e7-4417-b806-a07659b0fcd5
Tree = @load DecisionTreeClassifier pkg=DecisionTree

# ╔═╡ 972070dc-6945-4a49-8801-56f7ac35b012
md"""
上面的using 语句是使用加载相应的包， 其中的`DecisionTree`是模型搜索的时候找到的包的名字。`MLJDecisionTreeInterface`是一个将`DecisionTree`中的模型函数转化为MLJ可以使用的模型的辅助包。如果不知道这个包的存在没有关系。后面加载模型时系统会提示需要安装该包。

@load 宏用于从一个注册的pkg中加载一个模型（这里用Tree绑定加载的模型）。 在MLJ中， 一个**模型**本质上是一个复合数据类型（struct）， 记录了模型的超参数信息。可以使用`@doc`宏看到这个模型的帮助信息。 读取请执行下面的语句看到相应的结果。

```julia
julia> @doc Tree
```


接下来， 需要构建模型的实例， 也就是构建这个复合类型的对象。
```julia
julia> tree = Tree()
DecisionTreeClassifier(
  max_depth = -1, 
  min_samples_leaf = 1, 
  min_samples_split = 2, 
  min_purity_increase = 0.0, 
  n_subfeatures = 0, 
  post_prune = false, 
  merge_purity_threshold = 1.0, 
  display_depth = 5, 
  feature_importance = :impurity, 
  rng = Random._GLOBAL_RNG())
```
注意， 这里模型结构（Tree)与模型实例（tree)之间的差别。模型结构只有一份， 但模型实例可以多次构建。不同的实例代表不同的具体模型（超参数可以不同）。上面构建的是默认参数的模型。

这里构建的模型将随机序列设定为`MersenneTwister(1234)`是为了方便结果的重现。

"""

# ╔═╡ a4936546-2bd1-4a97-bf27-66907783ebdf
tree = Tree(rng=MersenneTwister(1234))

# ╔═╡ 31a386ef-4f17-4c94-8664-0cbf4e31aac7
models("DecisionTree")

# ╔═╡ a0b1219f-02a7-4a2b-9b76-d525033b2ab1
md"""
## 3. 构造机器（machine）
准备好模型和数据之后， 需要将两者联系起来才能进行后续的学习。 这在MLJ中被称作构建机器。 **机器（machine）**可以认为是绑定了数据的模型。构建机器很简单， 使用`machine`函数即可。其基本用法如下：
```julia
machine(model, args..)
```
其中， 
- `model`是构建的模型实例。
- `args...`是模型要学习的数据。通常情况下，监督学习需要同时给定X和y。无监督学习只需要指定X就可以了。

下面是构建刚刚创建的决策树模型的学习机器。 
"""

# ╔═╡ 00a7cba8-8e18-4be6-acbe-f9b089a8def6
mach = machine(tree, X, y)

# ╔═╡ b536589e-f7ad-4d81-a532-7bcd27f12984
md"""
## 4. 划分训练集和测试集
接下来要开始训练模型。但在训练之前需要将数据划分为训练集和测试集。划分训练集和测试集， 只需要分别记录训练集和测试集的样本ID号即可。可以使用`partition`函数实现。该函数的基本用法如下：
```julia
partition(X, fractions...; shuffle=nothing)
```
其中, 
- `X`是由数据集样本ID号构成的容器。
- `fractions`用于指定划分的比例。这里单个小于1的数字表示将数据集划分为两个部分中第一个部分占总体的比例。
- `shuffle`用于指定是否需要打乱数据。相当于随机划分。默认情况下是按顺序划分的。如果要随机划分，需要指定`shuffle = true`

下面的代码将数据集按70%做训练集，30%做测试集划分。 其中`eachindex(y)`由目标向量`y`的索引（下标）构成的容器。这里我们选择随机划分数据集。`MLJ.`的作用是限定使用的是来自MLJ包的`partition`函数。
"""

# ╔═╡ 04bce1e8-38f7-4df7-a3ed-caa3df624841
trainid, testid = MLJ.partition(eachindex(y), 0.7, shuffle = true, rng=MersenneTwister(1234)) 

# ╔═╡ 95820822-3ffe-4a5b-9f3f-058bb3d83656


# ╔═╡ 08999fb3-e10b-4f64-b0cc-d41c21d4f3ed
md"""
## 5. 训练模型
训练模型就是在数据集上拟合模型的参数。使用函数`fit!`即可。其基本用法如下：
```julia
MLJ.fit!(mach::Machine, rows=nothing)
```
其中：
- `mach`是构建好的机器。
- `rows`用于指定机器要学习的数据范围， 即在数据的哪些行上学习。也就是训练集。默认情况下是所有行也就是在所有数据上训练模型。
- `MLJ.`是限定`fit!`来自于MLJ包。这里的限定不是必须的，但由于很多机器学习的包也会实现一个fit！函数。为了避免冲突，加一个包名前缀。
注意这个函数的后面有一个惊叹号。这表示模型训练的过程会修改参数。本质上是机器`mach`中会存储训练得来的参数。使用`fitted_params`函数可以查看拟合的模型参数。或者使用`report`函数报告一些相关信息。
"""

# ╔═╡ 9519d45b-48d9-4287-a8c8-dae8a1551b0d
MLJ.fit!(mach, rows=trainid)

# ╔═╡ 623e7c43-a0e1-4500-8e3a-6e3607eebfb8
md"""
模型拟合之后，可以用`fitted_params`函数查看模型拟合的结果。该函数主要返回一个适合打印的树。同时也给出了拟合的树的一些基本信息。比如， 上面拟合的树模型有246个叶子节点。树的深度为38。 显然这是一颗很庞大的树。
"""

# ╔═╡ e060deb3-46a6-41f8-b341-0f4597a368a9
fitted_params(mach)

# ╔═╡ d39d16aa-c9b7-4d24-916a-c1666ff183ae
md"""
使用`report`函数报告的信息中， 有一个`print_tree`对象， 可以用于简单打印出树形解构。
"""

# ╔═╡ 6d7d7024-2fdc-4ea5-8e45-767c2a684f80
report(mach)

# ╔═╡ 9d9b66df-564f-47d3-9aac-b5a2f2ba3d85
report(mach).print_tree(8) # 数字是限定树的深度

# ╔═╡ 1bd17442-1b24-486e-b1fb-1f9c9ba1d30d
md"""
## 6. 模型预测
模型训练好之后就可以用模型去预测了。通常我们先到测试集上进行预测， 以评估模型的效果。注意， 因为预测目标是一个类别（两种之一）， 这里预测结果是一个分布：相当于属于每一种的概率。 事实上， 在模型的元信息中，存在`predict_scitype`字段， 其取值为`AbstractVector{Density{_s25} where _s25<:Finite}`,表明该模型预测值是一个概率密度(Density)。预测使用`predict`函数：
```julia
MLJ.predict(mach::Machine, new_data...)
```
其中，
- `mach`是拟合好的机器。
- `new_data`是用于预测的数据。注意， 这里必须按照与训练集相同的格式输入数据。

下面的代码在测试集（X[testid,:]）上预测结果。
"""

# ╔═╡ 15919fa0-59d6-4590-9af1-8708bbb62c2e
yhat = MLJ.predict(mach, X[testid,:])

# ╔═╡ a2e0f1b9-2173-4dd7-be7b-78f1d3b16f28
md"""
如果不想获得分布预测结果，可以使用predict_mode函数。也可以在分布预测结果上去求众数(mode)及获得概率最大的预测结果。

```julia
julia> yhat2 = predict_mode(mach, X[testid,:])
julia> mode.(yhat)
```
"""

# ╔═╡ 8b269dd4-5366-411b-93b8-143d98f8eb64
md"""
## 7. 评估模型
评估模型效果本质上是要评估预测值与实际值(ground truth)之间的差距（损失），可以使用`measure()`列出所有的损失评估函数, 参考[这里](https://alan-turing-institute.github.io/MLJ.jl/v0.3/measures/)。 
```julia
julia> measures()
```
模型评估的通用方法是：
```julia
m(ŷ, y)
```
其中，  $\hat{y}$表示模型预测的结果。$y$是相应的真实结果。m是一个评估函数。比如， 我们可以计算模型的`auc`值。这只需要使用`auc`函数即可。
"""

# ╔═╡ c1ecfd38-634c-480d-a9fd-45d362f16c9d
auc(yhat, y[testid])

# ╔═╡ 40c72f1b-10cd-4d76-9d3b-02622f494df0
md"""
从上述auc值来看， 当前的模型还有待改进。对于分类问题， 我们经常会需要模型的精度(precision)、查全率（recall）、和f1值。这三个指标是基于预测结果计算混淆矩阵得到的。由于这里的预测结果是一个概率密度我们需要首先将其转换为对类别的预测才能进而计算这三个指标值。
"""

# ╔═╡ 72a07c0b-b535-4a03-b209-fb7820b4ee1c
yhat1 = MLJ.mode.(yhat)

# ╔═╡ 6dbcbf2f-d1ee-4759-8d3a-a50b7bc18a4c
f1score(yhat1, y[testid])

# ╔═╡ e4ecf5f9-fc33-457d-9412-93f23b916848
md"""
# 任务2 CART模型应用
上面延时用到的模型已经是CRAT模型， 但使用到的参数都是默认参数。我们可以修改默认参数以得到不同的模型。详细的模型超参数列表可以通过帮助文档查看。下面给出几个重要的超参数。

- max\_depth=-1: 用于设定树的最大深度。默认情况下不限制。

- min\_samples_leaf=1: 设置一个叶子节点需要包含的样本的最少数目。
- min\_purity_increase=0: 节点划分时，需要增加的最小纯度。

- n\_subfeatures=0: 需要选择的特征数目。默认情况0表示选择全部特征。

- post\_prune=false: 如果需要后剪枝，需要设定为true。

- merge\_purity\_threshold=1.0: （后剪枝）合并合在一起之后纯度大于这个阈值的叶子节点。

上面的超参数基本都是用于设置预剪枝策略。只有后两个用于后剪枝。 下面我们设定模型的最大深度为10， 叶子节点至少包含5个节点的新模型， 重新训练，并评估其效果。


"""

# ╔═╡ b8d300ba-2042-4783-900c-65fd3d7c7fde
md"""
## 1. 设置模型
由于模型结构已经在上面加载好了，这里不再需要重新加载。 只需要按照相关要求，重新构建一个模型实例。下面构建的模型就是符合要求的模型实例。
"""

# ╔═╡ ddf61ac2-9a80-4dc8-80c7-6a4e83d4fdbf
tree2 = Tree(max_depth=10, min_samples_leaf=5, rng = MersenneTwister(1234))

# ╔═╡ 579d41a6-9de0-4821-86f8-ecec88e31f9a
md"""
## 2. 构建机器
接下来重新绑定数据，构建机器。 这是必须要的步骤， 因为机器是模型实例和数据相关的。
"""

# ╔═╡ 347b878a-01d8-4593-a5d3-47591687045b
mach2 = machine(tree2, X,y)

# ╔═╡ eacf2f99-9271-405f-8a12-7737078c98d4
md"""
## 3. 拟合模型
拟合模型的操作跟上面是一样的。
"""

# ╔═╡ 63898854-3f5f-4824-baee-e170eb1fca17
MLJ.fit!(mach2, rows=trainid)

# ╔═╡ 67270c9a-7d58-428d-9528-2c137260ff62
fitted_params(mach2)

# ╔═╡ e55e8b4e-11d2-4ed5-9d7a-af670f5300e4
md"""
## 4. 评估模型结果
读者可以自行利用任务1中的有关函数查看重新得到的模型。接下来，重新评估模型的效果。
"""

# ╔═╡ d91f51e1-a722-4ba4-a73c-249f093ae9e6
yhat2 = MLJ.predict(mach2, X[testid,:])

# ╔═╡ 0ea171ef-dca8-4e19-81aa-6b9b5b330432
auc(yhat2, y[testid])

# ╔═╡ 1eee4cc6-631f-4eb4-8f32-0193d4949671
auc(yhat, y[testid])

# ╔═╡ b1661b78-7ee1-4f69-b7db-1ef78ea2c69a
md"""
对比两个模型的结果， 显然， 第二个模型比第一个模型效果要好一些。 这说明最开始的模型可能过于复杂，导致效果反而不是很理想。

当然， 整体而言，现在的模型效果都不是很理想。
"""

# ╔═╡ 46187ce3-0407-4bd2-8c30-81badef940df
md"""
由于这里模型相对较小， 我们可以画出树形结构。
"""

# ╔═╡ 3f7dd110-b2d4-4550-9033-10ff7f04a509
tr = fitted_params(mach2).tree

# ╔═╡ 8413eb8b-5ac5-4f46-a248-129708695a98
plot(tr)

# ╔═╡ 10f54722-bdb8-4949-b1ce-93df9d6cc972
md"""
由于模型中包含随机数， 我们两个模型都采用了相同的随机数发生器和相同的随机种子。 如果， 不做这种设置，每一次跑这个模型， 结果都可能不一样，甚至差异巨大。 
""" |> box(:red, :注意)

# ╔═╡ a7926f4d-eac0-483c-a35b-c1baa9fb5913
md"""
# 附
下面给出本实验所用模型的帮助文档。
"""

# ╔═╡ 845563ab-b8eb-4b38-9d18-ce2ce89eb02d
 doc("DecisionTreeClassifier", pkg="DecisionTree")


# ╔═╡ Cell order:
# ╟─169e578d-b1a6-43a3-8d4d-bd09e1beb989
# ╠═474a99e2-9032-11ee-2d38-95a5b97c5516
# ╠═c9a97f79-ce2c-4cdc-b765-0608162f7e8c
# ╟─7a2fb632-ff40-41b7-bbd2-cc08cb3ed9a9
# ╟─798913b3-a263-40e9-96df-35b1c5d68acf
# ╠═1c6dbcff-e276-40bf-a92a-e8fd867778b6
# ╟─b4c4a8b6-c535-465e-b204-279e6e1f1a54
# ╟─8e1b157c-6587-4a1f-8ebc-bfe0a66ea0ce
# ╟─0ee80ce8-a007-4e26-8dd4-dbf0938fd96a
# ╟─8344e755-ffc6-4bb3-ac3b-e2a737033030
# ╠═6fc60358-3beb-481e-b0d7-e664ccd03bdb
# ╠═9f60ced4-f98a-4298-9da8-f062d6b7e842
# ╟─1bfc9917-68ac-415a-aea3-336728d39b37
# ╠═2118bc17-9972-4e70-b4ae-0cb8f493eb01
# ╠═80493e58-24b8-4493-8cde-a7540767c41d
# ╟─884ad14a-dd1a-419d-bec1-d4744d51d099
# ╟─89154da7-bddb-472c-ab06-2832410e9939
# ╠═8ea9afae-7cc2-44ea-8606-daca1dba25dd
# ╠═731c9424-4b31-4454-95d6-aad92b411975
# ╠═441adb16-78e7-4417-b806-a07659b0fcd5
# ╟─972070dc-6945-4a49-8801-56f7ac35b012
# ╠═0649a662-1900-4bc9-bf8d-bbc01cd84ed6
# ╠═a4936546-2bd1-4a97-bf27-66907783ebdf
# ╠═31a386ef-4f17-4c94-8664-0cbf4e31aac7
# ╟─a0b1219f-02a7-4a2b-9b76-d525033b2ab1
# ╠═00a7cba8-8e18-4be6-acbe-f9b089a8def6
# ╟─b536589e-f7ad-4d81-a532-7bcd27f12984
# ╠═04bce1e8-38f7-4df7-a3ed-caa3df624841
# ╠═95820822-3ffe-4a5b-9f3f-058bb3d83656
# ╟─08999fb3-e10b-4f64-b0cc-d41c21d4f3ed
# ╠═9519d45b-48d9-4287-a8c8-dae8a1551b0d
# ╟─623e7c43-a0e1-4500-8e3a-6e3607eebfb8
# ╠═e060deb3-46a6-41f8-b341-0f4597a368a9
# ╟─d39d16aa-c9b7-4d24-916a-c1666ff183ae
# ╠═6d7d7024-2fdc-4ea5-8e45-767c2a684f80
# ╠═9d9b66df-564f-47d3-9aac-b5a2f2ba3d85
# ╟─1bd17442-1b24-486e-b1fb-1f9c9ba1d30d
# ╠═15919fa0-59d6-4590-9af1-8708bbb62c2e
# ╟─a2e0f1b9-2173-4dd7-be7b-78f1d3b16f28
# ╟─8b269dd4-5366-411b-93b8-143d98f8eb64
# ╠═c1ecfd38-634c-480d-a9fd-45d362f16c9d
# ╟─40c72f1b-10cd-4d76-9d3b-02622f494df0
# ╠═72a07c0b-b535-4a03-b209-fb7820b4ee1c
# ╠═6dbcbf2f-d1ee-4759-8d3a-a50b7bc18a4c
# ╟─e4ecf5f9-fc33-457d-9412-93f23b916848
# ╠═b8d300ba-2042-4783-900c-65fd3d7c7fde
# ╠═ddf61ac2-9a80-4dc8-80c7-6a4e83d4fdbf
# ╟─579d41a6-9de0-4821-86f8-ecec88e31f9a
# ╠═347b878a-01d8-4593-a5d3-47591687045b
# ╟─eacf2f99-9271-405f-8a12-7737078c98d4
# ╠═63898854-3f5f-4824-baee-e170eb1fca17
# ╟─67270c9a-7d58-428d-9528-2c137260ff62
# ╟─e55e8b4e-11d2-4ed5-9d7a-af670f5300e4
# ╠═d91f51e1-a722-4ba4-a73c-249f093ae9e6
# ╠═0ea171ef-dca8-4e19-81aa-6b9b5b330432
# ╠═1eee4cc6-631f-4eb4-8f32-0193d4949671
# ╟─b1661b78-7ee1-4f69-b7db-1ef78ea2c69a
# ╟─46187ce3-0407-4bd2-8c30-81badef940df
# ╠═3f7dd110-b2d4-4550-9033-10ff7f04a509
# ╠═8413eb8b-5ac5-4f46-a248-129708695a98
# ╟─10f54722-bdb8-4949-b1ce-93df9d6cc972
# ╟─a7926f4d-eac0-483c-a35b-c1baa9fb5913
# ╠═845563ab-b8eb-4b38-9d18-ce2ce89eb02d
