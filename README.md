# 欢迎光临（￣︶￣）↗　
你可能对这个项目有点迷糊。不是很清楚这个项目是干什么的。所以在开始之前，我要介绍一下。

这个项目是做本地文件的资源管理的。也就是让你的珍贵的文件尽可能按照你的意思移来移去的项目。目前工具只通过命令行来执行，没有搞GUI的打算。

# 本项目的本意
这个项目已经开始了有10多年了。最开始是批处理做的，后来越发觉得我已经能触摸到批处理的上限，例如说我发现它很容易就报错，再例如说变量里面有很个空格就闪退。于是我就把就把项目全都转移到Powershell上来了。

本项目最开始叫做分类管理（这个脚本目前还在，叫做a.ps1），从检查文件的后缀名开始，或者是判断文件的创建日期，按月来粗暴区分文件。然后才到了建立起一套可以自定义命名的规则(Sort_Bank.ini)，让批处理拿着这一套命名规则，从上往下，一条一条地检查当前文件名称是否符合规则条件，才能对大量的文件进行较为细致的区分。

以前的我会有严重的仓鼠病。总感觉什么东西都可以永远归为一类（这也是我开发本项目的原因）。所以会在电脑文件里存储大量各种类型的文件。然而，即使我很早以前就开发了分类管理，但无论如何分类，但当一个文件夹内的文件数量的增多，文件夹内的状况依然会变得越加混乱，管理所需要的时间也随之增多，除非再进一步进行细分。于是这就成了一个一个循环往复，不断细分，明明本意是为降低文件读取和管理成本但最后却是文件夹套娃越来越严重的的问题了。

## 不区分同类文件就会乱，区分了但只要文件多起来也还是会乱，这怎么办呢？

现在我改变了一些想法。我是这样想的：既然“文件管理”是一个问题，那么就要用发展的目光来看待问题，用批判的目光来看待解决方案。

用接地气一点的说法来说，意思就是**大浪淘沙，建立起一套归档机制，每年都把已经一年来没动过的，或者已经判定为不重要的文件或者项目文件夹进行归档或是删除。同时对依然使用项目进行必要性的思考和考量**

再接地气一点的说法就是，除非零管理成本（例如使用Dropit这款自动归档分类管理软件），以后的文件就不能只是单纯按自己的喜好和类型堆放在一起了。比起关心这些文件是否方便按照自己能够理解的方式读取和管理，不如多关心和记录自己目前正在进行的项目进度和想想自己为啥还要做这个项目。

## 现在的情况

把一个专门储存特定项目的文件夹（例如我有一个文件夹，里面的文件都是与我要写的论文的相关内容）叫做Project

每次往这样的文件夹里存储新文件，我都希望有一个文件来储存相关信息，例如我什么时候新增的文件，对这个文件夹有什么想法，工作进度如何。所以我把这个责任交给本项目，而存储这些信息的文件叫做Profile。

Profile是用Markdown格式储存起来，这样无论什么文本编辑工具都可以打开它并进行编辑，删减，或者增加内容。

多个Project可以对应到同一个Profile,而且Project的存储路径可以是不固定在某一处的。但是Profile只存在特定的文件夹里面，离开特定的文件夹，那它也只是一个普通的文件而已。例如本文件，虽然记录了很多关于本项目的想法，但也只是一个普通的Mardown文件而已。

本项目一大特点是如果通过本项目的特定脚本把新的内容输入到Profile里面，那输入的内容前面都会有当前的日期和时间的时间戳。

目前本项目的脚本分为这么几个部分：
1. 使用本项目的push脚本来把指定文件移动到特定Project。
2. 用脚本qu（取）来获取profile的路径，然后再用脚本i来对ProFile 畅所欲言；而每一次提交都带有时间戳。
3. 使用脚本a （原本的分类整理）来对指定目录下的大量的文件进行移动。
4. 重命名工具，Pretime和postime都是把文件的创建日期成为到文件名的一部分的工具。

至于Project，也无需担心藏得有多深，只要能用push脚本随时推送过去，也能通过push脚本随时迅速打开，只需要输入Push和Project的全名或部分名称即可。

总之，我的愿景是：只要打开命令行工具，本地文件资源的调配和工作进度的贡献报告都是垂手可得。

## “听起来你这也不难做呀，我手动移动过去不也行吗？为啥还要打开命令行？我为什么不用Git而是转用你这个项目?”
确实不难。正因为简单，所以假设出故障了，也可以手动移动过去，再自己做个报告。本项目的重点已经从对文件管理转为对对项目的管理，希望是通过这个项目最大程度减少“东一边，西一处，文件想找都不知道丢哪里”的局面。

Git是版本管理工具，我这个是方便自己作记录汇报，移动和打开项目。Git 不能在没有改动的前提下Commit,但我这个哪怕没东西提交都可以对项目说上一大段文字并且便于被任何文字编辑工具修改。两者定位不同。