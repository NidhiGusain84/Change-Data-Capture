import { LightningElement, api } from 'lwc';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class DisplayRefreshMessage extends LightningElement {

    @api  channelName = '/data/AccountChangeEvent';
    @api recordId;
    isDisplayMessage = false;
    subscription = {};

    connectedCallback() {
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback =  (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.handleChangeEventResponse(response);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
        });
    }
    

     registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    disconnectedCallback(){
        this.handleUnsubscribe();
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    handleChangeEventResponse(response){
        console.log(response);
        if (response.hasOwnProperty("data")) {
            let jsonObject = response.data;
            if (jsonObject.hasOwnProperty("payload")) {
                let payload = response.data.payload;
               const isRecordFound = payload.ChangeEventHeader.recordIds.find(currentItem => currentItem === this.recordId);
               if (isRecordFound != undefined) {
                this.isDisplayMessage = true;
               }
            }
        }
    }

   async refreshPage(){
         await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
         this.isDisplayMessage = false;
    }


}