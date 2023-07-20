#!/usr/bin/python
#coding:gbk



import time
import cmem


cmem_api = cmem.CmemAPI()

config ={
'addrs':[
    ("10.130.70.219",9101),
    ("10.161.13.83", 9101),
    ],
'bid':100150,
'pswd':"larkliu"

}

bid = config['bid']
cmem_api.config_server_addr(config['addrs'])
cmem_api.set_passwd(bid,config['pswd'])

#----------------------------
print "#get,set,add,delete,append,prepend,insert"

ret = cmem_api.set(bid, '1234', 'abcde',-1)
ret =cmem_api.get(bid, '1234')
print ret

cas = ret[2]
ret = cmem_api.set(bid, '1234', 'abcde',cas)
print ret
ret = cmem_api.get(bid, '1234')
print ret
cas = ret[2]
ret = cmem_api.set(bid, '1234', 'x',cas,0,0,1)
print ret
print cmem_api.get(bid, '1234')


try:
    cmem_api.delete(bid, 'key2')
except Exception,e:
    print e
cmem_api.add(bid, 'key2', 'val2')
cmem_api.append(bid, 'key2', ' append', -1)
cmem_api.prepend(bid, 'key2', 'prepend ', -1)
cmem_api.insert(bid, 'key2', ' insert ', -1, 0, 10)
print cmem_api.get(bid, 'key2')

print '----------------------------'
print '#getlist,setlist,dellist'
keys = [
    ('1234', 0, -1),
    ('key2', 0, -1),
]
print cmem_api.getlist(bid, keys)


keys1 = [
    ('key_setlist1', -1, ),
    ('key_setlist2', -1, ),
    ('key_setlist3', -1, ),
    ('key_setlist4', -1, ),
    ('key_setlist5', -1, ),
]
print cmem_api.dellist(bid, keys1)

nodes = [
('key_setlist1', 'setlist1', -1, 0, 0, -1),
('key_setlist2', 'setlist2', -1, 0, 0, -1),
('key_setlist3', 'setlist3', -1, 0, 0, -1),
('key_setlist4', 'setlist4', -1, 0, 0, -1),
('key_setlist5', 'setlist5', -1, 0, 0, -1),
]
print cmem_api.setlist(bid, nodes)

keys2 = [
    ('key_setlist1', 0, -1),
    ('key_setlist2', 0, -1),
    ('key_setlist3', 0, -1),
    ('key_setlist4', 0, -1),
    ('key_setlist5', 0, -1),
]
print cmem_api.getlist(bid, keys2)

print '----------------------------'
print '#performance'
#测试性能

beg = time.time()
for i in xrange(1):
    cmem_api.getlist(bid, keys2)
end = time.time()
print "time:%f" % (end - beg,)


try:
    print cmem_api.get(bid, '12345')
except Exception,e:
    print e

print '----------------------------'
print '#get_col,set_col,del_col'

print cmem_api.set_col(bid, "key_set_col", 0, "key_set_col:col0", -1)
print cmem_api.set_col(bid, "key_set_col", 1, "key_set_col:col1", -1)
print cmem_api.set_col(bid, "key_set_col", 2, "key_set_col:col2", -1)

print cmem_api.get_col(bid, "key_set_col", 0)
try:
    #列5不存在
    print cmem_api.get_col(bid, "key_set_col", 5)
except Exception,e:
    print e

print cmem_api.del_col(bid, "key_set_col", 2, -1)
try:
    #列2不存在
    print "Note!!!, return null string, do not raise exception."
    print cmem_api.get_col(bid, "key_set_col", 2)
except Exception,e:
    print e

print '----------------------------'
print '#get_mul_col,set_mul_col,del_mul_col'
#set_mul_col
#node: [key, cas,          [(col1, val1),    (col2, val2),    ...] ]
#ret:  [key, cas, retcode, [(col1, retcode1),(col2, retcode2),...] ]
node = [
    "key_set_mul_col", 
    -1,          
    [(0, 'key_set_mul_col:col0'),    
     (1, 'key_set_mul_col:col1'),
     (2, 'key_set_mul_col:col2'),
     (3, 'key_set_mul_col:col3'),
     (4, 'key_set_mul_col:col4'),] 
]
print cmem_api.set_mul_col(bid, node)

#get_mul_col
#node: [key, cas,          [ col1,                  col2,                 ...] ]                             ]
#ret:  [key, cas, retcode, [(col1, val1, retcode1),(col2, val2, retcode2),...] ]
node = [
    "key_set_mul_col", 
    -1,          
    [0, 1, 2, 3, 4, 5] #note: 没有5
]
print cmem_api.get_mul_col(bid, node)

#测试性能
beg = time.time()
for i in xrange(100):
    cmem_api.get_mul_col(bid, node)
end = time.time()
print "time:%f" % (end - beg,)


#del_mul_col
#node: [key, cas           [ col1,            col2,           ...] ]                             ]
#ret:  [key, cas, retcode, [(col1, retcode1),(col2, retcode2),...] ]

node = [
    "key_set_mul_col", 
    -1,          
    [0, 1, 2, 3, 4, 5] #note: 没有5
]
print cmem_api.del_mul_col(bid, node)
print cmem_api.get_mul_col(bid, node)


node = [
    "key_set_mul_col_notexist", 
    -1,          
    [0, 1, 2, 3, 4, 5] 
]
print cmem_api.get_mul_col(bid, node)

print '----------------------------'
print '#incr_init,incr_value,incr_get'

incr_key = 'incr_id100' 
incr_key_not_init = 'incr_id101' 
cmem_api.incr_init(bid, incr_key)
val = cmem_api.incr_get(bid, incr_key)
print "key=%s: value=%s" % (incr_key, val)

cmem_api.incr_value(bid,incr_key,100)
cmem_api.incr_value(bid,incr_key,-1)
val = cmem_api.incr_get(bid, incr_key)
print "key=%s: value=%s" % (incr_key, val)

try:
    cmem_api.incr_value(bid,incr_key_not_init,100)
except Exception,e:
    print e
try:
    cmem_api.incr_get(bid,incr_key_not_init)
except Exception,e:
    print e

print '----------------------------'
print '#L5'

cmem_api2 = cmem.CmemAPI()

config2 ={
    'modid':107521,
    'cmdid':786432,
    'bid':100150,
}

cmem_api2.config_l5_sid(config2['modid'], config2['cmdid'])

incr_key = 'incr_id100' 
incr_key_not_init = 'incr_id101' 
try:
    cmem_api2.incr_init(bid, incr_key)
    l5_addr1 = cmem_api2.get_last_server()
    print "key=%s: value=%s" % (incr_key, cmem_api2.incr_get(bid, incr_key))
    cmem_api2.incr_value(bid,incr_key,100)
    cmem_api2.incr_value(bid,incr_key,-1)
    l5_addr2 = cmem_api2.get_last_server()
    print "key=%s: value=%s" % (incr_key, cmem_api2.incr_get(bid, incr_key))
    print 'l5_addr1:%s, l5_addr2:%s' % (l5_addr1, l5_addr2)
except Exception,e:
    print e

print '----------------------------'
print '#cmem_api.version'
cmem_api.version()
print '\n#cmem_api.stat'
print cmem_api.stat()
print '#cmem_api.hostinfo'
infos = cmem_api.hostinfo()
for info in infos:
    print '--info:'
    for key in info:
        print "%s:%s" % (key, info[key] )

