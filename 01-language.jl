### A Pluto.jl notebook ###
# v0.19.41

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 9b0ff6f0-80be-445f-ba53-5c0d38c2a699
using PlutoUI

# ╔═╡ d336f6a2-a0dc-48ff-8e9a-39e0f2a0062f
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

# ╔═╡ 5a64e73d-d7b8-4fa3-b81a-3154ae5a122b
md"""
实验1 Julia安装与入门
""" |> shiyan

# ╔═╡ dc1a4db7-a9fd-49dd-b135-10c7099463b6
md"""
 # 目的与要求
1. 掌握Julia软件的安装与基本使用
2. 掌握Pluto的安装与使用
3. 掌握Julia语言的基础语法
""" |> box()

# ╔═╡ cfb64224-5ef7-4300-a6e0-f38ad8e68cac
md"""
# ===第一部分 软件安装===
"""

# ╔═╡ ec6b4326-88a1-4375-a828-3e28ca7b2063
md"""
## 安装REPL环境
虽然是编译型的语言， 但Julia语言提供了一个类似R语言的控制台。 其安装过程非常简单， 只需按照如下步骤依次操作即可。

1. 请根据自己的电脑系统， 到[**Julia官网**](https://julialang.org/downloads/)下载最新版本的相应软件。下面假定是windows系统。

2. 双击下载的exe文件，选择安装路径（或者采用默认的安装路径），其余都是默认就行。

3. 安装成功之后，桌面上会出现Julia图标。
5. 双击图标打开Julia控制台， 通常叫做**REPL环境**。REPL是“Read–Eval–Print Loop”(读取-求值-打印-循环)的缩写,是一种简单的、交互式的编程环境。

下面是一个打开的REPL环境的图片。 图中的 `julia>` 提示当前是Julia语句的输入模式， 在该模式下， 在光标处输入语句，回车之后就可以看到语句执行的结果。

"""

# ╔═╡ 02124a75-a225-4b7d-9b11-f22c5022a9a5
LocalResource("img/repl.png")

# ╔═╡ 4edc479e-ea0e-4e87-975b-35ac93cc6314
md"""
## 安装Pluto包
Pluto是一个基于Julia的科学计算环境， 类似Jupyte notebook， 但存在一些设计上的显著差异。 本教程关于Julia的操作都在Pluto中完成。 下面介绍如何安装Pluto环境， 具体可以参考下面的视频。

Pluto是一个Julia的包（package）， 其安装只需要
1. 在REPL环境中， 将REPL切换到包安装模式（在Julia模式下，输入**英文状态**的右中括号 ]。）
2. 在包模式下（提示符： `(@v1.9) pkg>`, 不同版本会稍有不同），执行`add Pluto`就可以了（你的安装信息可能跟视频中的不同， 视频中是因为已经安装了）。
3. 安装完成之后， 通过输入删除符号（Backspace）切换到Julia语句模式下， 通过执行
```julia
using Pluto
Pluto.run()
```
两条语句即可启动Pluto环境。默认情况下，Pluto会打开一个网页。
"""



# ╔═╡ aaafcdbe-a5e4-44da-bb6b-6a2d08c61602
md"""
## Pluto的使用
由于Pluto是本教程的关键计算环境， 下面的视频简要介绍了一下Pluto的使用。 更多使用的方法， 可以参考Pluto提供的官方notebook。
"""



# ╔═╡ 51f50e0a-e271-4448-b054-4c813dd2f55f
md"""
# ===第二部分 Julia基础===
"""

# ╔═╡ 6a64ae31-96b9-4eeb-a696-23859c898481
md"""
# 1 基本概念
"""

# ╔═╡ f0e96543-bbd5-4095-89e4-e11f510c2d12
md"""
本部分粗略的摘录了Julia的基本语法，以方便对后续实验的理解。 不熟悉Julia 的同学可以先粗略地通读该教程， 以大致了解基本概念与操作。由于不是Julia语法书，相关内容将尽量保持简洁， 如果想要深入了解详细内容可以查阅[官方文档](https://docs.julialang.org/en/v1/)。
"""

# ╔═╡ 167ee46b-e00f-406a-aa9e-b0d932641611
md"""
## 变量与值
在Julia中， 变量是与值关联(或绑定)的名称。 值是一个具有类型（Type）的对象， 占用一定的内存空间， 比如数字、字符串等等。 通常， 可以用**赋值操作符（=）**实现将一个值和对应的变量关联起来。 例如:
```julia
	# 变量x绑定数值10
	julia> x = 10
	10
	# 用变量x绑定的数字做运算
	julia> x + 1
	11
	# 重新绑定x的值为一个表达式运算的结果
	julia> x = 1 + 1
	2
	# 也可以把变量x绑定到其他的数据类型上去（比如字符串）
	julia> x = "Hello World!"
	"Hello World!"
```
"""

# ╔═╡ bf4cc08f-e9ba-460e-bf86-e6e0f064fecb
md"""
## 变量命名规则
"""

# ╔═╡ 36ce4558-39b7-4c2e-9e78-4f0ecbdfae41
md"""
很多语言要求变量名只能是字母数字下划线构成， 在julia中，你可以使用**几乎所有可能的符号做变量名（变量名必须以字母(A-Z或a-z)、下划线或大于00A0的Unicode码点子集开头，其后可以跟几乎所有的字符。** 
"""

# ╔═╡ 5a17111d-845c-4c70-b275-8b1318fc1a40
md"""
# 2 基本数据类型
"""

# ╔═╡ 7fc75f1d-d3c4-435d-a6d3-9a9f453e999c
md"""
## 2.1 数值类型
数字是我们从小的开始学习的概念， 从最开始的整数到，有理数， 实数， 复数， 我们接触了各种数值的概念。 在程序语言中， 数值是通常最简单、最基础的一种值。 在Julia中， 数值具有丰富的类型， 罗列部分如下：

- 布尔类型：Bool
- 有符号整数类型： BigInt、Int8、Int16、Int32、Int64和Int128
- 无符号整数类型： UInt8、UInt16、UInt32、UInt64和UInt128
- 浮点数类型： BigFloat、Float16、Float32和Float64

    将数值细分为不同的类型是有意义的， 不仅能减少数据的存储空间， 还可以提高数据的计算效率。 当然， 如果你觉得处理这么多数据类型很麻烦， 你也可以不管数据类型。 Julia会自动选择默认的数据类型。 比如， 通常整数会当成Int64的类型（在64位的机器里）， 而带了小数点的有理数会当成Float64类型。

可以使用`typeof`函数查看一个值的类型。 比如（在64位的机器上）
```julia
julia> typeof(10)
Int64

julia> x = 10
10

julia> typeof(x)
Int64

julia> typeof(1.2)
Float64
```
注意： 变量只是一个名字， 本身并没有类型。 一个变量的类型通常指的是变量所绑定的值的类型。
"""

# ╔═╡ 04ce6f55-1b44-4457-9b2a-f55383e83acd
md"""
### 类型转化
如果你需要的是某种特定的类型， 可以采用如下方式获得。
- **类型名（数字或数字变量）**
- **变量::类型名 = 数字**

```julia
julia> x = Int16(8)
8

julia> typeof(x)
Int16

julia> y::Int8 = 10
10

julia> typeof(y)
Int8
```
"""

# ╔═╡ 8f5cfec9-5c67-4c72-86f0-1ec62215e924
md"""
上面的两个冒号`::`表示**类型注释符**， 用于告诉系统左边的变量类型是双冒号之后的类型。
"""

# ╔═╡ fad5f0b9-da41-4123-bb91-51500a57dea5
md"""
字符串在数据分析中一种常用应用是： 我们读取的数据可能是字符串格式， 需要将其转换为数字。常使用的函数是`parse(type, str)`， 这个函数通常用于类型之间的转换。
"""

# ╔═╡ 33a162b4-21dd-40f5-b1fc-f0315b9750d3
md"""
### 基本运算与运算符
"""

# ╔═╡ 35fbe418-4bd5-4dee-a98d-9e976a8cb3d9
md"""
这里主要是总结一下Julia中的常见操作符，也称运算符（Operator）。 Julia中的运操作符是用于对变量和值执行操作的数学符号， 这些符号通常用来进行算术和逻辑计算。 操作符对其执行操作的变量称为操作数(Operands)。 比如，在表达式
`a + b` 中， a和b就是操作数，而 `+` 就是操作符, 以下是四种运算符： 

- 算术运算符   
- 比较运算符
- 逻辑运算符 
- 矢量化运算符

"""

# ╔═╡ 292223b0-0549-47d5-9c13-55e4bca029e2
md"""
### 算术运算符
算术运算符是一门语言中常见的， 主要包括 + - * /等。

|运算符| 含义 | 用法|
|-----|------|-----|
| + | 求和  | a + b |
| - | 求差  | a - b |
| * | 乘法  | a * b |
| / | 除法  | a / b |
| \ | 除法  | a \ b (等价于 b / a) |
| $\div$ | 整除 | a $\div$ b|
| % | 求余数 | a % b|
| ^ | 乘方  | a ^ b|

注意， + - 也可以用作一元运算符， 在变量前添加 + ， 不会改变变量值； 添加 - ， 会将变量变相反数。 上面的$\div$在编辑器中可以通过 \div+[TAB] 键输入。 这也是Julia特殊的地方， 它是完全支持Unicode字符的， 所以我们可以使用类似于数学书写的方式去写各种变量。 以后看到类似的数学符号， 他们都是通过相应的latex符号+ TAB键打印出来的。 你也可以通过复制一个符号， 然后用 `? 符号`的方式在REPL中获得其书写方法帮助， 或者用`@doc 符号`的方式获得相关符号的帮助文档。下面演示的是整除。
下面是一些例子：
"""

# ╔═╡ f699b11c-6d47-4c18-9fef-3136467a090c
7 ÷ 3

# ╔═╡ 5839e72e-8771-4184-a065-2196ba60b2f4
2^3

# ╔═╡ 0b6940b5-9d5e-439d-a974-fa056ee1ad2e
 # 定义变量， 你也可以改变这里的定义, 一次给多个变量赋值， 跟Python类似
a, b = 9, 4

