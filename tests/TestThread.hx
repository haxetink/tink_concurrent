package;
import haxe.unit.TestCase;
import tink.concurrent.Thread;

class TestThread extends TestCase {

	function testMain() {
		assertTrue(Thread.MAIN == Thread.current);
	}
	
	#if (target.threaded && concurrent)
	function testCurrent() {
		var threads:Array<Thread> = null;
		threads = [
			for (i in 0...100) {
				new Thread(function () {
					Sys.sleep(.1);
					for (j in 0...threads.length) {
						if (i == j) 
							assertTrue(threads[j] == Thread.current);
						else
							assertFalse(threads[j] == Thread.current);
					}
				});
			}
		];
		threads.push(Thread.current);
		assertTrue(Thread.MAIN == Thread.current);
		Sys.sleep(.2);
	}
	#end
}