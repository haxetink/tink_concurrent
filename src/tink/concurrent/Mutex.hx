package tink.concurrent;

using tink.CoreApi;

@:forward
abstract Mutex(Impl) {
	public inline function new() 
		this = new Impl();
	
	public function synchronized<A>(f:Void->A) {
		#if concurrent
			this.acquire();
			return try {
				var ret = f();
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

#if concurrent
	#if neko
		private abstract Impl(Any) {
			public inline function new()
				this = mutex_create();
				
			public inline function acquire()
				mutex_acquire(this);
			
			public inline function tryAcquire():Bool
				return mutex_try(this);
				
			public inline function release()
				mutex_release(this);
				
			static var mutex_create = neko.Lib.loadLazy("std","mutex_create",0);
			static var mutex_release = neko.Lib.loadLazy("std","mutex_release",1);
			static var mutex_acquire = neko.Lib.loadLazy("std","mutex_acquire",1);
			static var mutex_try = neko.Lib.loadLazy("std","mutex_try",1);			
		}
	#elseif cpp
		private abstract Impl(Any) {
			
			public inline function new() 
				this = untyped __global__.__hxcpp_mutex_create();
				
			public inline function acquire() 
				untyped __global__.__hxcpp_mutex_acquire(this);
				
			public function tryAcquire():Bool
				return untyped __global__.__hxcpp_mutex_try(this);
				
			public function release()
				untyped __global__.__hxcpp_mutex_release(this);
				
		}

	#elseif java
		@:forward
		private abstract Impl(java.util.concurrent.Semaphore) {
			public inline function new()
				this = new java.util.concurrent.Semaphore(1);
		}
	#else
		typedef Impl<T> = Thread;//For consistent error messages
	#end
#else
	private abstract Impl(Bool) {
		public inline function new() this = false;
		public inline function tryAcquire():Bool return true;
		public inline function acquire():Void {}
		public inline function release():Void {}
	}
#end
