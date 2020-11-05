## **解决方案**

- 在cygwin中，使用git add添加要提交的文件的时候，如果文件名是中文，会显示形如 274\232\350\256\256\346\200\273\347\273\223.png 的乱码。

    - 解决方案：在bash提示符下输入： `git config --global core.quotepath false`

    - core.quotepath设为false的话，就不会对0x80以上的字符进行quote。中文显示正常。

        

- 在MsysGit中，使用git log显示提交的中文log乱码。

    解决方案：

    1. 设置git gui的界面编码 `git config --global gui.encoding utf-8`

    2. 设置 commit log 提交时使用 utf-8 编码，可避免服务器上乱码，同时与linux上的提交保持一致！ `git config --global i18n.commitencoding utf-8`

    3. 使得在 $ git log 时将 utf-8 编码转换成 gbk 编码，解决Msys bash中git log 乱码。`git config --global i18n.logoutputencoding gbk`

    4. 使得 git log 可以正常显示中文（配合i18n.logoutputencoding = gbk)，在 /etc/profile 中添加：`export LESSCHARSET=utf-8`

        

- 在MsysGit自带的bash中，使用ls命令查看中文文件名乱码。cygwin没有这个问题。

    - 解决方案：

        1. 使用 `ls --show-control-chars` 命令来强制使用控制台字符编码显示文件名，即可查看中文文件名。

        2. 为了方便使用，可以编辑 /etc/git-completion.bash ，新增一行 alias ls=“ls --show-control-chars”

            

- 终极的解决方案是通过修改git和TortoiseGit源码实现，有网友这么做了：让Windows下Git和TortoiseGit支持中文文件名/UTF-8 ，也可以直接访问这个开源的Google项目：utf8-git-on-windows 。

    

- 如果不抗拒命令行的话，直接用Cygwin来提交Git库。因为Cygwin其实是一个在Windows平台上的模拟器，它完全模拟GNU/Linux的方式运行，所以Cygwin中的Git是采用UTF-8编码来保存中文的。