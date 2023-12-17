### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ dff9e5b0-959b-11ee-2223-419029c55758
begin
using CSV, DataFrames, MLJ,DataFramesMeta, MLJModels,PlutoUI
include("funs.jl");# 加入通用函数
PlutoUI.TableOfContents(title = "目录", indent = true, depth = 4, aside = true)
end

# ╔═╡ 95a98d49-137d-4394-9e0e-ca841181c4fd
using MLJDecisionTreeInterface 

# ╔═╡ 9f348928-ffc6-451f-a8bc-d197c4d8a611
 html"<font size=\"80\">实验5 模型寻优</font>"

# ╔═╡ dc6658b0-e0f4-48d0-a58b-6ef2921998f6
md"""
**目的与要求**
1. 掌握MLJ数据预处理模型
2. 掌握模型评估与调优方法
3。 掌握管道模型构建
""" |> fenge

# ╔═╡ 390aa058-7b07-4ec0-aacd-d43b43c2d61a
md"""
# 1 数据预处理模型
"""

# ╔═╡ 6ceb287c-fec1-43a3-9822-49bef5003607
md"""
很多时候， 我们更重要的工作是对数据做预处理， 比如做特征选择， 数据变换等等。这些操作可以看成是对数据做无监督的学习。MLJ提供了一些无监督学习的模型，可以方便的对数据做一些简单处理。

在MLJ中， 提供了以下几种内置的数据变换模型：

- MLJModels.Standardizer ： 数据标准化

- MLJModels.OneHotEncoder ： 独热编码

- MLJModels.ContinuousEncoder ： 连续编码

- MLJModels.FillImputer ： 缺失值计算

- MLJModels.UnivariateFillImputer ：单变量缺失值计算

- MLJModels.FeatureSelector ： 特征选择

- MLJModels.UnivariateBoxCoxTransformer ：BoxCox变换

- MLJModels.UnivariateDiscretizer  ：单变量离散化

- MLJModels.UnivariateTimeTypeToContinuous ：时间转连续变量

下面对常用的无监督模型做简要介绍。 看[这里](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/#Transformers-and-Other-Unsupervised-Models)了解更多。
"""

# ╔═╡ 0da6aa89-d6d7-47fa-9cf1-7425d806ca8d
md"""
## 特征选择
一个模型对输入的特征总是有要求的， 因此， 选择我们想要的特征是建模的第一步。 特征选择可以使用FeatureSelector模型。这个模型可以用于选择我们要的特征，或者不要的特征。由于这也是模型， 所以可以有类似的模型操作框架。
1. 加载模型代码；
2. 构建模型实例； 
3. 构建机器； 
4. 拟合模型；
5. 转换数据； 

具体细节可以参考[这里](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/#MLJModels.FeatureSelector)
"""

# ╔═╡ 5bc9dbcf-841b-4bb6-b438-6dcce5d662ab
trains = CSV.read("data/trainbx.csv", DataFrame)

# ╔═╡ 59ddc03e-b710-4848-bf94-6fd1d93086fb
names(trains)

# ╔═╡ 54dec9c9-31a9-42ce-98c3-bdce214415ed
md"""
### 加载模型代码
这里要加载的模型都在MLJModels里面。
"""

# ╔═╡ a180eec7-1da4-4900-8be2-3dd7cc2cf24e
FeatureSelector = @load FeatureSelector pkg=MLJModels # 加载模型代码

# ╔═╡ 054f9a1d-1521-4131-8ed8-2e2b2179cca0
md"""
### 构建模型实例
构建特征选择模型的实例时， 一个重要的参数是指定要选择的特征features, 通常是一个特征名字(Symbol）组成的向量。
比如，下面的模型可以用于从数据集中选择两列:age, :customer_months。

当然， 也可以使用一个函数， 请参考[这里](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/#MLJModels.FeatureSelector)了解更多。
"""

# ╔═╡ 80ab5f06-dec1-4eae-996f-397832d5a83f
selector = FeatureSelector(features=[:age, :customer_months ])

# ╔═╡ eca076c5-5dcd-4536-92d3-62ead66632eb
md"""
### 构建机器
构建机器就是将模型跟数据绑定起来。 这里的模型只是从数据中选择列， 所有没有y（无监督学习）
"""

# ╔═╡ daef6a63-5eea-441c-ad66-6d4f11f885a0
mach1 = machine(selector, trains)

