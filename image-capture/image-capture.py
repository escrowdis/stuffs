import sys
import cv2
import numpy as np

cap = cv2.VideoCapture(0)

#check if camera is open
if not cap.isOpened():
    sys.exit("No camera mounted")
else:
	# capture frame by frame
	ret, frame = cap.read()
	if not ret:
	    sys.exit("no image")
	else:
		cv2.imwrite('img-captured.jpg', frame)

cap.release()