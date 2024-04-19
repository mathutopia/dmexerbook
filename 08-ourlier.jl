### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ b1a2133e-fdcf-11ed-0ea5-adbe7e8f4872
begin
using OutlierDetectionNeighbors  ,Plots,CSV,DataFrames, MLJ, PlutoUI
end

# ╔═╡ 8edf52c4-9f1c-476b-8d09-1a847dc001a0
begin
function box(color::Symbol = :green, title::Union{String,Nothing} = nothing)
	#@assert color in [:green, :yellow, :blue, :red]
	function green(text)
   		Markdown.MD(Markdown.Admonition("tip", ifelse(isnothing(title),"✍🏻️ 插播", title), [text])) # 绿色
	end

	function yellow(text)
		Markdown.MD(Markdown.Admonition("warning",ifelse(isnothing(title),"👀 注意", title),  [text])) # 黄色
	end

	function blue(text)
		Markdown.MD(Markdown.Admonition("hint", ifelse(isnothing(title),"👁️ 提示", title), [text])) # 蓝色
	end

	function red(text)
		Markdown.MD(Markdown.Admonition("danger", ifelse(isnothing(title), "🚦 警告", title), [text])) # 红色
	end

	function other(text)
		Markdown.MD(Markdown.Admonition("info", ifelse(isnothing(title),"", title), [text])) # 默认
	end

	if color == :green
		return green
	elseif color == :yellow
		return yellow
	elseif color == :blue
		return blue
	elseif color == :red
		return red
	else
		return other
	end
	
end
# ====================================================
#如果直接用名字， 相当于提供信息。
box(text::Markdown.MD) = box(:green,nothing)(text)

# 如果直接用hint， 相当于提示：
hint(text::Markdown.MD) = box(:blue,nothing)(text)
hintbox(text::Markdown.MD) = box(:blue,"")(text)
# 如果直接用无参数box， 相当于给出一个真正的框。
box() = box(:green, "")
# 只给颜色， 用默认标题， 不需要标题， 需要用空字符串表示
box(color::Symbol) = box(color, nothing)
box(title::String) = box(:green, title) # 只给文本， 默认就是绿色
# 文本和颜色，可以交换着给
box(title::String, color::Symbol) = box(color, title)
# 如果给两个Symbol， 则后一个当成标题
box(color::Symbol, title::Symbol) = box(color, String(title))
# 如果给两个Stiring， 则前一个当成颜色
box(color::String, title::String) = box(Symbol(color), title)

end;


# ╔═╡ 618378a2-2c91-4d49-9018-66c3860f9f0e
PlutoUI.TableOfContents(title = "目录", indent = true, depth = 4, aside = true)

# ╔═╡ 9f76c5c6-8b05-4236-b37b-1aba15fc75ae
 html"<font size=\"80\">实验7 异常检测</font>"

# ╔═╡ 034a8c13-65f3-47b8-b490-27fc665983ef
md"""
**目的与要求**
	1. 了解OutlierDetection.jl包中存在哪些异常检测模型
	2. 掌握异常检测模型的使用与结果解读
	3. 选择1~2个异常检测模型，结合保险欺诈检测数据集， 测试模型效果，并分析结果，撰写报告。
""" |> fenge

# ╔═╡ c6b172d1-beca-4363-aede-0b29d43aa606
md"""
实验目的：
了解异常检测的基本原理与异常因子度量方法
评估不同异常检测算法的性能
掌握异常检测应用
"""

# ╔═╡ e53eb5eb-84f9-4719-91bb-f8019a7e751b
md"""
知识链接：
1.异常检测基本概念
2.基于聚类的异常检测算法

"""