# ╔═╡ 05e3e86b-b61c-4c6f-8a0e-b9840c17d7e8
md"""
### 拟合模型
这里拟合模型其实不需要做太多的工作。因为并没有太多参数需要学习。不过， 有些无监督学习时需要学习一些参数的， 比如标准化就需要学习均值和方差。

同时请注意， 我们这里也没有指定训练集和测试集， 因为在特征选择里， 不需要区分这两者。
"""

# ╔═╡ 3b0ac5de-0c27-448b-8957-48f9347a3ddc
MLJ.fit!(mach1)

# ╔═╡ 769ce8e1-cf8c-47b7-b921-00c2329af64a
md"""
### 变换数据
拟合机器之后， 就可以用机器去变换数据了。变换使用的函数是transform。 从下面的结果可以看到， 我们的悬链数据经过变换之后， 只剩下两列了。
"""

# ╔═╡ dcaf72e8-43f2-4e8c-b777-4818d4fd281d
MLJ.transform(mach1, trains)

# ╔═╡ 63049bd2-d1b2-4040-8c21-53f556e10b10
md"""
上面演示了一个简单的特征选择模型的作用过程。从上面可以看出， 这类模型显然比常规的监督学习模型要简单很多， 但在处理数据的框架上，还是有很多类似之处。 下面再演示几个例子。 

由于我们可以会需要根据不同的特征建立多个相关模型， 因此， 我们可以建立多个特征选择模型。 这时候， 因为特征选择模型已经加载好了。 我们只需要构建不同的实例就可以了。

比如， 下面的特征选择模型选择了另外的特征。
"""

# ╔═╡ 4b05e29d-f70b-4907-8b16-450d434828cb
selector1 = FeatureSelector(features=[:age,	:customer_months,	:policy_bind_date ])

# ╔═╡ cf7f5aeb-e198-458e-bb2d-697451ce01a2
md"""
为了演示方便， 下面把构建机器， 拟合机器， 数据变换写到了同一行里。 
"""

# ╔═╡ e3e3cd08-cc48-4a4f-b199-d860f0a659f1
MLJ.transform(MLJ.fit!(machine(selector1, trains)),trains)

# ╔═╡ 0561ca5d-7f5f-4e27-a33f-553458a0c70a
md"""
## 独热编码
独热编码可以实现将类别变量或有序因子转换为独热变量。 因为在我们的数据集中，并没有这种类型的变量。 所以我们需要首先对数据做类型转化。 比如， 我们可以将文本类型的变量先转化为类别型变量。
"""

# ╔═╡ d9e87f1d-e1a7-4707-97ae-bfce36c9880d
trainsn = coerce(trains, Textual => Multiclass)

# ╔═╡ e6dbe3ed-7686-42c1-b6e4-f67e07747ee3
OneHotEncoder = @load OneHotEncoder pkg=MLJModels

# ╔═╡ cf1c3ee6-d0b1-4c24-8716-f28d193f4622
OneHotEncoder()

# ╔═╡ 492fc857-69d0-48ed-9d72-6cd280f4ab79
machcode = MLJ.fit!(machine(OneHotEncoder(), trainsn))

# ╔═╡ 2408cdbe-32ff-4703-9a7f-d019c021bd43
MLJ.transform(machcode, trainsn)

# ╔═╡ aa39c47e-7eb5-4295-9649-d95c040cc3e6
md"""
## 连续编码
连续编码的作用是将所有可以数值化的特征全部数值化。 其使用方法跟上述模型是类似的。
"""

# ╔═╡ 2c2db3b4-b761-4c94-9aba-bbfb75fecde6
ContinuousEncoder = @load ContinuousEncoder pkg=MLJModels

# ╔═╡ b33efe80-feb3-4933-88ba-332bc8cb648a
machcontinuous = MLJ.fit!(machine(ContinuousEncoder(), trains))

# ╔═╡ 8566fb19-726a-4d3b-8171-2607ce74dbe5
MLJ.transform(machcontinuous, trains)

# ╔═╡ 66ef0379-d1af-4b3b-b2a7-144ee76f5424
md"""
# 2 模型串联（管道）
MLJ中还有更多的数据变换模型， 但操作方式都基本相同。可以在需要的时候自己去看文档。这里介绍一个更重要的需求--将多个操作的串联在一起，形成一个整体。

事实上， 数据处理的过程就像一个对数据的加工过程。 加工过程中的每一个环节都是对数据做模型类型的操作。
我们希望将各种类型的操作合并在一起形成一个整体。 比如， 我们先选择某些特征， 然后对数据做合适的科学类型转换， 最后将其做连续编码。这可以通过将多个操作（模型）串联到一起实现， 其基本的语法是：
```julia
pipe = mode1 |> model2 |> model3 |> ... |> modeln
```
这里的模型（model）既可以是前面讲过的模型， 也可以是某个函数。 唯一需要注意的是：数据是依次通过各个模型处理， 然后再输出的。前一个模型的输出结果会输入后一个模型。
"""

