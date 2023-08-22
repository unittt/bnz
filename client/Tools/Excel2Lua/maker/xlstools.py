# -*- coding: utf-8 -*
import xlrd
import os
import os.path

ROW_TITLE = 0 #第0行中文解释
ROW_TYPE = 1 #第1行类型定义
ROW_KEY =2 #第2行定义该列的key

def list_todict(l):
	d = {}
	for i, k in enumerate(l):
		d[i+1] = k
	return d

def list_concat(l, symbol):
	s = ""
	for i, k in enumerate(l):
		s+= str(k)
		if i != len(l)-1:
			s+=symbol
	return s

def table_key_str(k):
	if type(k) == int:
		return "[%i]" % k
	else:
		return "['%s']" % k

def table_value_str(v):
	if v == None:
		return "nil"
	elif type(v) == str:
		return "'%s'" % v
	else:
		return str(v)

def force_cast(v, stype):
	if stype == "int":
		return int(v)
	elif stype == "float":
		return float(v)
	elif stype == "str":
		if type(v) == unicode:
			return v.encode("utf-8")
		else:
			return str(v)
	else:
		return v

def serialize(d):
	if type(d) != dict:
		return str(d);
	def ser_python_dict(d, level):
		if type(d) == list:
			d = list_todict(l)
		align = "\n"+"\t"*(level -1)
		indent = "\t"*level
		strlist = []
		keylist = d.keys()
		keylist.sort()
		for k in keylist:
			v = d[k]
			if type(v) == list:
				v = list_todict(v)
			if type(v) == dict:
				strlist.append(indent+table_key_str(k)+" = "+ser_python_dict(v, level + 1))
			elif type(v) == str:
				strlist.append(indent+table_key_str(k)+" = "+table_value_str(v))
			else:
				strlist.append(indent+table_key_str(k)+" = "+table_value_str(v))
		return align+"{\n"+list_concat(strlist,",\n")+align+"}"
	return ser_python_dict(d, 1)

def sheet_to_dict(sheet):
	d = {}
	type_dict = {}
	key_dict = {}
	for col_idx in xrange(sheet.ncols):
		v = sheet.cell_value(ROW_TYPE, col_idx)
		type_dict[col_idx] = str(v)
		v = sheet.cell_value(ROW_KEY, col_idx)
		key_dict[col_idx] = str(v)
	for row_idx in xrange(ROW_KEY+1, sheet.nrows):
		rowdict = {}
		rowid = 0
		for col_idx in xrange(sheet.ncols):
			v = sheet.cell_value(row_idx, col_idx)
			v = force_cast(v, type_dict[col_idx])
			rowdict[key_dict[col_idx]] = v
			if col_idx == 0:
				rowid = v
		d[rowid] = rowdict
	return d

def GetSheetData(filename, sheetname):
	if not os.path.isfile(filename):
		raise NameError, "%s is	not	a valid	filename" % filename
	book_xlrd = xlrd.open_workbook(filename)
	for sheet in book_xlrd.sheets():
		if sheetname == sheet.name:
			sheetobj = sheet
			return sheet_to_dict(sheet)

#[[name, dict],...]
def OutPutData(filename, list):
	s ="module(..., package.seeall)\n-------------auto generated-------------\n"
	for k in list:
		name, d = k[0], k[1]
		s += name+" ="+serialize(d)+"\n\n"
	# print s
	try:
		outfp = open(filename, "w")
		outfp.write(s)
		outfp.close()
		print("success----->"+filename)
	except:
		print("error------->"+filename)


# d = GetSheetData("G:/1.xls", "Sheet1")
# OutPutData("G:/1.lua", [["Data", d],["Data2", d]])
