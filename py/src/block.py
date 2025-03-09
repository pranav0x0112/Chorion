from rounds import double_round

def chacha20_block(state):
    working_state = state.copy()
    for _ in range(10):
        working_state = double_round(working_state)
    
    return[(x+y) & 0xFFFFFFFF for x,y in zip(state, working_state)]