# ╔═╡ 125eeff4-3204-4492-b68d-51354f4e7dd5
pipe = FeatureSelector(features=[:age,	:customer_months ,:insured_sex, :insured_education_level]) |>  (X -> coerce(X, Textual => Multiclass)) |> ContinuousEncoder() 

# ╔═╡ f81a805a-ab4a-4cb1-bff9-3db3f2cf2551
machpip = machine(pipe, trains)

# ╔═╡ e3fcaf6e-d1bd-41d4-8ac9-a1f1f7ff7b26
MLJ.fit!(machpip)

# ╔═╡ 23b28bfe-15b9-4eb1-8a17-252b2ae494ea
MLJ.transform(machpip, trains)

# ╔═╡ cac7a664-4fdf-4de4-96e5-14992586ebc1
md"""
# 3 MLJ建模回顾
简单来说， 用MLJ建模可以划分为以下7个步骤，
1. 加载合适模型
2. 构建模型实例
3. 构造机器
4. 划分训练集、测试集
5. 模型拟合
6. 模型预测
7. 模型评估

不过， 要建立一个合理的模型， 需要更多的操作。比如， 如何更好的评估模型？如何找到更优的模型参数？ 如何整合数据预处理与模型的整个过程？如何整合更多的模型等等。
"""

# ╔═╡ 83a87a73-e5a0-459a-a7e5-d0da95abc7dd
train = select(trains, Not(:fraud))

# ╔═╡ e3e579f6-4df1-4e1e-a4bc-42579521871a
X = @select train :age :mon = :customer_months  :claim = :property_claim

# ╔═╡ 69516ebe-ad2c-4bdd-8d09-f612fc4eff68
schema(X)

# ╔═╡ a33a1c89-823d-48d5-b5a8-376a144c346a
y = categorical(trains.fraud)

# ╔═╡ 6068432b-9d44-4828-b117-3186ddcc23e9
models(matching(X,y))

# ╔═╡ 4f13dff3-9d90-458c-8d4d-e97f4f33206a
rfm = (@load RandomForestClassifier pkg = DecisionTree)()

# ╔═╡ d7a2e839-bc72-449e-8018-e241d2c19ca8
machrfm = machine(rfm, X, y)

# ╔═╡ 024ef752-157a-4c75-a77d-16fd8a0fc884
trainid, testid = MLJ.partition(eachindex(y), 0.7, shuffle = true)

# ╔═╡ aff69643-b08f-45c3-a79f-a046d7c95263
MLJ.fit!(machrfm,rows = trainid)

# ╔═╡ eb28592b-d1db-420d-b888-1a75a2b56382
ŷ =  MLJ.predict(machrfm, X[testid, :])

# ╔═╡ 30af5722-139b-4949-92f8-cd05b64ee430
MLJ.auc(ŷ, y[testid])

# ╔═╡ 3c3b607a-bdb0-48c1-86e9-23ad39d3d253
MLJ.accuracy( MLJ.mode.(ŷ), y[testid])

# ╔═╡ ddd9ec16-ebf0-433f-a100-39963da74a47
md"""
# 4 更好的评估模型
从上面可以看得出来， 每一次评估模型，我们需要划分训练集、测试集， 绑定机器， 同时需要指定评估的指标。 但实际上， 对每一个可能的模型。 上面的过程是重复的。 因此， 我们可以将其纳入一个函数， 实现更好的评估模型。

evaluate函数可以实现只要给定模型实例、数据、抽样策略（用于生成训练集、测试集）、评估函数，就可以方便测试模型。
"""

# ╔═╡ fac7ec8c-1e36-476c-a95a-a72953f2b7c7
eres = evaluate(rfm, X, y, resampling=CV(nfolds=5), measure=[auc])

# ╔═╡ d248536a-48fe-487d-bc41-7ba54ec9c39f
eres.per_fold[1]

# ╔═╡ 3bbcf0f5-0c7c-4c7a-9151-1d43f878da27
md"""
上面的measurement是每一折检验的评估函数的取值的均值。SE表示标准误（Stand Error）。反映的是估计的均值跟真实的均值之间的偏离程度。1.96\*SE是95%置信区间的大小， 即真正的均值以95%概率
分布在 [ measurement \- 1.96\*SE, measurement + 1.96\*SE]之间。


"""