# ╔═╡ 219318af-f095-4d13-a104-46d3008398f9
md"""
实验步骤：
任务1：熟悉常见异常检测模型
了解不同异常检测模型的特点及其在不同环境中的模型类型
任务2：模型训练
选择异常检测模型
选择和整理相关数据
执行异常检测算法
查看异常检测结果
任务3：应用异常检测模型
选定某应用场景（比如欺诈识别），应用异常检测方法（任务2）完成相关任务，查看效果。
分析实验结果：比较不同算法的性能差异，并解释其原因。
可视化分析：例如绘制ROC曲线、精度-召回率曲线等，以更好地理解算法的效果。
"""

# ╔═╡ befdd4f0-c2ea-4300-ad58-80b3ef37b474
md"""
## 1. 搜索异常检测模型
Julia中， 有一个专门的异常检测的包，[OutlierDetection.jl](https://outlierdetectionjl.github.io/OutlierDetection.jl/dev/documentation/installation/)包。更多的内容可参考该包的帮助文档。

不过， 我们并不直接使用异常检测模型， 而是使用MLJ中包含的异常检测模型。 一般来说， MLJ中的模型如果是Detector结尾， 代表该模型是异常检测模型。

下面的代码搜索MLJ中所有的异常检测模型。
"""

# ╔═╡ 1704e12c-3f81-4d34-a9ee-88ae1f572fac
models("Detector")

# ╔═╡ 979a7cc8-1118-4738-8f63-e2885ed3fd29
md"""
## 2. 保险欺诈数据集读取
下面读取乳腺肿瘤（良、恶性）数据分类数据集， 采用CSV.read函数。
这里有一个分析的范例[csdn](https://blog.csdn.net/weixin_44615820/article/details/88841309)

1. Sample code number id number（患者编号）
2. Clump Thickness 1 - 10（肿瘤厚度）
3. Uniformity of Cell Size 1 - 10 （细胞大小均匀性）
4. Uniformity of Cell Shape 1 - 10（细胞形状均匀性）
5. Marginal Adhesion 1 - 10（边缘粘附力）
6. Single Epithelial Cell Size 1 - 10（单上皮细胞大小）
7. Bare Nuclei 1 - 10（裸核）
8. Bland Chromatin 1 - 10（染色质的颜色）
9. Normal Nucleoli 1 - 10（核仁正常情况）
10. Mitoses 1 - 10（有丝分裂情况）

class是分类情况，2为良性，4为恶性

"""

# ╔═╡ 8ab684d8-a652-425d-9c45-14261222e01a
trains = CSV.read("data/brcancer.csv", DataFrame)

# ╔═╡ f0d0add7-ff03-4667-879c-a64d960fb6f4
md"""
## 3. 特征选择
由于模型要求输入连续特征， 下面选择部分满足条件的特征，用于后续构建新的数据集。
"""

# ╔═╡ 52f62a39-8a9e-45e7-aefc-b8d33968d2aa
selected_feats = [:age ,:customer_months , :policy_state , :insured_sex , :insured_education_level ,  :property_claim ,:insured_occupation ,:insured_hobbies]

# ╔═╡ e27fedb5-4327-4ac5-9345-b7ff8cb84c90
md"""
## 4 数据预处理
### 4.1 构建预处理模型
"""

# ╔═╡ a21c24bd-fdaf-4e54-98ab-788659d2f202
md"""
这个模型用于将数据从训练集直接准备成连续型数据。 该模型实现对数据集实施3个操作： 

	1. 选择特征
	2. 类型转换
	3. 连续编码
"""

# ╔═╡ c13ee636-ef0e-4483-8aa1-6c970854baec
pipe1 = FeatureSelector(features=selected_feats) |> (x -> coerce(x,  Count => Continuous, Textual => Multiclass)) |> ContinuousEncoder() 

# ╔═╡ c5974bfe-48af-472a-a098-c352f3e4a088
md"""
### 4.2 模型绑定机器
"""

# ╔═╡ 46fd04f9-e556-40ae-b8c7-c61cf8751b0a
mach = machine(pipe1, trains)

# ╔═╡ 4d001c9a-a1c8-4dcb-b7dd-1fc3fc41df22
md"""
### 4.3 训练模型（拟合机器）
这个不存在指定训练集与测试集的问题， 因为是数据变换。
"""

