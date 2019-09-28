import SwiftcType

public final class IntegerLiteralExpr : Expr {
    public unowned let source: SourceFile
    public let sourceRange: SourceRange
    public var type: Type?
    
    public init(source: SourceFile,
                sourceRange: SourceRange)
    {
        self.source = source
        self.sourceRange = sourceRange
    }
    
    public var descriptionPartsTail: [String] { Exprs.descriptionParts(self) }
    
    public func accept<V>(visitor: V) throws -> V.VisitResult where V : ASTVisitor {
        try visitor.visit(self)
    }
}
