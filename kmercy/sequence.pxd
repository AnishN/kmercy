from libc.stdint cimport *

cpdef enum Base:
    BASE_A = 0
    BASE_C = 1
    BASE_G = 2
    BASE_T = 3


cdef class Sequence(object):
    cdef:
        uint8_t *bases
        size_t num_bases
    
    @staticmethod
    cdef Base char_to_base(char base_char) nogil
    @staticmethod
    cdef char base_to_char(Base base) nogil

    cpdef void create(self, size_t num_bases) except *
    cpdef void delete(self) except *
    cdef void randomize(self) except *
    cdef void from_bytes(self, bytes data) except *
    cdef void to_bytes(self, bytes data) except *
    cdef Base get_base(self, size_t index)
    cdef void set_base(self, size_t index, Base base)