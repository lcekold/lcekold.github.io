const h1=document.querySelector('h1');
h1.innerHTML=h1.textContent.replace(/\S/g,"<span>$&</span>")

document.querySelectorAll('span').forEach((span,index)=>{
    span.style.setProperty('--delay',`${index * 0.1}s`)
})

document.querySelectorAll('button').forEach(button=>{
     // 获取页面上所有的按钮元素，并通过 forEach 方法遍历每个按钮元素。
    button.addEventListener('click',e=>{
        // 给每个按钮元素添加点击事件监听器。
        h1.style.setProperty('--animation',e.target.getAttribute('data-animation'))
        // 通过获取按钮元素的自定义属性"data-animation"的值，将其作为CSS变量的值，设置给h1元素的样式中的"--animation"属性。

        h1.classList.remove('animate')
        // 移除h1元素的样式中与动画相关的类名"animate"。
        void h1.offsetWidth
        // 使用void运算符访问h1元素的offsetWidth属性，触发重绘，使上一行代码生效。
        h1.classList.add('animate')
        // 向h1元素的样式中添加与动画相关的类名"animate"。
    })
})
