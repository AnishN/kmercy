import time
from libc.stdlib cimport *
srand(time.time())

cdef class Sequence(object):

    def __cinit__(self):
        self.bases = NULL
        self.num_bases = 0

    def __dealloc__(self):
        self.bases = NULL
        self.num_bases = 0

    @staticmethod
    cdef Base char_to_base(char base_char) nogil:
        if base_char == b"A":
            return BASE_A
        elif base_char == b"C":
            return BASE_C
        elif base_char == b"G":
            return BASE_G
        else:
            return BASE_T

    @staticmethod
    cdef char base_to_char(Base base) nogil:
        if base == BASE_A:
            return b"A"
        elif base == BASE_C:
            return b"C"
        elif base == BASE_G:
            return b"G"
        else:
            return b"T"

    cpdef void create(self, size_t num_bases) except *:
        cdef:
            size_t num_bytes

        self.num_bases = num_bases
        num_bytes = (num_bases + 3) / 4
        self.bases = <uint8_t *>calloc(num_bytes, sizeof(uint8_t))
    
    cpdef void delete(self) except *:
        free(self.bases)
        self.bases = NULL
        self.num_bases = 0
    
    cdef void randomize(self) except *:
        cdef:
            size_t i
            Base rand_base
        
        for i in range(self.num_bases):
            rand_base = <Base>(rand() % 4)
            self.set_base(i, rand_base)

    cdef void from_bytes(self, bytes data) except *:
        cdef:
            uint8_t *data_ptr = <uint8_t *>data
            size_t data_len = <size_t>len(data)
            size_t i
            Base base

        if self.num_bases != data_len:
            raise ValueError("Sequence: bytes length does not match num_bases")

        for i in range(self.num_bases):
            base = Sequence.char_to_base(data_ptr[i])
            self.set_base(i, base)

    cdef void to_bytes(self, bytes data) except *:
        cdef:
            uint8_t *data_ptr = <uint8_t *>data
            size_t data_len = <size_t>len(data)
            size_t i
            Base base
        
        if self.num_bases != data_len:
            raise ValueError("Sequence: bytes length does not match num_bases")

        for i in range(self.num_bases):
            base = self.get_base(i)
            data_ptr[i] = Sequence.base_to_char(base)

    cdef Base get_base(self, size_t index):
        cdef:
            size_t byte_index
            uint8_t bit_index
            uint8_t mask
            uint8_t[4] masks = [
                0b11000000, 
                0b00110000, 
                0b00001100, 
                0b00000011,
            ]
            uint8_t value
            Base base
        
        byte_index = index / 4
        bit_index = index % 4
        mask = masks[bit_index]
        value = self.bases[byte_index] & mask
        base = <Base>(value >> 2 * (4 - bit_index - 1))
        return base

    cdef void set_base(self, size_t index, Base base):
        cdef:
            size_t byte_index
            uint8_t bit_index
            uint8_t mask
            uint8_t[4][4] masks = [
                [0b00000000, 0b01000000, 0b10000000, 0b11000000],
                [0b00000000, 0b00010000, 0b00100000, 0b00110000],
                [0b00000000, 0b00000100, 0b00001000, 0b00001100],
                [0b00000000, 0b00000001, 0b00000010, 0b00000011],
            ]
        
        byte_index = index / 4
        bit_index = index % 4
        mask = masks[bit_index][<uint8_t>base]
        self.bases[byte_index] |= mask