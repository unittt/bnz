import xlstools
XLS_PATH = "./xls/test.xls"
OUTPUT_PATH = "./data/test.lua"

def main():
	d = xlstools.GetSheetData(XLS_PATH, "Sheet1")
	xlstools.OutPutData(OUTPUT_PATH, [["Data", d]])
main()
