import bb.cascades 1.0

NavigationPane {
    id: cardNavPaneId
    objectName: cardNavPaneId
    property alias invokationMode : invocationModeLabelId.text
    property alias counter : pageId.counter
    Page {
        property int counter: 0
        id: pageId
        objectName: pageId
        Container {
            id: containerId
            layout: StackLayout {
            }
            Label {
                id: invocationModeLabelId
                text: "Invoked"
            }
            Label {
                id: labelId
                text: "--"
            }
            Button {
                text: "Press Me to count"
                onClicked: {
                    pageId.calculateLabeltext()
                }
            }
        }
        function calculateLabeltext(){
            pageId.counter++
            labelId.text = "Pressed " + pageId.counter + " times"
        }
        onCreationCompleted: {
            calculateLabeltext();
        }
    }
    onCreationCompleted: {
        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All;
    }
}
