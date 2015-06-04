package tink.concurrent;
import tink.core.Error;

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
	private typedef Impl =
		#if neko
			neko.vm.Mutex;
		#elseif cpp
			cpp.vm.Mutex;
		#elseif java
			java.vm.Mutex;		
		#else
			Thread;//Just to get consistent errors
		#end
#else
	private abstract Impl(Bool) {
		public inline function new() this = false;
		public inline function tryAcquire():Bool return true;
		public inline function acquire():Void {}
		public inline function release():Void {}
	}
#end
