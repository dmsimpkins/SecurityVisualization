#!/usr/bin/python

import re
from datetime import datetime
import MySQLdb

class IPAddress(object):
    """An IP address"""
    def __init__(self, string):
        if type(string) is int:
            self.value = string
            return

        parts = string.split('.')
        self.value = \
            int(parts[0]) * (2**24) + \
            int(parts[1]) * (2**16) + \
            int(parts[2]) * (2**8) +  \
            int(parts[3])

    def __str__(self):
        part1 = (self.value & 0xff000000) >> 24
        part2 = (self.value & 0x00ff0000) >> 16
        part3 = (self.value & 0x0000ff00) >> 8
        part4 = (self.value & 0x000000ff)
        
        return str(part1) + '.' + \
            str(part2) + '.' + \
            str(part3) + '.' + \
            str(part4)
        
class IPRange(object):
    """A range of IP addresses"""
    def __init__(self, string):
        """Initialize the range with a string like '10.1.60.1/24'"""
        parts = string.split('/', 1)
        ip = parts[0]
        maskBits = int(parts[1])
        mask = ~(2**(32 - maskBits) - 1)

        value = IPAddress(ip).value
        self.beginRange = value & mask
        self.endRange = self.beginRange + (~mask + 1)

    def contains(self, string):
        value = IPAddress(string).value
        return self.beginRange <= value < self.endRange

AlertIPMap = ['Local', 'Safe', 'Unknown', 'Unsafe', 'Foreign']
AlertIPClasses = [('Local', [IPRange('10.1.60.1/24'), \
                             IPRange('31.154.241.9/29'), \
                             IPRange('7.204.241.162/30'), \
                             IPRange('222.100.5.235/30'), \
                             IPRange('154.241.88.202/30'), \
                             IPRange('180.242.137.182/30'), \
                             IPRange('65.190.233.38/30'), \
                             IPRange('3.75.190.182/30'), \
                             IPRange('140.13.22.34/30')]), \
                  ('Safe', []), \
#                  ('Unknown', []), \
                  ('Unsafe', [IPRange('212.117.116.37/29')]), \
                  ('Foreign', [])]

class Alert(object):
    """An alert from Snort"""
    def __init__(self):
        self.alert_id = 0
        self.date_time = 0
        self.age = 0
        self.priority = -1
        self.srcIP = ''
        self.srcIPClass = 'Invalid'
        self.srcIPType = 0
        self.srcPort = '-1'
        self.dstIP = ''
        self.dstIPClass = 'Invalid'
        self.dstIPType = 0
        self.dstPort = '-1'
        self.details = ''

    def parse(self, string):
        lines = string.split('\n')

        # Parse the alert description
        match = re.search('\[\*\*\] \[.*?\] (.*?) \[\*\*\]', lines[0])
        if match is None:
            print 'Failed to parse alert details'
        else:
            self.details = match.group(1)

        # Parse the alert priority
        match = re.search('\[Priority: (\d*)\]', lines[1])
        if match is None:
            print 'Failed to parse alert priority'
        else:
            self.priority = int(match.group(1))

        # Parse the date, time, source IP, and dest IP information
        dt, source, foo, destination = lines[2].split(' ')
        self.date_time = datetime.strptime('2011/' + dt, '%Y/%m/%d-%H:%M:%S.%f')

        # Some magic numbers from the data:
        startTime = datetime(2011, 11, 8, 9, 43, 9, 173299)
        total_seconds = 330535.923175
        self.age = (self.date_time - startTime).total_seconds() / total_seconds

        srcParts = source.split(':')
        self.srcIP = srcParts[0]
        if len(srcParts) > 1:
            self.srcPort = srcParts[1]

        dstParts = destination.split(':')
        self.dstIP = dstParts[0]
        if len(dstParts) > 1:
            self.dstPort = dstParts[1]

        # Classify source and destination IP addresses
        self.srcIPClass = 'Unknown'
        self.dstIPClass = 'Unknown'
        for c, ranges in AlertIPClasses:
            for r in ranges:
                if r.contains(self.srcIP):
                    self.srcIPClass = c
                if r.contains(self.dstIP):
                    self.dstIPClass = c
        self.srcIPType = AlertIPMap.index(self.srcIPClass)
        self.dstIPType = AlertIPMap.index(self.dstIPClass)

        # Testing
        parts = lines[3].split()
        self.protocol = parts[0]
        self.ttl = parts[1][4:]
        self.id = parts[3][3:]
        self.iplen = parts[4][6:]
        self.dgmlen = parts[5][7:]

        self.flags = ''
        self.seq = ''
        if self.protocol == 'TCP':
            parts = lines[4].split()
            self.flags = parts[0]
            self.seq = parts[2]
            self.ack = parts[4]
            self.win = parts[6]
            self.tcplen = parts[8]

    def __str__(self):
        ret = ''
        ret += 'Time/Date: ' + str(self.age) + '\n'
        ret += 'Priority: ' + str(self.priority) + '\n'
        ret += 'Source: ' + self.srcIP + ' (' + self.srcIPClass + ')\n'
        ret += 'Destination: ' + self.dstIP + ' (' + self.dstIPClass + ')\n'
        ret += 'Details: ' + self.details + '\n'
        return ret


