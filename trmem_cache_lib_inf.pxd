
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
        unsigned int col #�кţ���0��ʼ,�����511
        string data      #setʱ��ʾҪ���õ�����
        int retcode      #������,0��ʾ�ɹ���������ʾʧ��
        
    ctypedef struct TGetNode:
        unsigned int col #�кţ���0��ʼ,�����511
        string data      #get��� 
        int retcode      #������,0��ʾ�ɹ���������ʾʧ��
        
    ctypedef struct TDelNode:
        unsigned int col #�кţ���0��ʼ,�����511
        int retcode      #������,0��ʾ�ɹ���������ʾʧ��
    #-------    
    ctypedef struct TKeySetListNode:
        string key                    #key
        int cas 	                  #-1��ʾ��ʹ��
        vector[TSetNode] v_col_node   #������
        int retcode                   #0 ȫ���ɹ�,> 0  retcode!=0�ĸ���, <0 ��ʾ�ӿڴ��󣬼�����������

    ctypedef struct TKeyGetListNode:
        string key                    #key
        int cas 	                  #-1��ʾ��ʹ�ã����ڷ���cas
        vector[TGetNode] v_col_node   #������
        int retcode                   #0 ȫ���ɹ�,> 0  retcode!=0�ĸ���, <0 ��ʾ�ӿڴ��󣬼�����������
       
    ctypedef struct TKeyDelListNode:
        string key                    #key
        int cas 	                  #-1��ʾ��ʹ��
        vector[TDelNode] v_col_node   #������
        int retcode                   #0 ȫ���ɹ�,> 0  retcode!=0�ĸ���, <0 ��ʾ�ӿڴ��󣬼�����������
        
    ctypedef struct TStatistics:
        void ToString(string &s)
       
    ctypedef struct THostCtrl:
        unsigned int uiIP
        unsigned short usPort
        unsigned char state
        int sock_fd
        #time_t last_freeze_time
        long int last_freeze_time
        unsigned long long statistics #���ӽ��������������ͳ��
        int latest_statics_time       #���60sͳ�ƿ�ʼʱ��
        int latest_request_cnt        #���60s��ʼ�����ڵ��������
        int latest_read_timeout_cnt   #���60s��ʼ�����ڵĶ���ʱ����
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
        
        
        
        