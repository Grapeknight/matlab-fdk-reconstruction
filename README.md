# FDK 3D Reconstruction from 2D Projections  
## 基于二维投影的FDK三维重建

**Author: 崔海霞 (Cui Haixia)**  
A MATLAB implementation of the FDK (Feldkamp-Davis-Kress) algorithm for 3D volume reconstruction from 2D X-ray projection images.  
基于二维X射线投影图像的FDK（Feldkamp-Davis-Kress）算法的MATLAB实现，用于三维体数据重建。

---

### 📘 Citation / 引用本文  
The formal citation information will be updated after the official publication of the associated work. Please check back for updates.  
相关研究成果正式发表后，将补充完整引用信息，敬请关注后续更新。

---

### 📌 Description / 项目简介  
Reconstructing 3D structures of objects from a series of 2D projection images.  
从一系列二维投影图像中重建物体的三维结构。

---

### 🔧 Features / 主要功能  
- ✅ **Automatic ROI extraction and background removal**  
  自动提取感兴趣区域（ROI）并去除背景干扰  
- ✅ **Rotation axis calibration using calibration spheres and K-means clustering**  
  基于校准球与K-means聚类的旋转轴自动校正  
- ✅ **Image alignment and denoising (Gaussian filtering)**  
  图像配准与去噪（高斯滤波）  
- ✅ **FDK-based filtered backprojection using `ifanbeam`**  
  基于 `ifanbeam` 函数的FDK滤波反投影重建  
- ✅ **3D volume output as PNG slices and GIF animation**  
  输出三维体数据为PNG切片序列与GIF动态预览

---

### 📁 Usage / 使用方法  
1. Run `code.m` in MATLAB.  
   在 MATLAB 中运行 `code.m` 文件。  
2. Select the folder containing your `.TIF` projection images (or modify the code for other formats).  
   选择包含 `.TIF` 投影图像的文件夹（如使用其他格式，请修改代码）。  
3. The reconstructed 3D volume will be saved in `./res/` as PNG slices.  
   重建的三维体数据将保存至 `./res/` 目录，以PNG切片形式输出。  
4. A slice-animation GIF will be generated as `0.gif`.  
   程序将生成 `0.gif` 文件，用于三维切片动态预览。

> **Requirement**: MATLAB with **Image Processing Toolbox**  
> **运行要求**：需安装 MATLAB 及 **图像处理工具箱**

---

### 📄 License / 许可证  
This project is licensed under the [MIT License](LICENSE).  
本项目采用 [MIT许可证](LICENSE) 开源。

---

> This code is shared for academic and research purposes.  
> 本代码仅供学术与研究用途，未经许可不得用于商业目的。