# Set up database table
db = MySQLdb.connect(host='localhost', user='root',passwd ='toor',db='netflow')
c = db.cursor()

# Delete all current table entries
c.execute('DELETE FROM alerts WHERE 1=1')
c.execute('DELETE FROM histogram WHERE 1=1')

index = 0
counts = []
firstIDs = []

times = []
numberOfBuckets = 100
for i in range(1, numberOfBuckets + 1):
    times.append(i / float(numberOfBuckets))

print times

# Read alerts
s = set()
with open('snort.alerts') as alerts_file:
    alerts_string = alerts_file.read()
    alert_strings = re.split('\n\n', alerts_string, flags=re.DOTALL)

    currentCount = 0

    for i in xrange(len(alert_strings) - 1):
        a = Alert()
        a.parse(alert_strings[i])
	c.execute(\
'''
INSERT INTO alerts (ALERT_ID, DATE_TIME, AGE, PRIORITY, SRC_IP, SRC_IP_CLASS, SRC_IP_TYPE, SRC_PORT, DST_IP, DST_IP_CLASS, DST_IP_TYPE, DST_PORT, DETAILS, PROTOCOL, TTL, ID, IPLEN, DGMLEN, FLAGS, SEQ)
VALUES ('{}', '{}', {}, {}, '{}', '{}', {}, {}, '{}', '{}', {}, {}, '{}', '{}', {}, {}, {}, {}, '{}', '{}');
'''.format(i, a.date_time, a.age, a.priority, a.srcIP, a.srcIPClass, a.srcIPType, a.srcPort, a.dstIP, a.dstIPClass, a.dstIPType, a.dstPort, a.details, a.protocol, a.ttl, a.id, a.iplen, a.dgmlen, a.flags, a.seq))
        if a.age < times[index]:
            currentCount += 1
        else:
            index += 1
            counts.append(currentCount)
            firstIDs.append(i)
            currentCount = 0

print counts
print firstIDs

print len(counts)

maxCount = 0
for i in range(0, numberOfBuckets):
    if counts[i] > maxCount:
        maxCount = counts[i]

print maxCount

for i in range(0, numberOfBuckets):
    try:   
        ex_count = c.execute(\
'''
INSERT INTO `histogram` (`INDEX`, `FIRST_ID`, `SIZE`)
VALUES ('{}', '{}', '{}');
'''.format(i, firstIDs[i], counts[i] / float(maxCount)))
        #print ex_count
        # Insert each alert's data into the table 
    except MySQLdb.IntegrityError:
        print "Failed to insert values!"
       

    if i == 0:
        print i
        print a.srcIPType

print "I made it."
# Close the database connection
c.close()
db.commit()
db.close()
