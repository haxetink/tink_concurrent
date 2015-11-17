package;

import haxe.unit.TestCase;
import tink.concurrent.Thread;

import tink.concurrent.Queue;

class TestQueue extends TestCase {
	function testBasic() {
		var q = new Queue();
		assertEquals(null, q.pop());
		q.add(5);
		assertEquals(5, q.pop());
		assertEquals(null, q.pop());
    q.push(3);
    q.add(1);
    q.push(2);
		assertEquals(2, q.pop());
		assertEquals(3, q.pop());
		assertEquals(1, q.pop());
		#if concurrent
		q.add(5);
		assertEquals(5, q.await());
		assertEquals(null, q.pop());
		#end
	}
	#if concurrent
	function testConcurrent() {
		
		var counter = 0,
				output = new Queue(),
				input = new Queue();
				
		new Thread(function () {
			assertEquals(4, output.await());
			counter += 1;
			
			Sys.sleep(.20);
			
			input.add(12);
		});
		
		Sys.sleep(.05);
		
		assertEquals(0, counter);
		
		output.add(4);
		Sys.sleep(.05);
		
		assertEquals(1, counter);

		assertEquals(12, input.await());
	}
	#end
}