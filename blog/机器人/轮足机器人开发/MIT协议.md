<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260227214257152.png"></div>

我们在控制关节电机的时候，只能通过发送扭矩值来控制电机的运动，无法直接控制电机的转速和位置。但是在机器人运动中，很多时候我们不仅需要实现力矩模式，也需要实现位置控制模式。这个时候又应该怎么办？

答案是电机内都有一个编码器，可以通过读取编码器的值来获取电机的转速和位置。为此通过将目标位置与当前位置相减，然后乘以一个系数Kp，我们就可以得到一个扭矩值来控制电机的运动，这就是位置控制模式的实现方法。

这样通过上述这个公式，就可以同时实现力矩控制和位置控制了。这就是MIT协议中定义的两种控制模式：Torque Control Mode和Position Control Mode。

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260227220452560.png"></div>

这种控制下，如果kp值过大，可能会导致电机产生震荡的效果，为了避免这种现象，为此我们可以引入电机速度的控制，通过电机速度的控制来引入类似于阻尼的效果，来减小因为Kp值设置过大而引起的震荡。

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260228011902958.png"><div>

通过引入电机速度的控制，当电机转动到指定位置的时候，目标速度为0，此刻就会产生一个反向的扭矩来抵消电机的运动，从而达到一个稳定的状态。

<div><img src="https://cdn.jsdelivr.net/gh/lcekold/blogimage@main/Network/20260228012553179.png"><div>

