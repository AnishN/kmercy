# kmercy
A k-mer analysis tool written in cython

The code can be built and run as follows:
```
python3 setup.py build_ext -i
python3 main.py
```

Example output:
```
Sequence: b'GTGTCGATACGATTAGGTCCCAAAACTACAATTGGAAGTAACCTACCGCT...'
Build Time (Python Dict): 4.629878282546997
Build Time (Cython Trie): 0.7583279609680176
Fixed Size Kmer Test (k = 3): Python Dict = 0.00012111663818359375, Cython Trie = 6.151199340820312e-05, Result = True
Fixed Size Kmer Test (k = 4): Python Dict = 0.0005424022674560547, Cython Trie = 0.00035119056701660156, Result = True
Fixed Size Kmer Test (k = 5): Python Dict = 0.0015718936920166016, Cython Trie = 0.0008847713470458984, Result = True
Fixed Size Kmer Test (k = 6): Python Dict = 0.007770061492919922, Cython Trie = 0.004984378814697266, Result = True
Fixed Size Kmer Test (k = 7): Python Dict = 0.040445566177368164, Cython Trie = 0.029092073440551758, Result = True
Fixed Size Kmer Test (k = 8): Python Dict = 0.13817310333251953, Cython Trie = 0.08140802383422852, Result = True
Random Sub Kmer Test (# Runs = 10000): Python Dict = 0.23161721229553223, Cython Trie = 0.1596088409423828, Result = True
```