



![](https://i.loli.net/2020/10/31/S1kcv5nhltMO2bD.png)

在朋友的推荐下装了Windows Terminal，我本以为这玩意自带了Bash，结果装完朋友才告诉我那个是WSL……得，那我还是再把Git Bash下回来吧。
注：本人使用的Windows Terminal版本为1.1.2021.0，在商店里已经没有Preview标志了
从网上找教程搞了半天，终于把Git Bash扔了Windows Terminal里，但结果……

![](https://i.loli.net/2020/10/31/Lmd4Q7DlT8c1uVN.jpg)

这玩意咋不支持中文啊？而且cd也进不去中文路径？？？
看了下网上的教程说是让下个旧版覆盖就行，嗯……总感觉很不爽，而且我寻思人家自带的git-bash.exe就能正常用，说是版本的问题总感觉有哪里不对。
于是我仔细观察了一下git-bash.exe这个小玩意，然后在它启动的时候发现了不一样的地方

![](https://i.loli.net/2020/10/31/iXQsTNolKHjcWJG.jpg)

通常网上的教程都是直接让把git安装目录下的/bin/bash.exe填上就完事了，但git自己的git-bash.exe却会自带两个参数运行，查了下这两个参数的作用，-i是以交互模式运行bash，--login参数令bash自己登录一个shell代替当前shell，这应该是在linux那边的说法，在windows这边应该就只有执行登录行为这一用途。
而在git安装目录/etc/profile.d/lang.sh中可以看到，bash在登录时会自动设置语言及字符编码环境，只是因为没有--login参数而没有执行这一脚本。profile.d目录内除了git-prompt.sh以外其他脚本文件都是由profile脚本文件调用的，当没有--login这一参数时，profile脚本不会执行，lang.sh自然无法设置编码环境。

![](https://i.loli.net/2020/10/31/tks6JdAMeTa4uQh.jpg)

那么问题应该解决了吧？还没

![](https://i.loli.net/2020/10/31/fqjB34pkGiuh7W6.jpg)

虽然中文能正常显示了，但在路径中有中文时有时会让前面颜色消失并出现个32m，标题栏也会乱码。
标题栏乱码的原因是UTF-8编码的字符串被当作GBK强行显示导致的，这个除非改Windows Terminal源码不然没法解决（至少写文章的时候我是没想到的，现已在文章末端补充解决方案），而恰恰是这个标题乱码导致了32m的出现，标题样式被定义在git-prompt.sh文件中，如下图

![](https://i.loli.net/2020/10/31/PfZUwWC4yoimuIl.jpg)

$PWD中存储着当前的路径，但Windows Terminal把$PWD中以UTF-8存储的字符串当作GBK来获取，结果获取多了几个字符（也可能是少了）导致后面设置颜色的32m无法正常显示了。
Windows Terminal在启动终端时会设置一个名为WT_SESSION的环境变量，因此只要判断有没有这个环境变量，让脚本设置不同的标题格式就可以了

![](https://i.loli.net/2020/10/31/zZQDEd8kptiLc6x.jpg)

![](https://i.loli.net/2020/10/31/fqjB34pkGiuh7W6.jpg)

嗯，效果不错，除了我电脑的网络名因为里面带中文所以不显示，不过也很少有人给自己机子设置中文网络名的，这是我自己的问题，而我也懒得解决= =
图上的脚本也显示了它会优先从用户目录加载这个啥啥啥样式，如果不愿意修改git安装目录下的文件，也可以自己在用户目录里搞，具体就不多说了
{
 "guid": "{a387a071-e0b9-4720-99ae-9716ccfe4f9f}",
 "name": "Git Bash",
 "commandline": "C:\\Program Files\\Git\\bin\\bash.exe --login -i",
 "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico"
}
这是我的Git Bash在Windows Terminal里的配置，仅供参考
那么接下来就是要把Windows Terminal加入右键菜单豪华午餐了！直接放出注册表文件
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt]
"SubCommands"=""
"MUIVerb"="&Windows Terminal"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell]

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\bash]
@="Git Bash"
"Icon"="C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\bash\command]
@="\"C:\\Users\\你的用户文件夹名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {a387a071-e0b9-4720-99ae-9716ccfe4f9f} -d \"%V%\""

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\cmd]
@="命令提示符"
"Icon"="cmd.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\cmd\command]
@="\"C:\\Users\\你的用户文件夹名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {0caa0dad-35be-5f56-a8ff-afceeeaa6101} -d \"%V\""

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\ps]
@="PowerShell"
"Icon"="powershell.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\ps\command]
@="\"C:\\Users\\你的用户文件夹名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {61c54bbd-c2c6-5271-96e7-009a87ff44bf} -d \"%V\""
需要将“你的用户文件夹名”替换为你自己的用户在C:\Users里的文件夹名，command中的-p参数后面跟的GUID是Windows Terminal设置文件中终端类型对应的GUID，当然也可以把GUID换成终端的name，换之后是这个样子
wt.exe -p "Windows PowerShell"
直接运行这个命令也是可以直接启动PowerShell终端的
wt.exe的-d参数是设置启动目录，后面的%V是由资源管理器传入的点击右键菜单的文件夹路径
Icon是设置图标，可以根据自己需要设置
效果如下

![](https://i.loli.net/2020/10/31/WpBQCvijbcAnT8l.jpg)

点击各个终端就可以直接进入Windows Terminal里相应的终端，目前Windows Terminal还没法自动合并已打开的终端窗口，也可能是我没找到相应的方法。

后续补充，关于git bash中文问题以及注册表的一些问题
我自己又修改了一下并写成了单独的git-prompt.sh文件（优先级我记得高于安装目录的文件），现在可以正常显示标题、判断管理员权限、正常显示中文计算机名
ISROOT="$(net session >/dev/null 2>&1 && echo ROOT)" # Check Administrator Permission
HOSTNAME="$(echo $HOSTNAME | iconv -f gbk -t utf-8)" # Fix Hostname encoding
if [[ -n "$WT_SESSION" || -n "$VSCODE_GIT_IPC_HANDLE" ]];then # Windows Terminal & VSCode
	PS1='\[\033]0;$TITLEPREFIX:`echo $PWD | iconv -f utf-8 -t gbk`\007\]'
else
	PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' # set window title
fi
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'\[\033[32m\]'       # change to green
if test -n "$ISROOT"
then
    PS1="$PS1"'root@$HOSTNAME '             # root@host<space>
else
    PS1="$PS1"'\u@$HOSTNAME '             # user@host<space>
fi
PS1="$PS1"'\[\033[35m\]'       # change to purple
PS1="$PS1"'$MSYSTEM '          # show MSYSTEM
PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
PS1="$PS1"'\w'                 # current working directory
if test -z "$WINELOADERNOEXEC"
then
	GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
	COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
	COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
	COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
	if test -f "$COMPLETION_PATH/git-prompt.sh"
	then
		. "$COMPLETION_PATH/git-completion.bash"
		. "$COMPLETION_PATH/git-prompt.sh"
		PS1="$PS1"'\[\033[36m\]'  # change color to cyan
		PS1="$PS1"'`__git_ps1`'   # bash function
	fi
fi
PS1="$PS1"'\[\033[0m\]'        # change color
PS1="$PS1"'\n'                 # new line
if test -n "$ISROOT"
then
	PS1="$PS1"'# '                 # Not always
else
	PS1="$PS1"'$ '                 # prompt: always $
fi
unset ISROOT
这个git-prompt.sh放在C:\Users\当前登录用户名\.config\git目录下面，在git bash里就是~/.config/git，上面好像有说
判断是否管理员启动的核心是net session命令的调用，这个命令需要管理员权限才能正常返回，所以配合&&和||就能让它根据是否有权限返回特定的值，开头判断一下就OK了
标题和计算机网络名的问题我用iconv命令转换了一下就OK了，好像会稍微慢一下
效果：

![](https://i.loli.net/2020/10/31/OKEkZGbsHoqc6lM.jpg)


注册表问题
之前说是用%V代替计算机当前路径，那个其实会有些问题，因为%V传入的路径没有对“\”这个转义符做转换，虽然在比较长的路径中wt会自动将其视为非转义符，但对于盘符根目录就没这种好事了，所以推荐用“.”代替“%V”
另外我搜了下怎么在命令行弹出UAC框框，费了点劲，大致就是用mshta执行vbs脚本的ShellExecute，在参数中设定启动方式为runas，我把这个以管理员身份执行的wt也放在了右键菜单（需按住shift再打开右键菜单）
新的注册表文件
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt]
"SubCommands"=""
"MUIVerb"="Windows &Terminal"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell]

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\bash]
@="Git Bash"
"Icon"="C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\bash\command]
@="\"C:\\Users\\你的用户名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {a387a071-e0b9-4720-99ae-9716ccfe4f9f} -d ."

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\cmd]
@="命令提示符"
"Icon"="cmd.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\cmd\command]
@="\"C:\\Users\\你的用户名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {0caa0dad-35be-5f56-a8ff-afceeeaa6101} -d ."

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\ps]
@="PowerShell"
"Icon"="powershell.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wt\shell\ps\command]
@="\"C:\\Users\\你的用户名\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe\" -p {61c54bbd-c2c6-5271-96e7-009a87ff44bf} -d ."

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas]
"SubCommands"=""
"MUIVerb"="Windows &Terminal (Admin)"
"Extended"=""
"HasLUAShield"=""

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell]

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\bash]
@="Git Bash"
"Icon"="GitBash安装目录\\mingw64\\share\\git\\git-for-windows.ico"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\bash\command]
@="mshta.exe vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"wt.exe\",\"-p {a387a071-e0b9-4720-99ae-9716ccfe4f9f} -d .\",\"\",\"runas\",1)(window.close)"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\cmd]
@="命令提示符"
"Icon"="cmd.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\cmd\command]
@="mshta.exe vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"wt.exe\",\"-p {0caa0dad-35be-5f56-a8ff-afceeeaa6101} -d .\",\"\",\"runas\",1)(window.close)"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\ps]
@="PowerShell"
"Icon"="powershell.exe"

