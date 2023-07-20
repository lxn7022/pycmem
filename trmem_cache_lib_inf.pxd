
#coding:gbk

from libcpp.string cimport string
from libcpp.vector cimport vector

from libc.stdint cimport  int64_t
from libc.stdint cimport uint64_t

cdef extern from "common_define.h" namespace "ssdasn":
    ctypedef struct TServerAddr:
        char strIP[20]
        unsigned short usPort
    #-------    
    ctypedef struct TKeyNode:
        string key
        string data
        int retcode
        
    ctypedef struct TKeyNodeV2:
        string key
        string data
        int retcode
        int cas     
        int expire        
        int offset        
        int len       
        
    ctypedef struct TRspExt:
        pass
    #-------    
    ctypedef struct TSetNode:
        unsigned int col #列号，从0开始,最大是511
        string data      #set时表示要设置的数据
        int retcode      #返回码,0表示成功，其他表示失败
        
    ctypedef struct TGetNode:
        unsigned int col #列号，从0开始,最大是511
        string data      #get结果 
        int retcode      #返回码,0表示成功，其他表示失败
        
    ctypedef struct TDelNode:
        unsigned int col #列号，从0开始,最大是511
        int retcode      #返回码,0表示成功，其他表示失败
    #-------    
    ctypedef struct TKeySetListNode:
        string key                    #key
        int cas 	                  #-1表示不使用
        vector[TSetNode] v_col_node   #列数组
        int retcode                   #0 全部成功,> 0  retcode!=0的个数, <0 表示接口错误，即其他错误码

    ctypedef struct TKeyGetListNode:
        string key                    #key
        int cas 	                  #-1表示不使用，用于返回cas
        vector[TGetNode] v_col_node   #列数组
        int retcode                   #0 全部成功,> 0  retcode!=0的个数, <0 表示接口错误，即其他错误码
       
    ctypedef struct TKeyDelListNode:
        string key                    #key
        int cas 	                  #-1表示不使用
        vector[TDelNode] v_col_node   #列数组
        int retcode                   #0 全部成功,> 0  retcode!=0的个数, <0 表示接口错误，即其他错误码
        
    ctypedef struct TStatistics:
        void ToString(string &s)
       
    ctypedef struct THostCtrl:
        unsigned int uiIP
        unsigned short usPort
        unsigned char state
        int sock_fd
        #time_t last_freeze_time
        long int last_freeze_time
        unsigned long long statistics #连接建立后发送请求次数统计
        int latest_statics_time       #最近60s统计开始时间
        int latest_request_cnt        #最近60s开始到现在的请求个数
        int latest_read_timeout_cnt   #最近60s开始到现在的读超时个数
        char strErr[512]              # add by cjhuang
    
cdef extern from "trmem_cache_lib.h" namespace "ssdasn":
    cdef cppclass trmem_client_api:
        TStatistics m_TStatistics
        #-----
        void Ver()
        void get_host_info(vector[THostCtrl] &vec)
        #-----
        int set_passwd(int bid, char *pPasswd)
        char* GetLastErr()
        int config_server_addr(vector[TServerAddr] &vaddr, unsigned int timeout_ms, int iFreezeSecs)
        int config_connect_timeout(unsigned int connect_timeout_ms)
        char* GetLastServer(string *pIP, unsigned short *pPort)
        int config_l5_sid(int modid, int cmdid, unsigned int timeout_ms, float l5_timeout_s)
        #-----
        int set_v2(  int bid, string &key, string &data, int &cas, int expire, int offset, int len)
        int set_v2_1(int bid, string &key, string &data, int &cas, int expire, int offset, int len)
        int set_v2_2(int bid, string &key, string &data, int &cas, int &value_len, int expire, int offset, int len)
        int get_v2(  int bid, string &key, string &data, int &cas,             int offset, int len, TRspExt* rsp_ext)
        int del_v2(  int bid, string &key,               int cas)
        int add(     int bid, string &key, string &data,           int expire)
        int replace( int bid, string &key, string &data, int &cas, int expire, int offset, int len)
        int append(  int bid, string &key, string &data, int &cas, int expire)
        int append_v2(int bid, string &key, string &data, int &cas, int &value_len, int expire)
        int prepend( int bid, string &key, string &data, int &cas, int expire)
        int insert(  int bid, string &key, string &data, int &cas, int expire, int offset)
        #-----
        int getlist_v2(int bid, vector[TKeyNodeV2] &v_node)
        int setlist_v2(int bid, vector[TKeyNodeV2] &v_node)
        int setlist_v2_1(int bid, vector[TKeyNodeV2] &v_node)
        int dellist_v2(int bid, vector[TKeyNodeV2] &v_node)	
        #-----
        int set_col(int bid, string &key, unsigned int col, string &data, int &cas)
        int get_col(int bid, string &key, unsigned int col, string &data, int &cas)
        int del_col(int bid, string &key, unsigned int col,               int &cas)
        #-----
        int set_mul_col(int bid, TKeySetListNode &node) 
        int get_mul_col(int bid, TKeyGetListNode &node) 
        int del_mul_col(int bid, TKeyDelListNode &node)
        #-----
        int setlist_mul_col(int bid, vector[TKeySetListNode] &v_node)
        int getlist_mul_col(int bid, vector[TKeyGetListNode] &v_node)
        int dellist_mul_col(int bid, vector[TKeyDelListNode] &v_node)
        #-----
        int incr_init( int bid, string &key, uint64_t value)
        int incr_value(int bid, string &key,  int64_t value)
        int incr_get(  int bid, string &key, uint64_t &value)
        
        
        
        