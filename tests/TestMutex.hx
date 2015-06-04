package;
import haxe.unit.TestCase;
import tink.concurrent.Mutex;
import tink.concurrent.Queue;
import tink.concurrent.Thread;

class TestMutex extends TestCase {
	#if concurrent
	var m:Mutex;
	var q:Queue<String>;
	
	override public function setup():Void {
		super.setup();
		m = new Mutex();
		q = new Queue();
	}
	
	function testAcquire() {
		var t = new Thread(function () {
			m.acquire();
			Sys.sleep(.1);
			m.release();
		});
		Sys.sleep(.05);
		assertFalse(m.tryAcquire());
		Sys.sleep(.1);
		assertTrue(m.tryAcquire());		
	}
	
	function testSynchronized() {
		var threads = 100,
		    count = 10000,
				counter = 0;
		for (i in 0...threads)
			new Thread(function () {
				for (i in 0...count)
					m.synchronized(function () counter++);
				q.add('yo');
			});
		for (i in 0...threads)
			q.await();
			
		assertEquals(threads * count, counter);		
	}
	
	function testExceptions() {
		var t = new Thread(function () {
			try {
				assertEquals(5, m.synchronized(function () return 5));
				m.synchronized(function () return throw 'foo');
			}
			catch (e:String)
				q.add(e);
		});
		
		assertEquals(q.await(), 'foo');
		assertTrue(m.tryAcquire());		
	}		
	#end
}