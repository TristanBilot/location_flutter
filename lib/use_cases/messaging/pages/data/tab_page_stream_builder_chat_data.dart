import 'package:flutter/material.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/pages/data/tab_page_stream_builder_data.dart';
import 'package:location_project/widgets/textSF.dart';
import '../../../../stores/extensions.dart';

class TabPageStreamBuilderChatData implements TabPageStreamBuilderData {
  Function(List<dynamic>) get filter => (snapshots) => snapshots
      .where(
          (chat) => chat.data()[ChatField.IsChatEngaged.value] as bool == true)
      .toList();

  Widget get placeholder => Center(
        child: TextSF(
          'No discussions yet.',
          fontSize: 18,
          color: Colors.grey,
        ),
      );
}
