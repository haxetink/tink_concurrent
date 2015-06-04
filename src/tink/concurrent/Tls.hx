package tink.concurrent;

#if concurrent

	#if neko
		abstract Tls<T>(Dynamic) {
			
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
	#end

#else
	@:forward(value)
	abstract Tls<T>(Ref<T>) {
		public inline function new() 
			this = new Ref();
	}
#end