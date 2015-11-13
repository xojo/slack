#tag Class
Protected Class Connector
Inherits Xojo.Net.HTTPSocket
	#tag Event
		Function AuthenticationRequired(Realm as Text, ByRef Name as Text, ByRef Password as Text) As Boolean
		  //
		End Function
	#tag EndEvent

	#tag Event
		Sub Error(err as RuntimeException)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Sub FileReceived(URL as Text, HTTPStatus as Integer, File as xojo.IO.FolderItem)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Sub HeadersReceived(URL as Text, HTTPStatus as Integer)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Sub PageReceived(URL as Text, HTTPStatus as Integer, Content as xojo.Core.MemoryBlock)
		  If HTTPStatus <> 200 Then
		    APIError(HTTPStatus, Content)
		    Return
		  End If
		  
		  Dim responseText As Text
		  responseText = Xojo.Core.TextEncoding.UTF8.ConvertDataToText(content)
		  
		  Dim jsonDict As Xojo.Core.Dictionary
		  jsonDict = Xojo.Data.ParseJSON(responseText)
		  
		  Dim method As Text = GetAPIMethod(url)
		  Select Case method
		  Case "auth.test"
		    AuthResponse(jsonDict)
		    
		  Case "channels.list"
		    If jsonDict.Value("ok") Then
		      ProcessChannelsList(jsonDict)
		    Else
		      APIError(-1, Content)
		    End If
		    
		  Case "chat.postMessage"
		    If jsonDict.Value("ok") Then
		      ProcessChatPostMessage(jsonDict)
		    Else
		      APIError(-1, Content)
		    End If
		    
		  Case "team.info"
		    If jsonDict.Value("ok") Then
		      ProcessTeamInfo(jsonDict)
		    Else
		      APIError(-1, Content)
		    End If
		  Case "users.list"
		    If jsonDict.Value("ok") Then
		      ProcessUsersList(jsonDict)
		    Else
		      APIError(-1, Content)
		    End If
		  Case "search.messages"
		    
		  End Select
		  
		  // https://api.slack.com/rtm
		  // rtm, real-time messaging is used to create a client.
		End Sub
	#tag EndEvent

	#tag Event
		Sub ReceiveProgress(BytesReceived as Int64, TotalBytes as Int64, NewData as xojo.Core.MemoryBlock)
		  //
		End Sub
	#tag EndEvent

	#tag Event
		Sub SendProgress(BytesSent as Int64, BytesLeft as Int64)
		  //
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AuthTest()
		  // Docs: https://api.slack.com/methods/auth.test
		  
		  Dim token As Text = "token=" + AuthToken
		  
		  // Convert to MemoryBlock
		  Dim data As Xojo.Core.MemoryBlock
		  data = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(token)
		  
		  SetRequestContent(data, "application/x-www-form-urlencoded")
		  Send("POST", "https://slack.com/api/auth.test")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChannelsList()
		  // Docs: https://api.slack.com/methods/channels.list
		  
		  Dim token As Text = "token=" + AuthToken
		  
		  // Convert to MemoryBlock
		  Dim data As Xojo.Core.MemoryBlock
		  data = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(token)
		  
		  SetRequestContent(data, "application/x-www-form-urlencoded")
		  Send("POST", "https://slack.com/api/channels.list")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetAPIMethod(url As Text) As Text
		  Dim paramStart As Integer = url.IndexOf("?")
		  If paramStart >= 0 Then
		    url = url.Left(paramStart)
		  End If
		  
		  Dim methodStart As Integer = url.IndexOf("/api/")
		  url = url.Right(url.Length - methodStart - 5)
		  
		  Return url
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PostMessage(channel As Text, message As Text, asUser As Boolean = False)
		  // https://api.slack.com/methods/chat.postMessage
		  
		  Dim user As Text = "False"
		  If asUser Then user = "True"
		  
		  Dim parameters As Text = "token=" + AuthToken + _
		  "&channel=" + EncodeURLComponent(channel).ToText + _
		  "&text=" + EncodeURLComponent(message).ToText + _
		  "&as_user=" + user
		  
		  // Convert to MemoryBlock
		  Dim data As Xojo.Core.MemoryBlock
		  data = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(parameters)
		  
		  SetRequestContent(data, "application/x-www-form-urlencoded")
		  Send("POST", "https://slack.com/api/chat.postMessage")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessChannelsList(jsonDict As Xojo.Core.Dictionary)
		  // Collect all the channel information from the API
		  // and put into an array of Channel classes.
		  
		  Dim channelsDict() As Auto = jsonDict.Value("channels")
		  
		  Dim channels() As Channel
		  Dim ch As Channel
		  For Each channelDict As Xojo.Core.Dictionary In channelsDict
		    ch = New Channel
		    ch.ID = channelDict.Value("id")
		    ch.Name = channelDict.Value("name")
		    channels.Append(ch)
		  Next
		  
		  ChannelListResponse(channels)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessChatPostMessage(jsonDict As Xojo.Core.Dictionary)
		  Dim mr As New MessageResponse
		  mr.Channel = jsonDict.Value("channel")
		  
		  Dim msg As Xojo.Core.Dictionary
		  msg = jsonDict.Value("message")
		  mr.Message = msg.Value("text")
		  
		  PostMessageResponse(mr)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessTeamInfo(jsonDict As Xojo.Core.Dictionary)
		  Dim teamJSON As Xojo.Core.Dictionary = jsonDict.Value("team")
		  
		  Dim t As New Team
		  t.ID = teamJSON.Value("id")
		  t.Name = teamJSON.Value("name")
		  t.Domain = teamJSON.Value("domain")
		  t.EmailDomain = teamJSON.Value("email_domain")
		  
		  TeamInfoResponse(t)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessUsersList(jsonDict As Xojo.Core.Dictionary)
		  
		  Dim usersDict() As Auto = jsonDict.Value("members")
		  
		  Dim users() As User
		  Dim u As User
		  For Each userDict As Xojo.Core.Dictionary In usersDict
		    u = New User
		    u.ID = userDict.Value("id")
		    u.Name = userDict.Value("name")
		    u.Deleted = userDict.Value("deleted")
		    
		    u.Profile = userDict.Value("profile")
		    users.Append(u)
		  Next
		  
		  UsersListResponse(users)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReplaceToken(url As Text) As Text
		  url = url.Replace("%token%", AuthToken)
		  
		  Return url
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetAuthToken(token As Text)
		  AuthToken = token
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub TeamInfo()
		  // Docs: https://api.slack.com/methods/team.info
		  
		  Dim token As Text = "token=" + AuthToken
		  
		  // Convert to MemoryBlock
		  Dim data As Xojo.Core.MemoryBlock
		  data = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(token)
		  
		  SetRequestContent(data, "application/x-www-form-urlencoded")
		  Send("POST", "https://slack.com/api/team.info")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UsersList()
		  // Docs: https://api.slack.com/methods/users.list
		  
		  Dim token As Text = "token=" + AuthToken
		  
		  // Convert to MemoryBlock
		  Dim data As Xojo.Core.MemoryBlock
		  data = Xojo.Core.TextEncoding.UTF8.ConvertTextToData(token)
		  
		  SetRequestContent(data, "application/x-www-form-urlencoded")
		  Send("POST", "https://slack.com/api/users.list")
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event APIError(HTTPStatus As Integer, content As Xojo.Core.MemoryBlock)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event AuthResponse(json As Xojo.Core.Dictionary)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event ChannelsListResponse(channels() As Slack.Channel)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event PostMessageResponse(response As Slack.MessageResponse)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TeamInfoResponse(t As Slack.Team)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UsersListResponse(users() As Slack.User)
	#tag EndHook


	#tag Property, Flags = &h21
		Private AuthToken As Text
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ValidateCertificates"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
