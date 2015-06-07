package tink.concurrent;
import haxe.ds.GenericStack;
import tink.core.Pair;

@:forward(value)
abstract Tls<T>(Impl<T>) from Impl<T> {
	public inline function new()
		this = new Impl();		
}

#if concurrent

	#if neko
		private abstract Impl<T>(Dynamic) {
			
			public var value(get, set) : T;
			
				inline function get_value() : T 
					return tls_get(this);
					
				inline function set_value( v : T ) {
					tls_set(this,v);
					return v;
				}
			
			public inline function new() 
				this = tls_create();
				
			static var tls_create = neko.Lib.load("std","tls_create",0);
			static var tls_get = neko.Lib.load("std","tls_get",1);
			static var tls_set = neko.Lib.load("std","tls_set",2);

		}	
	#elseif (cpp && !workaround_1234)
		private abstract Impl<T>(Int) {
			static var sFreeSlot = 0;
			static var lock = new Mutex();
			
			public var value(get, set):T;
				inline function get_value():T 
					return untyped __global__.__hxcpp_tls_get(this);
				
				inline function set_value(v:T) {
					untyped __global__.__hxcpp_tls_set(this, v);
					return v;
				}			
			
			public inline function new() 
				this = lock.synchronized(function () return sFreeSlot++);
			
		}
	#elseif java
		private abstract Impl<T>(java.lang.ThreadLocal<T>) {
			public var value(get,set):T;
				
				inline function get_value():T
					return this.get();
					
				inline private function set_value(v:T):T {
					this.set(v);
					return v;
				}
				
			public inline function new() 
				this = new java.lang.ThreadLocal();
				
		}
	#else
		private class Impl<T> {
			var storage:GenericStack<MPair<Thread, T>>;
			var lock:Mutex;
			public var value(get, set):T;
				function get_value() {
					var cur = Thread.current;
					for (p in storage)
						if (p.a == cur)
							return p.b;
					return null;
				}
					
				function set_value(param:T) {
					trace(param);
					var cur = Thread.current;
					for (p in storage) {
						if (p.a == cur) {
							p.b = param;
							return param;
						}
					}
					return lock.synchronized(function () {
						var p = new MPair(cur, param);
						storage.add(p);
						return p.b;
					});
				}
					
			public function new() {
				lock = new Mutex();
				storage = new GenericStack<MPair<Thread, T>>();
			}
		}	
	#end	
#else
	@:forward(value)
	private abstract Impl<T>(tink.core.Ref<T>) {
		public inline function new() 
			this = tink.core.Ref.to(cast null);
	}
#end