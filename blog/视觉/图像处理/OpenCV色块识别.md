色块识别 (Color Blob Detection 或 Color Tracking) 是一种计算机视觉技术，它的核心目标是在图像或视频流中，根据其颜色特征来定位、跟踪和识别出特定的区域或物体。

色块识别一般也是初学者接触视觉后第一个想要做的算法，并且很多比赛事实上也很常见色块识别的应用场景，为此我们就来详细介绍一下色块识别如何实现

# 一、色块识别具体流程

首先这里给出色块识别的一个完整代码示例，随后我们会对代码进行逐步讲解。

在 OpenCV 中，色块识别通常涉及以下几个步骤：

1. **颜色空间转换**：首先，将图像从 BGR（OpenCV 默认的颜色空间）转换为 HSV（色调、饱和度、明度）颜色空间。HSV 颜色空间更适合进行颜色分割，因为它将颜色信息与亮度信息分离开来。

   ```python
   import cv2
   import numpy as np

   # 读取图像
   image = cv2.imread('image.jpg')
   # 转换为 HSV 颜色空间
   hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
   ```


2. **定义颜色范围**：确定要识别的颜色的 HSV 范围。可以通过实验来找到合适的下限和上限值。

   ```python
    
    # 定义颜色范围（例如，红色）
    lower_color = np.array([0, 100, 100])
    upper_color = np.array([10, 255, 255])
    ```

3. **创建掩膜**：使用 `cv2.inRange()` 函数创建一个二值掩膜，掩膜中符合颜色范围的像素点将被设置为白色（255），其他像素点将被设置为黑色（0）。

    ```python
    # 创建掩膜
    mask = cv2.inRange(hsv_image, lower_color, upper_color)
    ```
4. **形态学操作**：为了去除噪声，可以对掩膜进行形态学操作，如腐蚀和膨胀。

    ```python
    # 定义核
    kernel = np.ones((5, 5), np.uint8)
    # 腐蚀操作
    mask = cv2.erode(mask, kernel, iterations=1)
    # 膨胀操作
    mask = cv2.dilate(mask, kernel, iterations=1)
    ```

5. **查找轮廓**：使用 `cv2.findContours()` 函数在掩膜中查找轮廓，从而定位色块的位置。

    ```python
    # 查找轮廓
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    ```

6. **绘制轮廓**：在原始图像上绘制找到的轮廓，以可视化识别结果。

    ```python
    # 绘制轮廓
    cv2.drawContours(image, contours, -1, (0, 255, 0), 3)
    ```

完整的代码示例如下：

```python
import cv2
import numpy as np
# 读取图像
image = cv2.imread('image.jpg')
# 转换为 HSV 颜色空间
hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
# 定义颜色范围（例如，红色）
lower_color = np.array([0, 100, 100])
upper_color = np.array([10, 255, 255])
# 创建掩膜
mask = cv2.inRange(hsv_image, lower_color, upper_color)
# 定义核
kernel = np.ones((5, 5), np.uint8)
# 腐蚀操作
mask = cv2.erode(mask, kernel, iterations=1)
# 膨胀操作
mask = cv2.dilate(mask, kernel, iterations=1)
# 查找轮廓
contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
# 绘制轮廓
cv2.drawContours(image, contours, -1, (0, 255, 0), 3)
# 显示结果
cv2.imshow('Color Blob Detection', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

# 二、具体事例

现在我们进行具体的实践，针对以下图片，要求识别到图片中的红色区域并进行标记：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204015138457.png"></div>

代码如下：

```python
import cv2
import numpy as np
import os
# 读取图像

# 将图片路径设为相对于脚本文件所在目录的路径，确保从任意工作目录运行都能找到图片
try:
    # 获取脚本所在的目录
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    # 假设图片在脚本同目录下
    IMAGE_PATH = os.path.join(SCRIPT_DIR, 'RedBall2.PNG')
except NameError:
    # 如果在交互式环境中运行， os.path.abspath(__file__) 会出错
    IMAGE_PATH = 'RedBall2.PNG' # 尝试在当前工作目录下查找
    
