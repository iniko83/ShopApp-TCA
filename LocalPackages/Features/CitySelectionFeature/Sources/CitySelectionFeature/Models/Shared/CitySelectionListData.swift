//
//  CitySelectionListData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import Foundation
import Utility

struct CitySelectionListData: Equatable {
  var sections = [ListSection]()
  var selectionHistoryCities = [City]()

  var isSelectionHistoryVisible: Bool { !selectionHistoryCities.isEmpty }
}