# ╔═╡ 86fb646b-616b-4df8-ac4c-e4f08082e947
1.96*std(eres.per_fold[1])/sqrt(5-1)

# ╔═╡ 1e033c2f-9c78-41ab-aaa9-8422296ca8b3
evaluate(rfm, X, y)

# ╔═╡ 364d5f97-9775-44fe-8af2-7681cd9fdd47
md"""
# 5 模型调优*
一个模型包含了很多的参数， 通常必要的参数都会有默认的值， 但默认的参数值不见得是最适合数据的。 因此， 需要通过一定的方法找到最合适的模型参数。 这个过程被称为**模型调优**。 简单来说， 模型调优就是要遍历所有可能的参数组合， 找到最合适的那个模型。 然而， 对连续取值的参数来说， 遍历所有可能的取值是不现实的。 因此， 调优的过程必然涉及到调优策略的问题。 

在MLJ中，模型调优是作为模型包装器实现的。在调优策略中包装模型并将包装的模型绑定到mach机器中的数据之后，调用fit!(mach)在指定的范围内搜索最优模型超参数，然后使用所有提供的数据来训练最佳模型。要使用该模型进行预测，可以调用predict(mach, Xnew)。通过这种方式，包装模型可以被视为未包装模型的“自调优”版本。也就是说，包装模型只是将某些超参数转换为学习参数。

更多细节请看[这里](https://alan-turing-institute.github.io/MLJ.jl/dev/tuning_models/#Tuning-Models)
"""

# ╔═╡ 6c3cf0e1-6668-44cf-893e-0d5f239f8bfa
rfm

# ╔═╡ a1d2b19e-8a88-4591-a518-cea603ff3063
md"""
## 指定调优参数范围
要对一个模型的某个参数去调优， 首先需要指定参数取值的范围。这可以通过range实现。
"""

# ╔═╡ 12f7dfbc-b709-49a6-92c5-d0f4911d1eeb
r = range(rfm, :n_trees  , lower=10, upper=100);

# ╔═╡ 434c064b-09e9-4b8a-8cfc-3499d0bc54b5
md"""
## 构造调优模型
因为调优过程本质上是在一系列模型中选取最好的模型。 在MLJ中， 我们通过构造调优模型的，然后去拟合该模型实现调优。

构造调优模型可以指定调优策略tuning， 和采样策略resampling。 默认情况下， tuning=RandomSearch(),
                         resampling=Holdout()。

下面用网格搜索策略构建随机森林的调优模型， 可以通过调整resolution(每一个维度的网格点数量， 当只有一个维度时， 相当于模型的个数)参数或通过设置goal参数（总体模型数量）， 指定要评估的模型的数量。 
"""

# ╔═╡ d78f506b-363a-46c3-8df5-e9293d3e367f
tuning_rfm = TunedModel(model=rfm,
							  resampling=CV(nfolds=3),
							  tuning=Grid(resolution=5),
							  range=r,
							  measure=auc)

# ╔═╡ d86277c1-14a6-4d23-8050-bc5f040c8bed
md"""
## 构造和拟合机器
"""

# ╔═╡ 798848dc-1006-45a3-a278-257f4d38cf65
tmach1 = machine(tuning_rfm, X,y)

# ╔═╡ f9f52d0c-12bd-4bf8-b094-3fd05113e841
MLJ.fit!(tmach1)

# ╔═╡ 3cf392fc-142d-4a66-88e1-d8005fe9beaf
md"""
## 查看拟合的最优模型
"""

# ╔═╡ c17359e8-ef79-4df6-a1dc-c9f80b08c3bf
MLJ.fitted_params(tmach1).best_model

# ╔═╡ 2963379c-5ca4-4019-9a97-7487a3b30fa4
md"""
## 查看拟合过程
主要是了解拟合的最优模型的一些计算过程中的参数。
"""

# ╔═╡ c47d9f05-aa06-4e56-bc96-5322469a3365
report(tmach1).best_history_entry

# ╔═╡ 6bbab1ff-20ca-40b5-b12c-7a8185eaad74
report(tmach1)

# ╔═╡ 242ffdf0-8d93-4048-ace1-3954200e9e9f
md"""
## 多个参数同时调优*
有时候， 我们可能需要多个参数同时调优， 这可以通过设置多个range实现。

假定我们还要对min\_purity\_increase参数进行调优。 那么，我们可以新建一个range，重新构造模型。
"""

