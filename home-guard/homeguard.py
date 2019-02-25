import cv2
import sys
import time
# from bgsacon.cython.bgsacon import bgSACON
from bgsacon.bgsacon import bgSACON

bg = bgSACON()

cap = cv2.VideoCapture(0)

while True:
    time_start = time.time()
    #check if camera is open
    if not cap.isOpened():
        sys.exit("No camera mounted")
        break

    # capture frame by frame
    ret, frame = cap.read()
    if not ret:
        break

    bg.run(frame)

    # cv2.imshow('img', frame)
    cv2.imshow('fg', bg.fg)
    # cv2.imshow('bg', bg.bg)
    if (cv2.waitKey(30) & 0xFF) in (27, ord('q')):
        break
    print('process time:', time.time() - time_start)

cap.release()
cv2.destroyAllWindows()
