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


#if (concurrent && !macro)
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
    @:forward(add, push)
		private abstract Impl<T>(java.util.concurrent.LinkedBlockingDeque<T>) {
      public inline function new()
        this = new java.util.concurrent.LinkedBlockingDeque<T>();
        
      public inline function pop(block:Bool):Null<T>
        return
          if (block) this.take();
          else this.poll();
    }
	#elseif cs
    //TODO: this is in bad need of a proper implementation
		private typedef Impl<T> = Naive<T>;
  #else
		private typedef Impl<T> = Naive<T>;
	#end
  private class Naive<T> {
    var read:Mutex;
    var write:Mutex;
    var data:List<T>;
    
    public function new() {
      read = new Mutex();
      write = new Mutex();
      data = new List();
    }
    
    function wait(iteration:Int) {
      //Moreless taken from http://referencesource.microsoft.com/#mscorlib/system/threading/SpinWait.cs
      if (iteration > 10)
        for (i in 0...4 << iteration) { }
      else 
        Sys.sleep(.001);
    }
    
    public function add(msg) 
      write.synchronized(function () data.add(msg));
      
    public function push(msg)
      write.synchronized(function () data.push(msg));
      
    public function pop(block:Bool):T {
      if (block) {
        read.acquire();
        var iteration = 0;
        while (data.length == 0) 
          wait(iteration++);//Rather awkward		
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
#else
	@:forward(add, push)
	private abstract Impl<T>(List<T>) {
		public inline function new() this = new List();
		public inline function pop(block:Bool) return this.pop();
	}
#end