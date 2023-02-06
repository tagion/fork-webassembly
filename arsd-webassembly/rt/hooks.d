module rt.hooks;

version(WebAssembly)
{
    public import core.arsd.memory_allocation;
    void abort() pure nothrow @nogc
    {
        static import arsd.webassembly;
        arsd.webassembly.abort();
    }

    /++
        Marks the memory block as OK to append in-place if possible.
    +/
    void assumeSafeAppend(T)(T[] arr) {
        auto block = getAllocatedBlock(arr.ptr);
        if(block is null) assert(0);

        block.used = arr.length;
    }

    /++
        Marks the memory block associated with this array as unique, meaning
        the runtime is allowed to free the old block immediately instead of
        keeping it around for other lingering slices.

        In real D, the GC would take care of this but here I have to hack it.

        arsd.webasm extension
    +/
    void assumeUniqueReference(T)(T[] arr) {
        auto block = getAllocatedBlock(arr.ptr);
        if(block is null) assert(0);

        block.flags |= AllocatedBlock.Flags.unique;
    }

}
else version(PSVita)
{
    pure nothrow @nogc @trusted
    {
        extern(C) void psv_abort();
        extern(C) void psv_free(ubyte* ptr);
        extern(C) ubyte* psv_realloc(ubyte* ptr, size_t newSize);
        extern(C) ubyte* psv_malloc(size_t sz);
        extern(C) ubyte* psv_calloc(size_t count, size_t newSize);

        void abort(){psv_abort();}
        void free(ubyte* ptr) @nogc{psv_free(ptr);}
        ubyte[] realloc(ubyte* ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__){return psv_realloc(ptr, newSize)[0..newSize];}
        ubyte[] realloc(ubyte[] ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__){return psv_realloc(ptr.ptr, newSize)[0..newSize];}
        ubyte[] malloc(size_t sz, string file = __FILE__, size_t line = __LINE__) {return psv_malloc(sz)[0..sz];}
        ubyte[] calloc(size_t count, size_t size, string file = __FILE__, size_t line = __LINE__){return psv_calloc(count, size)[0..count*size];}

    }
}