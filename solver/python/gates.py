
def satisfy(clauses, assignment):
    for clause in clauses:
        satisfied = False
        for literal in clause:
            if (literal > 0 and assignment[literal]) or (literal < 0 and not assignment[-literal]):
                satisfied = True
                break
        if not satisfied:
            return False
    return True


def Xor(i0, i1, o0):
    return [
        [-i0, -i1, -o0],
        [-i0, i1, o0],
        [i0, -i1, o0],
        [i0, i1, -o0],
    ]


def And(i0, i1, o0):
    return [
        [-i0, -i1, o0],
        [i0, -o0],
        [i1, -o0]
    ]


def Or(i0, i1, o0):
    return [
        [i0, i1, -o0],
        [-i0, o0],
        [-i1, o0]
    ]


def Not(i0, o0):
    return [
        [-i0, -o0],
        [i0, o0]
    ]


def Add(a, b, ci, s, co):
    return [
        [-a, -b, -ci, s],
        [-a, -b, ci, -s],
        [-a, b, -ci, -s],
        [-a, co, s],
        [a, -b, ci, s],
        [a, b, -ci, s],
        [a, b, ci, -s],
        [a, -co, -s],
        [-b, -ci, co],
        [b, ci, -co],
    ]


def Sub(a, b, bi, d, bo):
    return [
        [-a, -b, -bi, d],
        [-a, -b, bi, -d],
        [-a, b, bi, d],
        [-a, b, -bo],
        [a, -b, -bi, -d],
        [a, -b, bo],
        [a, b, -bi, d],
        [a, b, bi, -d],
        [-bi, -d, bo],
        [bi, d, -bo]
    ]
