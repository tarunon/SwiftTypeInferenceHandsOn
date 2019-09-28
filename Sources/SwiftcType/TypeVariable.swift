import SwiftcBasic

open class _TypeVariable :
    _EquatableType,
    Hashable,
    Comparable
{
    public init() {}
    
    open var id: Int { abstract() }
    
    public func print(options: TypePrintOptions) -> String {
        "$T\(id)"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
        hasher.combine(id)
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : TypeVisitor {
        try visitor.visit(self)
    }
    
    public static func ==(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id == b.id
    }
    
    public static func <(a: _TypeVariable, b: _TypeVariable) -> Bool {
        return a.id < b.id
    }
}
