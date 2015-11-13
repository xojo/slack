# Slack
A Xojo library for communicating with Slack using the Slack API.

Slack API: https://api.slack.com

## Usage ##
Copy the Slack module to your project.

In your app, drag Slack.Connector onto your layout.

Set your AuthToken by calling the SetAuthToken method on Slack.Connector using your bearer token. You can create a token here: https://api.slack.com/web


Once authorized, you can call methods on the Connector (see below) to communicate with Slack. The results of the calls are returned as event handlers on the Connector.

Note: Slack uses Xojo.Net.HTTPSocket, which is currently only compatible with Desktop and iOS apps.

## Classes ##
These are the classes in the Slack module (namespace).

### Channel ###
Contains information about the channel. This is returned by calling Connector.ChannelsList.
* ID
* Name

### Connector
A subclass of Xojo.Net.HTTPSocket that is used to communicate with Slack. This class has methods that call Slack API method. The methods return results to their related event handlers.

Events
* APIError
* AuthResponse: 
* ChannelsListResponse
* PostMessageResponse
* TeamInfoResponse
* UsersListResponse

Methods
* AuthTest: Returns to AuthResponse event.
* ChannelsList: Returns to ChannelListResponse event.
* PostMessage: Returns to PostMessageResponse event.
* SetAuthToken: Sets the Auth token.
* TeamInfo: Returns to TeamInfoResponse event.
* UsersList: Returns to UsersListResponse event.

### MessageResponse
Contains information about a posted message. This is returned by calling Connector.PostMessage.

### Team
Contains information about the Slack Team. This is returned by calling Connector.TeamInfo.

### User
Contains information about Slack users. This is returned by calling Connector.UsersList.