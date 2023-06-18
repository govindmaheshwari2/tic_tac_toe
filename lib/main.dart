import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tic_tac_toe/room_state.dart';
import 'package:tic_tac_toe/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: JoimRoom(),
    );
  }
}

class JoimRoom extends StatelessWidget {
  const JoimRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                "TIC TAC TOE",
                style: GoogleFonts.pressStart2p(
                    textStyle: const TextStyle(
                        color: Colors.white, letterSpacing: 3, fontSize: 20)),
              ),
            ),
            AvatarGlow(
              endRadius: 140,
              child: CircleAvatar(
                backgroundColor: Colors.grey[900],
                radius: 80,
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  if (await getPermissions()) {
                    // ignore: use_build_context_synchronously
                   await showDialog(context: context, builder: (context){
                      TextEditingController controller = TextEditingController();
                      return AlertDialog(
                        title: const Text("Enter Name"),
                        content: TextField(
                          controller: controller,
                          
                        ),
                        actions: [
                          ElevatedButton(onPressed: (){
                            if(controller.text.trim().isEmpty){
                              Get.snackbar("Enter Name", "Please Enter name to join the game",
        snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.black,colorText: Colors.white);
                            }else{
                              Get.back();
    Get.put(RoomStateNotifier(controller.text.trim()));
                    Get.to(const HomePage());
                            }

                          }, child: const Text("JOIN"))
                        ],
                      );
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(30),
                  margin:
                      const EdgeInsets.only(left: 40, right: 40, bottom: 60),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: Text(
                    "JOIN GAME",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            letterSpacing: 3,
                            fontSize: 20)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

Future<bool> getPermissions() async {
  if (Platform.isIOS) return true;
  await Permission.camera.request();
  await Permission.microphone.request();

  while ((await Permission.camera.isDenied)) {
    await Permission.camera.request();
  }
  while ((await Permission.microphone.isDenied)) {
    await Permission.microphone.request();
  }

  return true;
}
