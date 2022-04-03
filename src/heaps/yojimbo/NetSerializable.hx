package heaps.yojimbo;

class NetSerializable implements hxbit.NetworkSerializable 
{
    public function startReplication(h : Host) {
        __host = h;
        h.register(this);   // __host is also set in here?
    }
    public function stopReplication() {
        if (__host != null) {
            __host.unregister(this);
            __host = null;
        }
    }
}