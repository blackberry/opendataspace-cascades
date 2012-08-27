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
 */
import bb.cascades 1.0

/*
 * 
 * Author: Ekkehard Gentz (ekke), Rosenheim, Germany
 *
*/
Page {
    property alias sheetBackground: backgroundImage.image
    signal done(bool ok)
    // the first Container to hold the Background
    Container {
            id: backgroundContainer
            layout: AbsoluteLayout {
            }
            ImageView {
                id: backgroundImage
                // image will be set from main.qml thru alias property sheetBackground
            }
            // the main container to do the Login
		    Container {
		        layout: StackLayout {
		        }
		        layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0
                    positionY: 0
                }
		        id: mainContainer
		        // would prefer to use background: Color.Transparent
		        // but doenst work to get the background from screen below
		        Container {
		            layout: StackLayout {
		                layoutDirection: LayoutDirection.TopToBottom
		            }
		            TextField {
    		            id: username
    		            hintText: qsTr("Username")
    		        }
    		        TextField {
    		            id: password
    		            hintText: qsTr("Password")
    		        }
		            Button {
		                text: qsTr ("LogIn")
		                preferredWidth: 50.0
		                onClicked: {
		                    // TODO call C++ function to test if Login was OK
		                    done(true)
		                }
		            }
		        }

		        
		    }
}
}
