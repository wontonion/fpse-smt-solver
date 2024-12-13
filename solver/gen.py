clauses = []

clauses.append('not c0')
for i in range(1):
    clauses.append(f'((a{i} xor b{i}) and c{i} or (a{i} and b{i})) implies c{i+1}')
    clauses.append(f'c{i+1} implies ((a{i} xor b{i}) and c{i} or (a{i} and b{i}))')
    clauses.append(f'(a{i} xor b{i} xor c{i}) implies s{i}')
    clauses.append(f's{i} implies (a{i} xor b{i} xor c{i})')

print('(' + (') and ('.join(clauses)) + ')')