import 'package:flutter/material.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/pages/data/tab_page_stream_builder_data.dart';
import 'package:location_project/widgets/textSF.dart';
import '../../../../stores/extensions.dart';

class TabPageStreamBuilderRequestData implements TabPageStreamBuilderData {
  Function(List<dynamic>) get filter => (snapshots) => snapshots
      .where(
          (chat) => chat.data()[ChatField.IsChatEngaged.value] as bool == false)
      .toList()
        ..sort((a, b) {
          bool isUserRequested =
              (b.data()[ChatField.RequestedID.value] as String) ==
                  UserStore().user.id;
          return isUserRequested ? 1 : -1;
        });

  Widget get placeholder => Center(
        child: TextSF(
          'No requests yet.',
          fontSize: 18,
          color: Colors.grey,
        ),
      );
}
