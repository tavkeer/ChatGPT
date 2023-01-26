import 'dart:async';
// api key
//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
import 'package:chat_gpt/three_dots.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //search bar text controller
  final TextEditingController _controller = TextEditingController();

  //message list
  final List<ChatMessage> _messages = [];

  //chat gpt object
  ChatGPT? chatGPT;

  //
  StreamSubscription? _subscription;

  //typing prompt
  bool _istyping = false;

  @override
  void initState() {
    chatGPT = ChatGPT.instance.builder(
      "Enter-Your-API-Key",
    );
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: 'user',
    );
    setState(() {
      _messages.insert(0, message);
      _istyping = true;
    });
    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

    _subscription = chatGPT!
        .builder(
          "Enter-your-API-Key",
          orgId: "",
        )
        .onCompleteStream(request: request)
        .listen((response) {
      ChatMessage botMessage =
          ChatMessage(text: response!.choices[0].text, sender: 'bot');

      setState(() {
        _istyping = false;
        _messages.insert(0, botMessage);
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
              hintText: "Send a message",
            ),
          ),
        ),
        IconButton(
            onPressed: () => _sendMessage(),
            icon: const Icon(
              Icons.send,
            )),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChatGPT Demo',
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
              reverse: true,
              padding: Vx.m8,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          if (_istyping) const ThreeDots(),
          const Divider(
            height: 1,
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
            ),
            child: _buildTextComposer(),
          )
        ]),
      ),
    );
  }
}
