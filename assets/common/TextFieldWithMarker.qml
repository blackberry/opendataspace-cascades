/*
 * Copyright (c) 2012 SSP Europe GmbH, Munich
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */import bb.cascades 1.0
/*
 * special textField with a redMarker if empty
 * to be used in StackLayout
 *
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/

Container {
    property alias redBarVisible : redBar.visible
    property alias redBarImage : redBar.image
    property alias textFieldHintText : textField.hintText
    property alias textFieldText : textField.text
    property alias textFieldInputMode : textField.inputMode
    id: textWithMarkerContainer
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    // the Marker Image
    ImageView {
        id: redBar
        visible: false
        // image must be set where the Container was used
        minWidth: 16
        rightMargin: 0
        leftMargin: 0
        layoutProperties: StackLayoutProperties {  
        }
        verticalAlignment: VerticalAlignment.Fill
    }
    TextField {
        id: textField
        hintText: qsTr("please enter your text")+ Retranslate.onLanguageChanged
        inputMode: TextFieldInputMode.Text
        leftMargin: 0
        textStyle {
            base: SystemDefaults.TextStyles.BodyText
        }
        onTextChanging: {
            redBar.visible = textField.text == ""
        }
    }
    onCreationCompleted: {
        redBar.visible = textField.text == ""
    }
}
