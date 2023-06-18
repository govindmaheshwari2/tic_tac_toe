import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe/room_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    TextStyle titleFont = GoogleFonts.pressStart2p(
        textStyle: const TextStyle(
            color: Colors.white, letterSpacing: 3, fontSize: 15));
    TextStyle boardFont = GoogleFonts.pressStart2p(
        textStyle: const TextStyle(
            color: Colors.white, letterSpacing: 3, fontSize: 40));

    final RoomStateNotifier roomStateNotifier = Get.find();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[800],
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FittedBox(
                                  child: Text(
                                    "Player X",
                                    style: titleFont,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Obx(
                                  () => Text(
                                    "${roomStateNotifier.exScore}",
                                    style: titleFont,
                                  ),
                                )
                              ]),
                        ),
                        Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FittedBox(
                                  child: Text(
                                    "Player O",
                                    style: titleFont,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Obx(
                                  () => Text(
                                    "${roomStateNotifier.ohScore}",
                                    style: titleFont,
                                  ),
                                )
                              ]),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Obx(
                        () => roomStateNotifier.remotePeer.value != null
                            ? Text(
                                (roomStateNotifier.localUserTurn.value)
                                    ? "It's Your Turn"
                                    : "Waiting for opponent to play",
                                textAlign: TextAlign.center,
                                style: titleFont.copyWith(color: Colors.blue),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              )),
              Expanded(
                flex: 2,
                child: Obx(
                  () => Center(
                    child: roomStateNotifier.remotePeer.value != null
                        ? GridView.builder(
                            itemCount: 9,
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => roomStateNotifier.tapped(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[700]!)),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        roomStateNotifier.displayExOh[index],
                                        style: boardFont,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Waiting for opponent to join 😄",
                              textAlign: TextAlign.center,
                              style: titleFont.copyWith(color: Colors.blue),
                            ),
                          ),
                  ),
                ),
              ),

              // Dyte Meeting Video View
              Expanded(
                  child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // if (roomStateNotifier.roomJoin.value) // Check if room is join by the localUser or not.
                          // Local user video tile and name
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  // child: const VideoView(      // Local user video tile
                                  //   isSelfParticipant: true,
                                  // ),
                                ),
                              ),
                              // Text(
                              //   roomStateNotifier.dyteClient.value.localUser.name, // Local user name
                              //   style: const TextStyle(color: Colors.white),
                              //   )
                            ],
                          ),
                        // if (roomStateNotifier.remotePeer.value != null)
                        // Remote user video tile and name
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  // child: VideoView(         // Remote user video tile
                                  //   meetingParticipant:
                                  //       roomStateNotifier.remotePeer.value,
                                  // ),
                                ),
                              ),
                              // Text(
                              //   roomStateNotifier.remotePeer.value!.name,   // Remote user name
                              // style: const TextStyle(color: Colors.white),)
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              roomStateNotifier.toogleVideo();
                            },
                            icon: Obx(
                              () => Icon(
                                  roomStateNotifier.isVideoOn.value
                                      ? Icons.camera_alt
                                      : Icons.camera_alt_outlined,
                                  color: roomStateNotifier.isVideoOn.value
                                      ? Colors.white
                                      : Colors.red),
                            )),
                        IconButton(
                            onPressed: () {
                              roomStateNotifier.toogleAudio();
                            },
                            icon: Obx(
                              () => Icon(
                                  roomStateNotifier.isAudioOn.value
                                      ? Icons.mic
                                      : Icons.mic_off_rounded,
                                  color: roomStateNotifier.isAudioOn.value
                                      ? Colors.white
                                      : Colors.red),
                            )),
                        GestureDetector(
                          onTap: () {
                            Get.defaultDialog(
                              title: "Want to leave?",
                              onConfirm: () {
                                roomStateNotifier.dyteClient.value.leaveRoom();
                                Get.back();
                              },
                              middleText: "",
                              onCancel: () {
                                Get.back();
                              },
                              confirmTextColor: Colors.red,
                              textCancel: "Cancel",
                              textConfirm: "Leave",
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
