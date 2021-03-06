import Foundation

/* expected edges:
FooClass ->
 String
 Array
 Int
 CustomStringConvertible
 
BarStruct ->
 FooClass
 String
*/
open class FooClass {
    var a_variable: String
    let a_constant: [Int]

    init(variable: String) {
        self.a_variable = variable

        let const = Array<Int>()
        a_constant = const
        _ = thing()
    }

    public func thing() -> String {
        return a_variable
    }
}

extension FooClass: CustomStringConvertible {
    public var description: String {
        return a_variable
    }
}

struct BarStruct {
    let fooClass = FooClass(variable: "Hello")

    func blah() -> String {
        return fooClass.thing()
    }
}