# ╔═╡ a31cc9e6-c836-4530-ad2f-ef10bdde34b6
fit!(mach)

# ╔═╡ 790d25dd-b48a-4034-996a-c5b8fe35c1af
md"""
### 4.4 转换数据
"""

# ╔═╡ e0dc4ce5-0c55-41bb-b284-d1c2e93d193d
tx = MLJ.transform(mach, trains)

# ╔═╡ 1b6374c9-c86b-4392-ab55-b69a44dfd46e
md"""
## 5. 构建异常检测的模型
### 5.1 加载并构建模型实例
"""

# ╔═╡ b203f03b-0964-4973-ae66-40bb7b2d24a8
knnd = (@load KNNDetector pkg=OutlierDetectionNeighbors verbosity=0)()

# ╔═╡ 1d605e65-9d35-40d7-809f-8642fb2ac6b2
knnd

# ╔═╡ c07401cb-e15d-4275-8185-217109dd725a
md"""
### 5.2 构建异常检测机器
将异常检测模型和上面准备好的数据进行绑定，形成机器。
"""

# ╔═╡ 319d913f-ef26-46b1-a09a-cee73af4cc7c
machd = machine(knnd, tx)

# ╔═╡ a5a3a0e2-da33-4567-9435-f656c4c83008
md"""
### 5.3 拟合机器
注意， 还是没有划分训练集合测试集。 因为我只打算通过这个算法计算一下各个样本的离群得分， 并不打算用这个模型去做分类。 如果你打算用异常检测模型去做分类的话， 最好划分训练集、测试集去评估一下模型。
"""

# ╔═╡ ed722e00-79ef-4de4-99d3-ccc1595fc29b
fit!(machd)

# ╔═╡ d1a52cbd-243f-4913-b3e9-8dc75ea52a77
md"""
### 5.4 计算离群因子（得分）
"""

# ╔═╡ c00a78ab-1df1-4520-aff1-fe083790dac4
scores = MLJ.transform(machd)

# ╔═╡ e61e43d6-b1af-458e-a42c-baf5ba13319e
md"""
## 6. 模型结果可视化
"""

# ╔═╡ 865baf0e-dc4d-45e5-8ba4-30912b0ba5ed
md"""
下面直接画出各个样本的离群点得分图。 从图中可以看出， 不同样本的离群点得分存在较大差异。 其中，存在部分样本，具有较大的离群点得分。
"""

# ╔═╡ 9a663992-122f-4533-881a-fb177299f187
plot(scores)

# ╔═╡ 787cf8db-a3bf-4a60-9eff-513ac9c13995
md"""

上面的图明显不是我们要的。 为了得到划分离群值的阈值， 我们需要将离群点得分图做一定修改， 使其从高到低呈现。 这可以通过将得分向量排序实现。
"""

# ╔═╡ fa72f1af-bbaa-45e6-b39e-3fc7c2bee347
md"""
sortperm获得按逆序排序后的顺序。
"""

# ╔═╡ 0b468f2d-9860-4803-bf61-bc6560c36cde
idx = sortperm(scores, rev = true)

# ╔═╡ d24f1295-a213-4801-8a48-39e944e812a9
plot(scores[idx])

# ╔═╡ 22546d0e-a7c4-46f9-87c5-af34ff14d2d0
md"""
从上面的图， 可以大致看到曲线的变化， 可以认为离群因子大概300以上可以认为是异常值。

当然， 我们也可以认为有5%的数据是离群点。 也就是从大到小排序大概35号样本之前都是离群点。 下面可以看到35号样本的得分是253.
"""

# ╔═╡ 3ccc9e0e-1bbe-4910-ac91-5b2b532fdf82
scores[idx[35]]

# ╔═╡ f7af7303-d33c-4500-a5a0-18cdf77b49b5
md"""
所有的离群点的编号是：
"""

# ╔═╡ 625c9194-a344-4105-868c-552fede14db9
idx[1:35]

