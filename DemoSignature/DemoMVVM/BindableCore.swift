//
//  BindableCore.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/10/16.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation
import UIKit

// simple bind use
class Observable<T> {
    typealias ValueChanged = ((T?) -> Void)
    
    public private(set) var value: T?
    private var valueChanged: ValueChanged?
    
    init(_ value: T? = nil) {
        self.value = value
    }
    
    /// bind valueChanged event
    @discardableResult
    func binding(valueChanged: ValueChanged?) -> Self {
        self.valueChanged = valueChanged
        return self
    }
    
    /// pass new value to trigger changed
    func onNext(_ value: T? = nil) {
        self.value = value
        valueChanged?(value)
    }
    
    // test for array values
    func onNextOfArray<Element>(_ value: Element) {
        if var newValues = self.value as? [Element] {
            newValues.append(value)
            self.value = newValues as? T
            valueChanged?(self.value)
            
        } else {
            fatalError("Pass incorrect value into array")
        }
    }
    
}

class Listener<T> {
    typealias ValueChanged = ((T?) -> Void)
    
    public private(set) var value: T?
    
    init(_ value: T?) {
        self.value = value
    }
    
    private var valueChanged: ValueChanged?
    
    /// bind valueChanged event
    func binding(valueChanged: @escaping ValueChanged) -> Self {
        self.valueChanged = valueChanged
        return self
    }
    
    /// pass new value to trigger changed
    func onNext(_ value: T?) {
        self.value = value
        valueChanged?(value)
    }
    
    // test for array values
    func onNextOfArray<Element>(_ value: Element) {
        if var newValues = self.value as? [Element] {
            newValues.append(value)
            self.value = newValues as? T
            valueChanged?(self.value)
            
        } else {
            fatalError("Pass uncorrect value into array")
        }
    }
}

// not simple
class Dynamic<T> {
    var value: T {
        didSet {
            //self.valueChanged?(value)
            for bondBox in bonds {
                bondBox.bond?.listener(value)
            }
            
        }
    }
    
    init(_ value: T) {
        self.value = value
    }

    var bonds: [Bondbox<T>] = []
    
    //
    //var valueChanged: ((T) -> Void)?
//    func bind(value: T) {
//        self.value = value
//    }
    
}

class Bondbox<T> {
    weak var bond: Bond<T>?
    init(_ bond: Bond<T>) {
        self.bond = bond
    }
}


class Bond<T> {
    typealias Listener = (T) -> Void
    
    var listener: Listener
    
    init(_ listener: @escaping Listener) {
        self.listener = listener
    }
    
    func bind(dynamic: Dynamic<T>) {
        dynamic.bonds.append(Bondbox(self))
    }
    
}


private var handle: UInt8 = 0
extension UILabel {
    
    var textBond: Bond<String> {
        if let b = objc_getAssociatedObject(self, &handle) as? Bond<String> {
            return b
            
        } else {
            let b = Bond<String> { [weak self] (value) in
                self?.text = value
            }
            objc_setAssociatedObject(self, &handle, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
        
    }
}

infix operator ->>

// right bind with left convience
func ->><T>(left: Dynamic<T>, right: Bond<T>) {
    right.bind(dynamic: left)
}
