//
//  TypeErasure.swift
//  Benchmarks
//
//  Created by Anders on 23/7/2016.
//  Copyright © 2016 Anders. All rights reserved.
//

import XCTest

protocol ObjectProtocol {
	associatedtype Value

	var value: Value { get }
}

final class Object<Value>: ObjectProtocol {
	var value: Value

	init(_ value: Value) {
		self.value = value
	}
}

final class ClosureWrapper<Value>: ObjectProtocol {
	let _value: () -> Value

	var value: Value {
		return _value()
	}

	init<O: ObjectProtocol where O.Value == Value>(_ object: O) {
		_value = { object.value }
	}
}

final class TypeErasureWrapper<Value>: ObjectProtocol {
	let object: _TypeErasureBoxBase<Value>

	var value: Value {
		return object.value
	}

	init<O: ObjectProtocol where O.Value == Value>(_ object: O) {
		self.object = _TypeErasureBox(object)
	}
}

final class _TypeErasureBox<O: ObjectProtocol>: _TypeErasureBoxBase<O.Value> {
	let object: O
	override var value: O.Value { return object.value }

	init(_ object: O) { self.object = object }
}

class _TypeErasureBoxBase<Value> {
	var value: Value { fatalError() }
}

func invoke<O: ObjectProtocol>(_ object: O, times: Int) {
	for _ in 0 ..< times {
		_ = object.value
	}
}

func pass<O: ObjectProtocol>(_ object: O, times: Int) {
	for _ in 0 ..< times {
		pass { object }
	}
}

func pass<O: ObjectProtocol>(_ action: () -> O) {
	_ = action()
}

class TypeErasure: XCTestCase {
	let iterationCount = 1000000

	func testClosureWrapperCallingPerformance() {
		self.measure {
			let rawObject = Object(1)
			let closureWrapper = ClosureWrapper(rawObject)
			invoke(closureWrapper, times: self.iterationCount)
		}
	}

	func testTypeErasureCallingPerformance() {
		self.measure {
			let rawObject = Object(1)
			let typeErasedWrapper = TypeErasureWrapper(rawObject)
			invoke(typeErasedWrapper, times: self.iterationCount)
		}
	}

	func testClosureWrapperCopyingPerformance() {
		self.measure {
			let rawObject = Object(1)
			let closureWrapper = ClosureWrapper(rawObject)
			pass(closureWrapper, times: self.iterationCount)
		}
	}
	
	func testTypeErasureCopyingPerformance() {
		self.measure {
			let rawObject = Object(1)
			let typeErasedWrapper = TypeErasureWrapper(rawObject)
			pass(typeErasedWrapper, times: self.iterationCount)
		}
	}
}
