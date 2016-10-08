package tink.concurrent;

using tink.CoreApi;

@:forward
abstract Mutex(Impl) {
	public inline function new() 
		this = new Impl();
	
	public function synchronized<A>(f:Void->A):A {
		#if concurrent
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
		private class Impl extends java.util.concurrent.locks.ReentrantLock {
      
      inline public function tryAcquire():Bool
        return this.tryLock();
			
      inline public function acquire()
        this.lock();
        
      inline public function release()
        if (this.getHoldCount() > 0)
          this.unlock();
			
		}
	#elseif cs
    private typedef Monitor = cs.system.threading.Monitor;
    private class Impl {
      var count = 0;
      var thread:Thread;
      
      public function new() {}
      inline public function tryAcquire():Bool
        return 
          if (Monitor.TryEnter(this)) {
            thread = Thread.current;
            count++;
            true;
          }
          else false;
			
      inline public function acquire() {
        Monitor.Enter(this);
        thread = Thread.current;
        count++;
      }
        
      inline public function release()
        if (count > 0 && thread == Thread.current) {
          count--;
          Monitor.Exit(this);
        }
    }
  #elseif python
		private abstract Impl(python.lib.threading.RLock) {
			public inline function new() this = new python.lib.threading.RLock();
			public inline function acquire() this.acquire();
			public inline function tryAcquire():Bool return this.acquire(false);
			public inline function release() try this.release() catch(e:Dynamic) {}
		} 
	#else
		private typedef Impl = Thread;//For consistent error messages
	#end
#else
	private abstract Impl(Bool) {
		public inline function new() this = false;
		public inline function tryAcquire():Bool return true;
		public inline function acquire():Void {}
		public inline function release():Void {}
	}
#end
