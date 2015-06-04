package;
import haxe.unit.TestCase;
import tink.concurrent.Thread;

class TestThread extends TestCase {

	function testMain() {
		assertEquals(Thread.MAIN, Thread.current);
	}
	
	#if concurrent
	function testCurrent() {
		for (i in 0...100) {
			var t = null;
			t = new Thread(function () {
				Sys.sleep(.1);
				assertEquals(t, Thread.current);
			});
		}
		Sys.sleep(.2);
	}
	#end
}