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
	#if (target.threaded && concurrent)
	function testConcurrent() {
		var l = new Tls();
		l.value = -1;
		var q = new Queue();
		var count = 50;
			
		for (i in 0...count) {
			
			new Thread(function () {
				var expected = i * count * 2;
				function next()
					l.value = expected = expected + 1;
				for (j in 0...count) {
					next();
					Sys.sleep(((i + j) % 10) / 10000);
					q.add({ expected: expected, actual: l.value });
				}
			});
		}
		
		for (i in 0...count * count)
			switch q.await() {
				case { expected: e, actual: a } :
					assertEquals(e, a);
			}
		assertEquals(l.value, -1);
	}	
	#end
}