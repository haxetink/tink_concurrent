package;

import haxe.unit.TestCase;
import tink.concurrent.*;

class TestTls extends TestCase {
	function testSimple() {
		var t = new Tls();
		for (i in 0...100) {
			t.value = i;
			assertEquals(i, t.value);
		}
	}
	#if concurrent
	function testConcurrent() {
		var l = new Tls();
		var q = new Queue();
		var count = 100;
		for (i in 0...count) {
			new Thread(function () {
				var expected = 0;
				function next()
					l.value = expected = Std.random(100);
				for (j in 0...count) {
					next();
					Sys.sleep(Math.random() / 1000);
					//q.add({ expected: expected, actual: l.value });
				}
			});
		}
		Sys.sleep(count / 500);//this should suffice, since it's twice as long as the slowest thread could be
		//for (i in 0...count * count)
			//switch q.pop() {
				//case null:
					//assertTrue(false);
				//case { expected: e, actual: a } :
					//assertEquals(e, a);
			//}
		
	}
	#end
}