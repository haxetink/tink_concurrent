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
		var count = 50;
			
		for (i in 0...count) {
			
			new Thread(function () {
				var expected = i * count * 2;
				function next()
					l.value = expected = expected + 1;
				for (j in 0...count) {
					trace([i, j]);
					next();
					trace([i, j]);
					Sys.sleep(((i + j) % 10) / 10000);
					trace([i, j]);
					q.add({ expected: expected, actual: l.value });
					trace([i, j]);
				}
			});
		}
		//Sys.sleep(count / 100);//this should suffice, since it's twice as long as the slowest thread could be
		for (i in 0...count * count)
			switch q.await() {
				case null:
					assertTrue(false);
				case { expected: e, actual: a } :
					assertEquals(e, a);
			}
		
	}
	#end
}