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



def double_round(state):
    state = state.copy()
    
    state[0], state[4], state[8], state[12] = quarter_round(state[0], state[4], state[8], state[12])
    state[1], state[5], state[9], state[13] = quarter_round(state[1], state[5], state[9], state[13])
    state[2], state[6], state[10], state[14] = quarter_round(state[2], state[6], state[10], state[14])
    state[3], state[7], state[11], state[15] = quarter_round(state[3], state[7], state[11], state[15])
    
    state[0], state[5], state[10], state[15] = quarter_round(state[0], state[5], state[10], state[15])
    state[1], state[6], state[11], state[12] = quarter_round(state[1], state[6], state[11], state[12])
    state[2], state[7], state[8], state[13] = quarter_round(state[2], state[7], state[8], state[13])
    state[3], state[4], state[9], state[14] = quarter_round(state[3], state[4], state[9], state[14])

    return state


