package tink.concurrent;
import tink.core.Any;

@:forward(add, push)
abstract Queue<T>(Impl<T>) {
	public inline function new() 
		this = new Impl();
		
	public inline function pop():Null<T>
		return this.pop(false);
		
	@:requires(target.threaded)
	@:requires(concurrent)
	public inline function await():T
		return this.pop(true);
}



#if (target.threaded && concurrent)
	private typedef Impl<T> = sys.thread.Deque<T>;
#else
	@:forward(add, push)
	private abstract Impl<T>(List<T>) {
		public inline function new() this = new List();
		public inline function pop(block:Bool) return this.pop();
	}
#end