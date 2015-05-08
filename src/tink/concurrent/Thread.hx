package tink.concurrent;

#if concurrent

	#if neko
	
		import neko.Lib.load;
		
		private enum ThreadHandle { }
		
		abstract Thread(ThreadHandle) {
			public inline function new(f:Void->Void) 
				this = thread_create(function(_) { return f(); }, null);
			
			static public var current(get, never):Thread;
			
				static inline function get_current():Thread
					return thread_current();
			
			static var thread_create = load("std", "thread_create", 2);
			static var thread_current = load("std", "thread_current", 0);
		}
		
	#elseif java
	
		import java.lang.Thread in Impl;
		
		class Wrapper implements java.lang.Runnable {
			var f:Void->Void;
			public function new(f) 
				this.f = f;
				
			public function run()
				f();
		}
		
		abstract Thread(Impl) from Impl {
			
			public inline function new(f) {
				this = new Impl(new Wrapper(f));
				this.setDaemon(true);
				this.start();
			}
			
			static public var current(get, never):Thread;
			
				static inline function get_current():Thread
					return Impl.currentThread();	
		}
		
	#elseif cpp
	
		abstract Thread(Dynamic) {
			
			public inline function new(f:Void->Void)
				this = untyped __global__.__hxcpp_thread_create(f);
			
			static public var current(get, never):Thread;
				static inline function get_current() 
					return new Thread(untyped __global__.__hxcpp_thread_current());
		}
		
	#else
	
		#error concurrency not supported on current platform
		
	#end
	
#else
	abstract Thread(String) {
		
		@:require(concurrent)
		public function new() 
			throw 'Not implemented';
			
		static public var current(default, null):Thread = cast 'Fake Main Thread';
	}
#end