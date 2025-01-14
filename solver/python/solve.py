from z3 import *

bv1 = BitVec('bv', 16)
bv2 = 3 * bv1
bv3 = bv2 + 4

bv4 = bv1 ^ 14

s = Solver()

s.add(bv3 == bv4)

while s.check() == sat:
    m = s.model()
    print(m)
    s.add(bv1 != m[bv1])