using Markdown
#=================下面是一个常见的盒子=========================================================================#
using Markdown

function _box(color::Symbol = :green, title::Union{String,Nothing} = nothing)
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



#如果直接用名字， 相当于提供信息。
box(text::Markdown.MD) = _box(:green,nothing)(text)

# 如果直接用hint， 相当于提示：
hint(text::Markdown.MD) = _box(:blue,nothing)(text)
hintbox(text::Markdown.MD) = box(:blue,"")(text)
# 如果直接用无参数box， 相当于给出一个真正的框。
box() = _box(:green, "")
# 只给颜色， 用默认标题， 不需要标题， 需要用空字符串表示
box(color::Symbol) = _box(color, nothing)
box(title::String) = _box(:green, title) # 只给文本， 默认就是绿色
# 文本和颜色，可以交换着给
box(title::String, color::Symbol) = _box(color, title)
# 如果给两个Symbol， 则后一个当成标题
box(color::Symbol, title::Symbol) = _box(color, String(title))
# 如果给两个Stiring， 则前一个当成颜色
box(color::String, title::String) = _box(Symbol(color), title)



# =================练习========================#
struct Exercise{C}
    content::C
end

exerstyle = """
<style>
.exercise {
	border-style:dotted solid solid;
    border-radius: 0 25px 25px 0 ;
	border-width:0 0 0 5px;
	border-color: green;
	background-color:#ccf;
}
</style>

"""

function Base.show(io, mime::MIME"text/html", ex::Exercise)

	write(io, exerstyle)
	write(io,"""<div class = "exercise">""")
    show(io, mime, ex.content)
    write(io,"</div>")
end

function timu(str::Markdown.MD)
	Exercise(str)
end


# =================实验大标题========================
struct Title{C}
    content::C
end

titlestyle = """
<style>
.extitle {
	border-style:dotted solid solid;
    border-radius: 25px 25px 25px 25px ;
	border-width:0 0 0 0px;
	border-color: green;
	text-align: center; 
	background-color:#ccf;
	font-size: 60px
}
</style>

"""

function Base.show(io, mime::MIME"text/html", ex::Title)

	write(io, titlestyle)
	write(io,"""<div class = "extitle">""")
    show(io, mime, ex.content)
    write(io,"</div>")
end

function shiyan(str::Markdown.MD)
	Title(str)
end


# =================实验任务========================
struct Task{C}
    content::C
end



taskstyle = """
<style>
.task {
	border-style: dotted solid solid;
    border-radius: 0px 25px 25px 0px ;
	border-width:0 0 0 0px;
	border-color: green;
	
	background-color:#ccf;
	font-size: 30px
}
</style>

"""

function Base.show(io, mime::MIME"text/html", ex::Task)

	write(io, taskstyle)
	write(io,"""<div class = "task">""")
    show(io, mime, ex.content)
    write(io,"</div>")
end

function renwu(str::Markdown.MD)
	Task(str)
end

#================折叠框===========================#

struct Foldable{C}
    title::String
    content::C
end


fboxstyle = """
	<style>
details > summary {
  padding: 2px 6px;
  background-color: #ccf;
  border: none;
  <!-- box-shadow: 3px 3px 4px black; -->
  cursor: pointer;
border-radius: 0 25px 25px 0 ;
	border-width:0 0 0 5px;
	border-color: green;
}

details {
  border-radius: 0 0 10px 10px;
  background-color: #ccf;
  padding: 2px 6px;
  margin: 0;
  <!-- box-shadow: 3px 3px 4px black; -->
border-radius: 0 25px 25px 0 ;
	border-width:0 0 0 5px;
	border-color: green;
}

details[open] > summary {
  background-color: #ccf;
}

</style>	
"""
	
function Base.show(io, mime::MIME"text/html", fld::Foldable)

	write(io, fboxstyle)
	write(io,"""<details><summary>$(fld.title)</summary><p>""")
    show(io, mime, fld.content)
    write(io,"</p></details>")
end

function fbox(str::Markdown.MD, title = "参考答案")
	Foldable(title,str)
end

#==其他================================#
	
--> = |> 



function print_supertypes(T)
    println(T)
    T == Any || print_supertypes(supertype(T))
    return nothing
end

function print_subtypes(T, indent_level=0)
println(" " ^ indent_level, T)
   for S in subtypes(T)
        print_subtypes(S, indent_level + 2)
   end
   return nothing
end