void main() {
    char* video = (char*)0xB8000;
    const char* msg = "Hello, kernel !";
    for (int i = 0; msg[i] != '\0'; i++) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x0F;  // blanc sur noir
    }

    while (1) {}
}



