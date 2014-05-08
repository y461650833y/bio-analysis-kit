#!/usr/bin/env python
#Date: 2013-5-28
#Author: Linxzh
#ver: 0.1
#This program is aimed to find the different snp in the same pos of two file, these files are generated by the BWA/SAMTools.

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-a', type=FileType('r'))
parser.add_argument('-b', type=FileType('r'))
parser.add_argument('-o', type=FileType('w'))
args.parser.parse_args()

def sep_v(x):
	'''this func is used to turn the INFO line into a dict'''
	d = {}
	value = []
	keylist = ['AF1','MQ','DP4']
	x = x.split(';')
	for i in x:
		i = i.split('=')
		try:
			d[i[0]]=i[1]
		except IndexError:
			pass
	for key in keylist:
		if key in d:
			value.append(d[key])
		else:
			value.append('None')
	return value

def find_snp(fa,ma,r):
	'''Find the snp position of two file(by BWA&SAMtools)

	>>>find_snp(father_file,mather_file,result_file)	

'''

	f = open(fa)
	m = open(ma) 

	result = open(r,'a')		#result file
	result.write('#CHROM'+'\t'+'Pos'+'\t'+'REF'+'\t'+'ALT'+'\t'+'QUAL'+'\t'+'AF1'+'\t'+'MQ'+'\t'+'DP4'+'\n') 						 #write healine


	while True:	
		a = f.readline() 
		if not a:
			break
		if '#' in a or 'INDEL' in a:
			continue
		a = a.split('\t')
		ad = sep_v(a[7])
		while 1:
			bpos = m.tell()
			b = m.readline()
			if not b:
				break
			if '#' in b:
				continue	
			elif 'Scaf' in b:
				continue
			elif 'INDEL' in b:
				continue
			
			b = b.split('\t')
			if cmp(a[0],b[0])==1:
				continue
			elif cmp(a[0],b[0])==-1:
				m.seek(bpos)
				break	
			elif int(a[1]) > int(b[1]):
				continue
			elif int(a[1]) < int(b[1]):
				m.seek(bpos)
				break
#			print 'Pos:%s |  %s | %s'%(a[0],a[1],b[1])
			bd = sep_v(b[7])
			if a[4] != b[4]:
				v = ad[0]+'/'+bd[0]+'\t'+ad[1]+'/'+bd[1]+'\t'+ad[2]+'/'+bd[2]
				line = a[0]+'\t'+a[1]+'\t'+a[3]+'\t'+a[4]+"/"+b[4]+'\t'+a[5]+"/"+b[5]+'\t'+v+'\n' 

				result.write(line)
				break		
			else:
				break
		
	
	result.close()
	f.close()
	m.close()	


if __name__ == '__main__':
	fing_snp(args.a, args.b, args.o)