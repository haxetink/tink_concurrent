package tink.concurrent;
import haxe.ds.GenericStack;
import tink.core.Pair;

@:forward(value)
abstract Tls<T>(Impl<T>) from Impl<T> {
	public inline function new()
		this = new Impl();
}


#if (target.threaded && concurrent)
private typedef Impl<T> = sys.thread.Tls<T>;
#else
	@:forward(value)
	private abstract Impl<T>(tink.core.Ref<T>) {
		public inline function new() 
			this = tink.core.Ref.to(cast null);
	}
#end