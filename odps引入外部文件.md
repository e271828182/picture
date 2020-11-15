odps处理zip文件

 ```python
import sys
sys.path.insert(0,'http://schedule@{env}inside.cheetah.alibaba-inc.com/scheduler/res?id=12345')
 ```

如果第三方包里面有so文件，可以在服务器上先解压

```python
import sys
import os
Pillow_archive_file = 'http://schedule@{env}inside.cheetah.alibaba-inc.com/scheduler/res?id=12345'
Pillow_archive_file_dir = os.path.dirname(Pillow_archive_file)
os.system('unzip ' + Pillow_archive_file + ' -d ' + Pillow_archive_file_dir)
sys.path.append(Pillow_archive_file_dir)
from PIL import Image
```



odps处理py文件

1. 方式一（借鉴py的import方案）

```python
spec = importlib.util.spec_from_file_location("update_legao_dataset", 'http://schedule@{env}inside.cheetah.alibaba-inc.com/scheduler/res?id=12345')
update_legao_dataset = importlib.util.module_from_spec(spec)
spec.loader.exec_module(update_legao_dataset)
```

2. 方式二（最优雅）

```python
exec(open('http://schedule@{env}inside.cheetah.alibaba-inc.com/scheduler/res?id=12345').read())
```

3. 方式三(odps文档推荐)

```python
## 资源文件名：python_import.py
def printname():
    print('test2')
## pyodps调用逻辑
import sys
import os
a='http://schedule@{env}inside.cheetah.alibaba-inc.com/scheduler/res?id=12345' ##引用资源路径
resPy=os.path.dirname(os.path.abspath(a)) ## 获取执行时的路径
b=resPy+"/python_import.py" ## 获取到执行时具体的文件路径
os.rename(a,b) ## 给文件路径重命名
sys.path.append(os.path.dirname(os.path.abspath(b))) #将资源引入工作空间
import python_import #引用资源
python_import.printname() #调用方法
```

