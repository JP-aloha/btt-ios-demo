import SwiftUI

struct TutorialPageView: View {
    let model: TutorialPageModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                VStack(spacing: 5) {
                    Image(systemName: model.iconName ?? "info.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentColor)

                    Text(model.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }

            Text(attributedDescription)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }

    private var attributedDescription: AttributedString {
        var attributed = AttributedString(model.desc)
        let keywords = ["Note:", "Scenario 1:", "Scenario 2:", ". "]

        for keyword in keywords {
            var searchStart = attributed.startIndex

            while let foundRange = attributed[searchStart...].range(of: keyword, options: .caseInsensitive) {
                attributed[foundRange].font = .body.bold()
                attributed[foundRange].foregroundColor = .primary
                searchStart = foundRange.upperBound
            }
        }

        return attributed
    }
}
