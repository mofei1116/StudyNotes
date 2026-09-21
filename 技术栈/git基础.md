复制快捷键是 `Ctrl`+`Insert`，粘贴快捷键是 `Shift`+`Insert`或鼠标滚轮

# 基本命令

- `git config --global user.name <用户名>`：设置用户名
- `git config --global user.email <邮箱>`：设置邮箱
- `git status 文件名`：查看单个文件状态
- `git status`:查看所有文件状态
- `git rm --cached 文件名`：从暂存区stage中移除
- `git add .`：添加所有文件到stage
- `git commit -m 消息内容`：提交stage中的文件到本地repository
- `git log 选项`：查看仓库提交日志，选项：
	- `--all`：显示所有分支
	- `--ptrtty=online`：将信息显示为一行
	- `--abbrev-commit`：是输出的commitld更简短
	- `--graph`：以图的形式显示
	- 利用alias设置别名：`alias git-log='git log --pretty=oneline --all --graph --abbrev-commit'`
- 设置永久别名：
	1.创建`~/.bashrc`文件
	2.把`alias git-log='git log --pretty=oneline --all --graph --abbrev-commit'`加到`.bashrc`里面
	3.`source ~/.bashrc`
- `git reset --hard commitID`：回退到指定的版本（包括之前的和之后的），如果不知道之后的版本ID，可以用`git reflog`查看已删除的记录

# 分支常用命令

工作区只能在一个分支工作

`HEAD`指向谁，谁就是当前分支

- `git branch [参数]`：查看本地分支
	- `-r`：查看远程仓库分支
	- `-a`：查看所有分支
- `git branch 分支名`：创建分支，创建的新分支会建立在当前分支的版本之上，所以新建的分支会有当前分支的内容
- `git checkout 分支名`：切换分支
- `git checkout -b 分支名`：创建并切换分支，切换分支后新的分支会把原来的工作区的文件覆盖，所以切换分支之前要把原来的暂存区里面的东西提交了
- `git merge 分支名`：合并指定分支到当前分支
- `git branch -d 分支名`：删除指定分支（不能删除当前分支）
- `git branch -D 分支名`：不做任何检查强制删除

若两个分支有冲突（同一文件的同一行，不同行会自动合并），需要手动更改冲突的地方，再add，再commit

master和子分支都有修改，合并时才会有分支效果，否则git 会采用合并的快进模式fast-forward

# 远程仓库

## 基本配置

- `ssh-keygen -t rsa`：生成SSH公钥，不断回车，若公钥已存在，则自动覆盖
- `cat ~/.ssh/id_rsa.pub`：获取公钥
- `ssh -T git@gitee.com`：验证是否配置成功(以码云为例)
- `git remote add <远端名(一般默认为origin)> SSH`：添加远程仓库，仓库地址用SSH
- `git remote`：查看远程仓库

## 推送

- `git push [-f] [--set-upstream] 远端名称 本地分支名:远端分支名`：本地分支推送到远程分支，如果远程分支名和本地分支名称相同，则可以只写本地分支`git push origin master`
	- `-f`：表示强制覆盖
	- `--set-upstream`：推送到远端的同时并且建立起和远端分支的关联关系，如果当前分支已经和远端分支关联，则可以省略分支名和远端名`git push`
- `git branch -vv`：查看本地分支与远程分支的关联关系
- `git clone [参数] 路径 [本地文件夹]`：从远程仓库克隆，一般情况下克隆不需要太频繁（只需要一次）
- `git fetch 远程仓库名 远程仓库里面的分支名`：从远程仓库抓取，`fetch`不会将抓取到的分支与本地分支合并，不指定远端名和分支名就抓取与本地当前分支相关联的分支
- `git pull <远程仓库名> <远程仓库里面的分支名>`：从远端拉取，`pull`会自动与本地分支合并，相当于`fetch`+`merge`，不指定远端名和分支名就拉取与本地当前分支相关联的分支

远程解决冲突基本思路与合并分支思路一样，解决有冲突的地方，再add，再commit

在push之前，要先pull到本地解决冲突再push