# ╔═╡ 4e8df286-dfb2-4693-9261-64a9bcc9d002
(a + b, a - b, a * b, a / b, a \ b, a \ b == b / a, a ÷ b, a % b, +a, -b)

# ╔═╡ 7019a3b5-f0cb-40fa-8e66-51055af971e8
md"""
每一个算术运算都可以跟赋值符号=结合在一起形成一个更新运算。 比如：
```julia
a += b
```
表示：
```julia
a = a + b
```
一般而言， 一个更新运算表示把左操作数与右操作数做相应运算的结果再赋值给左操作数。
""" |> box(:green, :注意)

# ╔═╡ 4e544be5-4a04-4182-a58e-13bdcd6c517e
md"""
### 比较运算
比较运算主要用于对变量的大小比较，主要有大于、小于、等于，以及衍生的大于等于、小于等于、不等于等6种情况， 比较的结果通常是逻辑值 true 或 false， 常用于 if 语句等逻辑判断场景。 下面是具体的含义和用法：

|运算符| 含义 | 用法|
|-----|------|-----|
|>	| 大于: 左操作数大于右操作数时为 true	| x > y |
|<	| 小于: 左操作数小于右操作数时为 true	| x < y |
|==	| 等于： 左操作数等于右操作数时为 true    | x == y |
|!=, ≠	| 不等于： 左操作数不等于右操作数时为 true 	| x != y or x ≠ y |
|>=, ≥	| 大于或等于: 左操作数大于或等于右操作数时为 true	| x >= y or x ≥ y |
|<=, ≤	| 小于或等于: 左操作数小于或等于右操作数时为 true	| x <= y or x ≤ y |

注意， 上面几个特殊符号对应的latex代码≠ （\ne）, ≥ (\geq), ≤ (\leq) 。 
下面是几个例子：

"""

# ╔═╡ f12ade36-ff61-435b-9a76-e9f739fe79ce
a > b, a < b, a == b, a != b, a >= b, a <= b

# ╔═╡ d5b8e5de-f040-408c-92ac-aed3c3dffe51
md"""
### 逻辑运算符
逻辑运算符主要用于构造复合条件， 多用于程序流程控制。 主要是三种： 与（and）, 或（or）, 非（not）。 具体用法如下：

|运算符| 含义 | 用法|
|---|---|---|
| &&	| 与: 当且仅当两个操作数都是 true 时， 结果为true	| x && y|
|  \|\|	|或： 当至少有一个操作数为true时， 结果为true |	x \|\| y | 
| !	| 非： 将true变为false， false变为true | !x |

下面是几个例子， 其中`isodd`和`iseven`分别用于判断一个数是奇数和偶数。
"""

# ╔═╡ 3540f431-7b50-4ed1-9d66-3cb4568856a2
isodd(a), iseven(b), isodd(a) && isodd(b), isodd(a) || isodd(b), !isodd(a)

# ╔═╡ 27e2d30c-96bb-4a28-ba47-6ea7d9bb3b2d
md"""
### 矢量化的点操作符
点操作符是Julia中实现向量化运算的关键操作符。在R、Python等语言中， 许多运算默认都是向量化的。 但在Julia中， 情况有所不同。 在Julia中， 只要在一个运算的前面加上一个点， 这个运算就变成了向量化的了。 即这个运算会作用到运算对象的每一个元素上。 下面的代码演示两个向量（向量会在后面介绍）的矢量化乘法和幂运算。
"""

# ╔═╡ 88e526c6-cd09-4a75-9bc0-cec5a7a80234
v1 = [1,2,3]; v2 = [4,5,6];

# ╔═╡ a89c40a4-4d12-4fc5-8cb9-75a8e2c9f708
v1 .* v2

# ╔═╡ ff6530fa-8b79-4321-bde4-d42f3de138c5
v1 .^ 2

# ╔═╡ a779ef7b-f4ff-4d01-9f69-6e04d4e224a9
v1 .* v2

# ╔═╡ 5912b3ca-a74b-4174-859c-ed5b4cd669d5
md"""
### 常用数学函数
Julia 预定义了非常丰富的数学函数。一些常用的函数如下：

- 数值类型转换： 主要有T(x)和convert(T, x)。其中，T代表目的类型，x代表源值。
- 数值特殊性判断： 有isequal、isfinite、isinf和isnan。
- 舍入： 有四舍五入的round、向正无穷舍入的ceil、向负无穷舍入的floor，以及总是向0舍入的trunc。
- 绝对值获取： 用于获取绝对值的函数是abs(x)。一个相关的函数是，用于求平方的abs2(x)。
- 求根： 函数sqrt(x)用于求取x的平方根，而函数cbrt(x)则用于求取x的立方根。
- 求指数： 函数exp(x)会求取x的自然指数。另外还有expm1(x)，为接近0的x计算exp(x)-1。
- 求对数： log(x)会求取x的自然对数，log(b, x)会求以b为底的x的对数，而log2(x)和log10(x)则会分别以2和10为底求对数。另外还有log1p(x)，为接近0的x计算log(1+x)。

除了以上函数之外，Julia 的Base包中还定义了很多三角函数和双曲函数，比如sin、cos、atanh、acoth等等。另外，在SpecialFunctions.jl包里还有许多特殊的数学函数。不过这个包就需要我们手动下载了。

通常可以用`@doc 函数名`获取一个函数的帮助文档。
"""


# ╔═╡ f5720acf-2ad6-4836-a349-897657ede9ac
md"""
## 2.2 字符与字符串
### 基本概念
Julia支持Unicode编码， **单引号**包裹的单个值表示字符。 字符串则是用**双引号**，或“**三引号\"\"\"”**包裹（常见于各类文档）。 字符的类型是Char， 字符串的类型是String。
"""

# ╔═╡ 8b84afb0-cb46-462b-abf6-d5411e1e8a71
typeof('我'), typeof('a'), typeof("我爱Julia编程")

# ╔═╡ c0714a91-39b8-4128-bf46-1121909d0559
md"""
### 字符串的常用操作
- `sizeof` 获取字符串（任何对象都可以）占用的字节数。
- `length` 获取字符串的字符数量。
- `*` 字符串拼接， 也可以使用`string`函数。
- [i] 字符串索引(获取第i个字符）， 不过请注意Unicode字符串索引可能引发的问题。
- [i:j] 字符串截取（获取索引号从i到j的所有字符）。
- `$(var)` 用变量var的值插入字符串中。
- occursin, contains 判断一个字符串是否包含某个子串（或模式）
- startswith， endswith 判断字符串是否以某个子串开头或结尾
- first, last 获取字符串前面或结尾的n个字符。
"""

# ╔═╡ a8379370-04e9-4d95-92d0-44eb5be552e7
md"""
下面简单演示字符串的拼接和插值。 其余相关函数的用法请参考文档。可以使用`@doc 函数名`获得相应函数的帮助信息。
```julia
julia> s1 = "Hello"
"Hello"

julia> s2 = "world!"
"world!"

julia> s1 * " " * s2
"Hello world!"

julia> name = "cwl"
"cwl"

julia> s = "Hello $name"
"Hello cwl"
```
"""

# ╔═╡ 2f992c55-3e22-4760-858c-6923a80ea3c2
"good" * "morning"

# ╔═╡ b7fbb4f3-8347-4f66-84b3-72119a857894
contains("JuliaLang is pretty cool!", "Julia")

# ╔═╡ 5d676eff-f5a6-46b4-9bc7-6fa877dca56a
md"""
## 2.3 符号Symbol
符号（Symbol）类型在已解析的julia代码中用于表示标识符的类型， 也经常用作标识实体的名称或标签(例如，作为字典键)。 符号可以使用:操作符构建， 是Julia中支持元编程的关键对象。 

符号跟变量名是不同的东西。变量名绑定了值。访问变量名就是访问相应的值。而符号代表的是被解析的代码（抽象语法树）中的标识符。 每一个变量名都会有一个对应的symbol, 但Symbol不一定是变量。比如一个字典变量中的键。

由于Symbol类型在Julia中很常见， 读者只需要知道符号类型是通过冒号引导构建的对象就行（类似字符串是用双引号构建）。

```julia
julia> x = :name
:name

julia> typeof(x)
Symbol

```
"""

# ╔═╡ d304524f-a6d8-4fe3-9a0c-aa55965f831f
md"""
## 2.4 元组
### 元组构造
**元组(tuple)**是由括号和逗号构建的不可变对象，其中元素可以是任意类型：
```julia
(e1,e2,e3,...)
```
元组的类型是：`Tuple{e1的类型, e2的类型， ...}`。 在很多时候，括号是可以省略的。Julia会把逗号分隔的对象自动构建为元组。 比如， 在需要函数返回多个值时，我们通常将值用逗号分隔， 返回的结果就是一个多个值构成的元组。 

元组可以用位置索引， 但值得注意的是：**Julia中， 索引是从下标1开始的**。
"""

# ╔═╡ b21dedc7-23a2-4e79-84fc-943dd3053fab
t = "ok",15

# ╔═╡ edd18731-64ee-4924-925f-c723ed9ab7ec
typeof(t)

# ╔═╡ 718f6f4a-f337-4cb3-a9f1-e90a32411d8e
t[2]

# ╔═╡ a055cb83-9e64-415a-bd1a-cfa4a2b5b7dc
length(t)

# ╔═╡ 8e01e846-b392-4610-8be1-e15485a74eaf
md"""
### 命名元组(NamedTuple)
命名元组中的“命名”并不是说元组有名字，而是说元组中的每一个元素都拥有自己的名字。例如，下面的学生(student1)元组。
"""

# ╔═╡ 0a4a689d-5a4e-4d5e-a278-beb137a80ac6
student1 = (name="Robert", reg_year=2020, 性别='男')

# ╔═╡ 18cae4b0-0b2a-407a-b8c6-236a631a84a7
typeof(student1)

# ╔═╡ a1d25013-d982-438b-a9be-cb8f2a651a8a
md"""
相对于普通元组， 命名元组的好处是， 提供了一种访问元组元素的新的方式，即  **元组名.元素名**
"""

# ╔═╡ e442bb4c-4470-4415-9247-caffda420bf5
student1.name

# ╔═╡ 7be99f73-40bf-4717-b64b-b4b0e850c364
student1[2]

