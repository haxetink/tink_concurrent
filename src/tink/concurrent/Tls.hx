package tink.concurrent;

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
	#elseif cpp
		#if workaround_1234
		private class Impl<T> {
			var storage:haxe.ds.WeakMap<Dynamic, T>;
			//var storage:Map<Int, T>;
			var lock:Mutex;
			public var value(get, set):T;
				function get_value()
					return lock.synchronized(function () return storage.get(Thread.current));
					//return lock.synchronized(function () return storage[id()]);
					
				function set_value(param)
					return lock.synchronized(function () { 
						storage.set(Thread.current, param);
						return param;
					});
					//return lock.synchronized(function () return storage[id()] = param);
					
			//static inline function id():Int 
				//return untyped __global__.__hxcpp_obj_id(Thread.current);
			public function new() {
				lock = new Mutex();
				storage = new haxe.ds.WeakMap();
				//storage = new Map();
			}
		}
		#else
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
		#end
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
		import tink.concurrent.Thread;//For consistent error messages
	#end

#else
	@:forward(value)
	private abstract Impl<T>(tink.core.Ref<T>) {
		public inline function new() 
			this = tink.core.Ref.to(cast null);
	}
#end