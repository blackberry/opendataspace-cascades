import bb.cascades 1.0

NavigationPane {
    id: navPaneId
    objectName: navPaneId
    property string mode: "??"
    Page {
        property int counter: 0
        id: pageId
        objectName: pageId
        Container {
            id: containerId
            layout: StackLayout {
            }
            Label {
                text: "Invoked as " + mode
            }
            Label {
                id: labelId
                text: "--"
            }
            Button {
                text: "Press Me"
                onClicked: {
                    counter ++
                    pageId.calculateLabeltext()
                }
            }
        }
        function calculateLabeltext(){
            labelId.text = "Pressed " + pageId.counter + " times"
        }
        onCreationCompleted: {
            calculateLabeltext();
        }
    }
}