# ╔═╡ efc49986-bd66-4538-bc16-cdbb3961ff3e
md"""
可以统计一下， 离群点中欺诈的比例和整体的欺诈比例， 看看离群点中是否欺诈比较多。 从而可以试试，是否用离群点检测的方式去做欺诈预测。 不过， 从结果来看， 似乎很不理想。
"""

# ╔═╡ 2baae936-4fee-4450-8b2a-403db785b5fb
sum(trains[idx[1:35], :fraud])/35

# ╔═╡ dedbc8f4-5dd3-4aa8-9883-11e9bbe788a2
sum(trains[:, :fraud])/700

# ╔═╡ 8d8f11fa-320a-4daa-a714-5b69e6478107
md"""
当然， 上面只是我们随便选择的模型， 随便选取的特征。 所以效果不好也能理解。 不过， 用离群值预测欺诈的结果必然不理想吧。
"""

# ╔═╡ 1d3dca0e-56d7-4e97-aa64-5c7458852a1b
md"""
# 作业要求
对天池竞赛的题目， 选择你的认为最好的异常检测模型，构建一个分类模型， 提交竞赛结果， 并将相关代码和竞赛截图提交。 请在两周内提交作业。
"""

# ╔═╡ 961ec1d0-3973-4f4f-b846-120a32dbcd9d
begin
tip(text) = Markdown.MD(Markdown.Admonition("tip", "💡 总结", [text])) # 绿色
hint(text) = Markdown.MD(Markdown.Admonition("hint", "💡 提 示", [text]))
attention(text) = Markdown.MD(Markdown.Admonition("warning", "⚡ 注 意", [text])) # 黄色
danger(text) = Markdown.MD(Markdown.Admonition("danger", "💣 危 险", [text])) # 红色
synr(text) = Markdown.MD(Markdown.Admonition("tip", "📘 实验内容、要求与步骤", [text])) # 蓝色
end;

# ╔═╡ 3d41879a-c594-4260-81b4-0f7313a3b7dc
md"""
从上面可以看到， MLJ中可以找到28个异常检测模型。虽然模型很多， 但并非每个模型都适合所有的数据。在采用相应模型之前， 要看清楚模型对数据数据的要求。

假设模型用这个模型， 
```julia
name = "KNNDetector"
package_name = "OutlierDetectionNeighbors"
```
可以看到该模型的输入数据类型要求是：
```julia input_scitype = 
Union{Table{<:AbstractVector{<:Continuous}}, AbstractMatrix{<:Continuous}}
```

这样,如果我们要使用这个模型， 需要将特征转换为连续特征。 由于数据集中通常不是所有特征都满足这个条件， 所以我们需要选择我们要的特征。
""" |> attention

# ╔═╡ 4dadc428-3189-4d34-888f-82a75c665a5a
md"""
通过上面的运算， 我们将数据集整理成了异常检测模型需要的数据形式。接下来可以在整理好的数据集上做异常检测。
""" |> tip

# ╔═╡ 85a6f723-9b57-4004-bca7-b44ed7bc9214
md"""
1. 竞赛题的数据格式多样， 有些算法可能跑不起来， 需要选择能跑起来的。

2. 最好是在测试集上先评估一下异常检测的效果， 找到相对较好的异常检测算法和用于异常检测的特征，再将异常检测算法应用于测试集。

3. 如果不能输出概率结果， 预测结果可以直接是不同类别的概率分别0和1.
""" |> hint

# ╔═╡ 0674b2f7-9a48-493b-8daf-0c968666ff39
TableOfContents(title="实验大纲")

