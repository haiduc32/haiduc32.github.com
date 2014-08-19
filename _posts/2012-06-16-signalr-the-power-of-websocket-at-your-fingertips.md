---
layout: post
title: SignalR - the power of WebSocket at your fingertips
date: 2012-06-16 22:50:20.000000000 +03:00
categories: []
tags: []
status: publish
type: post
published: true
meta:
  _edit_last: '1'
  _syntaxhighlighter_encoded: '1'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
A few months back, Scott Hanselman had a <a href="http://www.hanselman.com/blog/AsynchronousScalableWebApplicationsWithRealtimePersistentLongrunningConnectionsWithSignalR.aspx">blog post about SignalR</a>. It was inspiring, but yesterday when I wanted to give it a shot, it proved to be not of much help as far as examples go.

It took me a bit of googling to figure out how to use the SignalR, so I decided to have a post of my own on getting started with SignalR.

First of all, a bit of introduction. What is SignalR? It's a framework for using the new WebSocket that was introduced in HTML5. It allows you to have 2 way communication between the browser and the server without using polling. A great thing if you want to build a browser based MMOG (I'm not sure how good it can handle the first M). As mentioned earlier, Scott has got a good post about it, you should really check it out.

Just as Scott I've decided to go with a chat application for checking it out. Scott's post wasn't helpful, so after googling found an example that was much clearer to implement <a href="http://geekswithblogs.net/jeroenb/archive/2011/12/14/signalr-starter-application.aspx">SignalR: example chat application</a>. Also the <a href="https://github.com/SignalR/SignalR/wiki">SingalR Github Wiki</a> proved to be of some help.

What we want is a way to push messages from one browser client to any other browser clients that are currently connected to our chat page. SignalR has a concept of Hubs. To my understanding it's like a service. It can have multiple methods on it. For my chat application only 2 are requried: Join and Message. First will register the new browser client with a name, and sencond will dispatch messages to all the other users that are connected.

First I'll create a new empty Asp.Net web application with a default.aspx. Then, add the SignalR package with NuGet. The important parts in the default.aspx are the required javascripts (the versions could be different for you):

    <script type="text/javascript" src="Scripts/jquery-1.6.4.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery.signalR-0.5.1.min.js"></script>
    <script type="text/javascript" src="/signalr/hubs"></script>

Next, we need to have a text box, a button and a list to show the messages:

    <script type="text/javascript">
    var chat = $.connection.chatHub;
                //login to chat
                $.connection.hub.start().done(function () {
                    chat.join($('#name').val(), function (value) {
                        $('#messages').append('<li>' + value + '</li>');
                    });
                });
    
                chat.addMessage = function (message) {
                    $('#messages').append('<li>' + message + '</li>');
                };
    
                $("#broadcast").click(function () {
                    var message = $('#msg').val();
                    chat.message(message);
                    $('#messages').append('<li>You: ' + message + '</li>');
                });
    </script>
    <div id="messageDiv">
       <input id="msg" type="text" />
       <input id="broadcast" type="button" value="send" />
    </div>

chatHub is the name of the hub, that is registered in the C# code. The join and message are the functions that are called on the server side, it doesn't require any configuration. The addMessage is a callback that is executed when you call the addMessage on the server side:

    [HubName("chatHub)]
    public class ChatHub : Hub
    {
        public string Join(string myName)
        {
            ...
        }
    
        public void Message(string message)
        {
            Clients.addMessage(message);
        }
    }

This is really all that you have to do for a minimal setup. There is a lot of "magic" being done behind in JavaScript code and C#, but you don't have to bother about it. There is also a lower level interface, if you need custom stuff, but you should check the SignalR Wiki for more info on that.

An important aspect that you have to keep in mind is that the ChatHub will be instantiated for each request. If you need to keep track of your users, and have some business logic, you'll have to setup static variables or create another class to handle the logic.

I created a Windows Azure trial account and deployed my web application (a bit enhanced) on <a href="http://signalr.azurewebsites.net/">http://signalr.azurewebsites.net/</a>. Just open it in 2 tabs and see how it goes (my first tries proved it to be kind of slow, but I do suspect it's a configuration issue as on my local machine it does work pretty fast). All that being said, you can <a href="http://www.blog.cyberkinetx.com/wp-content/uploads/2012/06/WebApplication2.zip">download</a> the source code and tinker with it.

Happy coding!
