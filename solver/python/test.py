from gates import *

clauses = Xor(1, 2, 3)
for i0 in False, True:
    for i1 in False, True:
        for o0 in False, True:
            assignment = {1: i0, 2: i1, 3: o0}
            res = satisfy(clauses, assignment)
            assert res == (o0 == (i0 != i1))

clauses = And(1, 2, 3)
for i0 in False, True:
    for i1 in False, True:
        for o0 in False, True:
            assignment = {1: i0, 2: i1, 3: o0}
            res = satisfy(clauses, assignment)
            assert res == (o0 == (i0 and i1))

clauses = Or(1, 2, 3)
for i0 in False, True:
    for i1 in False, True:
        for o0 in False, True:
            assignment = {1: i0, 2: i1, 3: o0}
            res = satisfy(clauses, assignment)
            assert res == (o0 == (i0 or i1))

clauses = Not(1, 2)
for i0 in False, True:
    for o0 in False, True:
        assignment = {1: i0, 2: o0}
        res = satisfy(clauses, assignment)
        assert res == (o0 == (not i0))

clauses = Add(1, 2, 3, 4, 5)
for a in False, True:
    for b in False, True:
        for ci in False, True:
            for s in False, True:
                for co in False, True:
                    assignment = {1: a, 2: b, 3: ci, 4: s, 5: co}
                    res = satisfy(clauses, assignment)
                    temp = int(a) + int(b) + int(ci)
                    assert res == ((s == bool(temp & 1))
                                   and (co == bool(temp & 2)))

clauses = Sub(1, 2, 3, 4, 5)
for a in False, True:
    for b in False, True:
        for bi in False, True:
            for d in False, True:
                for bo in False, True:
                    assignment = {1: a, 2: b, 3: bi, 4: d, 5: bo}
                    res = satisfy(clauses, assignment)
                    temp = 2 + int(a) - int(b) - int(bi)
                    assert res == ((d == bool(temp & 1))
                                   and (bo != bool(temp & 2)))