# ╔═╡ 169dac4a-8880-4be4-a71f-599734cf0e01
rfm

# ╔═╡ b8ba286d-3b8a-4896-8e16-ab8ee2149049
r2 = range(rfm, :min_purity_increase   , lower=0, upper=1);

# ╔═╡ 4254c86e-534d-4386-8855-af07fff4006e
tuning_rfm2 = TunedModel(model=rfm,
							  resampling=CV(nfolds=3),
							  tuning=Grid(goal=10),
							  range=[r,r2],
							  measure=auc)

# ╔═╡ 130f7560-7b3b-4c3c-a2f0-8838a0e38f6d
mach2 = machine(tuning_rfm2, X, y)

# ╔═╡ 523cd9cd-0856-4fb8-9272-c9a64ba3c1d0
MLJ.fit!(mach2)

# ╔═╡ 289a3f94-abae-46e7-9a5a-1f5f58b3094f
report(mach2).best_history_entry

# ╔═╡ 77dfeb9e-5d70-4571-a0af-8180366db755
report(mach2).best_model

# ╔═╡ 29edd637-bcbc-44e7-b1b0-859074e52a05
md"""
## 预测
拟合的调优模型可以直接用于预测， 注意，默认情况下会使用最优模型去预测， 所以不需要将最优模型调出来。

可以直接通过rows指定要预测的数据所在的行， 或者直接给出预测属性。
"""

# ╔═╡ 2e380486-3768-4712-9b26-6d308984bc28
MLJ.predict(tmach1, rows = 1:10)

# ╔═╡ 195bc721-ee69-441b-b5c5-984fea174636
MLJ.predict(tmach1, X[1:10,:])

# ╔═╡ 47177e82-0cd6-4b6c-b5f4-19f595f98756
selected_feats2 = [:age ,:autoage, :customer_months , :policy_state , :insured_sex , :insured_education_level ,  :property_claim ,:insured_occupation ,:insured_hobbies]


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MLJDecisionTreeInterface = "c6f25543-311c-4c74-83dc-3ea6d1015661"
MLJModels = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.11"
DataFrames = "~1.6.1"
DataFramesMeta = "~0.14.1"
MLJ = "~0.20.2"
MLJDecisionTreeInterface = "~0.4.0"
MLJModels = "~0.16.12"
PlutoUI = "~0.7.54"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "d019a10f4fa9da7ff1980bab191a26b3ea35d7bb"

