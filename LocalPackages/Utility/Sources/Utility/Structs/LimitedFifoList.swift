//
//  LimitedFifoList.swift
//  Utility
//
//  Created by Igor Nikolaev on 07.07.2025.
//

public struct LimitedFifoList<Item: Equatable> {
  private(set) public var items: [Item]
  public let limit: Int
  
  public init(
    items: [Item] = [], // without limit check
    limit: Int
  ) {
    self.items = items
    self.limit = limit
  }
  
  public mutating func insertItem(_ item: Item) {
    var next = items.filter { $0 != item }
    next = Array(next.prefix(limit - 1))
    next.insert(item, at: .zero)
    items = next
  }
  
  public mutating func removeItem(_ item: Item) {
    items.removeFirst(where: { $0 == item })
  }
  
  public mutating func removeAll() {
    items = []
  }
}
