import itertools as its
import time

def count_kmers(bytes string, size_t k_min, size_t k_max):
    cdef:
        size_t i, j, k
        size_t n = len(string)
        bytes kmer
        dict counter = {}
    for i in range(0, n - k_max + 1):
        for j in range(k_min, k_max + 1):
            kmer = string[i:i+j]
            counter[kmer] = counter.get(kmer, 0) + 1
    return counter

def run_fixed_size_kmer_test(dict counts, KmerTrie trie, size_t k):
    cdef:
        bytes alphabet = b"ACGT"
        Sequence small_kmer
        bytes b_small_kmer
        char *b_small_kmer_ptr
        size_t num_small_kmers
        list small_kmers = []
        list small_kmer_bytes = []
        list small_kmer_bytes_tmp = []
        size_t count
        dict slow_counts = {}
        dict fast_counts = {}
        bint match_count
        double python_time
        double cython_time

    small_kmer_bytes_tmp = list(its.product(alphabet, repeat=k))
    num_small_kmers = len(small_kmer_bytes_tmp)
    for i in range(len(small_kmer_bytes_tmp)):
        b_small_kmer = bytes(k)
        b_small_kmer_ptr = <char *>b_small_kmer
        for j in range(k):
            b_small_kmer_ptr[j] = small_kmer_bytes_tmp[i][j]
        small_kmer_bytes.append(b_small_kmer)
        small_kmer = Sequence()
        small_kmer.create(k)
        small_kmer.from_bytes(b_small_kmer)
        small_kmers.append(small_kmer)

    start = time.time()
    slow_counts = {}
    for i in range(num_small_kmers):
        b_small_kmer = small_kmer_bytes[i]
        count = counts.get(b_small_kmer, 0)
        slow_counts[b_small_kmer] = count
    end = time.time()
    python_time = end - start

    start = time.time()
    for i in range(num_small_kmers):
        small_kmer = small_kmers[i]
        count = trie.get_count(small_kmer)
        fast_counts[small_kmer] = count
    end = time.time()
    cython_time = end - start

    match_count = list(slow_counts.values()) == list(fast_counts.values())

    print("Fixed Size Kmer Test (k = {0}): Python Dict = {1}, Cython Trie = {2}, Result = {3}".format(
        k, python_time, cython_time, match_count,
    ))

def run_random_sub_kmer_test(dict counts, KmerTrie trie, size_t k_min, size_t k_max, size_t num_runs):
    cdef:
        size_t i
        Sequence kmer = Sequence()
        size_t num_sub_kmers = k_max - k_min
        bytes kmer_bytes
        Sequence sub_kmer
        bytes b_sub_kmer
        list sub_kmers
        list sub_kmer_bytes
        size_t count
        dict slow_counts
        dict fast_counts
        double python_time = 0.0
        double cython_time = 0.0
        bint match_count = True
        size_t n
    
    for n in range(num_runs):
        kmer.create(k_max)
        kmer.randomize()
        kmer_bytes = bytes(k_max)
        kmer.to_bytes(kmer_bytes)
        sub_kmers = []
        sub_kmer_bytes = []
        slow_counts = {}
        fast_counts = {}

        for i in range(k_min, k_max + 1):
            b_sub_kmer = kmer_bytes[:i]
            sub_kmer = Sequence()
            sub_kmer_bytes.append(b_sub_kmer)
            sub_kmer = Sequence()
            sub_kmer.create(i)
            sub_kmer.from_bytes(b_sub_kmer)
            sub_kmers.append(sub_kmer)

        start = time.time()
        for i in range(num_sub_kmers):
            b_sub_kmer = <bytes>sub_kmer_bytes[i]
            count = counts.get(b_sub_kmer, 0)
            slow_counts[b_sub_kmer] = count
        end = time.time()
        python_time += end - start
        
        start = time.time()
        for i in range(num_sub_kmers):
            sub_kmer = <Sequence>sub_kmers[i]
            count = trie.get_count(sub_kmer)
            fast_counts[sub_kmer] = count
        end = time.time()
        cython_time += end - start

        if list(slow_counts.values()) != list(fast_counts.values()):
            match_count = False

        kmer.delete()
        for i in range(num_sub_kmers):
            <Sequence>sub_kmers[i].delete()

    kmer_bytes = None
    sub_kmers = None
    sub_kmer_bytes = None

    print("Random Sub Kmer Test # Runs:", num_runs)
    print("Random Sub Kmer Test (Python Dict):", python_time)
    print("Random Sub Kmer Test (Cython Trie):", cython_time)
    print("Random Sub Kmer Test Result:", match_count)

cdef:
    size_t num_bases = 130_000
    Sequence seq
    bytes seq_bytes
    dict counts
    KmerTrie trie
    size_t k_min = 3
    size_t k_max = 16
    size_t fixed_k_min = 3
    size_t fixed_k_max = 8
    size_t k
    size_t num_runs = 10_000
    
seq = Sequence()
seq_bytes = bytes(num_bases)
counts = {}
trie = KmerTrie()

seq.create(num_bases)
seq.randomize()
seq.to_bytes(seq_bytes)
print("Sequence:", seq_bytes[:50] + b"...")

start = time.time()
counts = count_kmers(seq_bytes, k_min, k_max)
end = time.time()
print("Build Time (Python Dict):", end - start)

start = time.time()
trie.build(seq, k_min, k_max)
end = time.time()
print("Build Time (Cython Trie):", end - start)

for k in range(fixed_k_min, fixed_k_max + 1):
    run_fixed_size_kmer_test(counts, trie, k)
run_random_sub_kmer_test(counts, trie, k_min, k_max, num_runs)

seq.delete()
seq = None
seq_bytes = None
counts = None
trie = None