package tink.concurrent;

using tink.CoreApi;

@:forward
abstract Mutex(Impl) {
	public inline function new() 
		this = new Impl();
	
	#if (!target.threaded || !concurrent) inline #end
	public function synchronized<A>(f:Void->A):A {
		#if (target.threaded && concurrent)
			this.acquire();
			return try {
				var ret:A = f();
				this.release();
				return ret;
			}
			catch (e:Dynamic) {
				this.release();
				Error.rethrow(e);
			}
		#else
			return f();
		#end
	}
}

#if (target.threaded && concurrent)
@:forward
private abstract Impl(sys.thread.Mutex) {
	public inline function new() 
		this = new sys.thread.Mutex();
	#if (java || cs || python) // on these platforms releasing a non-owned lock will throw
	public function release()
		try this.release() catch(_) {}
	#end
}
#else
	private abstract Impl(Bool) {
		public inline function new() this = false;
		public inline function tryAcquire():Bool return true;
		public inline function acquire():Void {}
		public inline function release():Void {}
	}
#end
