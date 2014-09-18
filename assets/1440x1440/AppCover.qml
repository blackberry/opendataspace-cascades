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
                minHeight: 114
                maxHeight: 114
                minWidth: 440
                maxWidth: 440
                bottomMargin: 0
                bottomPadding: 0
                Label {
                    id: headerText
                    translationY: 4
                    translationX: 16
                    text: "OpenDataSpace"
                    textStyle.fontSizeValue: 30
                    textStyle.fontFamily: "Slate Pro"
                    textStyle.color: Color.White
                }
            }
            Container {
                minHeight: 440
                maxHeight: 440
                minWidth: 440
                maxWidth: 440
                topMargin: 0
                leftPadding: 0
                leftMargin: 0
                ImageView {
                    id: minimizedImage
                    imageSource: "asset:///images/minimized.png"
                    minHeight: 440
                    maxHeight: 440
                    minWidth: 440
                    maxWidth: 440
                    topMargin: 0
                    leftMargin: 0
                    //translationX: ods.isSquare()? -20 : 0
                }
            }

        }
    }
}