# ╔═╡ 4ba402a6-2fbe-493d-8de8-266eace85a35
md"""
在构建命名元组时， 经常在括号的前面加上一个分号；， 这是为了避免元组只有一个元素时产生错误。没有分号， 一个元素放进括号还是这个元素， 并不会变成元组。

构建元组时， 最后一个元素后面加一个逗号，不会影响最终的结果。但如果整个元组只有一个元素， 这个逗号就必须要添加了。
""" |> box(:red, :注意)

# ╔═╡ 17e4686d-f9a0-4201-baec-4cc1730b1821
(; xt=3)

# ╔═╡ 7d20bf88-7f1f-4159-88b3-c40d2e671781
(xt=3)

# ╔═╡ 9fa94e04-fdbb-4f05-af6b-9330b3f52ec4
(xt,)

# ╔═╡ 57a03ff9-6fa0-457c-88d4-898a6fde710c
(xt)

# ╔═╡ 1f03b743-60c7-45e1-bba0-1f008697a03e
md"""
## 2.5 Pair对象
一个Pair对象是由两个值构成的对象。 类似于只有一个元素的字典（有key和value）。 用推出符号 `=>`可以构建pair对象。 当然， 也可以用Pair构造： 
```julia
Pair(x, y)
x => y
```
一个pair对象包含一个first元素， 和second元素。 看上去有点像一个元素的命名元组， 但在迭代时， 一个pair对象是一个整体。
"""

# ╔═╡ 1260013b-da66-439a-9a2b-76ccb7b4a132
p1 = "age"=>7

# ╔═╡ 0e00515a-3a2b-45a2-b6b5-a9810de85fd4
typeof(p1)

# ╔═╡ 065f15ad-1cbe-474e-901f-411aefb2e07f
p1.first

# ╔═╡ 6fa90f17-74c4-4ee7-9f1d-ac317c36100d
p1.second

# ╔═╡ cfab338f-19b1-4a26-b74c-ee630f4a3769
md"""
## 2.6 字典Dict
字典也是常用的数据结构。字典中有键-值对， 通过键可以方便的获得值。可以用键值对元组向量构建字典， 也可以用键值对Pair构建字典。

```julia
Dict([(key1, value1), (key2, value2),...])
Dict(key1=>value1, key2=>value2,...)
```
对于字典， 可以使用keys，values函数分别获取由key和value构成的可迭代集。

### 字典相关操作
- haskey(collection, key) -> Bool 判断是否存在某个key
- get(collection, key, default) 获取某个key的值， 如果不存在这个key，返回default。对于字典， 可以直接使用中括号给定的key的方式获取key对应的值，即 **D[key]**, 但如果key不存在， 这种操作方法会出错。
- get!(collection, key, default) 获取某个key的值， 如果不存在这个key， 增加key=>default对，返回default
- delete!(collection, key) 删掉给定的key， 如果存在的话，并返回collectio。
- pop!(collection, key[, default]) 删掉给定的Key， 返回对应的值， 如果key不存在，返回默认值default， 这时候不指定默认值会出错。
- merge(d::AbstractDict, others::AbstractDict...)合并两个字典， 如果字典中具有相同的key，最后的字典中的对应值会被保留。
"""

# ╔═╡ 269d7cff-d99e-4eb9-a573-c08b869463e7
D = Dict('a'=>2, 'b'=>3)

# ╔═╡ 33103b72-5f3b-4699-9649-9204361ee9d7
keys(D), values(D)

# ╔═╡ 6cc5ec16-ff84-44c6-a704-d3ab92b49cc1
haskey(D, 'a'), haskey(D, 'c')

# ╔═╡ dd807cf4-15cd-4d8f-816d-ffeb259953ae
D['a']

# ╔═╡ 5ccba59a-fec6-429e-8bf2-0445819ba1d2
get(D, 'a', 1), get(D, 'c', 1)

# ╔═╡ 3764bd78-069b-4c9d-bcbe-12f85da65d9c
md"""
## 2.7 集合set
Julia中实现了数学上集合的概念， 即集合包含的元素具有：互异性、无序性、确定性。集合常见的操作是：
- 判断元素是否在集合中（确定性） in
- 结合求并 union
- 求交 intersect
- 求差 setdiff
- 对称差 symdiff
具体请参考[集合相关文档](https://docs.julialang.org/en/v1/base/collections/#Set-Like-Collections)
"""

# ╔═╡ d3b4eb44-ff14-424d-b97c-53fc373ae03d
md"""
## 2.8 向量
向量是数据分析中是非常常见的。 跟元组类似，向量也是一列数据。只不过， 向量中的元素是同一种类型。
### 向量的构造
构造向量非常简单， 只要用中括号(元组用的是小括号）包裹， 元素之间用逗号(分号)分隔即可。
```julia
[e1,e2,e3,...]
```
"""

# ╔═╡ 4803a865-00ad-4595-8d05-43aef456e398
[1, 2, 3]

# ╔═╡ 4ac509b2-61ca-401a-83db-9298537de7e1
[1;2;3]

# ╔═╡ 5f70b1ed-6f99-4997-aa37-0efd6b1b6249
md"""
向量的数据类型是`Vector{元素类型}`
"""

# ╔═╡ a386ef9e-674a-4d7a-8f55-6603070457c3
typeof([1, 2, 3])

# ╔═╡ 8d091301-85e9-46d5-a4ae-1aac98f1fedd
md"""
使用**collect函数**可以方便的把一个范围（range）里的所有元素提取到向量中
"""

# ╔═╡ ba6b772c-5691-4e48-8f37-972956cdee65
collect(1:10)

# ╔═╡ c05d7186-3761-4d86-be54-ccd0c8c58b5a
collect(range(1,10, 5))

# ╔═╡ dbace4f9-e018-4356-8ed3-e652c7f123b4
collect(range(1,10,2))

# ╔═╡ cd2211ae-5864-4e87-9293-3b4c81ef23b2
md"""
此外， 可以使用数组的构造函数。 比如 `Vector{Float32}(undef, 100)` 就是构造一个长度是100的未初始化的元素类型是Float32的向量（用`@doc Vector `可以查看帮助文档）（这时候可以用循环来实现数据构造）。 对于向量来说， 还可以用  **类型[]**的方式构造某种类型的向量, 但不能同时指定长度（这时候可以使用push!, append!添加元素）。 


"""

# ╔═╡ 524df39e-8200-4a53-b762-5558e7a1a527
md"""
### 向量的提取
从向量中提取元素是非常简单的， 只要通过中扩号给定下标或一个下标的范围即可。在表示范围时， begin， end两个关键字分别表示第一和最后一个元素的位置。
"""

# ╔═╡ 7fa1ca91-8c28-4a02-8d91-79e23decf30c
xv = collect(1:10)

# ╔═╡ bab0698a-7ec1-4e37-a9b1-c66746062e3e
xv[end]

# ╔═╡ a855e0ec-cb0f-49c8-a9de-fa0e72b1f8ea
xv[1:5]

# ╔═╡ 58a47ef9-3f48-46a3-a0c2-e2030e9d6cbe
xv[5]

# ╔═╡ b3afedf1-ec7b-4c7f-a9fd-d110e319cd91
xv[xv .> 5 ]

# ╔═╡ 1ae9fe95-4028-4ad9-8bea-9e70038d97aa
xv .> 5

# ╔═╡ 83cdb063-631d-4665-99f7-160485675b15
xv[(begin+1):(end-1)]

# ╔═╡ d2bc4dba-f8af-49ed-bede-a4b5a4b0d63c
md"""
### 向量的修改
当向量的提取操作放在赋值号的左边时， 可以实现对向量相应元素的修改。
"""

# ╔═╡ 3f8f066b-8d6c-4503-9223-66a03f3c92cc
xv[3] = 4

# ╔═╡ bdff1fdf-1fb9-4efe-95a8-cfe84b4d1b5c
xv[9:10] = [28, 30]

# ╔═╡ 308270ba-883a-42a6-98ef-84ace09f581f
xv

# ╔═╡ 0243070a-ee48-4909-b14e-dfcd770490f2
md"""
push!函数可以在向量后面增加一个元素， 而pop!函数弹出向量的最后一个元素， 注意， 这两个函数名后面有惊叹号， 表明这种函数会修改参数值。 在这里其实是会修改输入的数组xv。
"""

# ╔═╡ 80208609-848e-4126-9728-3a4e96073209
push!(xv, 100)

# ╔═╡ d168ee9a-d869-446b-9de7-cd8c5feaf52c
pop!(xv)

# ╔═╡ aeb2f9dc-9337-4417-b6fe-56b89b4e3553
xv

# ╔═╡ 0e8b63aa-60aa-4624-99fc-3201e9ccd0be
md"""
### 向量的统计
求向量的元素个数（length）， 所有元素的和（sum）， 累积和（cumsum）, 相邻元素的差（diff）,最大值（maximum）， 最小值（minimum）, 最大值所在位置argmax, 最小值所在位置argmin
"""

# ╔═╡ 19cb9bbc-0d03-4aab-9817-8c44c1467f1c
vs = rand(1:10, 10)

# ╔═╡ 2fb307cf-3c4c-4496-9d28-6d00045f9a0e
length(vs)

# ╔═╡ ee209254-aaaa-47bc-8742-66b41f5cc1cb
sum(vs)

# ╔═╡ cc1de85e-004f-4dfa-a470-3cb4fc44ccb9
cumsum(vs)

# ╔═╡ f8789abc-2109-4933-b601-a364d4632abb
diff(vs)

# ╔═╡ f17023ef-d835-445d-ba18-bfd5872f0764
maximum(vs),minimum(vs)

# ╔═╡ 3c64486c-4aab-40f4-8fd5-2cfbb74cf856
argmax(vs)

# ╔═╡ ee70a87a-4a0f-49b6-83f9-eaa421300682
argmin(vs)

