import SwiftcType

public final class DeclRefExpr : ASTExprNode {
    public var name: String
    public var target: ValueDecl!
    public var type: Type?
    
    public init(name: String,
                target: ValueDecl,
                source: SourceFile)
    {
        self.name = name
        self.target = target
        source.ownedNodes.append(self)
    }
    
    public func dispose() {
        target = nil
    }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visitDeclRefExpr(self)
    }
}
