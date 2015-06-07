package tink.concurrent;
import tink.core.Any;

@:forward(add, push)
abstract Queue<T>(Impl<T>) {
	public inline function new() 
		this = new Impl();
		
	public inline function pop():Null<T>
		return this.pop(false);
		
	@:requires(concurrent)
	public inline function await():T
		return this.pop(true);
}


#if concurrent
	#if neko
		private abstract Impl<T>(Any) {
			public inline function new() 
				this = deque_create();
				
			public inline function add(i:T)
				deque_add(this,i);
			
			public function push(i:T) 
				deque_push(this, i);
				
			public function pop(block:Bool):Null<T>
				return deque_pop(this,block);
			
			static var deque_create = neko.Lib.loadLazy("std","deque_create",0);
			static var deque_add = neko.Lib.loadLazy("std","deque_add",2);
			static var deque_push = neko.Lib.loadLazy("std","deque_push",2);
			static var deque_pop = neko.Lib.loadLazy("std","deque_pop",2);
		}
	#elseif cpp
		private abstract Impl<T>(Any) {
			public inline function new() 
				this = untyped __global__.__hxcpp_deque_create();
				
			public inline function add(i:T) 
				untyped __global__.__hxcpp_deque_add(this, i);
				
			public inline function push(i:T) 
				untyped __global__.__hxcpp_deque_push(this, i);
				
			public inline function pop(block:Bool):Null<T> 
				return untyped __global__.__hxcpp_deque_pop(this, block);
				
		}
	#elseif java
		private typedef Impl<T> = java.vm.Deque<T>;
	#else
		private class Impl<T> {
			var read:Mutex;
			var write:Mutex;
			var data:List<T>;
			
			public function new() {
				read = new Mutex();
				write = new Mutex();
				data = new List();
			}
			
			public function add(msg) 
				write.synchronized(function () data.add(msg));
				
			public function push(msg)
				write.synchronized(function () data.add(msg));
				
			public function pop(block:Bool):T {
				if (block) {
					read.acquire();
					while (data.length == 0) 
						Sys.sleep(.001);//Awkward			
				}
				else {
					if (!read.tryAcquire())
						return null;
				}
				
				var ret = write.synchronized(function () return data.pop());
				read.release();
				return ret;
			}
		}
	#end
#else
	@:forward(add, push)
	private abstract Impl<T>(List<T>) {
		public inline function new() this = new List();
		public inline function pop(block:Bool) return this.pop();
	}
#end