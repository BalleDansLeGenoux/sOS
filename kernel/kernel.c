#define VIDEO_ADDRESS 0xB8000

void main() {
    char* video = (char*)VIDEO_ADDRESS;
    const char* msg = "Hello from kernel !";
    for (int i = 0; msg[i] != '\0'; i++) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x0F;  // blanc sur noir
    }
}

void kernel() {
    main();
    while (1) {}
}