[HKEY_CLASSES_ROOT\Directory\Background\shell\wtrunas\shell\ps\command]
@="mshta.exe vbscript:CreateObject(\"Shell.Application\").ShellExecute(\"wt.exe\",\"-p {61c54bbd-c2c6-5271-96e7-009a87ff44bf} -d .\",\"\",\"runas\",1)(window.close)"

记得用之前先把路径以及GUID改成你自己的
mshta启动wt不需要完整路径，惊不惊喜意不意外，但写mshta那么长一串还是太要命了所以一般不用

![](https://i.loli.net/2020/10/31/WpBQCvijbcAnT8l.jpg)

嗯也就多了一个Admin，没写成中文是因为会变得很长很长很长很长……

```json
// This file was initially generated by Windows Terminal 1.3.2651.0
// It should still be usable in newer versions, but newer versions might have additional
// settings, help text, or changes that you will not see unless you clear this file
// and let us generate a new one for you.

// To view the default settings, hold "alt" while clicking on the "Settings" button.
// For documentation on these settings, see: https://aka.ms/terminal-documentation
{
    "$schema": "https://aka.ms/terminal-profiles-schema",

    "defaultProfile": "{1c4de342-38b7-51cf-b940-2309a097f589}",

    // You can add more global application settings here.
    // To learn more about global settings, visit https://aka.ms/terminal-global-settings

    // If enabled, selections are automatically copied to your clipboard.
    "copyOnSelect": false,

    // If enabled, formatted data is also copied to your clipboard
    "copyFormatting": false,

    // A profile specifies a command to execute paired with information about how it should look and feel.
    // Each one of them will appear in the 'New Tab' dropdown,
    //   and can be invoked from the commandline with `wt.exe -p xxx`
    // To learn more about profiles, visit https://aka.ms/terminal-profile-settings
    "profiles":
    {
        "defaults":
        {
            // Put settings here that you want to apply to all profiles.
        },
        "list":
        [
            {
                "acrylicOpacity":0.9,// 透明度
                "useAcrylic":true,// 是否开启透明度
                "closeOnExit":true,// 关闭的时候退出命令终端
                "colorScheme":"Campbell",// 样式配置，如果没有这个样式可以自行修改或者注释
                "commandline":"C:\\ProgramFiles\\Git\\bin\\bash.exe --login -i",// gitbash的命令行所在位置
                // "commandline":"C:\\ProgramFiles\\Git\\git-bash.exe --cd-to-home",
                // "fontSize":12,// 终端字体大小
                "guid":"{1c4de342-38b7-51cf-b940-2309a097f589}",// 唯一的标识
                "icon":"%SystemDrive%\\ProgramFiles\\Git\\mingw64\\share\\git\\git-for-windows.ico",// git的图标，打开终端时候会看到
                "name":"Git-Bash" // tab栏的标题显示
                // "padding":"10, 0, 10, 10",// 边距
                // "startingDirectory":"%HOMEDRIVE%%HOMEPATH%"// gitbash的启动的位置
            },
            {
                // Make changes here to the powershell.exe profile.
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "name": "Windows PowerShell",
                "commandline": "powershell.exe",
                "hidden": false
            },
            {
                // Make changes here to the cmd.exe profile.
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
                "name": "命令提示符",
                "commandline": "cmd.exe",
                "hidden": false
            },
            // {
            //     "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
            //     "hidden": false,
            //     "name": "Azure Cloud Shell",
            //     "source": "Windows.Terminal.Azure"
            // }
            
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": true,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            }
        ]
    },

    // Add custom color schemes to this array.
    // To learn more about color schemes, visit https://aka.ms/terminal-color-schemes
    "schemes": [],

    // Add custom actions and keybindings to this array.
    // To unbind a key combination from your defaults.json, set the command to "unbound".
    // To learn more about actions and keybindings, visit https://aka.ms/terminal-keybindings
    "actions":
    [
        // Copy and paste are bound to Ctrl+Shift+C and Ctrl+Shift+V in your defaults.json.
        // These two lines additionally bind them to Ctrl+C and Ctrl+V.
        // To learn more about selection, visit https://aka.ms/terminal-selection
        { "command": {"action": "copy", "singleLine": false }, "keys": "ctrl+c" },
        { "command": "paste", "keys": "ctrl+v" },

        // Press Ctrl+Shift+F to open the search box
        { "command": "find", "keys": "ctrl+shift+f" },

        // Press Alt+Shift+D to open a new pane.
        // - "split": "auto" makes this pane open in the direction that provides the most surface area.
        // - "splitMode": "duplicate" makes the new pane use the focused pane's profile.
        // To learn more about panes, visit https://aka.ms/terminal-panes
        { "command": { "action": "splitPane", "split": "auto", "splitMode": "duplicate" }, "keys": "alt+shift+d" }
    ]
}
```

ps:

设置右键注册表，上图

![](https://i.loli.net/2020/10/31/8zKhLTcsdo4gWRU.png)

处理git的乱码问题，更改C:\ProgramFiles\Git\etc\profile.d\git-prompt.sh

```sh
if test -f /etc/profile.d/git-sdk.sh
then
	TITLEPREFIX=SDK-${MSYSTEM#MINGW}
else
	TITLEPREFIX=$MSYSTEM
fi

if test -f ~/.config/git/git-prompt.sh
then
	. ~/.config/git/git-prompt.sh
else
	# PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' # set window title
	if [[ -n "$WT_SESSION" || -n "$VSCODE_GIT_IPC_HANDLE" || -n "$MSYSTEM" ]];then # Windows Terminal & VSCode & CMD
		PS1='\[\033]0;$TITLEPREFIX:`echo $PWD | iconv -f utf-8 -t gbk`\007\]'
	else
		PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' # set window title
	fi

	PS1="$PS1"'\n'                 # new line
	PS1="$PS1"'\[\033[32m\]'       # change to green
	PS1="$PS1"'\u@\h '             # user@host<space>
	PS1="$PS1"'\[\033[35m\]'       # change to purple
	PS1="$PS1"'$MSYSTEM '          # show MSYSTEM
	PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
	PS1="$PS1"'\w'                 # current working directory
	if test -z "$WINELOADERNOEXEC"
	then
		GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
		COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
		COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
		COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
		if test -f "$COMPLETION_PATH/git-prompt.sh"
		then
			. "$COMPLETION_PATH/git-completion.bash"
			. "$COMPLETION_PATH/git-prompt.sh"
			PS1="$PS1"'\[\033[36m\]'  # change color to cyan
			PS1="$PS1"'`__git_ps1`'   # bash function
		fi
	fi
	PS1="$PS1"'\[\033[0m\]'        # change color
	PS1="$PS1"'\n'                 # new line
	PS1="$PS1"'$ '                 # prompt: always $
fi

MSYS2_PS1="$PS1"               # for detection by MSYS2 SDK's bash.basrc

# Evaluate all user-specific Bash completion scripts (if any)
if test -z "$WINELOADERNOEXEC"
then
	for c in "$HOME"/bash_completion.d/*.bash
	do
		# Handle absence of any scripts (or the folder) gracefully
		test ! -f "$c" ||
		. "$c"
	done
fi

```

另一个好用的windows的命令行

https://github.com/cmderdev/cmder

用Hyper-V安装虚拟机：

1. 增加网络
2. 安装虚拟机
3. 安装设置之后，再次重启，DVD驱动器设置设置为无，不然会一直循环安装
4. ps和cmd，git-bash可以ssh登录，不需要安装xshell之类的工具