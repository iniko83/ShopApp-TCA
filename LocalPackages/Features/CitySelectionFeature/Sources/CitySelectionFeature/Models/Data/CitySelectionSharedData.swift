//
//  CitySelectionSharedData.swift
//  CitySelectionFeature
//
//  Created by Igor Nikolaev on 11.07.2025.
//

import UIKit

struct CitySelectionSharedData: Equatable {
  var selectedCityId: Int?

  var locationRelated = CitySelectionLocationRelatedData()
  var toast = CitySelectionToastData()

  var layout = LayoutData()
}

extension CitySelectionSharedData {
  struct LayoutData: Equatable {
    var searchFieldFrames = Frames()

    // history
    var isSelectionHistoryVisible = false
    var selectionHistoryHeight = CGFloat.zero

    func listTopPadding() -> CGFloat {
      let historyHeight = isSelectionHistoryVisible ? selectionHistoryHeight : 0
      let result = searchFieldFrames.content.height + historyHeight
      return result
    }
  }
}
