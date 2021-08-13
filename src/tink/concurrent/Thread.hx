package tink.concurrent;

using tink.CoreApi;

abstract Thread(Impl) from Impl to Impl {
	@:require(target.threaded)
	@:require(concurrent)
	public inline function new(f:Void->Void)
		#if (target.threaded && concurrent)
			this = Impl.create(f);
		#else
			throw 'Not Implemented';
		#end
		
	static public var current(get, never):Thread;
	
		static inline function get_current():Thread
			return Impl.getCurrent();
		
	@:op(A==B)
	public static inline function eq(a:Thread, b:Thread):Bool
		return Impl.eq(a, b);
			
	static public var MAIN(default, null) = current;
}


#if (target.threaded && concurrent)
	private abstract Impl(sys.thread.Thread) from sys.thread.Thread to sys.thread.Thread {
		public static inline function create(f):Impl
			return sys.thread.Thread.create(f);
		public static inline function getCurrent():Impl
			return sys.thread.Thread.current();
		public static inline function eq(a:Impl, b:Impl):Bool
			return (a:sys.thread.Thread) == (b:sys.thread.Thread);
		
	}
	
#else
	private abstract Impl(String) {
		inline function new(s) this = s;
		static public inline function getCurrent():Impl 
			return new Impl('Fake Main Thread');
		
		public static inline function eq(a:Impl, b:Impl):Bool
			return a == b;
	}
#end