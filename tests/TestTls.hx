package;

import haxe.unit.TestCase;
import tink.concurrent.*;

class TestTls extends TestCase {

	function test() {
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
					q.add({ expected: expected, actual: l.value });
				}
			});
		}
		
		for (i in 0...count * count)
			switch q.pop() {
				case null:
					assertTrue(false);
				case { expected: e, actual: a } :
					assertEquals(e, a);
			}
		
	}
}