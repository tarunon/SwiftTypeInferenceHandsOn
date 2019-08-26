import SwiftcType

public final class VariableDecl : ValueDecl {
    public weak var parentContext: DeclContext?

    public var name: String
    public var initializer: ASTExprNode?
    public var typeAnnotation: Type?
    public var type: Type?
    public init(parentContext: DeclContext,
                name: String,
                initializer: ASTExprNode?,
                typeAnnotation: Type?)
    {
        self.name = name
        self.initializer = initializer
        self.typeAnnotation = typeAnnotation
    }
    
    public var interfaceType: Type? { type }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitVariableDecl(self)
    }

    public func resolveInSelf(name: String) -> [ValueDecl] {
        var decls: [ValueDecl] = []
        if self.name == name {
            decls.append(self)
        }
        return decls
    }
}
