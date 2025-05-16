
enum HomeCellType {
    case connect
    case screenMirroring
    case collection(cellTypes: [HomeCollectionCellType])
}

enum HomeCollectionCellType: CaseIterable {
    case photo
    case video
    case safari
    case youtube
}

class HomeViewModel {
    
    var cells: [HomeCellType] = [
        .connect,
        .screenMirroring,
        .collection(cellTypes: HomeCollectionCellType.allCases)
    ]
}
