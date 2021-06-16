import time

def count_kmers(bytes string, size_t k_min, size_t k_max):
    cdef:
        size_t i, j
        size_t n = len(string)
        bytes kmer
        dict counter = {}
    for i in range(0, n - k_max + 1):
        for j in range(k_min, k_max + 1):
            kmer = string[i:i+j]
            counter[kmer] = counter.get(kmer, 0) + 1
    return counter

cdef:
    size_t num_bases = 130_000
    Sequence seq = Sequence()
    bytes seq_bytes = bytes(num_bases)
    KmerTrie trie = KmerTrie()
    size_t k_min = 3
    size_t k_max = 16
    size_t k_size = 5
    Sequence kmer = Sequence()
    bytes kmer_bytes = bytes(k_size)

seq.create(num_bases)
seq.randomize()
seq.to_bytes(seq_bytes)
print(seq_bytes[:50])

kmer.create(k_size)
kmer.randomize()
kmer.to_bytes(kmer_bytes)
print(kmer_bytes)

start = time.time()
counts = count_kmers(seq_bytes, k_min, k_max)
end = time.time()
print(end - start)

start = time.time()
print(counts[kmer_bytes])
end = time.time()
print(end - start)

start = time.time()
trie.build(seq, k_min, k_max)
end = time.time()
print(end - start)

start = time.time()
print(trie.get_count(kmer))
end = time.time()
print(end - start)

kmer.delete()
seq.delete()