# ╔═╡ 28df5976-321b-4e33-a4dd-e301ca141ab9
md"""
### 向量化代码
在Python、R等语言中， 为了写出更高效的代码， 一般都尽量使得代码是向量化的。一个函数``f(x)``施加到向量``v``上时，默认会施加到向量中的每一个元素上``f(v[i])``。在Julia中， 直接写循环速度也差不多。 但Julia也支持向量化。只需要在函数调用的括号前面加一个点即可（点操作符）。例如
```julia
x = rand(10)
sin.(x)
```
可以实现对10个元素同时求正弦sin。 因为运算符也是函数， 所以运算符也可以是向量化的， 可以通过在运算符前加一个点让运算符变成向量化运算符。比如，下面的 **.^**可以实现对向量中的每一个元素求平方。

```julia
x = rand(10)
x.^2
```

多个函数同时向量化也是允许的， 而且在Julia中会比较快。 比如， 我们对一个向量中每一个元素平方之后，求正弦， 再求余弦， 那么可以这么写：

```julia
x = rand(10)
cos.(sin.(x.^2))
```
上面的代码中有三个点， 表明三个相关函数（^这个也是函数）都是向量化的。不过，如果有太多点运算， 可能代码看起来比较繁琐， 这时候可以使用宏`@.`。 宏有点像函数， 但不需要写括号。宏`@.`是告诉Julia， 这个宏后面的代码是向量化的， 只是不需要写点了。因此，上面的代码也可以写成：
```julia
x = rand(10)
@. cos(sin(x^2))
```
这时候， 如果你要告诉Julia， 其中的某个函数不是向量化的， 那么你需要在该函数名前加上美元\$符号。

例如`@. sqrt(abs($sort(v)))`表示对向量排序（sort）之后，再每个元素求绝对值（abs），然后再开方（sqrt）。

在julia中， 你直接写循环会比向量化代码更快， 所以不需要担心自己的代码不是向量化的。 我们还是会写向量化的代码是因为非常方便，仅此而已。
"""

# ╔═╡ 753dd774-bc71-40a6-866e-99167ec5a635
md"""
## 2.9 矩阵
矩阵也是一种常见的数据类型。 与向量相比， 矩阵是二维的， 即有行、列两个维度。还是可以使用中括号构造矩阵。 这时候， 空格分隔的元素会按行排列。
"""

# ╔═╡ b4f5295a-71a1-45a1-b840-465b97dfa35f
# 空格分隔的元素被排成了一行， 请注意返回结果是一个一行的矩阵， Julia中没有行向量。
[1 2 3]

# ╔═╡ bde035e5-8e89-4f57-82d3-cf4a3538cb62
[1 2 3; 4 5 6]

# ╔═╡ f5910485-4831-4fec-b7c6-dde8da9ea4c4
md"""
矩阵的数据类型是： Matrix{T}，其中T表示元素的类型。例如， 由Int32构成的矩阵是Matrix{Int32}。
"""

# ╔═╡ f434ec9b-f21f-4b13-a2b3-0d1fb3249e1c
md"""
### 简单构造方法
- 特殊数组的构造。 比如全是1或0的数组， ones(m, n)(构造m``\times``n的全1矩阵)， zeros(m, n, k)构造全是0的三维数组。
- 根据已有的数据去构造。 已有一个数组A， 要构造一个跟A的结构一样的（维度，长度都一样）数组， 可用similar函数。 如similar（A）构造一个数据类型和维度跟A完全相同的未初始化数组。
- rand: 可以通过给定维度长度构造（0,1）间的随机数数组， 例如：rand(m, n)构造m*n的随机矩阵。-
- randn: 可以通过给定维度长度构造符合正态分布的随机数数组
"""

# ╔═╡ 465a6a3d-51fa-438d-99cd-d4225e69f891
ones(3,4)

# ╔═╡ da814e35-d7bb-4bb7-880a-1200de12680a
rand(3,4,5)

# ╔═╡ 45a9bbc8-fd43-46c9-b4bb-f0ce8a0cf7cd
md"""
### 矩阵的提取与修改
矩阵元素的提取和修改跟向量是类似的， 只是，矩阵指定元素时， 需要同时给定行，列下标。 单个冒号表示所有元素。
"""

# ╔═╡ 9f143610-c2ac-419a-94c5-aeb832eab25a
m1 = rand(3,4)

# ╔═╡ b8481b81-e60a-460a-bdd2-ad843825c974
m1[3,4]

# ╔═╡ bff39067-4254-4759-ba96-c39fdb21dbc7
m1[:, 1]

# ╔═╡ ab60a221-31ac-4f22-9949-ffcef1bf33bc
m1[1:2, :]

# ╔═╡ c5b7f19b-1d06-4c30-b9d6-700e6d8cb95b
md"""
## 2.10 数组
上面介绍的向量和矩阵是数组的一种特殊情况（1维数组和2维数组）。Julia语言本身对数组提供了非常多的支持。不像Python， 需要使用Numpy包才能处理数据 。 数据具有如下特点 ：1）元素是可变的； 2）数组中所有元素都具有相同类型； 3）数组具有维度；

数组的类型是Array{T,N}， 其中T表示数组元素的类型， N表示数组的维度。 一维数组（向量）也可以表示为Vector{T}, 二维数据可表示为： Matrix{T}
"""

# ╔═╡ f7f76395-39d5-49d7-a9b9-f10d232f46bf
md"""
### 数组的维度
维度是数组特有的一个性质。 在Julia中， 天然的支持多维度的数组。那么，怎么理解维度呢？ 尤其是怎么理解一个多维数组呢？以下，提供一个直观的关于维度的理解--奇怪的图书馆。

想象一个奇怪的图书馆， 其中的书中的文字是按列先从上之下， 再从左至右排列的（这就是奇怪之处）。每一本书就是一个三维数组（对于书来说， 数组中的元素是文字，不是数字）。其中的每一页是一个矩阵。

于是， 第一个维度代表列方向（向下）， 第二个维度代表行方向， 第三个维度是厚度的方向（页数增加的方向）。第四个维度是书架上的最底层，从左到右的方向。第五个维度是书架从低到高增加的方向。 当然还可以继续增加维度， 但实际中用到第五个维度已经很难想象了。

许多数组操作函数都包含一个维度dim参数， 需要结合具体场景理解。
"""

# ╔═╡ 05b2f5c1-cecc-4815-ad4c-87bce0b103ca
md"""
### 数组操作的基本函数
由于Julia是为科学计算设计的， 其包含了非常丰富的数据操作函数， 具体可以参考[**数组文档**](https://docs.julialang.org/en/v1/base/arrays/)， 下面是一些常见的函数。
- eltype： 获取数组的元素类型。
- length： 获取数组的元素个数。
- size： 获取数组各个维度上的长度， 还可以指定维度dim，获取指定维度的长度。 
- reshape: 改变数组的维度
- [i,j,k]: 典型索引操作， 获取（假定是3维数组）第i,j,k号元素(这是笛卡尔坐标表示)。 也可以使用：连续选取， 或者仅用：表示选取所在维度的所有元素。


- **搜索**
|函数名|	搜索的起始点|	搜索方向	|结果值|
|---|---|---|---|
|findfirst|	第一个元素位置|	线性索引顺序|	首个满足条件的元素值的索引号或nothing|
|findlast|	最后一个元素位置|	线性索引逆序|	首个满足条件的元素值的索引号或nothing|
|findnext|	与指定索引号对应的元素位置|	线性索引顺序|	首个满足条件的元素值的索引号或nothing|
|findprev|	与指定索引号对应的元素位置|	线性索引逆序|	首个满足条件的元素值的索引号或nothing|
|findall|	第一个元素位置|	线性索引顺序|	包含了所有满足条件元素值的索引号的向量|
|findmax|	第一个元素位置|	线性索引顺序|	最大的元素值及其索引号组成的元组或NaN|
|findmin|	第一个元素位置|	线性索引顺序|	最小的元素值及其索引号组成的元组或NaN|
"""

# ╔═╡ 8b049907-5266-4066-84db-271b747996d7
tmp = rand(3,4,5)

# ╔═╡ 867b78a8-1183-41b3-ad1c-a0d6db7dc075
size(tmp)

# ╔═╡ 0edff351-2fc8-4759-b2ad-fb5c447119d2
eltype(tmp),length(tmp), size(tmp), size(tmp, 1)

# ╔═╡ f5a96665-ee82-4aec-8db8-59ec603276be
mx = reshape(1:24, 2,3,4)

# ╔═╡ ba31c664-e23f-487d-826f-e259a2b2ccbd
md"""
### 向量堆叠stack
矩阵是由列向量按行排列而成的。因此， 如果我们有一系列等长的向量， 可以将其简单拼接起来就好。
"""

# ╔═╡ c3887ca1-3727-4121-a93d-4fea9fa55e9d
vecs = (1:2, [30, 40], Float32[500, 600]);

# ╔═╡ 6a25736a-190e-4f7a-8625-b4bd10e9c463
stack(vecs)

# ╔═╡ d31c6d68-7929-4420-a3fb-1b4e9f6d2fc4
md"""
### 向量的拼接cat
如果有多个向量需要拼接为一个向量， 可以使用cat函数。
```julia
cat(A...; dims)
```
该函数有一个关键字参数， dims， 用于给定拼接的维度。 也就是把数据放在哪个维度上（单个维度）。 注意， 这里的参数名是复数， 意味着可以同时给多个维度， 这时候拼接的结果是多个维度同时增加。比如， 构造分块矩阵。

在第一个维度拼接也可以用vcat， 在第二个维度拼接可以用hcat。看[**这里**](https://docs.julialang.org/en/v1/base/arrays/#Base.cat)了解更多。
"""

# ╔═╡ 794b30c9-c990-41f6-81e3-9bdae57bffcc
cat([1,2],[3,4], dims=1)# 按第一个维度（行）方向拼接

# ╔═╡ 58eb6102-a11e-419b-a6a2-ce1d38621203
cat([1,2],[3,4], dims=2)# 按第二个维度（列）方向拼接

# ╔═╡ cbd27fc4-ba4e-43b3-8783-6d1bade31447
md"""
下面是按第三个维度（厚度）方向拼接的结果。 这本书有两页， 每一页上只有一列。
"""

# ╔═╡ 281165a4-036e-42c7-bf85-2beab7626fbc
cat([1,2],[3,4], dims=3)

# ╔═╡ bbb0e8bf-ea62-4620-837f-74e9b84b2529
cat([1,2],[3,4], dims=(1,2))

