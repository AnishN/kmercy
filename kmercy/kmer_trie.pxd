from libc.stdint cimport *
from libc.stdlib cimport *
from libc.string cimport *
from kmercy.sequence cimport *
from kmercy.item_vector cimport *

cdef struct KmerTrieNodeC:
    uint64_t[4] children
    size_t count

cdef class KmerTrie(object):

    cdef:
        ItemVector nodes
    
    cdef void build(self, Sequence seq, size_t k_min, size_t k_max) except *
    cdef void build_k(self, Sequence seq, size_t k) except *
    cdef size_t get_count(self, Sequence seq) except *