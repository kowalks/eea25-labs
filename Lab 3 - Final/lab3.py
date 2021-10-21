import math

posl = []
posh = []
negl = []
negh = []

for ang in range(0, 91):
	pos = round(100*(270+ang)/9) - 1
	posl = posl + [str(pos % 256)]
	posh = posh + [str(pos // 256)]
	
	neg = round(100*(270-ang)/9) - 1
	negl = negl + [str(neg % 256)]
	negh = negh + [str(neg // 256)]


print("POSL:\n   .db " + ",".join(posl) + ", ' '")
print("POSH:\n   .db " + ",".join(posh) + ", ' '")
print("NEGL:\n   .db " + ",".join(negl) + ", ' '")
print("NEGH:\n   .db " + ",".join(negh) + ", ' '")
