import numpy as np
from numpy import genfromtxt
import cv2

dir = 'D:/chien/a.csv'
img_w = 48
img_h = 48

data = genfromtxt(dir, delimiter=',')
p = 0;
for i in range(0, len(data)):
    d = data[i]
    img = np.reshape(d, (img_h, img_w))
    cv2.imwrite("img_" + str(p) + ".jpg", img)
    p += 1