# ╔═╡ 94a3cd24-9221-4f12-9112-ef2117edd009
sin.(1:10)

# ╔═╡ 5ca71a2a-b7c5-494a-b7e4-25dc4b0a11fa
md"""
###  数组推导
数组推导是构建数组的一个常见形式。与python类似，Julia也提供了数组推导式, 通用的格式如下：
- [f(e) for e in colletion if condition]。 这是遍历collection里面的元素， 当满足条件condition时就进行某种操作f， 最后形成一个数组。 e in colletion 也可以写成 e = colletion， if condition可以省略, 下同。
- [f(x,y) for x in c1, y in c2 if condition]。 这种情况下， x,y分别从两个集合c1,c2取值，如果没有if条件，结果是一个矩阵， 矩阵第i,j位置上的元素是f(x[i],y[j])， 由于Julia中矩阵按列存储， 所以会先计算出第1列，再第二列，依次类推； 如果有if条件， 结果是向量， 相当于先计算一个矩阵，再过滤掉不满足条件的元素。  
**注意：**如果外侧不是用[ ]包裹， 那就不是数组推导。 比如， 用（）包裹得到的可不是python里面的元组， 而是生成器了。
"""

# ╔═╡ b5c18a8d-e20c-4a8f-983d-746a20ee41d4
[(x,y) for x in 1:3,  y in 1:4]

# ╔═╡ 21c58017-2d2c-4abd-b7f4-e05fcbd0a936
[sin(x) for x in 1:100 if isodd(x)]

# ╔═╡ 49ec27d1-72ec-4e50-b38e-bef8941e5522
[x + y + z for x in 1:2, y in 3:5, z in 6:9]

# ╔═╡ 92977747-cbc3-41e5-ba86-a8f1bb547a4c
[x + y for x in [1,2,3] , y in [4,5,6,7] if isodd(x)]

# ╔═╡ 8b9e2b3b-4654-40bd-9304-2ac8f520a2b7
[x + y for x in [1,2,3] , y in [4,5,6,7] ]

# ╔═╡ 46662d36-c690-4bb4-998a-6d6ac9b33a51
[e^2 for e in 1:10], [e^2 for e in 1:10 if iseven(e)]

# ╔═╡ 8ca24420-966f-45a5-86f6-ac21b999006e
md"""
## 2.11 范围类型range
范围类型通常用于表示一定范围内具有某种性质的数据构成的集合。最常见的是等差数列, 可以使用冒号运算， 或者range函数构造。
```julia
start:step:stop#step省略的话就是1
range(start, stop, length)
range(start, stop; length, step)
range(start; length, stop, step)
range(;start, length, stop, step)
```
"""

# ╔═╡ 53238993-9668-4412-8d6e-c24bcc3518f3
1:2:10

# ╔═╡ c4d18d69-a8a1-4dd5-862a-4dc4d9a5db44
range(1,10,3)

# ╔═╡ ffc4b3ae-f6d3-4b66-a323-61e256fac24f
range(1,10, length=2 )

# ╔═╡ cef4db28-eea2-4c3f-8a35-71a01f4a3297
3 in 1:2:10

# ╔═╡ c18f82cb-f7b3-4f03-b387-b17745e11597
md"""
**函数调用：**上面给出的range函数有四种调用方式，我们应该怎么去调用呢？或者Julia是怎么实现一个名字（range）可以实现多种不同功能的呢？

在编程语言中， 一个名字（函数）在不同语境中可以表示不同含义（不同的调用方式，实现不同的功能），被称为多态。在C++、Python等语言中， 是通过对象实现多态的，即不同的对象调用相同的函数可能得到不同的结果。

在Julia中， 通过**多重分派**实现多态。一个函数名只是给出了一个通用的功能(generic function)。然后对这个功能的不同实现表示该函数的方法（method）。上面就给出的range函数的四个方法。

Julia是怎么根据用户输入的参数去判断要调用哪个方法的呢？答案隐藏在Julia的多重分派（multiple dispatch）里。简单来说， 多重分派的意思是：一个函数在寻找匹配的方法时， 根据其多个参数的类型去确定要调用的方法。当然， 并非所有的参数都会用于多重分派。只有参数列表里，分号；前面的参数（称为**位置参数**）会起作用（也就是给出的位置参数类型及顺序不同， 调用的方法就不同）。这些参数在调用的时候， 不需要给出参数名， 直接按顺序给出参数值即可。分号后的参数通常被称为**关键字参数**， 关键字参数在赋值时， 需要给出关键字的名字。在函数调用时， 位置参数和关键字参数不需要用分号隔开。 所以， 你知道下面的代码的含义吗？
```julia
range(1,10, 2)
range(1,10, length=2 )
range(1,10, step=2 )
```
""" |> box(:green, :扩展)

# ╔═╡ 5560ec19-78a4-4c1d-accd-9c07c29c0e18
md"""
可以通过`methods`函数查看一个函数有多少个方法， 下面的结果表明range函数有6个方法。
"""

# ╔═╡ 1c7fbed3-6035-48b9-94ac-2b50086a6a12
methods(range)

# ╔═╡ 2dd38b7f-1310-460e-996d-61f104dbfa7d
md"""
## 2.12* [容器类型Collections](https://docs.julialang.org/en/v1/base/collections/)
容器类型并非一种特定的数据类型， 而是多种数据类型的一种抽象。 直观上来说， 只要可以用于存储多个数据对象的数据结构，都可以看成是容器类型。 上面说到的所有数据类型， 都可以看成是容器类型（Pair对象除外， Pair对象被视为单一元素）。

为什么要单独提容器类型呢？因为Julia中， 很多的操作对容器类型都是有效的。上面给出的向量的统计里的函数， 很多都对容器适用。 具体可以参考每一个函数的文档。 容器类型定义了多种函数， 具体可以参考其[文档](https://docs.julialang.org/en/v1/base/collections/)

在容器类型中， 使用非常频繁的一种是可迭代容器类型Iteration。顾名思义， 可迭代容器类型是指， 这个容器中的元素可以通过for循环依次去遍历。具体内容在下面流程控制部分解释。

"""

# ╔═╡ f4bde725-a4c4-4822-b4db-cd66a21e9944
md"""
# 3 流程控制
流程控制是实现逻辑的重要一环。程序从结构上可以分为顺序结构、分支结构和循环结构三种。默认情况下，程序会顺序执行， 当需要构造分支和循环时， 需要特殊的关键字。在Julia中，有：
1. begin ... end 构造复合语句（在Pluto中，任何一个cell只能输入一条语句， 如果你要输入多条， 则需要用begin...end构造成复合语句）。
2. if elseif else end. 实现分支语句， 当然也有三元操作符?:。
3. for i in collection ... end。 实现固定范围的for循环。
4. while condition... end。 实现基于条件的while循环。
5. continue, break， 用于跳出、提前结束循环。

注意，Julia中任何一个代码块开始关键字都需要以end结尾
"""

# ╔═╡ 974d0237-4e0d-4abc-a52c-649813b6290e
md"""
## 3.1 复合语句
当多个语句要组合为一条语句的时候， 需要用到。 下面是三条语句组成的复合语句。该语句的值为复合语句中最后一条语句的值。
"""

# ╔═╡ fd358455-35a1-42d1-bf67-e6b201ad37f2
z1 = begin
           ac = 1
           bc = 2
           ac + bc
       end

# ╔═╡ 03f1bd8c-5eec-41c4-b0bf-4bdabed6319f
begin
	a1 = 1
	a2=2
end

# ╔═╡ 9f65d099-dda1-4c13-b41d-e1c45cc8410c
md"""
Julia并不要求语句有结束符， 不过， 如果我们想多条语句写到同一行中， 可用分号；分隔即可。当然， begin...end也可以写到一行。
```juli
begin ad = 1; bd = 2; ad + bd end
```
"""

# ╔═╡ e56fb773-68dd-4b1c-b98a-575aea4d1a83
z2 = (ad = 1; bd = 2; ad + bd)

# ╔═╡ 0edb4a14-21f8-462b-8d42-ce95f45aebc3
md"""
## 3.2 if语句
if语句用于实现分支结构，其基本的用法如下：
基本的使用方法是：
```julia
#单分支条件语句
if 条件
	满足条件要执行的语句
end
```
```julia
# 两分支语句
if 条件
	满足条件要执行的语句
else 
	不满足条件要执行的语句
end
```
```julia
# 多分支语句， elseif可以有多个
if 条件1
	满足条件1要执行的语句
elseif 条件2
	不满足条件1， 满足条件2要执行的语句
elseif 条件3
	不满足条件1、2， 满足条件3要执行的语句
else
	不满足条件1、2、3要执行的语句
end

```
"""

# ╔═╡ a82faf94-ebc6-4f64-9110-cfae5d478c40
md"""
不像C等语言，在Julia中， 要求条件求值的结果必须是bool值， 即true或者false。如果不是， 则程序会错误。（在C语言中， 不是0都当成是true）
""" |> box(:red, :注意)

# ╔═╡ 42a8ee30-8f6a-4805-a196-1f50bd1be76e
md"""
单分支语句有一个常用的替换， 也就是利用逻辑运算（&&和||）的**短路求值**。 由于`a&&b`只有在a和b同时为true时才能为ture， 因此， 当a计算的结果为false时， b不需要计算， 只有当a为true时， 才需要计算b的值。因此，
```julia
if 条件
	表达式 
end 
```
可以写成
```julia
条件 && 	表达式 
```
类似的， `a||b`只有在a计算结果为false时， 才需要计算b的值。因此， 当我们要表达不满足某个条件要执行某条语句时， 可以利用或运算。即：

```julia
if 不满足条件(!条件)
	表达式 
end 
```
可以写成
```julia
条件 || 	表达式 
```

"""

# ╔═╡ eeb589d3-ef08-45e6-96d0-e8a43990f355
md"""
对于双分支语句， 可以用一个简单的表达式表示：
```julia
a ? b : c
```
在这个简单表达式中， a是条件表达式，如果a的测试结果为真true， 则返回表达式b的值， 否则返回表达式c的值。
"""

