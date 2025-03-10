# 参考

<a href="https://blog.csdn.net/WL0616/article/details/129118087">【QT】史上最全最详细的QSS样式表用法及用例说明</a>

<a href="https://blog.csdn.net/qq21497936/article/details/79401577">qss样式表笔记大全(一)：qss名词解析（包含相关示例）</a>

<a href="https://blog.csdn.net/qq21497936/article/details/79423622">qss样式表笔记大全(二)：可设置样式的窗口部件列表（上）（持续更新示例）</a>

<a href="https://blog.csdn.net/qq21497936/article/details/79424146">qss样式表笔记大全(三)：可设置样式的窗口部件列表（中）（持续更新示例）</a>

<a href="https://blog.csdn.net/qq21497936/article/details/79424536">qss样式表笔记大全(四)：可设置样式的窗口部件列表（下）（持续更新示例）</a>

# 盒子模型解释

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/Snipaste_2025-02-27_20-41-38.png"></div>

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/6966c6cd793c626aa09035a25c9d844b.png"></div>

```c++

QSpinBox {
    color: lightgray;
    background: rgb(44, 44, 44);
    border: 10px solid rgb(76, 76, 76);
    padding: 5px;
}
 
QSpinBox::down-button, QSpinBox::up-button {
    subcontrol-origin: border;
    width: 16px;
    height: 10px;
    background: white;
    border: 2px solid rgb(170, 170, 170);
}
 
QSpinBox::down-button {
    subcontrol-position: center left;
}
 
QSpinBox::up-button {
    subcontrol-position: center right;
}
 
QSpinBox::up-arrow,  QSpinBox::down-arrow {
    subcontrol-origin: content;
    subcontrol-position: center center;
    width: 6px;
    height: 6px;
    background: rgb(76, 76, 76);
}
```

<a href="https://blog.csdn.net/qq_40732350/article/details/86807224">SubControl 介绍大全</a>


在QSS（Qt Style Sheets）中，subcontrol（子控件）​是Qt特有的概念，用于对复杂控件的内部组成部分进行精细化样式控制。以下是其核心要点：

## 一、Subcontrol的定义与作用
​1. 本质
​
Subcontrol是复杂控件（如QComboBox、QCheckBox等）的逻辑子部件。例如：

* QCheckBox的勾选框部分（::indicator）
* QComboBox的下拉按钮（::drop-down）
* QSpinBox的增减箭头（::up-button、::down-button）

这些子部件无法独立存在，但可以通过QSS单独定制样式。

2. ​与CSS的区别
​
CSS中没有subcontrol概念，这是Qt为控件层级化设计扩展的功能。通过subcontrol，开发者可以精准定位到控件的某个功能区域进行样式调整。

## 二、Subcontrol的核心属性

1. 定位属性​

* **subcontrol-origin**​

定义子控件的参考坐标系，可选值：margin（外边距区域）、border（边框区域）、padding（内边距区域）、content（内容区域）。默认值为padding。

例如：将QSpinBox的增减按钮定位在边框区域内

```qss
QSpinBox::up-button { subcontrol-origin: border; }
```

* ​**subcontrol-position**​
设置子控件在参考坐标系内的对齐方式，水平方向（left/center/right）和垂直方向（top/center/bottom）。例如：

```css
QComboBox::drop-down { subcontrol-position: right center; }
```

2. 微调属性​

* **top/left**
​
在伪状态（如:hover）下微调子控件位置。例如按钮按下时的偏移效果：

```css
QSpinBox::up-button:pressed { top: 1px; left: 1px; }
```

# 三、典型应用场景
|控件类型|	常用Subcontrol示例|	典型样式规则|
|------|------|------|
​QComboBox |​	::drop-down（下拉按钮）	|QComboBox::drop-down { image: url(arrow.png); width: 20px; }|
​QCheckBox|​	::indicator（勾选框）	|QCheckBox::indicator { border: 2px solid gray; }|
​QSpinBox​|	::up-button（增加按钮）|	QSpinBox::up-button { background: #FFF; }|
​QScrollBar​|	::handle（滑块）	|QScrollBar::handle { background: #CCC; min-height: 20px; }|

# 四、注意事项
1. ​子控件独立性​

设置subcontrol的尺寸（如width/height）可能破坏控件默认布局，需手动调整父控件的padding或spacing属性。

2. ​伪状态联动​

Subcontrol支持与伪状态（:hover、:pressed等）结合，实现动态交互效果。例如：

```css
QComboBox::drop-down:hover { background: #EEE; }
```
3. ​兼容性
​
某些控件的subcontrol在跨平台时表现可能不一致（如QSlider的::handle在不同系统下的默认样式），需针对性测试。