# ╔═╡ Cell order:
# ╟─8edf52c4-9f1c-476b-8d09-1a847dc001a0
# ╠═b1a2133e-fdcf-11ed-0ea5-adbe7e8f4872
# ╠═618378a2-2c91-4d49-9018-66c3860f9f0e
# ╟─9f76c5c6-8b05-4236-b37b-1aba15fc75ae
# ╟─034a8c13-65f3-47b8-b490-27fc665983ef
# ╠═c6b172d1-beca-4363-aede-0b29d43aa606
# ╠═e53eb5eb-84f9-4719-91bb-f8019a7e751b
# ╠═219318af-f095-4d13-a104-46d3008398f9
# ╠═befdd4f0-c2ea-4300-ad58-80b3ef37b474
# ╠═1704e12c-3f81-4d34-a9ee-88ae1f572fac
# ╠═3d41879a-c594-4260-81b4-0f7313a3b7dc
# ╠═979a7cc8-1118-4738-8f63-e2885ed3fd29
# ╠═8ab684d8-a652-425d-9c45-14261222e01a
# ╟─f0d0add7-ff03-4667-879c-a64d960fb6f4
# ╠═52f62a39-8a9e-45e7-aefc-b8d33968d2aa
# ╟─e27fedb5-4327-4ac5-9345-b7ff8cb84c90
# ╟─a21c24bd-fdaf-4e54-98ab-788659d2f202
# ╠═c13ee636-ef0e-4483-8aa1-6c970854baec
# ╟─c5974bfe-48af-472a-a098-c352f3e4a088
# ╠═46fd04f9-e556-40ae-b8c7-c61cf8751b0a
# ╟─4d001c9a-a1c8-4dcb-b7dd-1fc3fc41df22
# ╠═a31cc9e6-c836-4530-ad2f-ef10bdde34b6
# ╟─790d25dd-b48a-4034-996a-c5b8fe35c1af
# ╠═e0dc4ce5-0c55-41bb-b284-d1c2e93d193d
# ╟─4dadc428-3189-4d34-888f-82a75c665a5a
# ╟─1b6374c9-c86b-4392-ab55-b69a44dfd46e
# ╠═b203f03b-0964-4973-ae66-40bb7b2d24a8
# ╠═1d605e65-9d35-40d7-809f-8642fb2ac6b2
# ╟─c07401cb-e15d-4275-8185-217109dd725a
# ╠═319d913f-ef26-46b1-a09a-cee73af4cc7c
# ╟─a5a3a0e2-da33-4567-9435-f656c4c83008
# ╠═ed722e00-79ef-4de4-99d3-ccc1595fc29b
# ╟─d1a52cbd-243f-4913-b3e9-8dc75ea52a77
# ╠═c00a78ab-1df1-4520-aff1-fe083790dac4
# ╟─e61e43d6-b1af-458e-a42c-baf5ba13319e
# ╟─865baf0e-dc4d-45e5-8ba4-30912b0ba5ed
# ╠═9a663992-122f-4533-881a-fb177299f187
# ╟─787cf8db-a3bf-4a60-9eff-513ac9c13995
# ╟─fa72f1af-bbaa-45e6-b39e-3fc7c2bee347
# ╠═0b468f2d-9860-4803-bf61-bc6560c36cde
# ╠═d24f1295-a213-4801-8a48-39e944e812a9
# ╟─22546d0e-a7c4-46f9-87c5-af34ff14d2d0
# ╠═3ccc9e0e-1bbe-4910-ac91-5b2b532fdf82
# ╟─f7af7303-d33c-4500-a5a0-18cdf77b49b5
# ╠═625c9194-a344-4105-868c-552fede14db9
# ╟─efc49986-bd66-4538-bc16-cdbb3961ff3e
# ╠═2baae936-4fee-4450-8b2a-403db785b5fb
# ╠═dedbc8f4-5dd3-4aa8-9883-11e9bbe788a2
# ╟─8d8f11fa-320a-4daa-a714-5b69e6478107
# ╟─1d3dca0e-56d7-4e97-aa64-5c7458852a1b
# ╟─85a6f723-9b57-4004-bca7-b44ed7bc9214
# ╟─961ec1d0-3973-4f4f-b846-120a32dbcd9d
# ╟─0674b2f7-9a48-493b-8daf-0c968666ff39
