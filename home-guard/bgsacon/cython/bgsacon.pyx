import numpy as np
import json
from enum import Enum
import copy
import time

class bgStatus(Enum):
    init = -2
    ungen  = -1
    gen = 0
    # working = 1

class bgSACON:
    def __init__(self):
        with open('conf.json') as param_file:
            conf = json.load(param_file)

        self.img_size = conf["camera"]["size"]
        self.cam_fps = conf["camera"]["fps"]

        #  amount for generating background
        self.frames_for_gen = conf["background"]["generate_frames"]
        #  possible foreground pixel if pixel difference over this threshold
        self.thresh_pixel_diff = conf["background"]["thresh_pixel_diff"]
        self.thresh_bg = conf["background"]["thresh_bg"]

        self.imgs_for_bg = []
        self.bg = np.zeros((self.img_size[0], self.img_size[1], 3), np.uint8)
        self.fg = np.zeros((self.img_size[0], self.img_size[1], 3), np.uint8)
        #  binary image distinguishing fore/back ground
        self.bg_binary = np.zeros((self.img_size[0], self.img_size[1], 1), np.uint8)
        self.bg_possible = np.zeros(self.img_size)
        self.TOM = np.zeros(self.img_size)

        self.status = bgStatus.init

    def reset(self):
        self.imgs_for_bg = []
        self.bg_binary.fill(0)
        self.bg_possible.fill(0)
        self.TOM.fill(0)

        self.status = bgStatus.ungen

    #  create first background from imgs_for_bg
    def generate(self):
        if len(self.imgs_for_bg) is 0:
            print("no images for generating background.")
            return

        if len(self.imgs_for_bg) < 5:
            self.bg = copy.copy(self.imgs_for_bg[0])
        else:
            amount = len(self.imgs_for_bg)
            img_last = self.imgs_for_bg[amount - 1]
            for r in range(self.img_size[0]):
                for c in range(self.img_size[1]):
                    arr = [[], [], []]
                    for i in range(amount - 1):
                        arr[0].append(self.imgs_for_bg[i][r][c][0])
                        arr[1].append(self.imgs_for_bg[i][r][c][1])
                        arr[2].append(self.imgs_for_bg[i][r][c][2])
                    # try median of medians    https://en.wikipedia.org/wiki/Median_of_medians
                    med = [np.median(arr[0]), np.median(arr[1]), np.median(arr[2])]
                    self.bg[r][c][0] = med[0]
                    self.bg[r][c][1] = med[1]
                    self.bg[r][c][2] = med[2]
                    #  create initial bg_binary
                    pixel_diff = abs(int(img_last[r][c][0]) - int(med[0])) + abs(int(img_last[r][c][1]) - int(med[1])) + abs(int(img_last[r][c][2]) - int(med[2]))
                    if pixel_diff > self.thresh_pixel_diff:
                        self.bg_binary[r][c] = 255

        self.status = bgStatus.gen

    def update(self, img):
        if self.status.value < bgStatus.gen.value:
            print("background hasn't established yet.")
            return

        for r in range(self.img_size[0]):
            for c in range(self.img_size[1]):
                p_img = img[r][c]
                p_bg = self.bg[r][c]
                pixel_diff = abs(int(p_img[0]) - int(p_bg[0])) + abs(int(p_img[1]) - int(p_bg[1])) + abs(int(p_img[2]) - int(p_bg[2]))
                if pixel_diff > self.thresh_pixel_diff:
                    self.bg_possible[r][c] += 1
                    self.fg[r][c][0] = p_img[0]
                    self.fg[r][c][1] = p_img[1]
                    self.fg[r][c][2] = p_img[2]
                else:
                    self.bg_possible[r][c] = 0
                    self.fg[r][c][0] = 0
                    self.fg[r][c][1] = 0
                    self.fg[r][c][2] = 0

                #  consider as foreground due to continuous pixel differences
                if self.bg_possible[r][c] > self.thresh_bg:
                    self.bg_binary[r][c] = 0
                    self.fg[r][c][0] = p_img[0]
                    self.fg[r][c][1] = p_img[1]
                    self.fg[r][c][2] = p_img[2]

    def run(self, img):
        if self.status.value is not bgStatus.gen.value:
            # collect images for generating background
            if len(self.imgs_for_bg) < self.frames_for_gen:
                self.imgs_for_bg.append(img)
            else:
                self.generate()
        else:
            self.update(img)
