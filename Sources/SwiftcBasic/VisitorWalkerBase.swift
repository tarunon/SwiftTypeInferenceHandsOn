public enum WalkerPreAction {
    case `continue`
    case skipChildren
    case stop
}

public enum WalkerAction {
    case `continue`
    case stop
}

public protocol VisitorWalkerBase : VisitorProtocol
    where VisitResult == WalkerAction
{
    typealias PreAction = WalkerPreAction
    typealias Action = WalkerAction
    
    var preWalk: (VisitTarget) -> PreAction { get }
    var postWalk: (VisitTarget) -> Action { get }
    
    func process(_ target: VisitTarget) -> Action
}

extension VisitorWalkerBase {
    public func process(_ target: VisitTarget) -> Action {
        switch preWalk(target) {
        case .continue:
            break
        case .skipChildren:
            return .continue
        case .stop:
            return .stop
        }
        
        switch visit(target) {
        case .continue:
            break
        case .stop:
            return .stop
        }
        
        switch postWalk(target) {
        case .continue:
            return .continue
        case .stop:
            return .stop
        }
    }
}
