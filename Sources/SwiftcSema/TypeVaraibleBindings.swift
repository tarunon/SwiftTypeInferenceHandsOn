import SwiftcType

public struct TypeVariableBindings {
    /**
     自分が代表の場合free, fixed、代表転送を持つ場合はtransfer
     */
    @frozen public enum Binding {
        case free
        case fixed(Type)
        case transfer(TypeVariable)
    }
    
    public private(set) var map: [TypeVariable: Binding] = [:]
    
    public init() {}
    
    public func binding(for variable: TypeVariable) -> Binding {
        map[variable] ?? .free
    }
    public mutating func setBinding(for variable: TypeVariable, _ binding: Binding) {
        map[variable] = binding
    }
    
    public mutating func merge(type1: TypeVariable,
                               type2: TypeVariable)
    {
        precondition(type1.isRepresentative(bindings: self))
        precondition(type1.fixedType(bindings: self) == nil)
        precondition(type2.isRepresentative(bindings: self))
        precondition(type2.fixedType(bindings: self) == nil)
        
        if type1 == type2 {
            return
        }
        
        func update(variable: TypeVariable, binding: Binding) {
            map
                .filter {
                    switch $0.value {
                    case .transfer(variable):
                        return true
                    default:
                        return false
                    }
                }
                .forEach { (key, value) in
                    setBinding(for: key, binding)
            }
        }
        
        if type1 > type2 {
            if type1.isRepresentative(bindings: self) {
                setBinding(for: type1, .transfer(type2))
                update(variable: type1, binding: .transfer(type2))
            } else {
                merge(type1: type1.representative(bindings: self), type2: type2)
            }
        } else {
            if type2.isRepresentative(bindings: self) {
                setBinding(for: type2, .transfer(type1))
                update(variable: type2, binding: .transfer(type1))
            } else {
                merge(type1: type1, type2: type2.representative(bindings: self))
            }
        }
            
        // <Q03 hint="understand data structure" />
    }
    
    public mutating func assign(variable: TypeVariable,
                                type: Type)
    {
        precondition(variable.isRepresentative(bindings: self))
        precondition(variable.fixedType(bindings: self) == nil)
        precondition(!(type is TypeVariable))
        
        map[variable] = .fixed(type)
    }
}

extension TypeVariable {
    public func isRepresentative(bindings: TypeVariableBindings) -> Bool {
        representative(bindings: bindings) == self
    }
    
    public func representative(bindings: TypeVariableBindings) -> TypeVariable {
        switch bindings.binding(for: self) {
        case .free,
             .fixed:
            return self
        case .transfer(let rep):
            return rep
        }
    }
    
    public func fixedType(bindings: TypeVariableBindings) -> Type? {
        switch bindings.binding(for: self) {
        case .free:
            return nil
        case .fixed(let ft):
            return ft
        case .transfer(let rep):
            return rep.fixedType(bindings: bindings)
        }
    }
    
    public func fixedOrRepresentative(bindings: TypeVariableBindings) -> Type {
        switch bindings.binding(for: self) {
        case .free:
            return self
        case .fixed(let ft):
            return ft
        case .transfer(let rep):
            return rep.fixedOrRepresentative(bindings: bindings)
        }
    }
    
    public func equivalentTypeVariables(bindings: TypeVariableBindings) -> Set<TypeVariable> {
        var ret = Set<TypeVariable>()
        for (tv, b) in bindings.map {
            switch b {
            case .free,
                 .fixed:
                if tv == self { ret.insert(tv) }
            case .transfer(let rep):
                if rep == self { ret.insert(tv) }
            }
        }
        return ret
    }
    
    public func isFree(bindings: TypeVariableBindings) -> Bool {
        switch bindings.binding(for: self) {
        case .free: return true
        case .fixed,
             .transfer: return false
        }
    }
}

extension Type {
    public func simplify(bindings: TypeVariableBindings) -> Type {
        transform { (type) in
            if let tv = type as? TypeVariable {
                var type = tv.fixedOrRepresentative(bindings: bindings)
                if !(type is TypeVariable) {
                    type = type.simplify(bindings: bindings)
                }
                return type
            }
             
            return nil
        }
    }
}
