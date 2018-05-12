import json
import urllib2
import glob
import os
import time

user = "mojmaildospamu@gmail.com"
lpmn = 'any2txt|wcrft2|liner2({"model":"n82"})'
url = "http://ws.clarin-pl.eu/nlprest2/base"

dump_base = "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex8/"

in_path = dump_base + 'judgments/*'
out_path = dump_base + 'ner_out/'


def upload(f):
    with open(f, "rb") as myfile:
        doc = myfile.read()
    return urllib2.urlopen(urllib2.Request(url + '/upload/', doc, {'Content-Type': 'binary/octet-stream'})).read()


def process(data):
    doc = json.dumps(data)
    taskid = urllib2.urlopen(urllib2.Request(url + '/startTask/', doc, {'Content-Type': 'application/json'})).read()
    time.sleep(0.2)
    resp = urllib2.urlopen(urllib2.Request(url + '/getStatus/' + taskid))
    data = json.load(resp)
    while data["status"] == "QUEUE" or data["status"] == "PROCESSING":
        time.sleep(0.5)
        resp = urllib2.urlopen(urllib2.Request(url + '/getStatus/' + taskid))
        data = json.load(resp)
    if data["status"] == "ERROR":
        print("Error " + data["value"])
        return None
    return data["value"]


def main():
    global_time = time.time()
    for f in glob.glob(in_path):
        fileid = upload(f)
        print("Processing: " + f)
        data = {'lpmn': lpmn, 'user': user, 'file': fileid}
        data = process(data)
        if data is None:
            print("data is none, {}".format(f))
            continue
        data = data[0]["fileID"]
        content = urllib2.urlopen(urllib2.Request(url + '/download' + data)).read()
        with open(out_path + os.path.basename(f) + '.ccl', "w") as outfile:
            outfile.write(content)
    print("GLOBAL %s seconds ---" % (time.time() - global_time))


main()
