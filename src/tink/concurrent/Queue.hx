package tink.concurrent;

@:forward(add, push)
abstract Queue<T>(Impl<T>) {
	public inline function new() 
		this = new Impl();
		
	public inline function pop():Null<T>
		return this.pop(false);
		
	@:requires(concurrent)
	public inline function await():Null<T>
		return this.pop(true);
}


#if concurrent
	private typedef Impl<T> =
		#if neko
			neko.vm.Deque<T>;
		#elseif cpp
			cpp.vm.Deque<T>;
		#elseif java
			java.vm.Deque<T>;		
		#else
			Thread;//Just to get consistent errors
		#end
#else
	@:forward(add, push)
	private abstract Impl<T>(List<T>) {
		public inline function new() this = new List();
		public inline function pop(block:Bool) return this.pop();
	}
#end