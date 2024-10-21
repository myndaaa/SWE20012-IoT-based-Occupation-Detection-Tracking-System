import cv2
cam=cv2.VideoCapture(0)
cam.set(3,640)
cam.set(4,480)

while True:
    result, video_frame = cam.read()
    if result is False:
        break
    
    cv2.imshow(
        "USB Camera Test", video_frame    
    )
    
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break
    
cam.release()
cv2.destroyAllWindows()