# ╔═╡ 44f60c42-a622-46a7-9b13-334bc7f2b1a4
md"""
你可以输入两个不同的值xn= $(@bind xn  NumberField(1:10, default=3)) ， yn= $(@bind yn  NumberField(1:10, default=4))， 然后下面的语句会根据你输入的值的大小比较结果输出不同的值。
"""

# ╔═╡ a36cc9c3-e097-4093-b9dc-29821c60e251
println(xn < yn ? "xn < yn" : "xn >= yn")

# ╔═╡ 2e677cda-c26f-445f-8f18-a7b1e55180b8
md"""
## 3.3 循环语句
当我们需要重复的做一件事情时， 可以使用for循环或while循环。

for 循环的典型用法如下：

```julia
for 循环变量 in（或者=） 容器
	# 做点事情， 一般会跟循环变量有关
	...
end
```
在for循环中， 循环变量会依次取容器中的每一个值。 所以， 在每一次循环， 循环变量的值可能都不同。 `循环变量 in（或者=） 容器 ` 表示: `循环变量 in 容器`或者 `循环变量 = 容器`都是合法的语法。 注意， 这时候的等号=不是将容器赋值的意思，而是容器中的元素依次赋值。


```julia
while 条件
    # 条件满足时，要做的事情
	...
end

while循环更简单， 只要条件能够满足， 就会执行while 和 end之间的代码。只是请注意，跟if语句中的条件一样， 这里的条件也必须是逻辑值。 
```
"""

# ╔═╡ c247f64b-457a-4bb7-88dd-a9d2ecc3ae0e
md"""
比如， 求 ``1+2+\cdots+100`` 的和，用for循环可以非常方便的实现：
```julia
s = 0
for i in 1:100
	s += i
end
```
如果用while循环， 也可以这样：
```julia
s = 0
i = 1
while i<=100
	s += i
	i += 1
end
```
上面两段代码中s最后的值都是所要的结果。
"""

# ╔═╡ e6181b7f-d65a-4ce0-b12a-cb76169cb0f6
begin
s = 0
for i in 1:100
	s += i
end
end

# ╔═╡ 212cf3bc-a0b2-4f8d-bb51-5e6104d17287
md"""
如果要遍历一个字典， 可以简单如下：
```julia
for (k,v) in D
	# 做一些事情
end
```
其中， k存储每一个元素的键key， v用于存储值value。	
"""

# ╔═╡ 602ea0fd-eb5c-4129-9987-02bf23074292
md"""
如果在遍历一个容器的时候， 我们不仅需要值， 还希望知道当前的值是第几个元素。这时候， 可以这么做。
```julia
for (i, x) in enumerate(collection)
 # 做一些事情
end
```
这时候， 变量i保存遍历过程中元素的顺序（从1开始）， 变量x保存相应元素的值（第i个元素的值）。`enumerate(iter)`的作用是生成一个可迭代对象。

比如， 我们要找到一个向量中的元素的最大值是哪个元素， 虽然有函数实现， 但可以用如下for循环:
```julia
v = rand(1:10, 10) # 从1:10中随机抽取10个元素构成向量。
ind = 1 # 用于保存最大值所在位置
for (i,x) in enumerate(v)
	if v[i]> v[ind] # 如果发现一个更大值
		ind = i # 更新最大值所在位置
	end
end
```
"""

# ╔═╡ 9ea456f7-0e60-44d5-8e5a-1ad3efe71996
md"""
## 3.4 补充： 迭代类型（Iteration）
可迭代类型一种可以用for循环遍历的数据容器。
```julia
for i in iter   # or  "for i = iter"
    # body
end
```
说迭代类型是容器其实不太确切。 因为可迭代类型并没有将数据存起来， 数据是在迭代的过程中不断计算出来的。 因此， 可迭代类型的数据可能是一个无穷集合。想象一下， 我们肯定没办法构建一个包含无穷多个元素的向量（因为内存限制）。


一个可迭代类型， 只是在该类型上，定义了一个iterate函数：

`iterate(iter [, state]) -> Union{Nothing, Tuple{Any, Any}}`

该函数实现在迭代对象上（iter）， 根据当前的状态（state）， 获取容器中的下一个值和下一个状态。 一般， 值和状态构成一个元组。 如果容器中的元素全部取出， 那么再次迭代获取的值将是nothing。 

有了这样的特征设定， 上面的for循环其实被转换为下面的while循环：

```julia

next = iterate(iter)
while next !== nothing
    (i, state) = next
    # body
    next = iterate(iter, state)
end
```

一个迭代类型可能还实现了IteratorSize和IteratorEltype等特性， 可以用于求迭代器中的元素数量和元素类型。 当然， 只要定义了上面的iterator函数， 一个迭代器类型就自动实现了很多操作。

上面介绍的所有数据结构都是可迭代类型。因此， 任何适用于可迭代类型的函数， 将适用于上面介绍的所有数据类型。
"""

# ╔═╡ 40d31e37-ad99-44c3-98e6-494b07d42d66
md"""
# 4 函数
在数学上， 一个函数是一个映射``f:x\rightarrow y``, 它将自变量映射为因变量。 在编程语言中， 函数的内涵更丰富。 简单来说， 一个函数就是一个功能function， 这个功能可以将一定的**输入**（可以没有），转化为**某种输出（也可以没有）**。 

输入也称为**参数列表**， 一般用括号形成的元组表示。 函数的输出是函数的返回值（return）， 默认情况下是函数的最后一条语句的结果。 


函数编写是一门语言非常重要的内容， 有了上述流程控制的内容， 编写函数就容易多了。 在Julia中， 有多种定义函数的方法。

## 4.1 经典定义
定义函数很简单， 用关键词 function， 给出函数名， 参数列表， 和函数体（函数的计算过程）即可。例如：
```julia
function f(x,y)
	x^2 + y^2
end
```
上面的函数定义中， `function ... end`之间的部分就是函数的部分。其中， `f`是函数名， `(x,y)`是参数列表， 其下一行`x^2 + y^2`是函数体。 这个函数很简单， 只是返回这两个参数的平方和。
"""

# ╔═╡ 11a3dd19-92ce-48c1-ae23-4b36a3a5e333
md"""
## 4.2 一句话函数
有时候， 我们的函数可能很简单（只有一句话）， 那么像上面那样去定义会显得啰嗦。这时候可以使用赋值直接定义。

```julia
f(par1, par2, ...) = 表达式
```
这种写法类似于数学函数的写法， 比如二次函数$f(x) = 3x^2 + 2x + 1$， 写成一个Julia函数，几乎是一样的。注意在下面，数字和字母x之间可以没有乘号*， Julia自己能判断这种情况是省略乘号的乘法， 因为变量不能以数字开头去命名。
```julia
f(x) = 3x^2 + 2x + 1
```
当然， 这里的“一句话”可以是复合语句， 比如：`begin ... end`包裹的多句话， 或者元组形式的多句话 `(语句1；语句2；语句3)`。
"""

# ╔═╡ a13a3943-3189-4ec5-be1e-1eabf1462118
md"""
## 4.3 匿名函数
有时候， 我们只是临时需要一个功能， 不想给它命名， 这时候可以用匿名函数的形式， 这是最想映射的定义方式：
```julia
(parlist) -> 表达式
```
匿名函数没有名字， 所以我们没法直接调用它。 一般匿名函数都是作为参数输入一个函数。 比如，在Julia中，有一个函数map， 其签名为
```julia 
map(f, c...) -> collection
``` 
该函数可以将一个函数`f`映射到一个或多个容器中的每一个元素上。 其第一个参数是一个函数。 如果需要映射的函数不需要复用。我们可以直接像上面一样定义一个匿名函数。 当匿名函数可能很复杂时， 可以使用`do...end`代码块。下面的do end之间的部分是一个匿名函数， 函数的参数是x。 这个函数将作为map的第一个参数。这种写法也被称为do代码块。

```julia
map(1:10) do x
    2x
end
```
"""

# ╔═╡ f54e0a94-b6f2-4fe4-8c59-d4fbbb27c727
map(x -> x^2, 1:5)

# ╔═╡ a3e15840-ec8d-4d13-802f-018d665086f2
sin.(1:5)

# ╔═╡ 2102c883-4c2f-461b-bfea-5421c9bfcae8
md"""

## 4.4 函数参数
以如下函数定义为例：
```julia
function f(a,b,..., m=x1, n=x2, ...; key1, key2 = xk, ...)
end
```
函数参数有两种类型： 位置参数和关键字参数， 每一种又分可选和必选， 位置参数和关键字参数在定义时用分号(；)分隔。 其中位置参数是通过位置来确定参数的赋值， 因此， 调用函数时， 提供的参数的顺序必须要跟对应的位置参数完全匹配。 关键字参数具有一个参数关键字， 调用的时候需要带着关键字去调用， 这时自然也不需要关注顺序的问题。 下面定义的函数`f`的参数中， `a,b...`是必选位置参数， `m,n,...`是可选位置参数（必选位置参数必须在可选位置参数之前）， 可选的意思是，如果没有给定也没关系（因为有默认值）。 分号之后的`key1, key2, ...`等是关键字参数， 关键字参数也可以提供默认值, 成为可选的关键字参数（否则就是必选的关键字参数， 没有必选要在可选之前的规定）。 注意， 位置参数调用时不能指定参数名， 指定参数名， 必然意味着这个参数是关键字参数。 Julia中函数会根据位置参数及其类型实现多重分派(同一函数名， 根据不同的输入参数实现不同的功能)， 细节请参考相关文档。

"""

# ╔═╡ e8c1a367-e3f3-4b0d-a0f9-2aa6a80b1123
md"""
## 4.5 ...操作符
"""

# ╔═╡ fa8f6be1-2429-499c-ac43-022a341bb71f
md"""
这个三点操作符是Julia中一个特殊的操作符， 在Julia中有两种作用，可以参考[`...文档`](https://docs.julialang.org/en/v1/manual/faq/#What-does-the-...-operator-do?)了解更多。

在函数定义的场景中， 可以表示“卷入”操作：把多个参数卷到一个参数上。比如在下面的函数定义， 只有一个参数，args，但args后面有三个点，他表示不管你输入多少个参数， 都将被卷入args这个变量里。当然这个变量会是一个元组，包含你给的所有参数。
```julia

function printargs(args...)
        println(typeof(args))
        for (i, arg) in enumerate(args)
            println("Arg #$i = $arg")
        end
end
```
"""

