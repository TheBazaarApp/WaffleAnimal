

def format():
	collFile = open('collegesList.txt', 'r')
	newFile = open('collegesPlain.txt', 'w')
	for line in collFile:
		linePieces = line.split(': ')
		print(linePieces[-1])
		newFile.write(linePieces[-1])

format()