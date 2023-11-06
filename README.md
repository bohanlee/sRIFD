# sRIFD
A multimodal image matching method, which can address the rotation issues.

Demo code of the sRIFD algorithm, which is designed for multimodal image feature matching. If it is helpful for you, please cite our paper:
@article{LI2023104970,
title = {sRIFD: A Shift Rotation Invariant Feature Descriptor for multi-sensor image matching},
journal = {Infrared Physics & Technology},
volume = {135},
pages = {104970},
year = {2023},
issn = {1350-4495},
doi = {https://doi.org/10.1016/j.infrared.2023.104970},
url = {https://www.sciencedirect.com/science/article/pii/S1350449523004280},
author = {Yong Li and Bohan Li and Guohan Zhang and Zhongqun Chen and Zongqing Lu},
keywords = {Rotation invariant, Multi-sensor image matching, Second order maximum index map, Phase congruency},
abstract = {Feature descriptors such as SIFT (Scale Invariant Feature Transform) have been widely used in various computer vision applications, and many methods have been proposed to adapt the descriptors to multi-sensor images. Recently, RIFT (Radiation variation Insensitive Feature Transform) utilized the phase congruency that is invariant to the illumination and radiometric variation to construct descriptors for multi-sensor images. However, RIFT does not perform well on images of certain rotation degrees even with accurate main orientation of keypoints. To address this issue, this work designs a SoMIM (second-order maximum index map) by using the orientational response of Log-Gabor filters, and then constructs a novel descriptor, sRIFD (shift Rotation Invariant Featured Descriptor), without the computing main orientations. sRIFD performs evenly well on images of almost all rotation angles. To evaluate the performance of sRIFD, we use three image datasets, Infrared-Optical, Thermal-Optical, and Optical-Optical datasets. The quantitative results demonstrated that sRIFD performed better on multi-sensor image datasets under varying rotation angles.}
}
