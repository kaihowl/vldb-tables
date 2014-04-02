import threading
import time
import os, subprocess, signal
import urllib, httplib
import json
import sys
import re

from glob import glob
from copy import copy

CWD = os.path.dirname(__file__)
HYRISE_BINARY = "./build/hyrise-server_release"
TABLE_PATH = os.path.join(CWD, '../scaler/output/')
QUERIES_DIR = os.path.join(CWD, './queries/*')
PREPARATIONS_DIR = os.path.join(CWD, './preparations/*')
LOG_FILE = open(os.path.join(CWD, 'run.log'), 'w')
FILE_FILTER = ".*\.tbl"

class User(threading.Thread):
    def __init__(self, user_name, queries, runs, server):
        threading.Thread.__init__(self)

        self._user_name = user_name
        self._queries = copy(queries)
        self._runs = copy(runs)
        self._server = server

    def output_dir(self):
        return "%s/user_%s" % (self._server.output_dir(), self._user_name)

    def query(self, d):
        data = None
        try:
            conn = self._server.get_connection()
            conn.request("POST", "", urllib.urlencode([("query",d)]))
            r = conn.getresponse()
            data = r.read()
            conn.close()
        except Exception, e:
            print e, d
            sys.exit(1)
        return data

    def query_with_time(self, d):
        start = time.time()
        result = eval(self.query(d))
        end = time.time()

        result["time"] = {
            "start": start,
            "end": end,
            "duration": end - start
        }
            
        return result

    def run(self):
        while(self._runs > 0):
            print "Running user %s with run %i" % (self._user_name, self._runs)
            for filename, content in self._queries:
                with open("%s_%s_%i.json" % (self.output_dir(), filename, self._runs), "wb") as f: 
                    f.write(
                        json.dumps(
                            self.query_with_time(content),
                            sort_keys=True,
                            indent=4,
                            separators=(',', ': ')
                        )
                    )
            self._runs -= 1

class Server(object):
    def __init__(self, table_path, log_file=open(os.devnull, 'wb')):
        os.environ["HYRISE_DB_PATH"] = TABLE_PATH
        os.environ["LD_LIBRARY_PATH"] = "./build"
        self.p = subprocess.Popen([HYRISE_BINARY], stdout=log_file, stderr=subprocess.STDOUT)
        time.sleep(3)
        self.port = int(open("hyrise_server.port").readlines()[0])
        assert(self.port != 0)
        self._starttime = int(time.time())
        self.create_output_dir()
        print "started server", self.port

    def create_output_dir(self):
        os.mkdir(self.output_dir())

    def output_dir(self):
        return "./output_%i" % self._starttime

    def __del__(self):
        self.p.send_signal(signal.SIGINT)
        self.p.wait()

    def get_connection(self):
        return httplib.HTTPConnection("localhost", self.port, strict=False)


def load_queries(directory):
    queries = []
    for filename in glob(directory):
        with open(filename) as f:
            queries.append((os.path.basename(filename), f.read()))
    return queries

def execute_preparations(directory, server):
    user = User('preparation', load_queries(directory), 1, server)
    user.start()
    user.join()

def set_tables(table_file, queries):    
    pattern = re.compile("([\w]+)\.tbl")
    m = pattern.match(table_file)
    table_name = m.group(1)

    def replace_tables(query): 
        replaced = query[1].replace("{{table_name}}", table_name)
        replaced = replaced.replace("{{table_file}}", table_file)
        return (query[0], replaced)

    return map(replace_tables, queries)
    
def main():
    server = Server(TABLE_PATH, LOG_FILE)
    execute_preparations(PREPARATIONS_DIR, server)

    for filename in glob(TABLE_PATH+"/*.tbl"):
        # Filter all files not matching FILE_FILTER
        pattern = re.compile(FILE_FILTER)
        m = pattern.match(filename)
        if not m:
          continue

        filename = os.path.basename(filename)
        print "Dumping file %s" % filename
        queries = set_tables(filename, load_queries(QUERIES_DIR))
        users = []
        users.append(User("%s" % (filename), queries, 1, server))

	for user in users:
		user.start()

	for user in users:
		user.join()

if __name__ == "__main__":
    main()