[[deps.ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "02f731463748db57cc2ebfbd9fbc9ce8280d3433"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "e28912ce94077686443433c2800104b061a827ed"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.39"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

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

[[deps.CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypes"]
git-tree-sha1 = "3124343a1b0c9a2f5fdc1d9bcc633ba11735a4c4"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.13"

    [deps.CategoricalDistributions.extensions]
    UnivariateFiniteDisplayExt = "UnicodePlots"

    [deps.CategoricalDistributions.weakdeps]
    UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"

[[deps.Chain]]
git-tree-sha1 = "8c4920235f6c561e401dfe569beb8b924adad003"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "e0af648f0692ec1691b5d094b8724ba1346281cf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.18.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "Reexport"]
git-tree-sha1 = "6970958074cd09727b9200685b8631b034c0eb16"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.14.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DecisionTree]]
deps = ["AbstractTrees", "DelimitedFiles", "LinearAlgebra", "Random", "ScikitLearnBase", "Statistics"]
git-tree-sha1 = "526ca14aaaf2d5a0e242f3a8a7966eb9065d7d78"
uuid = "7806a523-6efd-50cb-b5f6-3fa6f1930dbb"
version = "0.12.4"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "5225c965635d8c21168e32a12954675e7bea1151"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.10"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a6c00f894f24460379cb7136633cef54ac9f6f4a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.103"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "98fdf08b707aaf69f524a6cd0a67858cefe0cfb6"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.3.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "ffb97765602e3cbe59a0589d237bf07f245a8576"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.1"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "35f0c0f345bff2c6d636f95fdb136323b5a796ef"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.7.0"
weakdeps = ["SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

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

[[deps.IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "d7df9a6fdd82a8cfdfe93a94fcce35515be634da"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.5.3"

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

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "PrecompileTools", "Requires", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "b0737cbbe1c8da6f1139d1c23e35e7cea129c0af"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.13"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "c879e47398a7ab671c782e02b51a4456794a7fa3"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "6.4.0"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "98eaee04d96d973e79c25d49167668c5c8fb50e2"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.27+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LatinHypercubeSampling]]
deps = ["Random", "StableRNGs", "StatsBase", "Test"]
git-tree-sha1 = "825289d43c753c7f1bf9bed334c253e9913997f8"
uuid = "a5e1c1ea-c99a-51d3-a14d-a9a37257b02d"
version = "1.9.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LearnAPI]]
deps = ["InteractiveUtils", "Statistics"]
git-tree-sha1 = "ec695822c1faaaa64cee32d0b21505e1977b4809"
uuid = "92ad9a40-7767-427a-9ee6-6e577f1266cb"
version = "0.1.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

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

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLFlowClient]]
deps = ["Dates", "FilePathsBase", "HTTP", "JSON", "ShowCases", "URIs", "UUIDs"]
git-tree-sha1 = "32cee10a6527476bef0c6484ff4c60c2cead5d3e"
uuid = "64a0f543-368b-4a9a-827a-e71edb2a0b83"
version = "0.4.4"

[[deps.MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBalancing", "MLJBase", "MLJEnsembles", "MLJFlow", "MLJIteration", "MLJModels", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "Reexport", "ScientificTypes", "StatisticalMeasures", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "981196c41a23cbc1befbad190558b1f0ebb97910"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.20.2"

[[deps.MLJBalancing]]
deps = ["MLJBase", "MLJModelInterface", "MLUtils", "OrderedCollections", "Random", "StatsBase"]
git-tree-sha1 = "e4be85602f010291f49b6a6464ccde1708ce5d62"
uuid = "45f359ea-796d-4f51-95a5-deb1a414c586"
version = "0.1.3"

[[deps.MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LearnAPI", "LinearAlgebra", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "Reexport", "ScientificTypes", "Serialization", "StatisticalMeasuresBase", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "6d433d34a1764324cf37a1ddc47dcc42ec05340f"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "1.0.1"
weakdeps = ["StatisticalMeasures"]

    [deps.MLJBase.extensions]
    DefaultMeasuresExt = "StatisticalMeasures"

[[deps.MLJDecisionTreeInterface]]
deps = ["CategoricalArrays", "DecisionTree", "MLJModelInterface", "Random", "Tables"]
git-tree-sha1 = "8059d088428cbe215ea0eb2199a58da2d806d446"
uuid = "c6f25543-311c-4c74-83dc-3ea6d1015661"
version = "0.4.0"

[[deps.MLJEnsembles]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Distributed", "Distributions", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatisticalMeasuresBase", "StatsBase"]
git-tree-sha1 = "94403b2c8f692011df6731913376e0e37f6c0fe9"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.4.0"

[[deps.MLJFlow]]
deps = ["MLFlowClient", "MLJBase", "MLJModelInterface"]
git-tree-sha1 = "89d0e7a7e08359476482f20b2d8ff12080d171ee"
uuid = "7b7b8358-b45c-48ea-a8ef-7ca328ad328f"
version = "0.3.0"

[[deps.MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random", "Serialization"]
git-tree-sha1 = "991e10d4c8da49d534e312e8a4fbe56b7ac6f70c"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.6.0"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "381d99f0af76d98f50bd5512dcf96a99c13f8223"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.9.3"

[[deps.MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Combinatorics", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "RelocatableFolders", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "10d221910fc3f3eedad567178ddbca3cc0f776a3"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.16.12"

[[deps.MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase", "StatisticalMeasuresBase"]
git-tree-sha1 = "44dc126646a15018d7829f020d121b85b4def9bc"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.8.0"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "3504cdb8c2bc05bde4d4b09a81b01df88fcbbba0"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.3"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "f512dc13e64e96f703fd92ce617755ee6b5adf0f"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.8"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "ac86d2944bf7a670ac8bf0f7ec099b5898abcc09"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.8"

    [deps.NNlib.extensions]
    NNlibAMDGPUExt = "AMDGPU"
    NNlibCUDACUDNNExt = ["CUDA", "cuDNN"]
    NNlibCUDAExt = "CUDA"
    NNlibEnzymeCoreExt = "EnzymeCore"

    [deps.NNlib.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    cuDNN = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenML]]
deps = ["ARFFFiles", "HTTP", "JSON", "Markdown", "Pkg", "Scratch"]
git-tree-sha1 = "6efb039ae888699d5a74fb593f6f3e10c7193e33"
uuid = "8b6db2d4-7670-4922-a472-f9537c81ab66"
version = "0.3.1"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f6f85a2edb9c356b829934ad3caed2ad0ebbfc99"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.29"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.PrettyPrinting]]
git-tree-sha1 = "22a601b04a154ca38867b991d5017469dc75f2db"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "3f43c2aae6aa4a2503b05587ab74f4f6aeff9fd0"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9ebcd48c498668c7fa0e97a9cae873fbee7bfee1"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "75ccd10ca65b939dab03b812994e571bf1e3e1da"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "3.0.2"

[[deps.ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

[[deps.ScikitLearnBase]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "7877e55c1523a4b336b433da39c8e8c08d2f221f"
uuid = "6e75b9c4-186b-50bd-896f-2d2496a4843e"
version = "0.5.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "5ef59aea6f18c25168842bded46b16662141ab87"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.7.0"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.StatisticalMeasures]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Distributions", "LearnAPI", "LinearAlgebra", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "StatisticalMeasuresBase", "Statistics", "StatsBase"]
git-tree-sha1 = "b58c7cc3d7de6c0d75d8437b81481af924970123"
uuid = "a19d573c-0a75-4610-95b3-7071388c7541"
version = "0.1.3"

    [deps.StatisticalMeasures.extensions]
    LossFunctionsExt = "LossFunctions"
    ScientificTypesExt = "ScientificTypes"

    [deps.StatisticalMeasures.weakdeps]
    LossFunctions = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
    ScientificTypes = "321657f4-b219-11e9-178b-2701a2544e81"

[[deps.StatisticalMeasuresBase]]
deps = ["CategoricalArrays", "InteractiveUtils", "MLUtils", "MacroTools", "OrderedCollections", "PrecompileTools", "ScientificTypesBase", "Statistics"]
git-tree-sha1 = "17dfb22e2e4ccc9cd59b487dce52883e0151b4d3"
uuid = "c062fc1d-0d66-479b-b6ac-8b44719de4cc"
version = "0.1.1"

[[deps.StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "30b9236691858e13f167ce829490a68e1a597782"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.2.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "e579d3c991938fecbb225699e8f611fa3fbf2141"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.79"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "323e3d0acf5e78a56dfae7bd8928c989b4f3083e"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.3"

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
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═dff9e5b0-959b-11ee-2223-419029c55758
# ╟─9f348928-ffc6-451f-a8bc-d197c4d8a611
# ╟─dc6658b0-e0f4-48d0-a58b-6ef2921998f6
# ╟─390aa058-7b07-4ec0-aacd-d43b43c2d61a
# ╟─6ceb287c-fec1-43a3-9822-49bef5003607
# ╟─0da6aa89-d6d7-47fa-9cf1-7425d806ca8d
# ╠═5bc9dbcf-841b-4bb6-b438-6dcce5d662ab
# ╠═59ddc03e-b710-4848-bf94-6fd1d93086fb
# ╟─54dec9c9-31a9-42ce-98c3-bdce214415ed
# ╠═a180eec7-1da4-4900-8be2-3dd7cc2cf24e
# ╟─054f9a1d-1521-4131-8ed8-2e2b2179cca0
# ╠═80ab5f06-dec1-4eae-996f-397832d5a83f
# ╟─eca076c5-5dcd-4536-92d3-62ead66632eb
# ╠═daef6a63-5eea-441c-ad66-6d4f11f885a0
# ╟─05e3e86b-b61c-4c6f-8a0e-b9840c17d7e8
# ╠═3b0ac5de-0c27-448b-8957-48f9347a3ddc
# ╟─769ce8e1-cf8c-47b7-b921-00c2329af64a
# ╠═dcaf72e8-43f2-4e8c-b777-4818d4fd281d
# ╟─63049bd2-d1b2-4040-8c21-53f556e10b10
# ╠═4b05e29d-f70b-4907-8b16-450d434828cb
# ╟─cf7f5aeb-e198-458e-bb2d-697451ce01a2
# ╠═e3e3cd08-cc48-4a4f-b199-d860f0a659f1
# ╠═0561ca5d-7f5f-4e27-a33f-553458a0c70a
# ╠═d9e87f1d-e1a7-4707-97ae-bfce36c9880d
# ╠═e6dbe3ed-7686-42c1-b6e4-f67e07747ee3
# ╠═cf1c3ee6-d0b1-4c24-8716-f28d193f4622
# ╠═492fc857-69d0-48ed-9d72-6cd280f4ab79
# ╠═2408cdbe-32ff-4703-9a7f-d019c021bd43
# ╟─aa39c47e-7eb5-4295-9649-d95c040cc3e6
# ╠═2c2db3b4-b761-4c94-9aba-bbfb75fecde6
# ╠═b33efe80-feb3-4933-88ba-332bc8cb648a
# ╠═8566fb19-726a-4d3b-8171-2607ce74dbe5
# ╟─66ef0379-d1af-4b3b-b2a7-144ee76f5424
# ╠═125eeff4-3204-4492-b68d-51354f4e7dd5
# ╠═f81a805a-ab4a-4cb1-bff9-3db3f2cf2551
# ╠═e3fcaf6e-d1bd-41d4-8ac9-a1f1f7ff7b26
# ╠═23b28bfe-15b9-4eb1-8a17-252b2ae494ea
# ╟─cac7a664-4fdf-4de4-96e5-14992586ebc1
# ╠═83a87a73-e5a0-459a-a7e5-d0da95abc7dd
# ╠═e3e579f6-4df1-4e1e-a4bc-42579521871a
# ╠═69516ebe-ad2c-4bdd-8d09-f612fc4eff68
# ╠═a33a1c89-823d-48d5-b5a8-376a144c346a
# ╠═6068432b-9d44-4828-b117-3186ddcc23e9
# ╠═95a98d49-137d-4394-9e0e-ca841181c4fd
# ╠═4f13dff3-9d90-458c-8d4d-e97f4f33206a
# ╠═d7a2e839-bc72-449e-8018-e241d2c19ca8
# ╠═024ef752-157a-4c75-a77d-16fd8a0fc884
# ╠═aff69643-b08f-45c3-a79f-a046d7c95263
# ╠═eb28592b-d1db-420d-b888-1a75a2b56382
# ╠═30af5722-139b-4949-92f8-cd05b64ee430
# ╠═3c3b607a-bdb0-48c1-86e9-23ad39d3d253
# ╟─ddd9ec16-ebf0-433f-a100-39963da74a47
# ╠═fac7ec8c-1e36-476c-a95a-a72953f2b7c7
# ╠═d248536a-48fe-487d-bc41-7ba54ec9c39f
# ╠═3bbcf0f5-0c7c-4c7a-9151-1d43f878da27
# ╠═86fb646b-616b-4df8-ac4c-e4f08082e947
# ╠═1e033c2f-9c78-41ab-aaa9-8422296ca8b3
# ╟─364d5f97-9775-44fe-8af2-7681cd9fdd47
# ╠═6c3cf0e1-6668-44cf-893e-0d5f239f8bfa
# ╟─a1d2b19e-8a88-4591-a518-cea603ff3063
# ╠═12f7dfbc-b709-49a6-92c5-d0f4911d1eeb
# ╟─434c064b-09e9-4b8a-8cfc-3499d0bc54b5
# ╠═d78f506b-363a-46c3-8df5-e9293d3e367f
# ╟─d86277c1-14a6-4d23-8050-bc5f040c8bed
# ╠═798848dc-1006-45a3-a278-257f4d38cf65
# ╠═f9f52d0c-12bd-4bf8-b094-3fd05113e841
# ╟─3cf392fc-142d-4a66-88e1-d8005fe9beaf
# ╠═c17359e8-ef79-4df6-a1dc-c9f80b08c3bf
# ╟─2963379c-5ca4-4019-9a97-7487a3b30fa4
# ╠═c47d9f05-aa06-4e56-bc96-5322469a3365
# ╠═6bbab1ff-20ca-40b5-b12c-7a8185eaad74
# ╟─242ffdf0-8d93-4048-ace1-3954200e9e9f
# ╠═169dac4a-8880-4be4-a71f-599734cf0e01
# ╠═b8ba286d-3b8a-4896-8e16-ab8ee2149049
# ╠═4254c86e-534d-4386-8855-af07fff4006e
# ╠═130f7560-7b3b-4c3c-a2f0-8838a0e38f6d
# ╠═523cd9cd-0856-4fb8-9272-c9a64ba3c1d0
# ╠═289a3f94-abae-46e7-9a5a-1f5f58b3094f
# ╠═77dfeb9e-5d70-4571-a0af-8180366db755
# ╟─29edd637-bcbc-44e7-b1b0-859074e52a05
# ╠═2e380486-3768-4712-9b26-6d308984bc28
# ╠═195bc721-ee69-441b-b5c5-984fea174636
# ╟─47177e82-0cd6-4b6c-b5f4-19f595f98756
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
