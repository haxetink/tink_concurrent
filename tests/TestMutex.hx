package;
import haxe.unit.TestCase;
import tink.concurrent.Mutex;
import tink.concurrent.Queue;
import tink.concurrent.Thread;

class TestMutex extends TestCase {
	var m:Mutex;
	var q:Queue<String>;
	
	override public function setup():Void {
		super.setup();
		m = new Mutex();
		q = new Queue();
	}
	
	function testSimple() {
		//these are basically noops without -D concurrent
		assertTrue(m.tryAcquire());
		assertTrue(m.tryAcquire());
		m.release();
		m.release();
		
		m.acquire();
		m.acquire();
		m.release();
		m.release();
		m.release();
		assertTrue(true);
	}
	
	#if concurrent
	
	function testAcquire() {
		var t = new Thread(function () {
			m.acquire();
			m.acquire();
			m.release();
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
		    count = #if (cpp || python) 1000 #else 10000 #end,//cpps/python mutexes are abysmally slow
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