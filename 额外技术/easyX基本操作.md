### 初始化绘图窗口

**initgraph()**

参数：宽度，高度，窗口样式（可省略，有两个用|隔开）

用_getch()暂停程序，阻止止窗口关闭

### 关闭绘图窗口

**closegraph()**

### 基本绘图函数

无填充圆：**circle()**

有边框有填充圆：**fillcircle()**

无边框填充圆：**solidcircle()**

直线：**line()**

矩形：**rectangle()**

椭圆ellipse，圆角矩形roundrect，多边形polygon，扇形pie，直线line

等等

### 获取绘图区高度和宽度

**int getheight()    int getwidth()**

### 图形设置

主要是color，mode，style

### 输出字符串

**outtextxy**

**settextstyle**：参数主要是高度，宽度，字体名（宽度或高度为零就自适应）

==**drawtext**==：向指定区域输出字符串，可指定居中等格式

### 图像处理

**loadimage()**：加载图像，主要参数：IMAEG对象指针，文件名（==注意一定不要把文件名写错了==），拉伸宽度，拉伸高度

**putimage()**：绘制图像，主要参数：坐标，IMAGE指针，宽度，高度，在IMAGE对象中的左上角坐标

**getimage()，saveimage()**：获取图像（截图）

**rotateimage()**：旋转图像

**setworkingimage()**：设置绘图设备

###  双缓冲

**beginbatchdraw()
endbatchdraw()    可设置区域
flushbatchdraw()    可设置区域**

### 消息处理(重要)

**peekmessage**：非阻塞

**getmessage**：阻塞

### 透明贴图方法（其一

要求图像素材本身背景是透明的

直接用函数：

```
void drawAlpha(int picture_x, int picture_y, IMAGE* picture) //x为载入图片的X坐标，y为Y坐标
{
    // 变量初始化
    DWORD* dst = GetImageBuffer(); // GetImageBuffer()函数，用于获取绘图设备的显存指针，EASYX自带
    DWORD* draw = GetImageBuffer();
    DWORD* src = GetImageBuffer(picture); //获取picture的显存指针
    int picture_width = picture->getwidth(); //获取picture的宽度，EASYX自带
    int picture_height = picture->getheight(); //获取picture的高度，EASYX自带
    int graphWidth = getwidth(); //获取绘图区的宽度，EASYX自带
    int graphHeight = getheight(); //获取绘图区的高度，EASYX自带
    int dstX = 0; //在显存里像素的角标
    // 实现透明贴图 公式： Cp=αp*FP+(1-αp)*BP ， 贝叶斯定理来进行点颜色的概率计算
    for (int iy = 0; iy < picture_height; iy++) {
        for (int ix = 0; ix < picture_width; ix++) {
            int srcX = ix + iy * picture_width; //在显存里像素的角标
            int sa = ((src[srcX] & 0xff000000) >> 24); //0xAArrggbb;AA是透明度
            int sr = ((src[srcX] & 0xff0000) >> 16); //获取RGB里的R
            int sg = ((src[srcX] & 0xff00) >> 8); //G
            int sb = src[srcX] & 0xff; //B
            if (ix >= 0 && ix <= graphWidth && iy >= 0 && iy <= graphHeight && dstX <=
                graphWidth * graphHeight) {
                dstX = (ix + picture_x) + (iy + picture_y) * graphWidth; //在显存里像素的角标
                int dr = ((dst[dstX] & 0xff0000) >> 16);
                int dg = ((dst[dstX] & 0xff00) >> 8);
                int db = dst[dstX] & 0xff;
                draw[dstX] = ((sr * sa / 255 + dr * (255 - sa) / 255)
                    << 16) //公式：Cp = αp * FP + (1 - αp) * BP ； αp = sa / 255 , FP = sr , BP = dr
                    | ((sg * sa / 255 + dg * (255 - sa) / 255) << 8) //αp = sa / 255 , FP = sg , BP = dg
                    | (sb * sa / 255 + db * (255 - sa) / 255); //αp = sa / 255 , FP = sb , BP = db
            }
        }
    }
}
```