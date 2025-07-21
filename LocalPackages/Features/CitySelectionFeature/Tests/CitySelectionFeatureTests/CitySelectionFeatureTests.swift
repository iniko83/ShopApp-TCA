import Testing
import Utility

@testable import CitySelectionFeature

@Suite("City search tests") struct CitySearchTests {
  @Test func citySearch() async throws {
    let api = CitySelectionApi.online
    let citiesResponse = await api.loadCities()
    
    let cities: [City]
    switch citiesResponse {
    case let .success(value):
      cities = value
    case .failure:
      cities = []
    }

    #expect(cities.count > 0)

    let engine = CitySearchEngine(cities: cities)
    
    let testVariants: [CitySearchTestVariant] = [
      .init(searchQuery: "москва", cityIds: [6]),
      .init(searchQuery: "краснознаменск", cityIds: [585, 586]),
      .init(
        searchQuery: "красно",
        cityIds: [4, 5, 580, 581, 582, 90, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594]
      ),
      .init(
        searchQuery: "кр",
        cityIds: [4, 5, 579, 580, 581, 582, 90, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601]
      ),
      .init(searchQuery: "ололо", cityIds: [])
    ]
    
    for variant in testVariants {
      let searchResult = await engine.search(unemptyQuery: variant.searchQuery)
      let cityIds = searchResult.listSections
        .map { $0.cities.map(\.id) }
        .flatMap { $0 }
      #expect(cityIds == variant.cityIds)
    }
  }
  
  fileprivate struct CitySearchTestVariant {
    let searchQuery: String // lowercased with spaces
    let cityIds: [Int]      // expected
  }
}
