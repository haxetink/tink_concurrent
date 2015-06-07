# Tink Concurrent Primitives

This library provides an abstraction layer over the target-specific concurrency APIs, namely:
	
- Thread
- Queue
- Tls
- Mutex

Being largely based on abstracts, it avaids allocation of wrapper objects, although in a multi-threaded environment that will probably hardly matter on a performance level. But if you compare java.vm.Thread and tink.concurrent.Thread, you will see that it also decreases complexity.

# Portability and `-D concurrent`

This library runs on all platforms out of the box, like so:
	
- Thread is implemented as dummy
- Queue is implemented as a List
- Tls is implemented as a tink.core.Ref
- Mutex is implemented with mere noops

There's exactly two things that will not compile without -D concurrent

- creation of new threads (with `new Thread`)
- blocking reads from a `Queue` (with `await`)

In those cases the library with actually tell you explicitly that `concurrent` is required (instead of the compiler complaining that a class or method is not found).

Support for `-D concurrent` exists on neko, java and cpp. On all other targets you will get compiler errors. 

## Handling the differences introduced with `-D concurrent`

For full portability, you will have to work around differences in the API that come from the `concurrent` flag. There are so many approaches, that this library cannot prescribe you how to go about it. This library is in fact not really intended for direct use, but rather with [tink_lang](http://haxetink.org/tink_lang) and/or [tink_runloop](http://haxetink.org/tink_runloop).
	
Ensuring code to run both with and without `-D concurrent` is a worthwhile endeavor.

## Merits of not using `-D concurrent` even when available

1. In some cases you execute code in an environment where you cannot create threads, because either the OS itself or other constraints don't allow it. In those cases all abstractions are replaced by cheap non-concurrent implementations, so there will be no performance penalty.
2. It is also useful for debugging purposes.

## API difference with `neko.vm.*` and the likes

This library omits reading and writing messages to threads directly. Surprisingly just using a `Queue` showed equal performance, and was thus chosen as the prefered way to pass messages, to increase type safety and keep the API lean.

The `Queue` API itself is slightly different from the corresponding `Deque` API. This concerns dissecting `pop` into two calls, because they are then more easily mapped to the type system and allow for more intelligible compiler errors.