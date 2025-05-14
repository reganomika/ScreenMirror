struct FAQModel {
    let title: String
    let subtitle: String
}

final class FAQViewModel {
    
    let models: [FAQModel] = [
        .init(
            title: "How do I connect the app to my TV?".localized,
            subtitle: "faq0".localized
        ),
        .init(
            title: "Devices are on the same network but can't connect".localized,
            subtitle: "faq1".localized
        ),
        .init(
            title: "I don’t have sound on the TV, what should i do?".localized,
            subtitle: "faq2".localized
        ),
        .init(
            title: "Screen mirroring doesn’t work?".localized,
            subtitle: "faq3".localized
        )
    ]
}
