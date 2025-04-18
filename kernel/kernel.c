#define VIDEO_ADDRESS 0xB8000
#define VIDEO_WIDTH 80
#define VIDEO_HEIGHT 25
#define VIDEO_SIZE VIDEO_WIDTH*VIDEO_HEIGHT*2
#define LIGNE_SIZE VIDEO_WIDTH*2

int offset = 0;

void clear() {
    for (int i = 0; i < VIDEO_SIZE; i+=2) {
        ((char*)VIDEO_ADDRESS)[i] = ' ';
        ((char*)VIDEO_ADDRESS)[i+1] = 0x0F;
    }
}

void pageDown() {
    char backup[VIDEO_SIZE-LIGNE_SIZE];

    for (int i = 0; i < VIDEO_SIZE-LIGNE_SIZE; i++) {
        backup[i] = ((char*)VIDEO_ADDRESS)[LIGNE_SIZE+i];
    }

    clear();

    offset = 0;

    for (int i = 0; i < VIDEO_SIZE-LIGNE_SIZE; i++) {
        ((char*)VIDEO_ADDRESS)[i] = backup[i];
        offset++;
    }
}

void newLigne() {
    offset = LIGNE_SIZE * (offset/LIGNE_SIZE + 1);
    if (offset >= VIDEO_SIZE) pageDown();
}

void printChar(const char* _c, int _color) {
    if (offset == VIDEO_SIZE) pageDown();

    ((char*)VIDEO_ADDRESS)[offset] = *_c;
    ((char*)VIDEO_ADDRESS)[offset+1] = _color;
    offset+=2;
}

void print(const char* _msg) {
    while (*_msg != '\0') {
        if (*_msg == '\n') {
            newLigne();
            _msg++;
            continue;
        }
        printChar(_msg, 0x0F);
        _msg++;
    }
}

void println(const char* msg) {
    print(msg);
    newLigne();
}

void kernel() {
    println("Wellcome in the kernel !");

    while (1) {}
}