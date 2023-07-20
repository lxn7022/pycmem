
#coding:gbk

from libcpp.string cimport string
from libcpp.vector cimport vector
from libc.string cimport memcpy
from libc.string cimport memset
cimport trmem_cache_lib_inf as inf
cimport cython

import socket
import struct

class CmemError(Exception):
    pass
class CmemClientError(CmemError):
    pass
class CmemMemCacheError(CmemError):
    pass
class CmemAccessError(CmemError):
    pass
class CmemMasterError(CmemError):
    pass
class CmemUnknownError(CmemError):
    pass
        
cdef class CmemAPI:
    cdef inf.trmem_client_api *thisptr
    def __cinit__(self):
        self.thisptr = new inf.trmem_client_api()
    def __dealloc__(self):
        del self.thisptr
    #-----------------------------------------
    def _check_error(self, err_code):
        if err_code==0:
            return
        else:
            #官方版本错误码繁多，这里不再细分具体类型
            raise CmemError, (err_code, "CmemError:"+self.get_last_err())
    #-----------------------------------------
    def version(self):
        self.thisptr.Ver()
        
    def stat(self):
        cdef string str_stat
        cdef bytes  bytes_stat
        self.thisptr.m_TStatistics.ToString(str_stat)
        bytes_stat = str_stat.c_str()[:str_stat.length()]
        return bytes_stat
        
    def hostinfo(self):
        cdef vector[inf.THostCtrl] vec
        self.thisptr.get_host_info(vec)
        infos = []
        for i in range(vec.size()):
            info ={
                'ip': socket.inet_ntoa(struct.pack("!I",vec[i].uiIP )),
                'port':   vec[i].usPort,
                'state':  vec[i].state,
                'last_freeze_time':vec[i].last_freeze_time,
                'statistics':vec[i].statistics,
                'latest_statics_time':vec[i].latest_statics_time,
                'latest_request_cnt':vec[i].latest_request_cnt,
                'latest_read_timeout_cnt':vec[i].latest_read_timeout_cnt,
            }
            infos.append(info)
        return infos
        
    #-----------------------------------------
    def set_passwd(self, bid, pswd):
        return self.thisptr.set_passwd(bid, pswd)
        
    def get_last_err(self):
        cdef char * c_str = self.thisptr.GetLastErr()
        cdef bytes py_str = c_str
        return py_str
        
    def config_server_addr(self, addrs, timeout_ms=10000, feeze_secs=60):
        cdef inf.TServerAddr _addr
        cdef vector[inf.TServerAddr] _addrs
        for addr in addrs:
            ip = addr[0]
            memset(_addr.strIP, 0, 20)
            memcpy(_addr.strIP, <char*>ip, min(len(ip),20))
            _addr.usPort = addr[1]
            _addrs.push_back(_addr)
        return self.thisptr.config_server_addr(_addrs, timeout_ms, feeze_secs)
        
    def config_connect_timeout(self, connect_timeout_ms=10000):
        return self.thisptr.config_connect_timeout(<unsigned int>connect_timeout_ms)
        
    #const char* GetLastServer(string *pIP, unsigned short *pPort)
    def get_last_server(self):
        cdef string str_ip
        cdef unsigned short port
        cdef char * c_str_ret
        cdef bytes  bytes_val
        c_str_ret = <char*>self.thisptr.GetLastServer(&str_ip, &port)
        if c_str_ret != NULL:
            bytes_val = str_ip.c_str()[:str_ip.length()]
            return (bytes_val, port)
        else:
            return ()
    
    #int config_l5_sid(int modid, int cmdid, unsigned int timeout_ms, float l5_timeout_s)
    def config_l5_sid(self, modid, cmdid, timeout_ms=10000, l5_timeout_s=0.2):
        return self.thisptr.config_l5_sid(modid, cmdid, <unsigned int>timeout_ms, l5_timeout_s)
    
    #-----------------------------------------
    def get(self, bid, key, offset=0, length=-1):
        #--
        cdef int err = 0
        cdef int cas = 0
        cdef string str_key
        cdef string str_val
        cdef bytes  bytes_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.get_v2(bid, str_key, str_val, cas, offset, length, NULL)
        if err:
            self._check_error(err)
        bytes_val = str_val.c_str()[:str_val.length()]
        return (key,bytes_val,cas)
        
    def set(self, bid, key, val, cas, expire=0, offset=0, length=-1):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.set_v2_1(bid, str_key, str_val, _cas, expire, offset, length)
        if err:
            self._check_error(err)
        return (key, _cas)
        
    def delete(self, bid, key, cas=-1):
        cdef int err = 0
        cdef string str_key
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.del_v2(bid, str_key, cas)
        if err:
            self._check_error(err)
        return 
    
    def add(self,bid, key, val, expire=0):
        cdef int err = 0
        cdef string str_key
        cdef string str_val
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.add(bid, str_key, str_val, expire)
        if err:
            self._check_error(err)
        return 
        
    def replace(self, bid, key, val, cas, expire=0, offset=0, length=-1):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.replace(bid, str_key, str_val, _cas, expire, offset, length)
        if err:
            self._check_error(err)
        return (key, _cas)
    
    def append(self, bid, key, val, cas, expire=0):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.append(bid, str_key, str_val, _cas, expire)
        if err:
            self._check_error(err)
        return (key, _cas)
    
    def prepend(self, bid, key, val, cas, expire=0):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.prepend(bid, str_key, str_val, _cas, expire)
        if err:
            self._check_error(err)
        return (key, _cas)
        
    def insert(self, bid, key, val, cas, expire, offset):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.insert(bid, str_key, str_val, _cas, expire, offset)
        if err:
            self._check_error(err)
        return (key, _cas)
    #-----------------------------------------
    def getlist(self, bid, nodes):  
        #nodes: [(key1,offset1,length1),(key2,offset2,length2),(key3,offset3,length3), ...]
        #return:[(key1, val1, retcode, cas, expire, offset, len), 
        #        (key2, val2, retcode, cas, expire, offset, len), ...]
        if len(nodes) == 0:
            return ()
        #--
        cdef int err = 0
        cdef inf.TKeyNodeV2 _node
        cdef vector[inf.TKeyNodeV2] _nodes
        for node in nodes:
            _node.key.assign(<char*>node[0], <Py_ssize_t>len(node[0]))
            _node.offset = node[1]
            _node.len = node[2]
            _nodes.push_back(_node)
        #--
        err = self.thisptr.getlist_v2(bid, _nodes)
        if err<0:
            self._check_error(err)
        #--
        retnodes = []
        cdef bytes bytes_key
        cdef bytes bytes_val
        for i in xrange(_nodes.size()):
            bytes_key = _nodes[i].key.c_str()[:_nodes[i].key.length()]
            bytes_val = _nodes[i].data.c_str()[:_nodes[i].data.length()]
            retnode = (
                bytes_key,
                bytes_val,
                _nodes[i].retcode,
                _nodes[i].cas,
                _nodes[i].expire,
                _nodes[i].offset,
                _nodes[i].len,
            )
            retnodes.append(retnode)
        return retnodes
        
    def setlist(self, bid, nodes):  
        #nodes: [(key1,data,cas,expire,offset,length),(key2,data,cas,expire,offset,length), ... ]
        #return: [(key1,errcode1,cas1),(key2,errcode2,cas2),(key3,errcode3,cas3),...]
        #--
        cdef int err = 0
        cdef inf.TKeyNodeV2 _node
        cdef vector[inf.TKeyNodeV2] _nodes
        for node in nodes:
            _node.key.assign( <char*>node[0], <Py_ssize_t>len(node[0]))
            _node.data.assign(<char*>node[1], <Py_ssize_t>len(node[1]))
            _node.cas = node[2]
            _node.expire = node[3]
            _node.offset = node[4]
            _node.len = node[5]
            _nodes.push_back(_node)
        #--
        err = self.thisptr.setlist_v2_1(bid, _nodes)
        if err<0:
            self._check_error(err)
        #--
        retnodes = []
        cdef bytes bytes_key
        for i in xrange(_nodes.size()):
            bytes_key = _nodes[i].key.c_str()[:_nodes[i].key.length()]
            retnode = (
                bytes_key,
                _nodes[i].retcode,
                _nodes[i].cas,
            )
            retnodes.append(retnode)
        return retnodes
                
    def dellist(self, bid, nodes):  
        #nodes: [(key1,cas),(key2,cas),(key3,cas), ...]
        #return: [(key1,errcode),(key2,errcode),(key3,errcode),...]
        cdef int err = 0
        cdef inf.TKeyNodeV2 _node
        cdef vector[inf.TKeyNodeV2] _nodes
        for node in nodes:
            _node.key.assign(<char*>node[0], <Py_ssize_t>len(node[0]))
            _node.cas = node[1]
            _nodes.push_back(_node)
        #--
        err = self.thisptr.dellist_v2(bid, _nodes)
        if err<0:
            self._check_error(err)
        #--
        retnodes = []
        cdef bytes bytes_key
        for i in xrange(_nodes.size()):
            bytes_key = _nodes[i].key.c_str()[:_nodes[i].key.length()]
            retnode = (
                bytes_key,
                _nodes[i].retcode,
            )
            retnodes.append(retnode)
        return retnodes
    #-----------------------------------------
    def set_col(self, bid, key, col, val, cas):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        cdef string str_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        str_val.assign(<char*>val, <Py_ssize_t>len(val))
        err = self.thisptr.set_col(bid, str_key, col, str_val, _cas)
        if err:
            self._check_error(err)
        return (key, col, _cas)

    def get_col(self, bid, key, col):
        #--
        cdef int err = 0
        cdef int _cas = -1
        cdef string str_key
        cdef string str_val
        cdef bytes  bytes_val
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.get_col(bid, str_key, col, str_val, _cas)
        if err:
            self._check_error(err)
        bytes_val = str_val.c_str()[:str_val.length()]
        return (key, col, bytes_val, _cas)
        
    def del_col(self, bid, key, col, cas):
        #--
        cdef int err = 0
        cdef int _cas = cas
        cdef string str_key
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.del_col(bid, str_key, col, _cas)
        if err:
            self._check_error(err)
        return (key, col, _cas)
    #-----------------------------------------
    def set_mul_col(self, bid, node):
        #node: [key, cas,          [(col1, val1),    (col2, val2),    ...] ]
        #ret:  [key, cas, retcode, [(col1, retcode1),(col2, retcode2),...] ]
        cdef int err = 0
        cdef inf.TKeySetListNode _node
        cdef inf.TSetNode _col_node
        _node.key.assign(<char*>node[0], <Py_ssize_t>len(node[0]))
        _node.cas = node[1]
        for elem in node[2]:
            _col_node.col = elem[0]
            _col_node.data.assign(<char*>elem[1], <Py_ssize_t>len(elem[1]))
            _node.v_col_node.push_back(_col_node)
        #--
        err = self.thisptr.set_mul_col(bid, _node)
        if err<0:
            self._check_error(err)
        #--
        key = node[0]
        cas = _node.cas
        retcode = _node.retcode
        ret_col_nodes = []
        for i in xrange(_node.v_col_node.size()):
            ret_col_node = (
                _node.v_col_node[i].col,
                _node.v_col_node[i].retcode
            )
            ret_col_nodes.append(ret_col_node)
        return [key, cas, retcode, ret_col_nodes]

    def get_mul_col(self, bid, node):
        #node: [key, cas,          [ col1,                  col2,                 ...] ]                             ]
        #ret:  [key, cas, retcode, [(col1, val1, retcode1),(col2, val2, retcode2),...] ]
        cdef int err = 0
        cdef inf.TKeyGetListNode _node
        cdef inf.TGetNode _col_node
        _node.key.assign(<char*>node[0], <Py_ssize_t>len(node[0]))
        _node.cas = node[1]
        for elem in node[2]:
            _col_node.col = elem
            _node.v_col_node.push_back(_col_node)
        #--
        err = self.thisptr.get_mul_col(bid, _node)
        if err<0:
            self._check_error(err)
        #--
        key = node[0]
        cas = _node.cas
        retcode = _node.retcode
        ret_col_nodes = []
        cdef bytes bytes_val
        for i in xrange(_node.v_col_node.size()):
            bytes_val = _node.v_col_node[i].data.c_str()[:_node.v_col_node[i].data.length()]
            ret_col_node = (
                _node.v_col_node[i].col,
                bytes_val,
                _node.v_col_node[i].retcode
            )
            ret_col_nodes.append(ret_col_node)
        return [key, cas, retcode, ret_col_nodes]

    def del_mul_col(self, bid, node):
        #node: [key, cas           [ col1,            col2,           ...] ]                             ]
        #ret:  [key, cas, retcode, [(col1, retcode1),(col2, retcode2),...] ]
        cdef int err = 0
        cdef inf.TKeyDelListNode _node
        cdef inf.TDelNode _col_node
        _node.key.assign(<char*>node[0], <Py_ssize_t>len(node[0]))
        _node.cas = node[1]
        for elem in node[2]:
            _col_node.col = elem
            _node.v_col_node.push_back(_col_node)
        #--
        err = self.thisptr.del_mul_col(bid, _node)
        if err<0:
            self._check_error(err)
        #--
        key = node[0]
        cas = _node.cas
        retcode = _node.retcode
        ret_col_nodes = []
        for i in xrange(_node.v_col_node.size()):
            ret_col_node = (
                _node.v_col_node[i].col,
                _node.v_col_node[i].retcode
            )
            ret_col_nodes.append(ret_col_node)
        return [key, cas, retcode, ret_col_nodes]
    #-----------------------------------------
    #int incr_init(int bid, string &key, uint64_t value = 0); 
    def incr_init(self, bid, key, value=0):
        cdef int err = 0
        cdef string str_key
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.incr_init(bid, str_key, value)
        if err:
            self._check_error(err)
            
    #int incr_value(int bid, string &key, int64_t value)
    def incr_value(self, bid, key, value):    
        cdef int err = 0
        cdef string str_key
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.incr_value(bid, str_key, value)
        if err:
            self._check_error(err)
            
    #int incr_get(int bid, string &key, uint64_t &value)
    def incr_get(self, bid, key):
        cdef int err = 0
        cdef string str_key
        cdef inf.uint64_t value = 0
        #--
        str_key.assign(<char*>key, <Py_ssize_t>len(key))
        err = self.thisptr.incr_get(bid, str_key, value)
        if err:
            self._check_error(err)
        return (key,value)
                