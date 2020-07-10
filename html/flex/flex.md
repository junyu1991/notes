# flex布局相关使用问题

1. 使用flexbox实现垂直居中，对于父级容器为```display:flex```的元素来说，它的每一个子元素都是垂直居中的:
``` css
.flex-center {
  background: black;
  color: white;
  border: 10px solid white;
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 200px;
  resize: vertical;
  overflow: auto;
}
.flex-center p {
  margin: 0;
  padding: 20px;
}
```
上述方法只适用于**父级容器拥有确定高度**的元素。
[示例代码](./code/flex_demo.html)

2. flax-wrap：让弹性盒元素在必要的时候拆行：
``` css
display: flex;
flex-wrap: wrap;
```

| 值 | 描述 |
| :--- | :--- |
| nowrap  |	默认值。规定灵活的项目不拆行或不拆列。 |
| wrap | 规定灵活的项目在必要的时候拆行或拆列。 |
| wrap-reverse  |  规定灵活的项目在必要的时候拆行或拆列，但是以相反的顺序。 |
| initial  | 设置该属性为它的默认值。请参阅 initial。 |
| inherit  | 从父元素继承该属性。请参阅 inherit。 |

[参考](https://www.runoob.com/cssref/css3-pr-flex-wrap.html)