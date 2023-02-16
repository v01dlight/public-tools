# credit: @waffl3ss
import socket
import argparse
import sys
from pathlib import Path
from argparse import RawTextHelpFormatter

parser = argparse.ArgumentParser(formatter_class=RawTextHelpFormatter)
parser.add_argument('-ip', dest='singleIP', default='', required=False, help="Single IP for testing")
parser.add_argument('-if', dest='fileIPs', default='', required=False, help="NewLine seperated list of IPs")
parser.add_argument('-to', dest='connTimeout', default=1, required=False, help="Timeout for socket connections")
args = parser.parse_args()

if args.singleIP == '' and args.fileIPs == '':
	print("[-] Single IP (-ip) or list of IPs (-if) required")
	sys.exit()
elif args.singleIP != '' and args.fileIPs != '':
	print("[-] Please only provide one input option")

if args.singleIP != '':
	s = socket.socket()
	s.settimeout(args.connTimeout)
	s.connect((args.singleIP, 9100))
	s.send(b"@PJL INFO ID\n")

	data = s.recv(256).decode("utf-8")
	printerName = data.split('"')[1]
	print("%s -- %s" % (args.singleIP,printerName))
	s.close()

if args.fileIPs != '':
	fileCheckPath = Path(args.fileIPs)
	if not fileCheckPath.is_file():
		print("[-] Input file does not exist")
		sys.exit()

	fileIPsList = open(args.fileIPs, 'r')

	for IPAddy in fileIPsList.readlines():
		ss = socket.socket()
		ss.settimeout(args.connTimeout)
		try:
			ss.connect((IPAddy.strip(), 9100))
			ss.send(b"@PJL INFO ID\n")

			data = ss.recv(256).decode("utf-8")
			printerName = data.split('"')[1]
			print("%s -- %s" % (IPAddy.strip(),printerName))

		except:
			pass

		ss.close()
	fileIPsList.close()
