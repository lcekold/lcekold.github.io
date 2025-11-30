# 一、什么是Flask?

在介绍我们将要实现的投屏功能之前，先来了解一下Flask框架。

Flask是一个使用Python编写的轻量级Web应用框架。它基于Werkzeug工具箱和Jinja2模板引擎，设计简洁且易于扩展。Flask非常适合用于构建小型到中型的Web应用程序，尤其适合初学者和快速开发项目。

Flask具体的教程这里就不阐述了，另外AI去写这些Python代码实际上是很强的，用AI去写Flask也不例外。

我们一会儿会使用Flask来创建一个简单的HTTP服务器，将电脑屏幕内容以MJPEG格式推送到手机浏览器，实现投屏功能。

# 二、什么是MJPEG?

Motion JPEG，简称 MJPG。JPEG是静态图片的编码格式。MJPG 是动态的视频编码格式，可以简单地理解：MJPG 就是把多个 JPEG 图片连续显示出来。

MJPEG 的优点是编码和解码都非常简单，适合实时传输和处理，很多摄像头本身就支持JPEG、MJPG。缺点是MJPEG只是多个 JPEG 图片的组合，它不考虑前后两帧数据的变化，总是传输一帧完整的图像，传输带宽要求高。H264 等视频格式，会考虑前后两帧数据的变化，只传输变化的数据，传输带宽要求低。

# 三、实现将电脑程序投屏到手机的方法

1. 使用 Python 截取屏幕或程序窗口
2. 将截图编码为 JPEG 格式
3. 通过 Flask 创建 HTTP 服务器
4. 使用 MJPEG (Motion JPEG) 格式持续推送图像帧
5. 手机浏览器访问 Flask 服务器的 URL 查看投屏


# 四、所使用的相关库的介绍

Flask之前已经介绍过，其也是python下的一个库，这里不做介绍，这里简要介绍一下Python中使用到的其它库

## 4.1 MSS (Multiple Screen Shots)

Python MSS（Multiple Screen Shots）是一款由BoboTiG开发的开源库，旨在提供高性能、纯Python编写的屏幕截图功能。该项目利用ctypes模块直接调用操作系统底层API，实现了对Windows、Linux、MacOS等主流操作系统的良好支持。其核心优势在于小体积、高效率以及出色的图像质量。

### 使用示例：

```python
import mss
import mss.tools

with mss.mss() as sct:
    # 获取所有显示器信息
    print(sct.monitors)
    # 输出: [{所有显示器}, {显示器1}, {显示器2}, ...]
    
    # 截取主显示器
    monitor = sct.monitors[1]
    screenshot = sct.grab(monitor)
    
    # 截取特定区域
    region = {"top": 100, "left": 100, "width": 500, "height": 400}
    screenshot = sct.grab(region)
    
    # 保存截图
    mss.tools.to_png(screenshot.rgb, screenshot.size, output='screenshot.png')
    
    # 转换为 PIL 图像
    from PIL import Image
    img = Image.frombytes('RGB', screenshot.size, screenshot.rgb)
```

## 4.2 OpenCV(opencv-python)

* 全称: Open Source Computer Vision Library
* 作用: 强大的计算机视觉和图像处理库

伟大无需多言

### 使用示例


#### 基础操作

```python
import cv2
import numpy as np

# 读取和显示图像
img = cv2.imread('image.jpg')
cv2.imshow('Image', img)
cv2.waitKey(0)

# 保存图像
cv2.imwrite('output.jpg', img)

# 调整大小
resized = cv2.resize(img, (800, 600))

# 颜色空间转换
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
```

#### 图像处理

```python
# 模糊处理
blurred = cv2.GaussianBlur(img, (5, 5), 0) # 通过高斯模糊处理加权平均周围像素来平滑图像



# 边缘检测
edges = cv2.Canny(img, 100, 200) # 通过Canny边缘检测算法识别图像中的边缘



# 图像旋转
rows, cols = img.shape[:2]  # 获取图像尺寸
M = cv2.getRotationMatrix2D((cols/2, rows/2), 45, 1) # 计算旋转矩阵，旋转中心为图像中心，旋转角度为45度，缩放比例为1
rotated = cv2.warpAffine(img, M, (cols, rows)) # 应用旋转矩阵进行图像旋转



# 绘制形状
cv2.rectangle(img, (100, 100), (300, 300), (0, 255, 0), 2) # 在图像上绘制绿色矩形，左上角坐标为(100,100)，右下角坐标为(300,300)，线宽为2
cv2.circle(img, (200, 200), 50, (255, 0, 0), -1) # 在图像上绘制蓝色实心圆，圆心坐标为(200,200)，半径为50
```

#### 其它功能

```python
# 人脸检测
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml') # 加载人脸检测分类器
faces = face_cascade.detectMultiScale(gray, 1.3, 5) # 检测人脸



# 视频处理
cap = cv2.VideoCapture(0)  # 打开摄像头
while True:
    ret, frame = cap.read() # 读取视频帧
    cv2.imshow('Video', frame) # 显示图像
    if cv2.waitKey(1) & 0xFF == ord('q'):  # 按下'q'键退出循环
        break
cap.release() # 释放摄像头
cv2.destroyAllWindows() # 关闭所有OpenCV窗口



# 图像编码
ret, buffer = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 80])
jpg_bytes = buffer.tobytes()
```

## 4.3 NumPy(Numerical Python)

