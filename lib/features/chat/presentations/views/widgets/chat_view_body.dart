import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/features/chat/presentations/views/widgets/chat_bubble.dart';
import 'package:taxi/features/chat/presentations/views_models/chat_cubit/cubit/chat_cubit.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constants.dart';

// ignore: must_be_immutable
class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key, required this.rideId});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();

  final int rideId;
}

final ScrollController scrollController = ScrollController();

class _ChatViewBodyState extends State<ChatViewBody> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final cubit = ChatCubit.get(context);
            var messagesList = cubit.messages;
            return Expanded(
              child: ListView.builder(
                reverse: false,
                controller: scrollController,
                itemCount: messagesList.length,
                itemBuilder: (context, index) {
                  return messagesList[index].userId.toString() ==
                          CacheHelper.getData(key: 'userId').toString()
                      ? customChatBubble(
                          message: messagesList[index],
                        )
                      : customChatBubbleForeFriend(
                          message: messagesList[index],
                        );
                },
              ),
            );
          },
        ),

        //   child: messagesList.isEmpty
        //       ? Center(
        //           child: Text('No Message yet'),
        //         )
        //       : ListView.builder(
        //           reverse: true,
        //           controller: chatCubit.listViewController,
        //           itemCount: messagesList.length,
        //           itemBuilder: (context, index) {
        //             return messagesList[index].id.toString() ==
        //                     CacheHelper.getData(key: 'userId').toString()
        //                 ? customChatBubble(
        //                     message: messagesList[index],
        //                   )
        //                 : customChatBubbleForeFriend(
        //                     message: messagesList[index],
        //                   );
        //           },
        //         ),
        // ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: BlocProvider.of<ChatCubit>(context).controller,
            onSubmitted: (data) {},
            decoration: InputDecoration(
              suffixIcon: InkWell(
                onTap: (() {
                  ChatCubit.get(context).sendMessage(rideId: widget.rideId);
                  // ChatCubit.get(context).resetMessageCount();
                  // BlocProvider.of<ChatCubit>(context)
                  //     .listViewController
                  //     .animateTo(
                  //       0,
                  //       duration: const Duration(microseconds: 500),
                  //       curve: Curves.easeIn,
                  //     );
                }),
                child: const Icon(
                  Icons.send,
                  color: kDeepBlue,
                ),
              ),
              hintText: 'Send Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kDeepBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kDeepBlue),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
