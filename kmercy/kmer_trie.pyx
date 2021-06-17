cdef class KmerTrie(object):

    def __cinit__(self):
        self.nodes = ItemVector(sizeof(KmerTrieNodeC))
        self.nodes.c_push_empty()

    def __dealloc__(self):
        self.nodes = None

    cdef void build(self, Sequence seq, size_t k_min, size_t k_max) except *:
        cdef:
            size_t i, j
            Base base
            size_t base_index
            size_t node_index
            size_t child_index
            KmerTrieNodeC *node_ptr
            KmerTrieNodeC *child_ptr

        for i in range(seq.num_bases - k_max + 1):
            node_index = 0
            for j in range(k_max):
                base = seq.get_base(i + j)
                base_index = <size_t>base
                node_ptr = <KmerTrieNodeC *>self.nodes.c_get_ptr(node_index)
                child_index = node_ptr.children[base_index]
                if child_index == 0:
                    node_ptr.children[base_index] = self.nodes.num_items
                    child_index = self.nodes.num_items
                    self.nodes.c_push_empty()
                child_ptr = <KmerTrieNodeC *>self.nodes.c_get_ptr(child_index)
                child_ptr.count += 1
                node_index = child_index
    
    cdef size_t get_count(self, Sequence kmer) except *:
        cdef:
            size_t i
            Base base
            size_t base_index
            size_t node_index = 0
            KmerTrieNodeC *node_ptr
        
        for i in range(kmer.num_bases):
            base = kmer.get_base(i)
            base_index = <size_t>base
            node_ptr = <KmerTrieNodeC *>self.nodes.c_get_ptr(node_index)
            node_index = node_ptr.children[base_index]
            if i != 0 and node_ptr.count == 0:
                return 0
        node_ptr = <KmerTrieNodeC *>self.nodes.c_get_ptr(node_index)
        return node_ptr.count