# ╔═╡ 4cf0696e-e821-471e-96df-1f6237008e9d
function printargs(args...)
        println(typeof(args))
        for (i, arg) in enumerate(args)
            println("Arg #$i = $arg")
        end
end

# ╔═╡ be9a3bb9-7ae6-465c-ac37-5f239d7aa49e
printargs(1, 2, 3,4)

# ╔═╡ dacd9f4a-924d-4cd3-a2d4-5a5753d2335e
md"""
三点操作符的另一个用法是展开。 通常，它可以将其前面的对象展开成一个一个元素组成的元组。这个用法经常出现在函数调用的场景， 我们给函数的参数，看上去可能只有一个， 但我们可以将这个参数展开， 得到多个值，分配给多个参数。
"""

# ╔═╡ 1aef68dd-ed5a-4c0c-aa02-d1fc956f7f24
tx = [1,2,3]

# ╔═╡ 7926b299-ba82-4ce1-ae1b-077e4150f71c
(tx...,)

# ╔═╡ 31c0e9d3-e4a3-4f9d-80f2-22e4cbd70ca8
printargs(tx...)

# ╔═╡ ce26d829-a7de-4194-96ef-9a81732db012
md"""
在Julia中， 有一个关于函数的习惯，**如果一个函数会修改其输入参数，该函数名要以！结尾**。 反过来， 如果发现一个带惊叹号的函数， 那么要知道这个函数会修改输入参数。
""" |> box(:red, :注意)

# ╔═╡ 355c0db5-ddfc-4af2-8902-1bcf0cacfb97
struct Point2D
x::Float32
y::Float32
end

# ╔═╡ aa9b6d9c-2999-4a48-8fd5-b3d94d1b3a68
md"""
# 5 复合类型Composite Type
在面向对象的编程语言中， 比如Python， 我们可以定义自己的类（class）。一个类可以包含一些字段（数据）， 同时也会有这个类的对象可以调用的相关函数（方法）。 一般， 类实例化之后被称为对象（object）。要调用相关函数， 我们需要使用`对象.方法`这样的语法形式， 这表明， 方法是由对象的类决定的。 在Julia中， 数据和方法是分开的。决定调用何种方法是由函数的位置参数共同决定的（多重分派），而不仅仅是函数的第一个参数。这种将数据跟方法解耦的方式具有非常多的优势。

因此， 在Julia中，我们不能定义类， 但可以定义包含一些字段的数据类型--复合类型。简单来说， 复合类型就是一个把多个名字绑定为一个整体的数据类型。 类似在C语言中， Julia使用struct关键字定义复合类型。
```julia
struct Point
	x
	y
end
```
上面定义了一个名为Point的复合类型。在该类型中， 有两个名字(字段field)。 这个定义很简单， 你可以给两个字段赋予任何的值。因为，我们没有对字段的数据类型做任何的限制， 这种情况下是默认类型Any。当然， 对于特定的应用来说， 我们限制字段的类型是有好处的（可以获得更快的代码）。如果我们要对类型做出限制， 可以使用类型断言符--两个冒号`::` 

```julia
struct Point
	x::Float32
	y::Float32
end
```
在这个定义里， 我们限制了字段的类型的字段只能是32位的浮点数。 
"""

# ╔═╡ 66d2514c-7deb-4f93-bc19-318812a9da2d
md"""
用struct直接定义的类型在实例化之后默认是不可修改的。如果要定义可修改的类型。 需要在struct关键字前加mutable：
```
mutable struct Typename
field1
field2
...
end
""" |> box(:gree, :注意)

# ╔═╡ 0042e8a0-61be-4768-ae31-0445d531e5ff
md"""
我们把一个复合类型当成函数调用， 实际上是调用了类的默认构造函数`constructor`。 一般一个复合类型在定义之后， Julia会自动为其提供两个默认构造函数：一个接受任意类型参数的构造函数和一个接受精确类型参数的构造函数。 接受任意类型参数的构造函数会自动调用convert函数将参数转化为类型指定的类型。 比如， 上面构造的点p， 我们输入的数据是整数2,3， 但仍然能正确构造出对象，是因为整数可以转化为浮点数。
"""

