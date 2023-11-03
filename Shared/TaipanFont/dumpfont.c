// convert the "bin" dump from the original game to a format that https://www.pentacom.jp/pentacom/bitfontmaker2/ can ingest

// remember to manually copy the single quote (') character to the RIGHT SINGLE QUOTATION MARK (U+2018) character that the
// game text actually uses if re-exporting.

#include <stdio.h>

int fromhex(int c)
{
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    else if (c >= '0' && c <= '9') {
        return c - '0';
    }
    return -1;
}

// *... ...*
// .*.. ..*.
// ..*. .*..

int flip(int c) {
    return
        ((c & 0x1) << 7) |
        ((c & 0x2) << 5) |
        ((c & 0x4) << 3) |
        ((c & 0x8) << 1) |
        ((c & 0x10) >> 1) |
        ((c & 0x20) >> 3) |
        ((c & 0x40) >> 5) |
        ((c & 0x80) >> 7);
}

int main(void)
{
    char codes[] = "`abcdefghijklmnopqrstuvwxyz{|}~ @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?";
    
    printf("{");
    FILE *f = fopen("taipan.font.bin", "r");
    int count = 0;
    while (!feof(f) && codes[count / 8] != '\0') {
        int n = fromhex(fgetc(f)) << 4 | fromhex(fgetc(f));
        fgetc(f);
        
        if (count % 8 == 0) {
            printf("\"%d\":[0,0,0,0,0,", codes[count / 8]);
        }
        
        int n2 = ((n & 0xFF00) >> 8) | ((n & 0xFF) << 8);
        int n3 = n2 >> 6;
        printf("%d", n3);
        
        // putchar((n & 0x01) ? '*' : ' ');
        // putchar((n & 0x02) ? '*' : ' ');
        // putchar((n & 0x04) ? '*' : ' ');
        // putchar((n & 0x08) ? '*' : ' ');
        // putchar((n & 0x10) ? '*' : ' ');
        // putchar((n & 0x20) ? '*' : ' ');
        // putchar((n & 0x40) ? '*' : ' ');
        // putchar((n & 0x80) ? '*' : ' ');
        // printf("\t0x%02X %d", n, n);
        // putchar('\n');
        
        count++;
        
        if (count % 8 == 0) {
            printf(",0,0,0]");
			if (codes[count / 8] != '\0') {
				printf(",");
			}
        }
        else {
            printf(",");
        }
    }
    fclose(f);
    printf("}");
    return 0;
}
