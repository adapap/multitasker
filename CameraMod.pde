class CameraMod {
    CameraMod() {}
    
    void resetCamera() {
        camera(width/2.0, height/2.0, (height/2.0) / tan(radians(30)),
        width/2.0, height/2.0, 0,
        0, 1, 0);
    }

    void rotate(float ang) {
        camera(width/2.0, height/2.0, (height/2.0) / tan(radians(30)),
        width/2.0, height/2.0, 0,
        radians(ang), 1, 0);
    }
}