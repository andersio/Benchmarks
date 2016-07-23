//
//  BenchmarksTests.swift
//  BenchmarksTests
//
//  Created by Anders on 23/7/2016.
//  Copyright © 2016 Anders. All rights reserved.
//

import XCTest
import Foundation

let iterationCount = 1000000

class BenchmarksTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}


	func testStaticDispatchLock_PthreadMutex() {
		self.measure {
			invoke(StaticMutexPthreadAtomic<Int>(), times: iterationCount)
		}
	}

	func testStaticDispatchLock_Mutex() {
		self.measure {
			invoke(StaticMutexAtomic<Int>(), times: iterationCount)
		}
	}

	func testStaticDispatchLock_Locking() {
		self.measure {
			invoke(StaticLockingAtomic<Int>(), times: iterationCount)
		}
	}

	func testStaticDispatchLock_PthreadLocking() {
		self.measure {
			invoke(StaticLockingPthreadAtomic<Int>(), times: iterationCount)
		}
	}

	func testDynamicDispatchLock_Locking() {
		self.measure {
			invoke(DynamicLockingAtomic<Int>(), times: iterationCount)
		}
	}

	func testDynamicDispatchLock_PthreadMutex() {
		self.measure {
			invoke(DynamicMutexPthreadAtomic<Int>(), times: iterationCount)
		}
	}

	func testDynamicDispatchLock_Mutex() {
		self.measure {
			invoke(DynamicMutexAtomic<Int>(), times: iterationCount)
		}
	}

	func testDynamicDispatchLock_PthreadLocking() {
		self.measure {
			invoke(DynamicLockingPthreadAtomic<Int>(), times: iterationCount)
		}
	}

	func testBaseline() {
		self.measure {
			invoke(BaselineAtomic<Int>(), times: iterationCount)
		}
	}
}

	func test<A: Mutex>(mutex: A) {
		mutex.lock()
		mutex.unlock()
	}

@_specialize(StaticMutexPthreadAtomic<Int>)
func invoke<A: Testable>(_ target: A, times: Int) {
	for _ in 0 ..< times {
		target.evaluate()
	}
}

protocol Mutex: class {
	func lock()
	func unlock()
}

extension Lock: Mutex {}

protocol Testable: class {
	func evaluate()
}

final class BaselineAtomic<Value>: Testable {
	var _mutex = pthread_mutex_t()

	init() {
		pthread_mutex_init(&_mutex, nil)
	}

	func evaluate() {
		pthread_mutex_lock(&_mutex)
		pthread_mutex_unlock(&_mutex)
	}

	deinit {
		pthread_mutex_destroy(&_mutex)
	}
}

final class PthreadMutex: Mutex, Locking {
	var _mutex = pthread_mutex_t()

	init() {
		pthread_mutex_init(&_mutex, nil)
	}

	func lock() {
		pthread_mutex_lock(&_mutex)
	}

	func unlock() {
		pthread_mutex_unlock(&_mutex)
	}

	deinit {
		pthread_mutex_destroy(&_mutex)
	}
}

final class DynamicLockingAtomic<Value>: Testable {
	let _lock: Locking

	init(lock: Locking = Lock()) {
		_lock = lock
	}

	func evaluate() {
		_lock.lock()
		_lock.unlock()
	}
}

final class DynamicMutexAtomic<Value>: Testable {
	let _mutex: Mutex

	init(mutex: Mutex = Lock()) {
		_mutex = mutex
	}

	func evaluate() {
		_mutex.lock()
		_mutex.unlock()
	}
}

final class DynamicMutexPthreadAtomic<Value>: Testable {
	let _mutex: Mutex

	init(mutex: Mutex = Lock()) {
		_mutex = mutex
	}

	func evaluate() {
		_mutex.lock()
		_mutex.unlock()
	}
}

final class DynamicLockingPthreadAtomic<Value>: Testable {
	let _mutex: Mutex

	init(mutex: Mutex = Lock()) {
		_mutex = mutex
	}

	func evaluate() {
		_mutex.lock()
		_mutex.unlock()
	}
}

final class StaticLockingAtomic<Value>: StaticLockingAtomicBase<Value, Lock>, Testable {
	init() {
		super.init(lock: Lock())
	}
}

final class StaticLockingPthreadAtomic<Value>: StaticLockingAtomicBase<Value, PthreadMutex>, Testable {
	init() {
		super.init(lock: PthreadMutex())
	}
}

final class StaticMutexAtomic<Value>: StaticMutexAtomicBase<Value, Lock>, Testable {
	init() {
		super.init(lock: Lock())
	}
}

final class StaticMutexPthreadAtomic<Value>: StaticMutexAtomicBase<Value, PthreadMutex>, Testable {
	init() {
		super.init(lock: PthreadMutex())
	}
}

class StaticLockingAtomicBase<Value, Lock: Locking> {
	let _lock: Lock

	init(lock: Lock) {
		_lock = lock
	}

	func evaluate() {
		_lock.lock()
		_lock.unlock()
	}
}

class StaticMutexAtomicBase<Value, Lock: Mutex> {
	let _lock: Lock

	init(lock: Lock) {
		_lock = lock
	}

	func evaluate() {
//	for _ in 0 ..< iterationCount {
		_lock.lock()
		_lock.unlock()
//	}
	}
}