# 转换为 HSV 颜色空间
image = cv2.imread(IMAGE_PATH)
hsv_image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
# 定义颜色范围（例如，红色）
lower_color = np.array([29, 47, 0])
upper_color = np.array([179, 255, 255])
# 创建掩膜
mask = cv2.inRange(hsv_image, lower_color, upper_color)
# 定义核
kernel = np.ones((5, 5), np.uint8)
# 腐蚀操作
mask = cv2.erode(mask, kernel, iterations=1)
# 膨胀操作
mask = cv2.dilate(mask, kernel, iterations=1)
# 查找轮廓
contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# 如果检测到多个分散的色块，计算合并掩膜的外接矩形并绘制一个整体框
if contours:
    # 绘制单个轮廓（深绿，便于调试）
    cv2.drawContours(image, contours, -1, (0, 128, 0), 2)

    # 基于掩膜的非零像素计算包围矩形，包含所有分散块
    non_zero = cv2.findNonZero(mask)
    if non_zero is not None:
        x, y, w, h = cv2.boundingRect(non_zero)
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 3)

# 显示结果
cv2.imshow('Color Blob Detection', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

处理后的效果如下：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204015335736.png"></div>

绿色矩形框框选到的区域即为红色区域，球内的绿色轮廓线即颜色阈值识别到的实际区域。

接下来我们将具体讲一讲这其中的细节和相关知识点，并讲一些扩展

# 三、颜色空间转换

## 3.1 什么是颜色空间？

众所周知颜色是一种连续的现象，它意味着有无数种颜色。但是，人类的眼睛和感知能力是有限的。所以，为了识别这些颜色，我们需要一种媒介或这些颜色的表示。这也因此诞生了颜色空间的概念。

许多人都知道在绘画时可以使用红色、黄色和蓝色这三种原色生成不同的颜色，这些颜色就定义了一个色彩空间。我们将品红色的量定义为 X坐标轴、黄色的量定义为 Y 坐标轴、蓝色的量定义为 Z 坐标轴，这样就得到一个三维空间，每种可能的颜色在这个三维空间中都有一个位置。

但是，这并不是一个色彩空间，它只是我们现实当中的三原色。而在计算机当中，通常使用 RGB（红色、绿色、蓝色）色彩空间定义，这是另外一种生成同样颜色的方法，红色、绿色、蓝色被当作 X、Y 和 Z坐标轴。另外一个生成同样颜色的方法是使用色相（X 轴）、饱和度（Y 轴）和明度（Z 轴）表示，这种方法称为 HSB 色彩空间。另外还有许多其它的色彩空间，许多可以按照这种方法用三维（X、Y、Z）、更多或者更少维表示，例如 CMYK（青色、品红色、黄色、黑色）色彩空间是用四个维度表示颜色的。

颜色空间是用来表示颜色的一种数学模型。不同的颜色空间有不同的表示方法和用途。常见的颜色空间包括： RGB、HSV、Lab 等。

接下来我们就介绍一下几种常见的颜色空间：

## 3.2 RGB颜色空间

RGB 颜色空间是计算机图像处理中最常用的颜色空间之一。它由红色（Red）、绿色（Green）和蓝色（Blue）三个通道组成，每个通道的取值范围通常为 0-255。通过调整这三个通道的值，可以表示出各种不同的颜色。

但是RGB颜色空间并不适合进行颜色分割，因为它将颜色信息与亮度信息混合在一起，RGB的三个通道都会受到光照的强烈影响，导致在不同光照条件下颜色识别效果不佳，并且由于RGB 颜色空间利用三个颜色分量的线性组合来表示颜色，任何颜色都与这三个分量有关，而且这三个分量是高度相关的，所以连续变换颜色时并不直观，想对图像的颜色进行调整需要更改这三个分量才行。

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251203100656606.png"></div>


在OpenCV中，默认的颜色空间就是BGR（蓝色、绿色、红色），它与RGB颜色空间类似，只是通道顺序不同。

当我们在OpenCV中读取一张图片时，实际上得到的是BGR格式的图像数据。

```py
# 1. 读取图片，得到 NumPy 数组
img = cv2.imread(IMAGE_PATH)

# 2. 直接使用 print() 函数输出整个数组的内容
# 如果图片很大，print() 只会输出头部和尾部的部分数据，并用省略号（...）表示中间省略的数据。
if img is not None:
    print(img)
else:
    print("图片读取失败，img 为 None。")
```

我们通过上面的代码可以看到读取的图片数据是一个三维数组，第三个维度表示颜色通道，顺序是BGR。

运行结果如下：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204010640749.png"></div>

## 3.3 HSV 颜色空间

HSV 颜色空间由色调（Hue）、饱和度（Saturation）和明度（Value）三个分量组成。HSV 颜色空间更符合人类对颜色的感知方式，因此在颜色分割和识别任务中更为常用。

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204011059764.png"></div>

用上图这个圆柱体来表示 HSV 颜色空间，圆柱体的横截面可以看做是一个极坐标系 ，H 用极坐标的极角表示，S 用极坐标的极轴长度表示，V 用圆柱中轴的高度表示。

HSV颜色空间相比如RGB颜色空间最大的优势就在于，HSV颜色空间将颜色信息（H 和 S）与亮度信息（V）分离开来，这样在不同光照条件下，颜色的识别效果更稳定。比如再HSV颜色空间中，深蓝色和浅蓝色的色调（H）是相同的，只是饱和度（S）和明度（V）不同，而在RGB颜色空间中，深蓝色和浅蓝色的RGB值差异较大。

那么HSV颜色空间中的色调究竟是什么样子的呢？让我们来看下图：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204012009045.png"></div>

在这个图片中，颜色圆环上所有的颜色都是光谱上的颜色，从红色开始按逆时针方向旋转，Hue=0 表示红色，Hue=120 表示绿色，Hue=240 表示蓝色等等。

我们在来研究一下HSV中的饱和度和明度，依旧是看下图：
<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204011531633.png"></div>

以上图为例，其中水平方向表示饱和度，饱和度表示颜色接近光谱色的程度。饱和度越高，说明颜色越深，越接近光谱色饱和度越低，说明颜色越浅，越接近白色。饱和度为0表示纯白色。取值范围为0～100%，值越大，颜色越饱和。

竖直方向表示明度，决定颜色空间中颜色的明暗程度，明度越高，表示颜色越明亮，范围是 0-100%。明度为0表示纯黑色（此时颜色最暗）。

可以通俗理解为：

在Hue一定的情况下，饱和度减小，就是往光谱色中添加白色，光谱色所占的比例也在减小，饱和度减为0，表示光谱色所占的比例为零，导致整个颜色呈现白色。

明度减小，就是往光谱色中添加黑色，光谱色所占的比例也在减小，明度减为0，表示光谱色所占的比例为零，导致整个颜色呈现黑色。

这也就是为什么HSV对用户来说是一种比较直观的颜色模型。我们可以很轻松的指定颜色角H，并让V=S=1，然后通过向其中加入黑色和白色来得到我们需要的颜色。增加黑色可以减小V而S不变，同样增加白色可以减小S而V不变。例如，要得到深蓝色，V=0.4 S=1 H=240度。要得到浅蓝色，V=1 S=0.4 H=240度。

# 四、图像掩膜 
图像掩膜（Mask）是一种二值图像，用于在图像处理中选择性地处理图像的某些部分。在色块识别中，掩膜用于隔离出符合特定颜色范围的像素点。

我们显示刚刚创建的掩膜图像则为下图：
<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204022012114.png"></div>

可以看到通过颜色阈值，我们将图像中的红色区域提取了出来，掩膜中白色部分表示符合颜色范围的像素点，黑色部分表示不符合颜色范围的像素点。


    事实上任意一张与原始图像大小相同的二值或布尔图像都可以作为掩膜使用。掩膜可以看作是一个蒙版，定义了图像中哪些区域需要被处理，哪些区域需要被忽略。掩膜中的白色（255）区域表示需要处理的部分，而黑色（0）区域表示需要忽略的部分。

    掩膜经常与位运算结合使用，例如与（AND）、或（OR）和非（NOT）操作，以实现更复杂的图像处理任务。可以实现以下任务：

    1. 提取感兴趣区,用预先制作的感兴趣区掩模与待处理图像相乘,得到感兴趣区图像,感兴趣区内图像值保持不变,而区外图像值都为0。 
    2. 屏蔽作用,用掩模对图像上某些区域作屏蔽,使其不参加处理或不参加处理参数的计算,或仅对屏蔽区作处理或统计。 
    3. 结构特征提取,用相似性变量或图像匹配方法检测和提取图像中与掩模相似的结构特征。 
    4. 特殊形状图像的制作。

    在这里并不过多阐述淹膜与原图像进行计算的方法和结果，有兴趣的可以自行查找，因为我们在色块识别中在得到掩膜后并没有拿掩膜与原图像进行计算去实现比如抠图的功能，而是直接在掩膜上进行轮廓检测，获取到轮廓坐标后再在原图像上绘制轮廓。因为掩膜和原图像的大小本身是相同的，所以轮廓坐标是可以直接对应到原图像上的。

在色块识别中掩膜的思路是：

1. 创建一个与原始图像大小相同的二值图像，初始值全部为0（黑色）。
2. 遍历原始图像的每个像素点，如果该像素点的颜色在指定的颜色范围内，则将掩膜对应位置的像素值设置为255（白色）；否则保持为0。
3. 使用掩膜对原始图像进行操作，只处理掩膜中为255的像素点。

在OpenCV中，可以使用 `cv2.inRange()` 函数来创建掩膜。该函数接受三个参数：输入图像、颜色范围的下限和上限，返回一个二值掩膜。

# 五、形态学运算

形态学运算是一种基于图像形状的图像处理技术，主要用于二值图像的处理。

形态学运算的基本操作包括腐蚀（Erosion）和膨胀（Dilation）。这些操作可以帮助我们去除噪声、填补空洞以及连接断裂的部分，从而改善掩膜的质量。

## 5.1 腐蚀（Erosion）

腐蚀操作会使图像中的白色区域（前景）变小。它通过将图像与一个结构元素（通常是一个小的矩形或圆形）进行卷积来实现。如果结构元素完全包含在白色区域内，则该区域保持为白色；否则，该区域被腐蚀为黑色。

我们举个例子来说明

例如，有张图像，其像素值如下：

    [[0 0 0 0 0]
    [0 1 1 1 0]
    [0 1 1 1 0]
    [0 1 1 1 0]
    [0 0 0 0 0]]

有个结构元，kernel的值为：

    [[1]
    [1]
    [1]]

那么使用该kernel 对图像 img 进行腐蚀后，可得到结果：

    [[0 0 0 0 0]
    [0 0 0 0 0]
    [0 1 1 1 0]
    [0 0 0 0 0]
    [0 0 0 0 0]]

从这个例子中我们可以看出：

* 如果kernel完全处于前景图像中,就将kernel中心点所对应的腐蚀结果图像中的像素点处理为前景色
* 如果kernel未完全处于前景图像中,就将kernel中心点对应的腐蚀结果图像中的像素点处理为背景色

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251204125806136.png"></div>

通过腐蚀操作我们可以用来“收缩”或者“细化”二值图像的前景，同时去除噪声，分割元素。

在OPenCV中，可以使用 `cv2.erode()` 函数来进行腐蚀操作。该函数接受三个参数：输入图像、结构元素（kernel）和迭代次数。



## 5.2 膨胀（Dilation）

膨胀操作会使图像中的白色区域（前景）变大。它通过将图像与一个结构元素进行卷积来实现。如果结构元素与白色区域有任何重叠，则该区域被膨胀为白色。

# 二、ROI裁剪

首先是第一个扩展，在某些应用中，我们可能只对图像的特定区域（Region of Interest, ROI）进行色块识别。ROI 裁剪可以帮助我们提高处理效率和准确性。

```python
# 定义 ROI 区域 (x, y, width, height)
x, y, w, h = 100, 100, 200, 200
# 裁剪 ROI
roi = image[y:y+h, x:x+w]
# 对 ROI 进行色块识别（同上面的步骤）
hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
mask_roi = cv2.inRange(hsv_roi, lower_color, upper_color)
mask_roi = cv2.erode(mask_roi, kernel, iterations=1)
mask_roi = cv2.dilate(mask_roi, kernel, iterations=1)
contours_roi, _ = cv2.findContours(mask_roi, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
cv2.drawContours(roi, contours_roi, -1, (0, 255, 0), 3)
# 将处理后的 ROI 放回原图
image[y:y+h, x:x+w] = roi
# 显示结果
cv2.imshow('Color Blob Detection with ROI', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

ROI裁剪解释：

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20251201143605700.png"></div>

通过这种方式，色块识别只会对图像的指定区域进行处理，而不会去遍历整个图像，从而提高了效率。

