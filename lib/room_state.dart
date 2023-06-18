import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';

class RoomStateNotifier extends GetxController
    implements
        DyteMeetingRoomEventsListener,
        DyteParticipantEventsListener,
        DyteChatEventsListener {
  // DyteMobileClient is manager to interact with dyte server.
  final Rx<DyteMobileClient> dyteClient = DyteMobileClient().obs;
  // Remote peer will hold the remote peer information like name, video, audio so on.
  Rxn<DyteMeetingParticipant> remotePeer = Rxn<DyteMeetingParticipant>();
  // isAudioOn is used to get and set local user audio status
  Rx<bool> isAudioOn = false.obs;
  // isVideoOn is used to get and set local user video status
  Rx<bool> isVideoOn = true.obs;
  // Array of 9 elements which will hold value for X and O.
  RxList<String> displayExOh = ['', '', '', '', '', '', '', '', ''].obs;
  // Room Join status
  Rx<bool> roomJoin = false.obs;
  // No of boxs are marked
  Rx<int> boxCount = 0.obs;
  // X player score
  Rx<int> exScore = 0.obs;
  // O player score
  Rx<int> ohScore = 0.obs;
  // Variable to check if it's local user turn or not.
  Rx<bool> localUserTurn = false.obs;
  // Symbol local user is going to use.
  String localSymbol = "";
  // Username is used to assign value in room.
  late String username;


  RoomStateNotifier(String name) {
    username = name;
    dyteClient.value.addMeetingRoomEventsListener(this);
    dyteClient.value.addParticipantEventsListener(this);
    dyteClient.value.addChatEventsListener(this);
    final meetingInfo = DyteMeetingInfoV2(
        authToken: '---TOKEN HERE---',
        enableAudio: false,
        enableVideo: true);
    dyteClient.value.init(meetingInfo);
  }

  sendMessage() {
    dyteClient.value.chat.sendTextMessage(displayExOh.toString());
  }

  toogleVideo() {
    if (isVideoOn.value) {
      dyteClient.value.localUser.disableVideo();
    } else {
      dyteClient.value.localUser.enableVideo();
    }
    isVideoOn.toggle();
  }

  toogleAudio() {
    if (isAudioOn.value) {
      dyteClient.value.localUser.disableAudio();
    } else {
      dyteClient.value.localUser.enableAudio();
    }
    isAudioOn.toggle();
  }

  @override
  void onMeetingInitCompleted() {
    dyteClient.value.localUser.setDisplayName(username);
    dyteClient.value.joinRoom();
  }

  @override
  void onMeetingRoomJoinCompleted() {
    roomJoin.value = true;
  }

  @override
  void onMeetingRoomLeaveStarted() {
    roomJoin.value = false;
    dyteClient.value.removeMeetingRoomEventsListener(this);
    dyteClient.value.removeParticipantEventsListener(this);
    dyteClient.value.removeChatEventsListener(this);
    Get.delete<RoomStateNotifier>();
    Get.back();
  }

  @override
  void onParticipantJoin(DyteJoinedMeetingParticipant participant) {
    if (participant.userId != dyteClient.value.localUser.userId) {
      remotePeer.value = participant;
      assignSymbol();
    }
  }

  @override
  void onParticipantLeave(DyteJoinedMeetingParticipant participant) {
    if (participant.userId != dyteClient.value.localUser.userId &&
        remotePeer.value != null) {
      remotePeer.value = null;
      Get.defaultDialog(
          barrierDismissible: false,
          onWillPop: () async {
            return false;
          },
          title: "Opponent Leave this game.",
          textConfirm: "Leave",
          middleText: "",
          confirmTextColor: Colors.white,
          onConfirm: () {
            dyteClient.value.leaveRoom();
            Get.back();
          });
    }
  }

  @override
  void onNewChatMessage(DyteChatMessage message) {
    if (message.userId == dyteClient.value.localUser.userId) {
      return;
    }
    DyteTextMessage textMessage = message as DyteTextMessage;
    List<String> temp = textMessage.message
        .replaceFirst("[", "")
        .replaceFirst("]", "")
        .split(", ");
    displayExOh.value = temp;
    localUserTurn.toggle();
    boxCount.value = displayExOh.where((p0) => p0!="").length;
    checkWinner();
  }

  @override
  void onMeetingInitFailed(Exception exception) {
    print("onMeetingInitFailed $exception");
  }

  @override
  void onMeetingInitStarted() {
    // TODO: implement onMeetingInitStarted
  }

  @override
  void onMeetingRoomDisconnected() {
    // TODO: implement onMeetingRoomDisconnected
  }

  @override
  void onMeetingRoomJoinFailed(Exception exception) {
    print("onMeetingRoomJoinFailed $exception");
  }

  @override
  void onMeetingRoomJoinStarted() {
    print("onMeetingRoomJoinStarted");
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    // TODO: implement onMeetingRoomLeaveCompleted
  }

  @override
  void onActiveParticipantsChanged(List<DyteJoinedMeetingParticipant> active) {
    // TODO: implement onActiveParticipantsChanged
  }

  @override
  void onActiveSpeakerChanged(DyteJoinedMeetingParticipant participant) {
    // TODO: implement onActiveSpeakerChanged
  }

  @override
  void onAudioUpdate(
      bool audioEnabled, DyteJoinedMeetingParticipant participant) {
    // TODO: implement onAudioUpdate
  }

  @override
  void onNoActiveSpeaker() {
    // TODO: implement onNoActiveSpeaker
  }

  @override
  void onParticipantPinned(DyteJoinedMeetingParticipant participant) {
    // TODO: implement onParticipantPinned
  }

  @override
  void onParticipantUnpinned(DyteJoinedMeetingParticipant participant) {
    // TODO: implement onParticipantUnpinned
  }

  @override
  void onScreenShareEnded(DyteScreenShareMeetingParticipant participant) {
    // TODO: implement onScreenShareEnded
  }

  @override
  void onScreenShareStarted(DyteScreenShareMeetingParticipant participant) {
    // TODO: implement onScreenShareStarted
  }

  @override
  void onScreenSharesUpdated() {
    // TODO: implement onScreenSharesUpdated
  }

  @override
  void onUpdate(DyteRoomParticipants participants) {}

  @override
  void onVideoUpdate(
      bool videoEnabled, DyteJoinedMeetingParticipant participant) {
    // TODO: implement onVideoUpdate
  }

  @override
  void onChatUpdates(List<DyteChatMessage> messages) {
    // TODO: implement onChatUpdates
  }

  checkWinner() {
    // 1st row
    if (displayExOh[0] == displayExOh[1] &&
        displayExOh[0] == displayExOh[2] &&
        displayExOh[0] != '') {
      _showWinnerDialog(displayExOh[0]);
    } else

    // checks 2nd row
    if (displayExOh[3] == displayExOh[4] &&
        displayExOh[3] == displayExOh[5] &&
        displayExOh[3] != '') {
      _showWinnerDialog(displayExOh[3]);
    } else

// checks 3rd row
    if (displayExOh[6] == displayExOh[7] &&
        displayExOh[6] == displayExOh[8] &&
        displayExOh[6] != '') {
      _showWinnerDialog(displayExOh[6]);
    } else

    // 1st column
    if (displayExOh[0] == displayExOh[3] &&
        displayExOh[0] == displayExOh[6] &&
        displayExOh[0] != '') {
      _showWinnerDialog(displayExOh[0]);
    } else

    // checks 2nd column
    if (displayExOh[1] == displayExOh[4] &&
        displayExOh[1] == displayExOh[7] &&
        displayExOh[1] != '') {
      _showWinnerDialog(displayExOh[1]);
    } else

// checks 3rd column
    if (displayExOh[2] == displayExOh[5] &&
        displayExOh[2] == displayExOh[8] &&
        displayExOh[2] != '') {
      _showWinnerDialog(displayExOh[2]);
    } else

    // checks 1st diagonal
    if (displayExOh[0] == displayExOh[4] &&
        displayExOh[0] == displayExOh[8] &&
        displayExOh[0] != '') {
      _showWinnerDialog(displayExOh[0]);
    } else

    // checks 2nd diagonal
    if (displayExOh[2] == displayExOh[4] &&
        displayExOh[2] == displayExOh[6] &&
        displayExOh[2] != '') {
      _showWinnerDialog(displayExOh[2]);
    } else if (boxCount.value == 9) {
      _showDrawDialog();
    }
  }

  _showWinnerDialog(String winner) {
    if (winner == "X") {
      exScore.value++;
    } else if (winner == "O") {
      ohScore.value++;
    }
    if (localSymbol == winner) {
      Get.snackbar("You Won", "Let's continue this winning streak.",
          snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.black,colorText: Colors.white);
      localUserTurn.value = true;
    } else {
      Get.snackbar("You Lost", "All the best for next round.",
          snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.black,colorText: Colors.white);
      localUserTurn.value = false;
    }
    Future.delayed(const Duration(seconds: 3), () {
      _clearBoard();
    });
  }

  _showDrawDialog() {
    Get.snackbar("Game Draw", "All the best for next round.",
        snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.black,colorText: Colors.white);
    Future.delayed(const Duration(seconds: 3), () {
      _clearBoard();
    });
  }

  _clearBoard() {
    boxCount.value = 0;
    displayExOh.value = ['', '', '', '', '', '', '', '', ''];
  }

  tapped(int index) {
    if (!localUserTurn.value) {
      return;
    }
    if (displayExOh[index] != '') {
      return;
    }

    if (localUserTurn.value) {
      displayExOh[index] = localSymbol;
    }
    sendMessage();
    boxCount.value = displayExOh.where((p0) => p0!="").length;
    localUserTurn.toggle();
    checkWinner();
  }

  assignSymbol() {
    List<String> peer = [
      dyteClient.value.localUser.userId,
      remotePeer.value!.userId
    ];
    peer.sort();
    if (peer.indexOf(dyteClient.value.localUser.userId) == 0) {
      localSymbol = "O";
      localUserTurn.value = true;
    } else {
      localSymbol = "X";
    }
  }
}
