def quarter_round(a,b,c,d):
    a = (a+b) & 0xFFFFFFFF
    d ^= a
    d = ((d << 16) | (d >> 16)) & 0xFFFFFFFF

    c =  (c+d) & 0xFFFFFFFF
    b ^= c
    b =((b << 12) | (b >> 20)) & 0xFFFFFFFF

    a = (a+b) & 0xFFFFFFFF
    d ^= a
    d = ((d << 8) | (d >> 24)) & 0xFFFFFFFF

    c =  (c+d) & 0xFFFFFFFF
    b ^= c
    b =((b << 7) | (b >> 25)) & 0xFFFFFFFF

    return a,b,c,d

