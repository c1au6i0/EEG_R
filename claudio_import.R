info <- file.choose()
info_bin <- file(info,"rb")

seek(info_bin, 0, origin = 'start')
readBin(info_bin, integer(), n = 1, size = 4) #magic

readBin(info_bin, integer(), n = 1, size = 2, signed = TRUE) #major
readBin(info_bin, integer(), n = 1, size = 2, signed = TRUE) #minor

readBin(info_bin, double(), n = 1) #sample rate


#python commands. THIS IS NOT R THE FOLLOWING COMMANDS ARE PYTHON!!!!!!!!!

from veda_eeg.io.load_intan_rhd_format import read_header
import yaml #magari prima fare pip install pyyaml

header_text = open('header.txt','w') #connessione a output
info_rhd = open('info.rhd') #connessione a file info
header = read_header(info_rhd) #leggi header

yaml.dump(header, stream=header_text) # salva su header.txt

header_text.close()
info_rhd.close()



library("reticulate")

info <- file.choose()

py <- import_builtins()

info_py = py$open(info,'r')

np$fromfile(info_py, dtype=np$int32, count = as.integer(1))

np$fromfile(info_py, dtype=np$int16, count = as.integer(1))

np$fromfile(info_py, dtype=np$int16, count = as.integer(1))

np$fromfile(info_py, dtype=np$single, count = as.integer(1))

