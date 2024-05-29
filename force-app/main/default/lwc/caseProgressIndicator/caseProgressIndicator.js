import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, api, wire } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_ID_FIELD from '@salesforce/schema/Case.Id';
import { getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import {
    subscribe,
    unsubscribe,
    onError
} from 'lightning/empApi';

export default class CaseProgressIndicator extends LightningElement {
    channelName = '/event/Case_Detail__e';
    statusOptions;
    caseStatusValue;
    subscription = {};
    @api recordId;
    //Get the picklist values for case status
    @wire(getObjectInfo, {
        objectApiName: CASE_OBJECT
    }) objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: CASE_STATUS_FIELD
    }) wiredPicklistFunction({ data, error }) {
        if (data) {
            console.log('Data', data);
            this.statusOptions = data.values;
        } else if (error) {
            console.log("Error while fetching picklist values", error);
        }
    };

    // Get the current value of case status

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [CASE_STATUS_FIELD]
    })
    getRecordOutput({ data, error }) {
        if (data) {
            console.log('data', data);
            this.caseStatusValue = getFieldValue(data, CASE_STATUS_FIELD);
            console.log('caseStatusValue', this.caseStatusValue);
        } else if (error) {
            console.log('Error while feching the data', error);
        }
    };

    // Initializes the component
    connectedCallback() {
        this.handleSubscribe();
        // Register error listener
        this.registerErrorListener();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            this.handleEventResponse(response);
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

    async handleEventResponse(response) {
        console.log('Response from the Postman', JSON.parse(JSON.stringify(response)));
        if (response.hasOwnProperty("data")) {
            let jsonObj = response.data;
            if (jsonObj.hasOwnProperty("payload")) {
                let responseCaseId = response.data.payload.Case_Id__c;
                let responseCaseStatus = response.data.payload.Case_Status__c;

                let fields = {};
                fields[CASE_ID_FIELD.fieldApiName] = responseCaseId;
                fields[CASE_STATUS_FIELD.fieldApiName] = responseCaseStatus;
                let recordInput = { fields };
                await (updateRecord(recordInput));
                 await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'success',
                    message:
                        `Case status is set to ${responseCaseStatus}.`,
                });
                this.dispatchEvent(event);
            }
        }

    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
    disconnectedCallback() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
}