# ╔═╡ ada4d6e7-4c4e-497f-b9cf-cd63ecd36315
PlutoUI.TableOfContents(title = "目录", indent = true, depth = 4, aside = true)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Box = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Box = "~1.0.1"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "2fbeba00feefb74233581601016e9bf342363021"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "297b6b41b66ac7cbbebb4a740844310db9fd7b8c"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Box]]
deps = ["Markdown"]
git-tree-sha1 = "d1bb190a6c0f8eec339173350c77d7d87ab900c8"
uuid = "247ae7ab-d1b9-4f88-8529-b44b862cffa0"
version = "1.0.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

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
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

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
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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
# ╟─5a64e73d-d7b8-4fa3-b81a-3154ae5a122b
# ╟─dc1a4db7-a9fd-49dd-b135-10c7099463b6
# ╟─cfb64224-5ef7-4300-a6e0-f38ad8e68cac
# ╟─ec6b4326-88a1-4375-a828-3e28ca7b2063
# ╟─02124a75-a225-4b7d-9b11-f22c5022a9a5
# ╟─4edc479e-ea0e-4e87-975b-35ac93cc6314
# ╟─aaafcdbe-a5e4-44da-bb6b-6a2d08c61602
# ╟─51f50e0a-e271-4448-b054-4c813dd2f55f
# ╟─6a64ae31-96b9-4eeb-a696-23859c898481
# ╟─f0e96543-bbd5-4095-89e4-e11f510c2d12
# ╟─167ee46b-e00f-406a-aa9e-b0d932641611
# ╟─bf4cc08f-e9ba-460e-bf86-e6e0f064fecb
# ╟─36ce4558-39b7-4c2e-9e78-4f0ecbdfae41
# ╟─5a17111d-845c-4c70-b275-8b1318fc1a40
# ╟─7fc75f1d-d3c4-435d-a6d3-9a9f453e999c
# ╟─04ce6f55-1b44-4457-9b2a-f55383e83acd
# ╟─8f5cfec9-5c67-4c72-86f0-1ec62215e924
# ╟─fad5f0b9-da41-4123-bb91-51500a57dea5
# ╟─33a162b4-21dd-40f5-b1fc-f0315b9750d3
# ╟─35fbe418-4bd5-4dee-a98d-9e976a8cb3d9
# ╟─292223b0-0549-47d5-9c13-55e4bca029e2
# ╠═f699b11c-6d47-4c18-9fef-3136467a090c
# ╠═5839e72e-8771-4184-a065-2196ba60b2f4
# ╠═0b6940b5-9d5e-439d-a974-fa056ee1ad2e
# ╟─4e8df286-dfb2-4693-9261-64a9bcc9d002
# ╟─7019a3b5-f0cb-40fa-8e66-51055af971e8
# ╟─4e544be5-4a04-4182-a58e-13bdcd6c517e
# ╠═f12ade36-ff61-435b-9a76-e9f739fe79ce
# ╟─d5b8e5de-f040-408c-92ac-aed3c3dffe51
# ╠═3540f431-7b50-4ed1-9d66-3cb4568856a2
# ╠═27e2d30c-96bb-4a28-ba47-6ea7d9bb3b2d
# ╠═88e526c6-cd09-4a75-9bc0-cec5a7a80234
# ╠═a89c40a4-4d12-4fc5-8cb9-75a8e2c9f708
# ╠═ff6530fa-8b79-4321-bde4-d42f3de138c5
# ╠═a779ef7b-f4ff-4d01-9f69-6e04d4e224a9
# ╟─5912b3ca-a74b-4174-859c-ed5b4cd669d5
# ╟─f5720acf-2ad6-4836-a349-897657ede9ac
# ╠═8b84afb0-cb46-462b-abf6-d5411e1e8a71
# ╟─c0714a91-39b8-4128-bf46-1121909d0559
# ╟─a8379370-04e9-4d95-92d0-44eb5be552e7
# ╠═2f992c55-3e22-4760-858c-6923a80ea3c2
# ╠═b7fbb4f3-8347-4f66-84b3-72119a857894
# ╟─5d676eff-f5a6-46b4-9bc7-6fa877dca56a
# ╟─d304524f-a6d8-4fe3-9a0c-aa55965f831f
# ╠═b21dedc7-23a2-4e79-84fc-943dd3053fab
# ╠═edd18731-64ee-4924-925f-c723ed9ab7ec
# ╠═718f6f4a-f337-4cb3-a9f1-e90a32411d8e
# ╠═a055cb83-9e64-415a-bd1a-cfa4a2b5b7dc
# ╟─8e01e846-b392-4610-8be1-e15485a74eaf
# ╠═0a4a689d-5a4e-4d5e-a278-beb137a80ac6
# ╠═18cae4b0-0b2a-407a-b8c6-236a631a84a7
# ╟─a1d25013-d982-438b-a9be-cb8f2a651a8a
# ╠═e442bb4c-4470-4415-9247-caffda420bf5
# ╠═7be99f73-40bf-4717-b64b-b4b0e850c364
# ╟─4ba402a6-2fbe-493d-8de8-266eace85a35
# ╠═17e4686d-f9a0-4201-baec-4cc1730b1821
# ╠═7d20bf88-7f1f-4159-88b3-c40d2e671781
# ╠═9fa94e04-fdbb-4f05-af6b-9330b3f52ec4
# ╠═57a03ff9-6fa0-457c-88d4-898a6fde710c
# ╟─1f03b743-60c7-45e1-bba0-1f008697a03e
# ╠═1260013b-da66-439a-9a2b-76ccb7b4a132
# ╠═0e00515a-3a2b-45a2-b6b5-a9810de85fd4
# ╠═065f15ad-1cbe-474e-901f-411aefb2e07f
# ╠═6fa90f17-74c4-4ee7-9f1d-ac317c36100d
# ╟─cfab338f-19b1-4a26-b74c-ee630f4a3769
# ╠═269d7cff-d99e-4eb9-a573-c08b869463e7
# ╠═33103b72-5f3b-4699-9649-9204361ee9d7
# ╠═6cc5ec16-ff84-44c6-a704-d3ab92b49cc1
# ╠═dd807cf4-15cd-4d8f-816d-ffeb259953ae
# ╠═5ccba59a-fec6-429e-8bf2-0445819ba1d2
# ╟─3764bd78-069b-4c9d-bcbe-12f85da65d9c
# ╟─d3b4eb44-ff14-424d-b97c-53fc373ae03d
# ╠═4803a865-00ad-4595-8d05-43aef456e398
# ╠═4ac509b2-61ca-401a-83db-9298537de7e1
# ╟─5f70b1ed-6f99-4997-aa37-0efd6b1b6249
# ╠═a386ef9e-674a-4d7a-8f55-6603070457c3
# ╟─8d091301-85e9-46d5-a4ae-1aac98f1fedd
# ╠═ba6b772c-5691-4e48-8f37-972956cdee65
# ╠═c05d7186-3761-4d86-be54-ccd0c8c58b5a
# ╠═dbace4f9-e018-4356-8ed3-e652c7f123b4
# ╟─cd2211ae-5864-4e87-9293-3b4c81ef23b2
# ╟─524df39e-8200-4a53-b762-5558e7a1a527
# ╠═7fa1ca91-8c28-4a02-8d91-79e23decf30c
# ╠═bab0698a-7ec1-4e37-a9b1-c66746062e3e
# ╠═a855e0ec-cb0f-49c8-a9de-fa0e72b1f8ea
# ╠═58a47ef9-3f48-46a3-a0c2-e2030e9d6cbe
# ╠═b3afedf1-ec7b-4c7f-a9fd-d110e319cd91
# ╠═1ae9fe95-4028-4ad9-8bea-9e70038d97aa
# ╠═83cdb063-631d-4665-99f7-160485675b15
# ╟─d2bc4dba-f8af-49ed-bede-a4b5a4b0d63c
# ╠═3f8f066b-8d6c-4503-9223-66a03f3c92cc
# ╠═bdff1fdf-1fb9-4efe-95a8-cfe84b4d1b5c
# ╠═308270ba-883a-42a6-98ef-84ace09f581f
# ╟─0243070a-ee48-4909-b14e-dfcd770490f2
# ╠═80208609-848e-4126-9728-3a4e96073209
# ╠═d168ee9a-d869-446b-9de7-cd8c5feaf52c
# ╠═aeb2f9dc-9337-4417-b6fe-56b89b4e3553
# ╟─0e8b63aa-60aa-4624-99fc-3201e9ccd0be
# ╠═19cb9bbc-0d03-4aab-9817-8c44c1467f1c
# ╠═2fb307cf-3c4c-4496-9d28-6d00045f9a0e
# ╠═ee209254-aaaa-47bc-8742-66b41f5cc1cb
# ╠═cc1de85e-004f-4dfa-a470-3cb4fc44ccb9
# ╠═f8789abc-2109-4933-b601-a364d4632abb
# ╠═f17023ef-d835-445d-ba18-bfd5872f0764
# ╠═3c64486c-4aab-40f4-8fd5-2cfbb74cf856
# ╠═ee70a87a-4a0f-49b6-83f9-eaa421300682
# ╟─28df5976-321b-4e33-a4dd-e301ca141ab9
# ╟─753dd774-bc71-40a6-866e-99167ec5a635
# ╠═b4f5295a-71a1-45a1-b840-465b97dfa35f
# ╠═bde035e5-8e89-4f57-82d3-cf4a3538cb62
# ╟─f5910485-4831-4fec-b7c6-dde8da9ea4c4
# ╟─f434ec9b-f21f-4b13-a2b3-0d1fb3249e1c
# ╠═465a6a3d-51fa-438d-99cd-d4225e69f891
# ╠═da814e35-d7bb-4bb7-880a-1200de12680a
# ╟─45a9bbc8-fd43-46c9-b4bb-f0ce8a0cf7cd
# ╠═9f143610-c2ac-419a-94c5-aeb832eab25a
# ╠═b8481b81-e60a-460a-bdd2-ad843825c974
# ╠═bff39067-4254-4759-ba96-c39fdb21dbc7
# ╠═ab60a221-31ac-4f22-9949-ffcef1bf33bc
# ╟─c5b7f19b-1d06-4c30-b9d6-700e6d8cb95b
# ╟─f7f76395-39d5-49d7-a9b9-f10d232f46bf
# ╟─05b2f5c1-cecc-4815-ad4c-87bce0b103ca
# ╠═8b049907-5266-4066-84db-271b747996d7
# ╠═867b78a8-1183-41b3-ad1c-a0d6db7dc075
# ╠═0edff351-2fc8-4759-b2ad-fb5c447119d2
# ╠═f5a96665-ee82-4aec-8db8-59ec603276be
# ╟─ba31c664-e23f-487d-826f-e259a2b2ccbd
# ╠═c3887ca1-3727-4121-a93d-4fea9fa55e9d
# ╠═6a25736a-190e-4f7a-8625-b4bd10e9c463
# ╟─d31c6d68-7929-4420-a3fb-1b4e9f6d2fc4
# ╠═794b30c9-c990-41f6-81e3-9bdae57bffcc
# ╠═58eb6102-a11e-419b-a6a2-ce1d38621203
# ╟─cbd27fc4-ba4e-43b3-8783-6d1bade31447
# ╠═281165a4-036e-42c7-bf85-2beab7626fbc
# ╠═bbb0e8bf-ea62-4620-837f-74e9b84b2529
# ╠═94a3cd24-9221-4f12-9112-ef2117edd009
# ╟─5ca71a2a-b7c5-494a-b7e4-25dc4b0a11fa
# ╠═b5c18a8d-e20c-4a8f-983d-746a20ee41d4
# ╠═21c58017-2d2c-4abd-b7f4-e05fcbd0a936
# ╠═49ec27d1-72ec-4e50-b38e-bef8941e5522
# ╠═92977747-cbc3-41e5-ba86-a8f1bb547a4c
# ╠═8b9e2b3b-4654-40bd-9304-2ac8f520a2b7
# ╠═46662d36-c690-4bb4-998a-6d6ac9b33a51
# ╟─8ca24420-966f-45a5-86f6-ac21b999006e
# ╠═53238993-9668-4412-8d6e-c24bcc3518f3
# ╠═c4d18d69-a8a1-4dd5-862a-4dc4d9a5db44
# ╠═ffc4b3ae-f6d3-4b66-a323-61e256fac24f
# ╠═cef4db28-eea2-4c3f-8a35-71a01f4a3297
# ╟─c18f82cb-f7b3-4f03-b387-b17745e11597
# ╟─5560ec19-78a4-4c1d-accd-9c07c29c0e18
# ╟─1c7fbed3-6035-48b9-94ac-2b50086a6a12
# ╟─2dd38b7f-1310-460e-996d-61f104dbfa7d
# ╟─f4bde725-a4c4-4822-b4db-cd66a21e9944
# ╟─974d0237-4e0d-4abc-a52c-649813b6290e
# ╠═fd358455-35a1-42d1-bf67-e6b201ad37f2
# ╠═03f1bd8c-5eec-41c4-b0bf-4bdabed6319f
# ╟─9f65d099-dda1-4c13-b41d-e1c45cc8410c
# ╠═e56fb773-68dd-4b1c-b98a-575aea4d1a83
# ╟─0edb4a14-21f8-462b-8d42-ce95f45aebc3
# ╟─a82faf94-ebc6-4f64-9110-cfae5d478c40
# ╟─42a8ee30-8f6a-4805-a196-1f50bd1be76e
# ╟─eeb589d3-ef08-45e6-96d0-e8a43990f355
# ╟─44f60c42-a622-46a7-9b13-334bc7f2b1a4
# ╠═a36cc9c3-e097-4093-b9dc-29821c60e251
# ╟─2e677cda-c26f-445f-8f18-a7b1e55180b8
# ╟─c247f64b-457a-4bb7-88dd-a9d2ecc3ae0e
# ╠═e6181b7f-d65a-4ce0-b12a-cb76169cb0f6
# ╟─212cf3bc-a0b2-4f8d-bb51-5e6104d17287
# ╟─602ea0fd-eb5c-4129-9987-02bf23074292
# ╟─9ea456f7-0e60-44d5-8e5a-1ad3efe71996
# ╟─40d31e37-ad99-44c3-98e6-494b07d42d66
# ╟─11a3dd19-92ce-48c1-ae23-4b36a3a5e333
# ╟─a13a3943-3189-4ec5-be1e-1eabf1462118
# ╠═f54e0a94-b6f2-4fe4-8c59-d4fbbb27c727
# ╠═a3e15840-ec8d-4d13-802f-018d665086f2
# ╟─2102c883-4c2f-461b-bfea-5421c9bfcae8
# ╟─e8c1a367-e3f3-4b0d-a0f9-2aa6a80b1123
# ╟─fa8f6be1-2429-499c-ac43-022a341bb71f
# ╠═4cf0696e-e821-471e-96df-1f6237008e9d
# ╠═be9a3bb9-7ae6-465c-ac37-5f239d7aa49e
# ╟─dacd9f4a-924d-4cd3-a2d4-5a5753d2335e
# ╠═1aef68dd-ed5a-4c0c-aa02-d1fc956f7f24
# ╠═7926b299-ba82-4ce1-ae1b-077e4150f71c
# ╠═31c0e9d3-e4a3-4f9d-80f2-22e4cbd70ca8
# ╟─ce26d829-a7de-4194-96ef-9a81732db012
# ╠═355c0db5-ddfc-4af2-8902-1bcf0cacfb97
# ╟─aa9b6d9c-2999-4a48-8fd5-b3d94d1b3a68
# ╟─66d2514c-7deb-4f93-bc19-318812a9da2d
# ╟─0042e8a0-61be-4768-ae31-0445d531e5ff
# ╟─9b0ff6f0-80be-445f-ba53-5c0d38c2a699
# ╟─ada4d6e7-4c4e-497f-b9cf-cd63ecd36315
# ╟─d336f6a2-a0dc-48ff-8e9a-39e0f2a0062f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
