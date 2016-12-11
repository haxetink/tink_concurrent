package tink.concurrent;

using tink.CoreApi;

abstract Thread(Impl) from Impl {
	@:require(concurrent)
	public inline function new(f:Void->Void)
		#if concurrent
			this = Impl.create(f);
		#else
			throw 'Not Implemented';
		#end
		
	static public var current(get, never):Thread;
	
		static inline function get_current():Thread
			return Impl.getCurrent();
			
	static public var MAIN(default, null) = current;
}

#if (concurrent && !macro)

	#if neko
	
		private abstract Impl(Any) {
			
			inline function new(v) this = v;
			
			static public inline function create(f:Void->Void) 
				return thread_create(function(_) { return f(); }, null);
			
			static public inline function getCurrent():Impl
				return thread_current();
			
			static var thread_create  =  neko.Lib.load("std", "thread_create", 2);
			static var thread_current =  neko.Lib.load("std", "thread_current", 0);
		}
		
	#elseif java
	
		private class Wrapper implements java.lang.Runnable {
			var f:Void->Void;
			public function new(f) 
				this.f = f;
				
			public function run()
				f();
		}
		
		private abstract Impl(java.lang.Thread) {
			inline function new(t)
				this = t;
				
			static public inline function create(f):Impl {
				var ret = new java.lang.Thread(new Wrapper(f));
				ret.setDaemon(true);
				ret.start();				
				return new Impl(ret);
			}
			
			static public inline function getCurrent():Impl
				return new Impl(java.lang.Thread.currentThread());
		}
		
	#elseif cs
  
    private abstract Impl(cs.system.threading.Thread) from cs.system.threading.Thread {
        
			static public inline function create(f:Void->Void):Impl {
				var ret = new cs.system.threading.Thread(f);
        ret.IsBackground = true;
				ret.Start();				
				return ret;
			}     
      
			static public inline function getCurrent():Impl
				return cs.system.threading.Thread.CurrentThread;
      
    }
    
	#elseif cpp
	
		private abstract Impl(Any) {
			
			static public inline function create(f:Void->Void):Impl
				return untyped __global__.__hxcpp_thread_create(f);
			
			static public inline function getCurrent():Impl
				return untyped __global__.__hxcpp_thread_current();
		}
		
	#else
	
		#error concurrency not supported on current platform
		
	#end
	
#else
	private abstract Impl(String) {
		
    inline function new(s) this = s;
    
		static public inline function getCurrent():Impl 
      return new Impl('Fake Main Thread');
	}
#end