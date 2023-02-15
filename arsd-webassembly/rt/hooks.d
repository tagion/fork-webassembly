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
    enum MAGIC = ushort.max - 1;
    package struct PSVMem
    {
        size_t size;
        ushort magicNumber = MAGIC;
        ubyte[0] data;
        pure nothrow @nogc @trusted void* getPtr () return {return (cast(void*)&this) + PSVMem.sizeof ;}
    }

    package bool isPSVMem(void* ptr) pure nothrow @nogc @trusted
    {
        if(cast(size_t)ptr <= PSVMem.sizeof) return false;
        PSVMem mem = *cast(PSVMem*)(ptr - PSVMem.sizeof);
        return mem.magicNumber == MAGIC;
    }
    package void* getPSVMem(void* ptr) pure nothrow @nogc @trusted
    {
        if(ptr is null || !isPSVMem(ptr)) return null;
        return ptr - PSVMem.sizeof;
    }




    pure nothrow @nogc @trusted
    {
        extern(C) void psv_abort();
        extern(C) void psv_free(ubyte* ptr);
        extern(C) int sceClibPrintf(const(char*) fmt, ...);
        extern(C) ubyte* psv_realloc(ubyte* ptr, size_t newSize);
        extern(C) ubyte* psv_realloc_slice(size_t length, ubyte* ptr, size_t newSize);
        extern(C) ubyte* psv_malloc(size_t sz);
        extern(C) ubyte* psv_calloc(size_t count, size_t newSize);

        void abort(){psv_abort();}
        // void free(ubyte* ptr) @nogc
        // {
        //     void* thePtr = getPSVMem(ptr);
        //     if(thePtr !is null) psv_free(cast(ubyte*)thePtr);
        // }

        // ubyte[] malloc(size_t sz, string file = __FILE__, size_t line = __LINE__) 
        // {
        //     PSVMem* mem  = cast(PSVMem*)psv_malloc(PSVMem.sizeof + sz);
        //     mem.magicNumber = MAGIC;
        //     mem.size = sz;
        //     ubyte[] ret = cast(ubyte[])mem.getPtr[0..sz];
        //     ret[] = 0;
        //     return ret;
        // }
        // ubyte[] realloc(ubyte* ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__)
        // {
        //     void* thePtr = getPSVMem(ptr);
        //     if(thePtr is null)
        //     {
        //         ubyte* ret = cast(ubyte*)malloc(newSize).ptr;
        //         if(getPSVMem(ret) is null) psv_abort();
        //         if(ptr !is null)
        //         {
        //             size_t sz = 0; while(ptr[sz] != '\0') sz++;
        //             //Find the initial size
        //             memcpy(ret, ptr, sz-1);
        //         }
        //         return ret[0..newSize];
        //     }
            
        //     size_t oldSize = (cast(PSVMem*)thePtr).size;
        //     thePtr = psv_realloc(cast(ubyte*)thePtr, newSize+PSVMem.sizeof);
        //     PSVMem* mem = cast(PSVMem*)thePtr;
        //     mem.size = newSize;
        //     mem.magicNumber = MAGIC;
        //     memcpy(mem.getPtr, ptr, oldSize);
        //     cast(void)sceClibPrintf("Copied %u bytes \n",oldSize );
        //     return cast(ubyte[])mem.getPtr[0..newSize];
        // }
        // ubyte[] realloc(ubyte[] ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__)
        // {
        //     if(ptr is null) return malloc(newSize);
        //     auto thePtr = getPSVMem(ptr.ptr);
        //     if(thePtr is null)
        //     {
        //         auto ret = malloc(newSize);
        //         ret[0..ptr.length] = ptr[];
        //         return ret;
        //     }
        //     return realloc(ptr.ptr, newSize);
        // }
        // ubyte[] calloc(size_t count, size_t size, string file = __FILE__, size_t line = __LINE__)
        // {
        //     return malloc(count*size);
        // }
        void free(ubyte* ptr) @nogc{psv_free(ptr);}
        ubyte[] malloc(size_t sz, string file = __FILE__, size_t line = __LINE__) {return psv_malloc(sz)[0..sz];}
        ubyte[] realloc(ubyte* ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__){return psv_realloc(ptr, newSize)[0..newSize];}
        ubyte[] realloc(ubyte[] ptr, size_t newSize, string file = __FILE__, size_t line = __LINE__){return psv_realloc_slice(ptr.length, ptr.ptr, newSize)[0..newSize];}

        ubyte[] calloc(size_t count, size_t size, string file = __FILE__, size_t line = __LINE__){return psv_calloc(count,size)[0..count*size];}

    }
}