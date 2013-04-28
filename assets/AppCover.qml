import bb.cascades 1.0

SceneCover {

    // property alias displayText: headerText.text
    // property alias displaySource: minimizedImage.imageSource

    content: Container {
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            Container {
                background: Color.create("#ff0099cc")
                opacity: 0.8
                minHeight: 62
                maxHeight: 62
                minWidth: 334
                maxWidth: 334
                bottomMargin: 0
                bottomPadding: 0
                Label {
                    id: headerText
                    translationY: 4
                    translationX: 16
                    text: "OpenDataSpace"
                    textStyle.fontSizeValue: 25
                    textStyle.fontFamily: "Slate Pro"
                    textStyle.color: Color.White
                }
            }
            Container {
                minHeight: 334
                maxHeight: 334
                minWidth: 334
                maxWidth: 334
                topMargin: 0
                ImageView {
                    id: minimizedImage
                    imageSource: "asset:///images/minimized.png"
                    minHeight: 334
                    maxHeight: 334
                    minWidth: 334
                    maxWidth: 334
                    topMargin: 0
                }
            }

        }
    }
}