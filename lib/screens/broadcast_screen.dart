// ignore_for_file: library_prefixes

import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twitch_clone/config/appId.dart';
import 'package:twitch_clone/providers/user_provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:twitch_clone/resources/firestore_methods.dart';
import 'package:twitch_clone/responsive/responsive_layout.dart';
import 'package:twitch_clone/screens/home_screen.dart';
import 'package:twitch_clone/widgets/chat.dart';
import 'package:http/http.dart' as http;

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen(
      {super.key, required this.isBroadcaster, required this.channelId});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  @override
  void initState() {
    _initEngine();
    super.initState();
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  String baseUrl = "https://go-server-twitch.onrender.com";

  String? token;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(
          "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${Provider.of<UserProvider>(context, listen: false).user.uid}/"),
    );
    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _addListeners() {
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      debugPrint('joinChannelSuccess $channel $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }, tokenPrivilegeWillExpire: (token) async {
      await getToken();
      await _engine.renewToken(token);
    }));
  }

  void _joinChannel() async {
    await getToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(token, widget.channelId,
        Provider.of<UserProvider>(context, listen: false).user.uid);
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if ('${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}' ==
        widget.channelId) {
      await FireStoreMethods().endLiveStream(widget.channelId);
    } else {
      await FireStoreMethods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ResponsiveLayout(
            dekstopBody: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _renderVideo(user),
                      if ("${user.uid}${user.username}" == widget.channelId)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: _switchCamera,
                              child: const Text('Switch Camera'),
                            ),
                            InkWell(
                              onTap: onToggleMute,
                              child: Text(isMuted ? 'Unmute' : 'Mute'),
                            ),
                            InkWell(
                              onTap: onToggleMute,
                              child: Text('ScreenShare'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                Chat(channelId: widget.channelId)
              ],
            ),
            mobileBody: Column(
              children: [
                _renderVideo(user),
                if ("${user.uid}${user.username}" == widget.channelId)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _switchCamera,
                        child: const Text('Switch Camera'),
                      ),
                      InkWell(
                        onTap: onToggleMute,
                        child: Text(isMuted ? 'Unmute' : 'Mute'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Chat(
                    channelId: widget.channelId,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _renderVideo(user) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          ? const RtcLocalView.SurfaceView(
              zOrderMediaOverlay: true,
              zOrderOnTop: true,
            )
          : remoteUid.isNotEmpty
              ? kIsWeb
                  ? RtcRemoteView.SurfaceView(
                      uid: remoteUid[0], channelId: widget.channelId)
                  : RtcRemoteView.TextureView(
                      uid: remoteUid[0], channelId: widget.channelId)
              : Container(),
    );
  }
}
